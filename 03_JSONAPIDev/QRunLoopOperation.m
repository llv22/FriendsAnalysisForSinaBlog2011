//
//  QRunLoopOperation.m
//  LinkedImageFetcher
//
//  Created by orlando ding on 12/9/11.
//  Copyright 2011 MakeDreamToFact. All rights reserved.
//

#import "QRunLoopOperation.h"

/*
 Theory of Operation
 -------------------
 Some critical points:
 
 1. By the time we're running on the run loop thread, we know that all further state 
 transitions happen on the run loop thread.  That's because there are only three 
 states (inited, executing, and finished) and run loop thread code can only run 
 in the last two states and the transition from executing to finished is 
 always done on the run loop thread.
 
 2. -start can only be called once.  So run loop thread code doesn't have to worry 
 about racing with -start because, by the time the run loop thread code runs, 
 -start has already been called.
 
 3. -cancel can be called multiple times from any thread.  Run loop thread code 
 must take a lot of care with do the right thing with cancellation.
 
 Some state transitions:
 
 1. init -> dealloc
 2. init -> cancel -> dealloc
 XXX  3. init -> cancel -> start -> finish -> dealloc
 4. init -> cancel -> start -> startOnRunLoopThreadThread -> finish dealloc
 !!!  5. init -> start -> cancel -> startOnRunLoopThreadThread -> finish -> cancelOnRunLoopThreadThread -> dealloc
 XXX  6. init -> start -> cancel -> cancelOnRunLoopThreadThread -> startOnRunLoopThreadThread -> finish -> dealloc
 XXX  7. init -> start -> cancel -> startOnRunLoopThreadThread -> cancelOnRunLoopThreadThread -> finish -> dealloc
 8. init -> start -> startOnRunLoopThreadThread -> finish -> dealloc
 9. init -> start -> startOnRunLoopThreadThread -> cancel -> cancelOnRunLoopThreadThread -> finish -> dealloc
 !!! 10. init -> start -> startOnRunLoopThreadThread -> cancel -> finish -> cancelOnRunLoopThreadThread -> dealloc
 11. init -> start -> startOnRunLoopThreadThread -> finish -> cancel -> dealloc
 
 Markup:
 XXX means that the case doesn't happen.
 !!! means that the case is interesting.
 
 Described:
 
 1. It's valid to allocate an operation and never run it.
 2. It's also valid to allocate an operation, cancel it, and yet never run it.
 3. While it's valid to cancel an operation before it starting it, this case doesn't 
 happen because -start always bounces to the run loop thread to maintain the invariant 
 that the executing to finished transition always happens on the run loop thread.
 4. In this -startOnRunLoopThread detects the cancellation and finishes immediately.
 5. Because the -cancel can happen on any thread, it's possible for the -cancel 
 to come in between the -start and the -startOnRunLoop thread.  In this case 
 -startOnRunLoopThread notices isCancelled and finishes straightaway.  And 
 -cancelOnRunLoopThread detects that the operation is finished and does nothing.
 6. This case can never happen because -performSelecton:onThread:xxx 
 callbacks happen in order, -start is synchronised with -cancel, and -cancel 
 only schedules if -start has run.
 7. This case can never happen because -startOnRunLoopThread will finish immediately 
 if it detects isCancelled (see case 5).
 8. This is the standard run-to-completion case. 
 9. This is the standard cancellation case.  -cancelOnRunLoopThread wins the race 
 with finish, and it detects that the operation is executing and actually cancels. 
 10. In this case the -cancelOnRunLoopThread loses the race with finish, but that's OK 
 because -cancelOnRunLoopThread already does nothing if the operation is already 
 finished.
 11. Cancellating after finishing still sets isCancelled but has no impact 
 on the RunLoop thread code.
 */

@interface QRunLoopOperation ()

// read/write versions of public properties
@property (assign, readwrite) QRunLoopOperationState    state;
@property (copy,   readwrite) NSError *                 error;          

@end

@implementation QRunLoopOperation

#pragma init & dealloc implmentation

-(id)init{
	self = [super init];
	if (self != nil) {
		//TODO : _state = 0
		assert(self->_state == kQRunLoopOperationStateInited);
	}
	return self;
}

-(void)dealloc{
	assert(self->_state!=kQRunLoopOperationStateExecuting);
	[self->_runLoopModes release];
	[self->_runLoopThread release];
	[self->_error release];
	[super dealloc];
}

#pragma mark * Properties

@synthesize runLoopThread = _runLoopThread;
@synthesize runLoopModes  = _runLoopModes;

// TODO :
// Returns the effective run loop thread, that is, the one set by the user 
// or, if that's not set, the main thread.
-(NSThread*)actualRunLoopThread{
	NSThread* result = self.runLoopThread;
	if (result == nil) {
		//TODO : Main Thread for cocoa
		result = [NSThread mainThread];
	}
	return result;
}

// TODO : 
// Returns YES if the current thread is the actual run loop thread.
-(BOOL)isActualRunLoopThread{
	return [[NSThread currentThread] isEqual:self.actualRunLoopThread];
}

// TODO :
// Return the NSSet for NSDefaultRunLoopMode into NSSet dictionary object.
-(NSSet*)actualRunLoopModes{
	NSSet* result = self.runLoopModes;
	if (result == nil || [result count] == 0) {
		result = [NSSet setWithObject:NSDefaultRunLoopMode];
	}
	return result;
}

@synthesize error         = _error;

#pragma mark * Core state transitions

@synthesize state         = _state;

