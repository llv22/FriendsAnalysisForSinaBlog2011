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
#import <NSObject+SBJson.h>
#pragma mark Base64 Encoding&Decoding 
//  Reference from 
//	- https://github.com/mattgemmell/MGTwitterEngine
//  - http://hi.baidu.com/niguang1024/blog/item/
#import "NSData+Base64.h"

#pragma mark Customized framework by myself
//#import "AsynJSONRequest.h" -> extract to class later

@interface RunLoopsThreadHost (PrivateMethod)

-(void) myThreadMainMethod:(id)param;
+(NSString *) stringFromDictionary:(NSDictionary*)dicInfo;
-(void) traverseJSONValue:(NSObject*)jsonvalue;

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
	if (self->_myhostThread != nil) {
		//TODO : for autorelease, then don't need release any more; just add retain then release for framework
		[self->_myhostThread release]; 
	}
	[super dealloc];
}

#pragma mark Thread Wrapper
//TODO : ThreadMain for host thread - don't need to working
-(void) startThreadMainForRunLoop{
	if (self->_isThreadExist == YES) {
		//TODO : if thread host already existed, stop it first then startThreadMainForRunLoop
		return;
	}
	//TODO : Mac OSX 10.5 later - autorelease for framework
	self->_myhostThread = [[[NSThread alloc] initWithTarget:self 
												 selector:@selector(startThreadMainForRunLoop:) 
													object:nil]retain];
	self->_isThreadExist = YES;
	//TODO : Actually to start thread status code - YES by setter of thread status
	[self->_myhostThread start];
}

//TODO : waiting for thread stop
-(void) startThreadMainForRunLoop:(id)param{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	//TODO : working for thread Host - for RunLoops inside
	NSLog(@"in the thread working - in run loop %d", self->_isThreadExist);
	self.IsDone = NO;
	
	//TODO : GET request
//	[self fetchGETRequestJSON:@"https://api.weibo.com/2/statuses/public_timeline.json"
//				  username:@"llv22@sina.com" 
//				  password:@"xiandao22" 
//				sinaappkey:@"2657678697"];
	
	//TODO : POST request
	[self fetchPOSTRequestJSON:@"https://api.weibo.com/2/statuses/update.json"
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
	//TODO : working for thread Host - for RunLoops outside
	NSLog(@"in the thread quitting - out of run loop %d", self->_isThreadExist);
	self->_isThreadExist = NO;
		
	[pool release];
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

#pragma mark URL generation
/**
 * Generate get URL
 */
+ (NSString*)serializeURL:(NSString *)baseUrl
                   params:(NSDictionary *)params
               httpMethod:(NSString *)httpMethod 
{	
	if ( [httpMethod isEqualToString:@"GET"] == FALSE )
		return baseUrl;
	
	NSURL* parsedURL = [NSURL URLWithString:baseUrl];
	NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
	NSString* query = [RunLoopsThreadHost stringFromDictionary:params];
	
	return [NSString stringWithFormat:@"%@%@%@", baseUrl, queryPrefix, query];
}

// private
+ (NSString*)stringFromDictionary:(NSDictionary*)dicInfo
{
	NSMutableArray* pairs = [NSMutableArray array];
	for (NSString* key in [dicInfo keyEnumerator]) 
	{
		if( ([[dicInfo valueForKey:key] isKindOfClass:[NSString class]]) == FALSE)
		{
			NSLog(@"Please Use NSString for this kind of params");
			continue;
		}
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [dicInfo objectForKey:key]]];
	}
	
	//TODO : Autorelease
	return [pairs componentsJoinedByString:@"&"];
}

#pragma mark Fetch implementation
//TODO : GET
-(void) fetchGETRequestJSON: (NSString*)nstrInitialURL 
				username:(NSString*)nstrUserName 
				password:(NSString*)nstrPassword
			  sinaappkey:(NSString*)nstrappkey{	
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
	[params setObject:nstrappkey forKey:@"source"];
	[params setObject:@"1" forKey:@"page"];
	[params setObject:@"10" forKey:@"count"];
	
	//TODO : /Users/orlando/Documents/06_weiboApp/FriendsAnalysisForSinaBlog2011/CocoaSOAP/SOAPClient.m NSURLRequest -> NSMutableURLRequest [avoid single url request, then to reuse mutable request, see programming guide of NSMutableURLRequest]	
	//TODO : /Users/orlando/Documents/06_weiboApp/FriendsAnalysisForSinaBlog2011/SinaWeiBoSDK/src/src/WBRequest.m
	//TODO : header for implementation of url of GET request
	//	1, http://stackoverflow.com/questions/1571336/sending-post-data-from-iphone-over-ssl-https
	NSString *getParams = [[self class] stringFromDictionary:params];
	NSURL* hosturl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", nstrInitialURL, getParams]];	
	NSMutableURLRequest *theRequest = [[[NSMutableURLRequest alloc] 
										initWithURL:hosturl
										cachePolicy:NSURLRequestReloadIgnoringCacheData 
										timeoutInterval:60.0] 
									   autorelease];
	
	//TODo : GET request
    [theRequest setHTTPMethod:@"GET"];
	
	//TODO : Http Header
	// Migrate from static string from following link on network to NSMutableString for fitting for both GET/POST case, POST header may be changed by http procotol
	//	1, http://www.chrisumbel.com/article/basic_authentication_iphone_cocoa_touch	
	//	2, https://github.com/mattgemmell/MGTwitterEngine	
	// - AUTHENTICATION based on 64Base
	// 1, previous static NSString for previous case - http://www.chrisumbel.com/article/basic_authentication_iphone_cocoa_touch
	// 2, NSMutableString for Post Case - http://hi.baidu.com/niguang1024/blog/item/ade949249467c2258744f9ce.html
	NSString *authString = [NSString stringWithFormat:@"%@:%@",nstrUserName,nstrPassword];
	NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
	NSString *encodingData = [authData base64EncodingWithLineLength:80];
	NSString *authValue = [NSString stringWithFormat:@"Basic %@", encodingData];
	[theRequest setValue:authValue forHTTPHeaderField:@"Authorization"];  	 
	
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
	theConnection = [[[NSURLConnection alloc] initWithRequest:theRequest delegate:self]retain];	//TODO : autorelease
}


