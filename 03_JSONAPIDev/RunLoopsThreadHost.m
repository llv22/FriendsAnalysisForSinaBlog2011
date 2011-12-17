//
//  RunLoopsThreadHost.m
//  runloopsThread
//
//  Created by orlando ding on 12/17/11.
//  Copyright 2011 MakeDreamToFact. All rights reserved.
//

#import "RunLoopsThreadHost.h"
//#import "JSON.h" -> deprecated, as sina api isn't used any more
#import "WBUtil.h"
#import <SBJson.h>
#import <SBJsonStreamParserAdapter.h>
#import "AsynJSONRequest.h"

@interface RunLoopsThreadHost (PrivateMethod)

-(void) myThreadMainMethod:(id)param;

@end

@interface RunLoopsThreadHost () <SBJsonStreamParserAdapterDelegate>
@end

@interface RunLoopsThreadHost (NSURLConnectionDelegate)
@end

@implementation RunLoopsThreadHost

@synthesize IsThreadExist = _isThreadExist;
@synthesize IsDone = _done;

#pragma mark Initialization&Destruction
-(id)init{
	if (self = [super init]) {
		self->_myhostThread = nil;
		self->_isThreadExist = NO;
	}
	return (self);
}

-(void)dealloc{
	[super dealloc];
}

#pragma mark Thread Wrapper
//TODO : ThreadMain for host thread - don't need to working
-(void) startThreadMainForRunLoop{
	if (self->_isThreadExist == YES) {
		//TODO : if thread host already existed, stop it first then startThreadMainForRunLoop
		return;
	}
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	//TODO : Mac OSX 10.5 later - autorelease for framework
	self->_myhostThread = [[[NSThread alloc] initWithTarget:self 
												 selector:@selector(startThreadMainForRunLoop:) 
													object:nil]autorelease];
	self->_isThreadExist = YES;
	//TODO : Actually to start thread status code - YES by setter of thread status
	[self->_myhostThread start];
    
	[pool drain];
}

//TODO : waiting for thread stop
-(void) startThreadMainForRunLoop:(id)param{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init ];
	
	//TODO : working for thread Host - for RunLoops inside
	NSLog(@"in the thread working - in run loop %d", self->_isThreadExist);
	self.IsDone = NO;
	
	[self fetchRequestJSON:@"https://api.weibo.com/2/statuses/public_timeline.json" 
			 username:@"llv22@sina.com" 
			 password:@"xiandao22"];
	/*
	 * Run Loop of Thread
	 */	
	do {
		//TODO : [NSDate distantFuture] 
		//	- You can pass this value when an NSDate object 
		//	is required to have the date argument essentially ignored.
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	} while ( self.IsDone != YES );
	
	//TODO : Actually to start thread status code - NO by setter of thread status
	self->_isThreadExist = NO;
	
	//TODO : working for thread Host - for RunLoops outside
	NSLog(@"in the thread quitting - out of run loop %d", self->_isThreadExist);
	
	[pool drain];
}

//TODO : stop thread for running loop
-(void)stopThreadMainForRunLoop{
	if (self->_myhostThread == nil || self->_isThreadExist == NO) {
		return;
	}
	//TODO : Thread stopping
	if (self.IsDone == YES) {
		return;
	}
	self.IsDone = YES;
}

#pragma mark Fetch implementation
-(void) fetchRequestJSON: (NSString*)nstrInitialURL username:(NSString*)nstrUserName password:(NSString*)nstrPassword{	
	NSURLRequest *theRequest=[NSURLRequest 
							  requestWithURL:[NSURL URLWithString:nstrInitialURL]
							  cachePolicy:NSURLRequestUseProtocolCachePolicy 
							  timeoutInterval:60.0];
	
	self->username = nstrUserName;
	self->password = nstrPassword;
	
	//TODO : for calling json parser adpater and callback, just ignored synchronization
	// [Sitg's comments]
	// We don't want *all* the individual messages from the
	// SBJsonStreamParser, just the top-level objects. The stream
	// parser adapter exists for this purpose.
	adapter = [[SBJsonStreamParserAdapter alloc]init];
	adapter.delegate = self;
	assert(adapter!=nil);
	
	
	// Create a new stream parser and set our adapter as its delegate.
	parser = [[SBJsonStreamParser alloc]init];
	parser.delegate = adapter;
	assert(parser!=nil);
	
	// Normally it's an error if JSON is followed by anything but
	// whitespace. Setting this means that the parser will be
	// expecting the stream to contain multiple whitespace-separated
	// JSON documents.
	parser.supportMultipleDocuments = YES;

	//TODO : NSURLConnection delegate to username/password for default url authentication
	NSURLConnection *theConnection = [[[NSURLConnection alloc] initWithRequest:theRequest delegate:self] autorelease];	
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
	[adapter release];
	[parser release];
}

@end
