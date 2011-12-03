#import <Foundation/Foundation.h>
#import "WBRequest.h"

//TODO : Micro to define key for verification
#define SinaWeiBoSDKDemo_APPKey @"2657678697"
#define SinaWeiBoSDKDemo_APPSecret @"6085bbad181f41c25dc7d164b0d6fde2"

#if !defined(SinaWeiBoSDKDemo_APPKey)
#error "You must define SinaWeiBoSDKDemo_APPKey as your APP Key"
#endif

#if !defined(SinaWeiBoSDKDemo_APPSecret)
#error "You must define SinaWeiBoSDKDemo_APPSecret as your APP Secret"
#endif

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // insert code here...
    NSLog(@"Hello, World!");
    [pool drain];
    return 0;
}
