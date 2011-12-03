#import <Foundation/Foundation.h>
#import "JSON.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // insert code here...
	SBJSON* proxy = [[SBJSON alloc]init];
	if (proxy != nil) {
		NSLog(@"Hello, World!");
	}
    NSLog(@"Hello, World!");
    [pool drain];
    return 0;
}
