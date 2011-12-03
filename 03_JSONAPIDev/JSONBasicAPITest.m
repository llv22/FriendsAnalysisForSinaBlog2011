//
//  JSONBasicAPITest.m
//  03_JSONAPIDev
//
//  Created by orlando ding on 12/3/11.
//  Copyright 2011 MakeDreamToFact. All rights reserved.
//

#import "JSONBasicAPITest.h"
#import "JSON.h"
#import "WBUtil.h"

@implementation JSONBasicAPITest

-(void) setUp
{
	//TODO : Optional
}

-(void) tearDown
{
	//TODO : Optional
}
-(void) testOCUnitFramework
{
	NSString *string1 = @"test";
	NSString *string2 = @"test";
	STAssertEqualObjects(string1, string2, @"Failure");
	
	NSUInteger unit_1 = 4;
	NSUInteger unit_2 = 4;
	STAssertEquals(unit_1, unit_2, @"Failure");
}

//TODO : Test JSON API for implementation
-(void) testWeiboAPI_00
{
	NSData* proxy = [[NSData alloc]init];
	STAssertNotNil(proxy, @"WBRequest can't be initialized successfully");
}

//TODO : Test JSON API for implementation
-(void) testWeiboAPI_01
{
	SBJSON* proxy = [[SBJSON alloc]init];
	STAssertNotNil(proxy, @"WBRequest can't be initialized successfully");
}

@end
