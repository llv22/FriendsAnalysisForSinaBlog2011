//
//  AsynJSONRequest.m
//  03_JSONAPIDev
//
//  Created by orlando ding on 12/5/11.
//  Copyright 2011 MakeDreamToFact. All rights reserved.
//

#import "AsynJSONRequest.h"


@implementation AsynJSONRequest

#pragma mark - Initialization Segement :: static ctor&wrapper ctor

//TODO : similar to /Users/orlando/Documents/06_weiboApp/FriendsAnalysisForSinaBlog2011/LinkedImageFetcher/LinkedImageFetcher.m :: + + (id)fetcherWithURLString:(const char *)urlCStr maximumDepth:(int)maximumDepth
//Singlton for static url accessing
+ (id)initWithURL:(NSString*)nstrInitialURL username:(NSString*)nstrUserName password:(NSString*)nstrPassword{	
	AsynJSONRequest *result;
	NSURL *url;			
	
	assert(nstrInitialURL!=nil);
	assert(nstrUserName!=nil);
	assert(nstrPassword!=nil);
	
	url = [NSURL URLWithString:nstrInitialURL];	
    if (url == nil) {
		//TODO : Macro to get program name via getproname() - stdlib.h
        fprintf(stderr, "%s: malformed URL: %s\n", getprogname(), [nstrInitialURL UTF8String]);
    } else {
        NSString *  scheme;
        
        scheme = [[url scheme] lowercaseString];
        assert(scheme != nil);
		
        if ( ! [scheme isEqual:@"http"] && ! [scheme isEqual:@"https"] ) {
            fprintf(stderr, "%s: unsupported URL scheme: %s\n", getprogname(), [scheme UTF8String]);
            url = nil;
        }
    }
	
	assert(url!=nil);
	result = [[[self alloc] initWithURL:url userName:nstrUserName password:nstrPassword] autorelease];
	
	return result;
}

- (id)initWithURL:(NSURL*)url userName:(NSString*)nstrUserName password:(NSString*)nstrPassword{
	assert(url!=nil);
	assert([[[url scheme]lowercaseString]isEqual:@"http"]||[[[url scheme]lowercaseString]isEqual:@"https"]);
	self = [super init];
	if (self != nil) {
		self->_nstrInitialURL = url;
		self->_nstrUserName = nstrUserName;
		self->_nstrPassword = nstrPassword;
	}
	return self;
}

//TODO : start to retrieve json request/response
-(void) start{
	[self startAsynJsonRequest:self->_nstrInitialURL];
}

- (void)startAsynJsonRequest:(NSURL *)jsonURL{
}

@end
