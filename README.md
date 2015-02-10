# Breadcrumb

Breadcrumb takes away the complexity that you normally encounter when working with other Bitcoin, or Blockchain libraries. 

With minimalistic interfaces you can quickly get started working with Bitcoin, and the Blockchain.

Explore the capabilities of the block chain by publishing, and building custom transactions, and scripts.

Making a wallet is so easy you can start receiving, and sending Bitcoin in just 4 lines.

## How to get started

To get started include Breadcurmb.framework, CommonCrypto.framework, and CoreData.framework into your xCode project then include the breadcrumb headers “#import <Breadcrumb/Breadcrumb.h>” to your applications.


Finally you can start working with breadcrumb.

```
  // The password is an NSData object so that you can easily use touch
  // authentication, and other authentication sources.
  NSData *password = [@"password" dataUsingEncoding:NSUTF8StringEncoding];

  // When you instantiate a wallet it requires a password to decrypt private
  // restoration data, or encrypt new private data such as the wallets' seed
  // phrase.
  BCWallet *wallet = [[BCWallet alloc] initNewWithPassword:password];

  // Sending Bitcoin is as easy just specify the amount of satoshi,
  // the address to send to, and a completion. The wallet, and service provider
  // will handle the rest.
  BCAddress *address = [@"3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy" toBitcoinAddress];
  NSNumber *amount = [@200 toSatoshi];
  [wallet send:amount to:address usingPassword:password withCallback:
  ^(NSError *error) { 
       if ( [error isKindOfClass:[NSError class]] )
       		NSLog(@"Transaction Failed: '%@'",error.localizedDescription); 
  }];

  // You can retrieve the wallets protected info like is mnemonic phrase using
  // the password
  [wallet mnemonicPhraseWithPassword:password
                       usingCallback:^(NSString *mnemonic) { 
  	NSLog(@"Brainwallet Phrase: %@",mnemonic);
  }];
                       
```



## License
Breadcrumb is under MIT license, and uses source from Breadwallet (also under MIT) 


The MIT License (MIT)

Copyright (c) 2015 Andrew Hurst

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.