//
//  MyOperation.h
//  NSOPerationSample
//
//  Created by orlando ding on 12/11/11.
//  Copyright 2011 MakeDreamToFact. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//TODO : Operation sample in Concurrency Programming - Operation Queues
@interface MyOperation : NSOperation {
	BOOL executing;
	BOOL finished;
}

-(void) completeOperation;

@end
