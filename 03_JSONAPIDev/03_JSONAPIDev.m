#import <Foundation/Foundation.h>
#import "RunLoopsThreadHost.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];	
	
	//TODO : Threadforrunloop
	RunLoopsThreadHost *threadHost = [[RunLoopsThreadHost alloc]init];
	[threadHost startThreadMainForRunLoop];
	
	int iSleepSec = 5;
	while (threadHost.IsThreadExist == YES) {
		sleep(iSleepSec);
		NSLog(@"waiting for thread sleep - %d seconds", iSleepSec);
	}
	[threadHost release];
	
    [pool drain];
    return 0;
}
