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
		[[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
		//TODO : Not working
		//[[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		//TODO : must be set by custom events to avoid BAD_ACCESS
	} while ( threadHost.IsThreadExist == YES );
	NSLog(@"threadHost release");
	[threadHost release];
	
    [pool drain];
    return 0;
}
