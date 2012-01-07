//
//  MyOperation.m
//  NSOPerationSample
//
//  Created by orlando ding on 12/11/11.
//  Copyright 2011 MakeDreamToFact. All rights reserved.
//

#import "MyOperation.h"


@implementation MyOperation

-(id)init{
	self = [super init];
	if (self) {
		self->executing = NO;
		self->finished = NO;
	}
	return (self);
}

//-(void)dealloc{
//	[super dealloc];
//}

-(BOOL)isConcurrent{
	return YES;
}

//-(BOOL)isCancelled{
//	return NO;
//}

-(BOOL)isExecuting{
	return self->executing;
}

-(BOOL)isFinished{
	return self->finished;
}

//- (BOOL)isReady{
//	return YES;
//}

#pragma mark Start method
-(void)start{
	//Always check for cancellation before lanuching the tasks.
	if ([self isCancelled]) {
		//Must move the operation to the finished state if it is cancelled.
		[self willChangeValueForKey:@"isFinished"];
		self->finished = YES;
		[self didChangeValueForKey:@"isFinished"];
		return;
	}
	
	//If the operation is not cancelled, begin executing the task.
	[self willChangeValueForKey:@"isExecuting"];
	//[self performSelectorOnMainThread:@selector(main) withObject:nil waitUntilDone:NO];
	//@interface NSObject (NSThreadPerformAdditions) - thread for selector on thread
	//[self performSelector:@selector(didFinishOperation:) onThread:self.targetThread withObject:object waitUntilDone:NO];
	[NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];	    
    //[self performSelector:@selector(main) with];
	self->executing = YES;
	[self didChangeValueForKey:@"isExecuting"];
}

-(void)completeOperation{
	[self willChangeValueForKey:@"isFinished"];
	[self willChangeValueForKey:@"isExecuting"];
	self->executing =  NO;
	self->finished = YES;
	//TODO : Change property for KVO for key/value -> for details, check up with KVO programming guide -> Chapter 2 in Page 27
	[self didChangeValueForKey:@"isExecuting"];
	[self didChangeValueForKey:@"isFinished"];
}

-(void)main{
	@try {
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
		NSLog(@"start NSOperation::start() method inside");
		//BOOL isDone = NO;
		while (![self isCancelled] && [self isExecuting]) {
			NSLog(@"sleep NSOperation::start() method inside");
			//TODO : usleep -> seconds
			sleep(5);
			NSLog(@"completeOperation - start NSOperation::start() method inside");
			//TODO: Do some work and set isDone to YES when finished
			[self completeOperation];
			NSLog(@"completeOperation - end NSOperation::start() method inside");
		}
		[pool release];
	}
	@catch (NSException * e) {
		//TODO : Nothing here
	}
	@finally {
		//TODO: Do some work and set isDone to YES when finished
		NSLog(@"completeOperation - Do some work and set isDone to YES when finished");
	}
}
	
@end
