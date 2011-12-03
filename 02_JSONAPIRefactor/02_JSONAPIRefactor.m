#import "JSON.h"
#import <Foundation/Foundation.h>


int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    NSLog(@"Hello, World!");
	SBJSON* proxy = [[SBJSON alloc]init];
	if (proxy != nil) {
		NSLog(@"SBJSON debugging");
	}
    [pool drain];
    return 0;
}
