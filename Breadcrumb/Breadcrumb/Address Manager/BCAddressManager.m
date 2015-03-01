//
//  BCAddressManager.m
//  Breadcrumb
//
//  Created by Andrew Hurst on 2/19/15.
//  Copyright (c) 2015 Breadcrumb. All rights reserved.
//

#import "BCAddressManager.h"
#import "_BCWallet.h"

@implementation BCAddressManager

@synthesize keySequence = _keySequence;
@synthesize coin = _coin;
@synthesize preferredSequenceType = _preferredSequenceType;

#pragma mark Construction

- (instancetype)initWithKeySequence:(BCKeySequence *)keys
                           coinType:(BCCoin *)coinType
                      preferredPath:(BCKeySequenceType)preferred
                       andMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    NSParameterAssert([keys isKindOfClass:[BCKeySequence class]]);
    self = [self init];
    if (!self) return NULL;
    _keySequence = keys;
    _coin = coinType;
    _preferredSequenceType = preferred;

    // Configure Keys
    [self setMasters:memoryKey];
    memoryKey = NULL;
    return self;
  }
}

#pragma Mark Configuration

- (void)setMasters:(NSData *)memoryKey {
  @autoreleasepool {
    BCKeyPair *currentKey;
    // Set Bip 44 masters FORCE ACCOUNT 0
    currentKey = [self.keySequence
        keyPairForComponents:
            @[ @(0x8000002C), @(self.coin.coinId), @(BIP32_PRIME | 0), @(1) ]
                andMemoryKey:memoryKey];
    _bip44Internal = [[BCAMMasterKey alloc] initWithKeyPair:currentKey
                                                    andCoin:self.coin];

    currentKey = [self.keySequence
        keyPairForComponents:
            @[ @(0x8000002C), @(self.coin.coinId), @(BIP32_PRIME | 0), @(0) ]
                andMemoryKey:memoryKey];
    _bip44External = [[BCAMMasterKey alloc] initWithKeyPair:currentKey
                                                    andCoin:self.coin];

    // Set bip 32 masters
    currentKey =
        [self.keySequence keyPairForComponents:@[ @(BIP32_PRIME | 0), @(1) ]
                                  andMemoryKey:memoryKey];
    _bip32Internal = [[BCAMMasterKey alloc] initWithKeyPair:currentKey
                                                    andCoin:self.coin];

    currentKey =
        [self.keySequence keyPairForComponents:@[ @(BIP32_PRIME | 0), @(0) ]
                                  andMemoryKey:memoryKey];
    _bip32External = [[BCAMMasterKey alloc] initWithKeyPair:currentKey
                                                    andCoin:self.coin];

    memoryKey = NULL;
  }
}

#pragma mark Address Data

- (BCAddress *)firstUnusedExternal {
  switch (self.preferredSequenceType) {
    case BCKeySequenceType_BIP32:
      return self.bip32External.firstUnusedAddress;
      break;
    default:
      return self.bip44External.firstUnusedAddress;
      break;
  }
}

- (BCAddress *)firstUnusedInternal {
  switch (self.preferredSequenceType) {
    case BCKeySequenceType_BIP32:
      return self.bip32Internal.firstUnusedAddress;
      break;
    default:
      return self.bip44Internal.firstUnusedAddress;
      break;
  }
}

#pragma mark Lookup

- (BCKeyPair *)keyPairForAddress:(BCAddress *)address
                  usingMemoryKey:(NSData *)memoryKey {
  @autoreleasepool {
    BCKeyPair *key;
    // Check all masters for key.
    key =
        [self.bip32Internal keyPairForAddress:address withMemoryKey:memoryKey];
    if ([key isKindOfClass:[BCKeyPair class]]) {
      memoryKey = NULL;
      return key;
    }

    key =
        [self.bip32External keyPairForAddress:address withMemoryKey:memoryKey];
    if ([key isKindOfClass:[BCKeyPair class]]) {
      memoryKey = NULL;
      return key;
    }

    key =
        [self.bip44Internal keyPairForAddress:address withMemoryKey:memoryKey];
    if ([key isKindOfClass:[BCKeyPair class]]) {
      memoryKey = NULL;
      return key;
    }

    key =
        [self.bip44External keyPairForAddress:address withMemoryKey:memoryKey];
    memoryKey = NULL;
    if ([key isKindOfClass:[BCKeyPair class]]) return key;

    return NULL;
  }
}

@end