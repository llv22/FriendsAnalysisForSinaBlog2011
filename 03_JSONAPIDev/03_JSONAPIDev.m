#import <Foundation/Foundation.h>
#import "RunLoopsThreadHost.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];	
	
	//TODO : Threadforrunloop
	RunLoopsThreadHost *threadHost = [[RunLoopsThreadHost alloc]init];
	[threadHost startThreadMainForRunLoop];
	
	/*
	 * Run Loop of Thread
	 */	
	do {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	} while ( threadHost.IsThreadExist == YES );
/*
 *	Implementation of raw thread check-up, should be replaced by RunLoop on the main thread
 *	to avoid inefficient thread lock for wasting CPU computing time
	int iSleepSec = 5;
	while (threadHost.IsThreadExist == YES) {
		sleep(iSleepSec);
		NSLog(@"waiting for thread sleep - %d seconds", iSleepSec);
	}
 */
	[threadHost release];
	
    [pool drain];
    return 0;
}