//TODO : POST
-(void) fetchPOSTRequestJSON: (NSString*)nstrInitialURL 
					username:(NSString*)nstrUserName 
					password:(NSString*)nstrPassword 
				  sinaappkey:(NSString*)nstrappkey
{
	NSURL* hosturl = [NSURL URLWithString:nstrInitialURL];	
	NSMutableURLRequest *theRequest = [[[NSMutableURLRequest alloc] 
										initWithURL:hosturl
										cachePolicy:NSURLRequestReloadIgnoringCacheData 
										timeoutInterval:60.0]autorelease];
	//TODO : POST Method
    [theRequest setHTTPMethod:@"POST"];
	
	//TODO : POST DATA content
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
	[params setObject:nstrappkey forKey:@"source"];
	[params setObject:@"Orlando Refined NSOperation Asynchronou Queue Implementation, Next Step with Picture location and Friend NSData Graphic Algorithm, Content Analysis" forKey:@"status"];	
	NSString *post = [[self class] stringFromDictionary:params];
	NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];	
	[theRequest setHTTPBody:postData];
	
	//TODO : POST Length
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];	
	[theRequest addValue:postLength forHTTPHeaderField:@"Content-Length"];
	
	// TODO : AUTHENTICATION, create the contents of the header 
	// 1, previous static NSString for previous case - http://www.chrisumbel.com/article/basic_authentication_iphone_cocoa_touch
	// 2, NSMutableString for Post Case - http://hi.baidu.com/niguang1024/blog/item/ade949249467c2258744f9ce.html
	NSString *authString = [NSString stringWithFormat:@"%@:%@",nstrUserName,nstrPassword];
	NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
	NSString *encodingData = [authData base64EncodingWithLineLength:80];
	NSString *authValue = [NSString stringWithFormat:@"Basic %@", encodingData];
	// TODO : add the header to the request.
	[theRequest setValue:authValue forHTTPHeaderField:@"Authorization"];  
	
	//TODO : Header for POST setting -> application/json MIME
	[theRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
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
	theConnection = 
	[[[NSURLConnection alloc] initWithRequest:theRequest delegate:self]retain];	//TODO : autorelease
}

/**********2. Delegation Category**********/
#pragma mark SBJsonStreamParserAdapterDelegate methods

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
    [NSException raise:@"unexpected" format:@"Should not get here"];
}

//TODO : json response format content
- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
	NSLog(@"(void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict\n");
	[self traverseJSONValue:dict];
}

//TODO : Using recursive algorithm to parse json content
-(void) traverseJSONValue:(NSObject*)jsonvalue{
	if (jsonvalue == nil) {
		return;
	}
	if ([jsonvalue isKindOfClass:[NSArray class]]) {
		//TODO : parse array items
		NSArray* array = (NSArray*)jsonvalue;
		for(NSObject* value in array){
			[self traverseJSONValue:value];
		}
	}
	else if([jsonvalue isKindOfClass:[NSDictionary class]]){
		//TODO : parse dictionary items
		NSDictionary* dict = (NSDictionary*)jsonvalue;
		for(NSObject* key in dict){
			if ([key isKindOfClass:[NSString class]]) {
				NSLog(@"%@ - ", (NSString*)key);
			}
			NSObject* value = [dict objectForKey:key];
			if ([value isKindOfClass:[NSString class]]) {
				NSLog(@"%@\n", (NSString*)value);
			}
			else if([value isKindOfClass:[NSNumber class]]){
				NSLog(@"%@\n", (NSNumber*)value);
			}
			else {
				[self traverseJSONValue:value];
			}
		}
	}
}

#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"Connection didReceiveResponse: %@ - %@", response, [response MIMEType]);
}

//TODO : ssl enablement
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	//TODO : http://stackoverflow.com/questions/933331/how-to-use-nsurlconnection-to-connect-with-ssl-for-an-untrusted-cert
	if([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]){
		// Note: it doesn't seem to matter what you return for a proper SSL cert
		//       only self-signed certs	
		return YES; 
	}
	// If no other authentication is required, return NO for everything else
	// Otherwise maybe YES for NSURLAuthenticationMethodDefault and etc.
	return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	NSLog(@"Connection didReceiveAuthenticationChallenge: %@", challenge);
//	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
//		if ([challenge.protectionSpace.host isEqualToString:@"api.weibo.com"]){
//			[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//		}
	
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
		NSLog(@"Parser error: %@", parser.error);
		self.IsDone = YES;		
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
	//TODO : Remove connection item entity, so in the initilaization of fetchRequestJSON don't add [connection autorelease]
	assert(connection==theConnection);
    [connection release];
	[theConnection release];
	//TODO : reuse the same adapter and parser, is it possible?
	[adapter release];
	[parser release];
	self.IsDone = YES;
}

@end
