//
//  JSONBasicAPITest.m
//  03_JSONAPIDev
//
//  Created by orlando ding on 12/3/11.
//  Copyright 2011 MakeDreamToFact. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONBasicAPITest.h"
//#import "JSON.h" -> deprecated, as sina api isn't used any more
#import "WBUtil.h"
#import <SBJson.h>
#import <SBJsonStreamParserAdapter.h>
#import "AsynJSONRequest.h"

@interface JSONBasicAPITest () <SBJsonStreamParserAdapterDelegate>
@end

@interface JSONBasicAPITest (NSURLConnectionDelegate)
@end

@implementation JSONBasicAPITest

//Help documentation - Xcode Unit Testing Guide [Adding Unit Tests to Your Projects]
//The SenTestCase class provides a harness for calling the methods of your subclass automatically. As long as you follow some standard naming conventions for your test case methods, the only thing you have to do is write your tests. Your test case methods must follow these conventions:
//
//The name of the method must begin with the word test. For example, you could have methods called testCase1, testMyBoundsChecking, testMyAlgorithm.
//The method must take no parameters.
//The method must have a return type of void.


/**********1. TestCase Impelementation**********/
-(void) setUp
{
	//TODO : for calling json parser adpater and callback, just ignored synchronization
	// [Sitg's comments]
	// We don't want *all* the individual messages from the
	// SBJsonStreamParser, just the top-level objects. The stream
	// parser adapter exists for this purpose.
	adapter = [[SBJsonStreamParserAdapter alloc]init];
	adapter.delegate = self;
	STAssertNotNil(adapter, @"SBJsonStreamParserAdapter initialization failed");
	
	
	// Create a new stream parser and set our adapter as its delegate.
	parser = [[SBJsonStreamParser alloc]init];
	parser.delegate = adapter;
	STAssertNotNil(parser, @"SBJsonStreamParser initialization failed");
	
	// Normally it's an error if JSON is followed by anything but
	// whitespace. Setting this means that the parser will be
	// expecting the stream to contain multiple whitespace-separated
	// JSON documents.
	parser.supportMultipleDocuments = YES;
	
	username = @"llv22@sina.com";
	password = @"xiandao22";
	cocoaCondition = [[NSCondition alloc]init];
	isFinished = false;
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

-(void) myThreadMainMethod:(id)param{
	//NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init ];	
	//NSNumber* value = (NSNumber*)param;	
	self->proxy = [AsynJSONRequest initWithURL:@"https://api.weibo.com/2/statuses/public_timeline.json" 
								username:@"llv22@sina.com" 
								password:@"xiandao22"];
	
	if (self->proxy == nil) {
		// Do nothing.  +fetcherWithURLString:maximumDepth: has already printed the error.
	}
	else {		
		[self->proxy start];
//		NSString *url = [NSString stringWithString:@"https://api.weibo.com/2/statuses/public_timeline.json"];	
//		NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url]
//												  cachePolicy:NSURLRequestUseProtocolCachePolicy
//											  timeoutInterval:60.0];
//		
//		//TODO : NSURLConnection delegate to username/password for default url authentication
//		NSURLConnection *theConnection = [[[NSURLConnection alloc] initWithRequest:theRequest delegate:self] autorelease];
//		STAssertNotNil(theConnection, @"Connection creation failed");
		//TODO : working
		//	NSLog(@"in the thread working - in thread %d", [value intValue]);
		//	if (cocoaCondition != nil) {
		//		[cocoaCondition lock];
		//		isFinished = true;
		//		[cocoaCondition signal];
		//		[cocoaCondition unlock];
		//	}
		//	
		//[pool drain];
	}

}

//TODO : Test JSON API for implementation
// API -> http://open.weibo.com/wiki/2/statuses/public_timeline
-(void) testWeiboAPI_00
{		
	//TODO : Mac OSX 10.5 later
	NSThread* myThread = [[NSThread alloc] initWithTarget:self 
												 selector:@selector(myThreadMainMethod:) 
												   object:nil//[NSNumber numberWithInt:2]
						  ];
	//TODO : Actually to start thread
	[myThread start];
	
	//sleep(50000);
	[cocoaCondition lock];
	while (!isFinished) {
		[cocoaCondition wait];
	}
	[cocoaCondition unlock];
	NSLog(@"Test case ended 00");
}

//TODO : Test JSON API for implementation
-(void) testWeiboAPI_01
{
	NSLog(@"Test case ended 01");
}


/**********2. Delegation Category**********/
#pragma mark SBJsonStreamParserAdapterDelegate methods

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
    [NSException raise:@"unexpected" format:@"Should not get here"];
}

- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
	//tweet.text = [dict objectForKey:@"text"];
}

#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"Connection didReceiveResponse: %@ - %@", response, [response MIMEType]);
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	NSLog(@"Connection didReceiveAuthenticationChallenge: %@", challenge);
	//TODO : Network credential setting
	NSURLCredential *credential = [NSURLCredential credentialWithUser:username
															 password:password
														  persistence:NSURLCredentialPersistenceForSession];
	
	[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"Connection didReceiveData of length: %u", data.length);
	
	// Parse the new chunk of data. The parser will append it to
	// its internal buffer, then parse from where it left off in
	// the last chunk.
	SBJsonStreamParserStatus status = [parser parse:data];
	
	if (status == SBJsonStreamParserError) {
        //tweet.text = [NSString stringWithFormat: @"The parser encountered an error: %@", parser.error];
		NSLog(@"Parser error: %@", parser.error);
		
	} else if (status == SBJsonStreamParserWaitingForData) {
		NSLog(@"Parser waiting for more data");
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [connection release];
//	TODO : reuse the same adapter and parser, is it possible?
//    [adapter release];
//    [parser release];
}

@end
