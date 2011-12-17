//
//  RunLoopsThreadHost.h
//  runloopsThread
//
//  Created by orlando ding on 12/17/11.
//  Copyright 2011 MakeDreamToFact. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SBJsonStreamParser;
@class SBJsonStreamParserAdapter;
@interface RunLoopsThreadHost : NSObject {

@private	
	NSThread* _myhostThread;
	BOOL _isThreadExist;
	BOOL _done;
	NSString* username;
	NSString* password;
	SBJsonStreamParserAdapter* adapter;
	SBJsonStreamParser* parser;
}

@property BOOL IsThreadExist;
@property (nonatomic, assign, readwrite) BOOL  IsDone;   // observable

-(void) startThreadMainForRunLoop;
-(void) stopThreadMainForRunLoop;
//TODO : start Request JSON later wrappered in one queue
-(void) fetchRequestJSON: (NSString*)nstrInitialURL username:(NSString*)nstrUserName password:(NSString*)nstrPassword;

@end
