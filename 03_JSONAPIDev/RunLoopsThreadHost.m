//
//  RunLoopsThreadHost.m
//  runloopsThread
//
//  Created by orlando ding on 12/17/11.
//  Copyright 2011 MakeDreamToFact. All rights reserved.
//

#import "RunLoopsThreadHost.h"

#pragma mark "stig framework implementation"
#import <WBUtil.h>
#import <SBJson.h>
#import <SBJsonStreamParserAdapter.h>

#pragma mark Customized framework by myself
//#import "AsynJSONRequest.h" -> extract to class later

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
				  password:@"xiandao22" 
				sinaappkey:@"2657678697"];
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
-(void) fetchRequestJSON: (NSString*)nstrInitialURL 
				username:(NSString*)nstrUserName 
				password:(NSString*)nstrPassword
			  sinaappkey:(NSString*)nstrappkey{
	//TODO : /Users/orlando/Documents/06_weiboApp/FriendsAnalysisForSinaBlog2011/CocoaSOAP/SOAPClient.m NSURLRequest -> NSMutableURLRequest [avoid single url request, then to reuse mutable request, see programming guide of NSMutableURLRequest]
	
	NSURL* hosturl = [NSURL URLWithString:nstrInitialURL];
	NSMutableURLRequest *theRequest = [[[NSMutableURLRequest alloc] 
										initWithURL:hosturl
										cachePolicy:NSURLRequestReloadIgnoringCacheData 
										timeoutInterval:60.0] 
									   autorelease];
	//TODO : http://stackoverflow.com/questions/1571336/sending-post-data-from-iphone-over-ssl-https
	NSString *post =[[NSString alloc] initWithFormat:@"source=%@&page=1&count=10", nstrappkey];
	NSLog(@"%@", post);
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];	
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    [theRequest setHTTPMethod:@"POST"];
	[theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[theRequest setHTTPBody:postData];
	
	/* when we user https, we need to allow any HTTPS cerificates, so add the one line code,to tell teh NSURLRequest to accept any https certificate, i'm not sure about the security aspects
	 */	
	//[NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[hosturl host]];
//	
    //[request setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
	
//	NSURLRequest *theRequest=[NSURLRequest 
//							  requestWithURL:[NSURL URLWithString:nstrInitialURL]
//							  cachePolicy:NSURLRequestUseProtocolCachePolicy 
//							  timeoutInterval:60.0];
	
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
	/*NSURLConnection *theConnection = */
	[[[NSURLConnection alloc] initWithRequest:theRequest delegate:self] autorelease];	
}

/**********2. Delegation Category**********/
#pragma mark SBJsonStreamParserAdapterDelegate methods

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
    [NSException raise:@"unexpected" format:@"Should not get here"];
}

//TODO : json response format content
- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
	NSLog(@"(void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict\n");
	NSString *key;
	for(key in dict){
		NSLog(@"Key: %@, Value %@", key, [dict objectForKey: key]);
	}
}

#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"Connection didReceiveResponse: %@ - %@", response, [response MIMEType]);
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	NSLog(@"Connection didReceiveAuthenticationChallenge: %@", challenge);
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
		if ([challenge.protectionSpace.host isEqualToString:@"api.weibo.com"]){
			[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
		}
	
	//TODO : Network credential setting
	NSURLCredential *credential = [NSURLCredential credentialWithUser:username
															 password:password
														  persistence:NSURLCredentialPersistenceForSession];
	
	[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"Connection didReceiveData of length: %u", data.length);
	
	// Parse the new chunk of data. The parser will append it to its internal buffer, then parse from where it left off in
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
