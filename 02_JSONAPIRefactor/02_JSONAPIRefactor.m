#import <Foundation/Foundation.h>
#import "JSON.h"
#import "WBUtil.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // insert code here...
	//SBJSON* proxy = [[SBJSON alloc]init];
	//[proxy fragmentWithString:@"error" error:
	id jsonObject = [jsonString JSONValue];
    NSLog(@"Hello, World!");
    [pool drain];
    return 0;
}
