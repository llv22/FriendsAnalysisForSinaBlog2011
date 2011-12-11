#import <Foundation/Foundation.h>
#import "MyOperation.h"

@interface ThreadTest : NSObject
{
	NSThread* myThread;
	NSOperationQueue* aQueue;
}

@property(retain/*copy*/, readonly) NSThread* WorkThread/*myThread*/;
@property(retain, readonly)NSOperationQueue* WorkQueue;

-(void) myThreadMainMethod:(id)param;
-(void) Test;

@end

@implementation ThreadTest

@synthesize WorkThread = myThread;
@synthesize WorkQueue = aQueue;

-(void) myThreadMainMethod:(id)param{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init ];
	
	
	//TODO : NSOperationQueue
	aQueue = [[NSOperationQueue alloc]init];
	MyOperation* anOp = [[MyOperation alloc]init];
	//[aQueue addObserver:aQueue forKeyPath: @"operations" options: NSKeyValueObservingOptionNew context: NULL];
	//[aQueue setSuspended:NO];
	[aQueue addOperation:anOp];
	[anOp release];
	
	//TODO : No response for alloperations -> NO operation, directly return : saying operation hasn't been finished
	//When called, this method blocks the current thread and waits for the receiver’s current and queued operations to finish executing. While the current thread is blocked, the receiver continues to launch already queued operations and monitor those that are executing. During this time, the current thread cannot add operations to the queue, but other threads may. Once all of the pending operations are finished, this method returns.
	//[aQueue waitUntilAllOperationsAreFinished];
	//[anOp waitUntilFinished];
	NSLog(@"start NSOperation::waitUntilAllOperationsAreFinished() method outside");
	
	[pool drain];
}

-(void) Test{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//TODO : All the versions
//	[NSThread detachNewThreadSelector: @selector(myThreadMainMethod:) 
//							 toTarget: self 
//						   withObject: nil];
	
	//TODO : Mac OSX 10.5 later
	myThread = [[NSThread alloc] initWithTarget:self 
									   selector:@selector(myThreadMainMethod:) 
										 object:nil
				];
	//TODO : Actually to start thread
	[myThread start];	
	
    [pool drain];
}

@end


int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];	
	ThreadTest* _test = [[ThreadTest alloc] init];
	[_test Test];
	
//	while (![_test.WorkThread isFinished]) {
//		sleep(5);
	//	}
	sleep(5);
	while ([_test.WorkQueue operationCount] > 0) {
		NSLog(@"count %d\n", [_test.WorkQueue operationCount]);
		sleep(5);
		NSLog(@"count %d\n", [_test.WorkQueue operationCount]);
	}
	//[anOp waitUntilFinished];
	NSLog(@"main thread work quit() out");
	
    [pool drain];
    return 0;
}