// TODO :
// Change the state of the operation, sending the appropriate KVO notifications.
-(void)setState:(QRunLoopOperationState)newState{
	@synchronized(self){
        QRunLoopOperationState  oldState;
		// The following check is really important.  The state can only go forward, and there 
        // should be no redundant changes to the state (that is, newState must never be 
        // equal to self->_state).
		assert(newState > self->_state);
		
        // Transitions from executing to finished must be done on the run loop thread.        
        assert( (newState != kQRunLoopOperationStateFinished) || self.isActualRunLoopThread ); 
		
		// inited    + executing -> isExecuting
        // inited    + finished  -> isFinished
        // executing + finished  -> isExecuting + isFinished		
        oldState = self->_state;
        if ( (newState == kQRunLoopOperationStateExecuting) || (oldState == kQRunLoopOperationStateExecuting) ) {
            [self willChangeValueForKey:@"isExecuting"];
        }
        if (newState == kQRunLoopOperationStateFinished) {
            [self willChangeValueForKey:@"isFinished"];
        }
        self->_state = newState;
        if (newState == kQRunLoopOperationStateFinished) {
            [self didChangeValueForKey:@"isFinished"];
        }
        if ( (newState == kQRunLoopOperationStateExecuting) || (oldState == kQRunLoopOperationStateExecuting) ) {
            [self didChangeValueForKey:@"isExecuting"];
        }
	}
}

#pragma mark * Subclass override points --- @interface QRunLoopOperation (SubClassSupport)

- (void)operationDidStart
{
    assert(self.isActualRunLoopThread);
}

- (void)operationWillCancel
{
    assert(self.isActualRunLoopThread);
}

- (void)operationWillFinish
{
    assert(self.isActualRunLoopThread);
}

#pragma mark * Overrides --- NSOperation

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return self.state == kQRunLoopOperationStateExecuting;
}

- (BOOL)isFinished
{
    return self.state == kQRunLoopOperationStateFinished;
}

//TODO : Override the start method of NSOperation
- (void)start
{
    assert(self.state == kQRunLoopOperationStateInited);
    
    // We have to change the state here, otherwise isExecuting won't necessarily return 
    // true by the time we return from -start.  Also, we don't test for cancellation 
    // here because that would a) result in us sending isFinished notifications on a 
    // thread that isn't our run loop thread, and b) confuse the core cancellation code, 
    // which expects to run on our run loop thread.  Finally, we don't have to worry 
    // about races with other threads calling -start.  Only one thread is allowed to 
    // start us at a time.    
    self.state = kQRunLoopOperationStateExecuting;
	// TODO :
	// START thread to Define a Custom Operation Object Page 26 -> startOnRunLoopThread
    [self performSelector:@selector(startOnRunLoopThread) onThread:self.actualRunLoopThread withObject:nil waitUntilDone:NO modes:[self.actualRunLoopModes allObjects]];
}

//TODO : Override the cancel method of NSOperation
- (void)cancel
{
    BOOL    runCancelOnRunLoopThread;
    BOOL    oldValue;
	
    // We need to synchronise here to avoid state changes to isCancelled and state
    // while we're running.    
    @synchronized (self) {
        oldValue = [self isCancelled];        
        // Call our super class so that isCancelled starts returning true immediately.        
        [super cancel];
        
        // If we were the one to set isCancelled (that is, we won the race with regards 
        // other threads calling -cancel) and we're actually running (that is, we lost 
        // the race with other threads calling -start and the run loop thread finishing), 
        // we schedule to run on the run loop thread.		
        runCancelOnRunLoopThread = ! oldValue && self.state == kQRunLoopOperationStateExecuting;
    }
    if (runCancelOnRunLoopThread) {
		// TODO :
		// thread to Define a Custom Operation Object Page 26 -> cancelOnRunLoopThread
        [self performSelector:@selector(cancelOnRunLoopThread) onThread:self.actualRunLoopThread withObject:nil waitUntilDone:YES modes:[self.actualRunLoopModes allObjects]];
    }
}


#pragma mark * Used operation in selector(start), (cancel)

// TODO : 
// Starts the operation.  The actual -start method is very simple, 
// deferring all of the work to be done on the run loop thread by this 
// method.
- (void)startOnRunLoopThread
{
    assert(self.isActualRunLoopThread);
    assert(self.state == kQRunLoopOperationStateExecuting);
	
    if ([self isCancelled]) {        
        // We were cancelled before we even got running.  Flip the the finished 
        // state immediately.        
        [self finishWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
    } else {
        [self operationDidStart];
    }
}

// TODO : 
// Cancels the operation.
- (void)cancelOnRunLoopThread
{
    assert(self.isActualRunLoopThread);	
    // We know that a) state was kQRunLoopOperationStateExecuting when we were 
    // scheduled (that's enforced by -cancel), and b) the state can't go 
    // backwards (that's enforced by -setState), so we know the state must 
    // either be kQRunLoopOperationStateExecuting or kQRunLoopOperationStateFinished. 
    // We also know that the transition from executing to finished always 
    // happens on the run loop thread.  Thus, we don't need to lock here.  
    // We can look at state and, if we're executing, trigger a cancellation.    
    if (self.state == kQRunLoopOperationStateExecuting) {
        [self finishWithError:[NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil]];
    }
}

// TODO : 
// Used in startOnRunLoopThead, cancelOnRunLoopThread
- (void)finishWithError:(NSError *)error
{
    assert(self.isActualRunLoopThread);	
    if (self.error == nil) {
        self.error = error;
    }
    [self operationWillFinish];
    self.state = kQRunLoopOperationStateFinished;
}

@end
