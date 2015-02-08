//
//  BCScript.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/8/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCScript.h"
#import "NSData+Bitcoin.h"
#import "NSMutableData+Bitcoin.h"

@interface BCScript ()

/*!
 @brief The buffer the script will be written into.
 */
@property(strong, nonatomic, readonly) NSMutableData *buffer;

#pragma mark Mutation

- (void)writeOpCode:(BCScriptOpCode)opCode;

- (void)writeBytes:(NSData *)data;

@end

@implementation BCScript

@synthesize buffer = _buffer;

#pragma mark Construction

- (instancetype)initWithData:(NSData *)data {
  self = [self init];
  if (self) [self.buffer setData:data];
  return self;
}

+ (instancetype)scriptWithData:(NSData *)data {
  return [[[self class] alloc] initWithData:data];
}

+ (instancetype)script {
  return [[[self class] alloc] init];
}

#pragma mark Internal

- (NSMutableData *)buffer {
  if (!_buffer) _buffer = [[NSMutableData alloc] init];
  return _buffer;
}

#pragma mark Mutation

- (void)writeOpCode:(BCScriptOpCode)opCode {
  [self.buffer appendUInt8:opCode];
}

- (void)writeBytes:(NSData *)data {
  if (data.length == 0) return;

  if (data.length < OP_PUSHDATA1) {
    [self.buffer appendUInt8:data.length];
  } else if (data.length < UINT8_MAX) {
    [self writeOpCode:OP_PUSHDATA1];
    [self.buffer appendUInt8:data.length];
  } else if (data.length < UINT16_MAX) {
    [self writeOpCode:OP_PUSHDATA2];
    [self.buffer appendUInt16:data.length];
  } else {
    [self writeOpCode:OP_PUSHDATA4];
    [self.buffer appendUInt32:(uint32_t)data.length];
  }

  [self.buffer appendData:data];
}

#pragma mark Representation

- (NSData *)toData {
  return [NSData dataWithBytes:self.buffer.bytes length:self.buffer.length];
}

- (NSString *)toString {
  BOOL lastWasOpCode;
  NSString *script, *nextSegment;
  const char *bytes;

  script = @"";
  lastWasOpCode = TRUE;
  bytes = [self.buffer bytes];

  // Process the bytes to get the human readable string
  for (NSUInteger i = 0; i < [self.buffer length]; i++) {
    // Attempt to get an op code from the current byte, append with a string for
    // readability
    nextSegment =
        [stringFromScriptOpCode(bytes[i]) stringByAppendingString:@" "];
    if (![nextSegment isKindOfClass:[NSString class]]) {
      // Failed to get an op code, attempt to look for pushed data. pass an
      // index
      // so we can jump to an index if we find data.
      nextSegment = [self processPushedData:bytes atIndex:&i];

      // Update char status so we can do spacing properly
      lastWasOpCode = FALSE;
    } else {
      if (!lastWasOpCode)
        nextSegment = [@" " stringByAppendingString:nextSegment];
      // Update char status so we can do spacing properly
      lastWasOpCode = TRUE;
    }

    // My safety hamlet
    if ([nextSegment isKindOfClass:[NSString class]])
      script = [script stringByAppendingString:nextSegment];
  }
  return script;
}

- (NSString *)processPushedData:(const char *)bytes atIndex:(NSUInteger *)i {
  NSString *processedValue;
  NSUInteger lengthToRead;
  if (bytes[*i] < OP_PUSHDATA1)
    lengthToRead = [self.buffer UInt8AtOffset:*i];
  else if (bytes[*i] == OP_PUSHDATA2)
    lengthToRead = [self.buffer UInt16AtOffset:*i + 1];
  else if (bytes[*i] == OP_PUSHDATA4)
    lengthToRead = [self.buffer UInt32AtOffset:*i + 1];
  else
    return NULL;

  processedValue = @"";
  for (NSUInteger q = 0; q < lengthToRead; ++q) {
    processedValue = [processedValue
        stringByAppendingString:[NSString stringWithFormat:@"%02hhx",
                                                           bytes[*i + 1 + q]]];
  }
  *i += lengthToRead;
  return processedValue;
}

#pragma mark Debug

- (NSString *)description {
  return [self toString];
}

@end

@implementation BCMutableScript

#pragma mark Mutation

- (void)writeOpCode:(BCScriptOpCode)opCode {
  [super writeOpCode:opCode];
}

- (void)writeBytes:(NSData *)data {
  [super writeBytes:data];
}

@end