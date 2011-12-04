//
//  JSONBasicAPITest.h
//  03_JSONAPIDev
//
//  Created by orlando ding on 12/3/11.
//  Copyright 2011 MakeDreamToFact. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class SBJsonStreamParser;
@class SBJsonStreamParserAdapter;

@interface JSONBasicAPITest : SenTestCase {
	
#pragma mark fields for authentication of calling json	
	NSString* username;
	NSString* password;
	
#pragma mark fields for synchronization block -> Page 71 of synchronization programming line	
	NSCondition* cocoaCondition;
	bool isFinished;
	int testCaseFinished;
	
#pragma mark field for calling json API of stig	
    SBJsonStreamParser *parser;
    SBJsonStreamParserAdapter *adapter;

}

@end
