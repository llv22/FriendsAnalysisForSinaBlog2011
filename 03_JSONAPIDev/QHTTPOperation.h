//
//  QHTTPOperation.h
//  LinkedImageFetcher
//
//  Created by orlando ding on 12/9/11.
//  Copyright 2011 MakeDreamToFact. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
 QHTTPOperation is a general purpose NSOperation that runs an HTTP request. 
 You initialise it with an HTTP request and then, when you run the operation, 
 it sends the request and gathers the response.  It is quite a complex 
 object because it handles a wide variety of edge cases, but it's very 
 easy to use in simple cases:
 
 1. create the operation with the URL you want to get
 
 op = [[[QHTTPOperation alloc] initWithURL:url] autorelease];
 
 2. set up any non-default parameters, for example, set which HTTP 
 content types are acceptable
 
 op.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
 
 3. enqueue the operation
 
 [queue addOperation:op];
 
 4. finally, when the operation is done, use the lastResponse and 
 error properties to find out how things went
 
 As mentioned above, QHTTPOperation is very general purpose.  There are a 
 large number of configuration and result options available to you.
 
 o You can specify a NSURLRequest rather than just a URL. 
 o You can configure the run loop and modes on which the NSURLConnection is 
 scheduled. 
 o You can specify what HTTP status codes and content types are OK. 
 o You can set an authentication delegate to handle authentication challenges. 
 o You can accumulate responses in memory or in an NSOutputStream.  
 o For in-memory responses, you can specify a default response size 
 (used to size the response buffer) and a maximum response size 
 (to prevent unbounded memory use). 
 o You can get at the last request and the last response, to track 
 redirects. 
 o There are a variety of funky debugging options to simulator errors 
 and delays.
 
 Finally, it's perfectly reasonable to subclass QHTTPOperation to meet you 
 own specific needs.  Specifically, it's common for the subclass to 
 override -connection:didReceiveResponse: in order to setup the output 
 stream based on the specific details of the response.
 */

#import "QRunLoopOperation.h"

//TODO : see The Objective-C Programming Language -> Referring to Other Protocols
@protocol QHTTPOperationAuthenticationDelegate;

@interface QHTTPOperation : QRunLoopOperation {

}

- (id)initWithURL:(NSURL *)url;                     // convenience, calls +[NSURLRequest requestWithURL:]

#pragma mark NSURL implementation
// Things that are configured by the init method and can't be changed.
@property (copy,   readonly)  NSURL *               URL;

@end

#pragma mark NSURLConnectionDelegate to set asynchronous mode accessing
@interface QHTTPOperation (NSURLConnectionDelegate)

// QHTTPOperation implements all of these methods, so if you override them 
// you must consider whether or not to call super.
//
// These will be called on the operation's run loop thread.

// TODO :Routes the request to the authentication delegate if it exists, otherwise 
// just returns NO.
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;

// TODO : Routes the request to the authentication delegate if it exists, otherwise 
// just cancels the challenge.
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

// TODO : Latches the request and response in lastRequest and lastResponse.
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response;

// TODO : Latches the response in lastResponse.
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;

// TODO : If this is the first chunk of data, it decides whether the data is going to be 
// routed to memory (responseBody) or a stream (responseOutputStream) and makes the 
// appropriate preparations.  For this and subsequent data it then actually shuffles 
// the data to its destination.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

// TODO : Completes the operation with either no error (if the response status code is acceptable) 
// or an error (otherwise).
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

// TODO : Completes the operation with the error.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end

#pragma mark Merge with NSObject procotol for QHTTPOperationAuthenticationDelegate
@protocol QHTTPOperationAuthenticationDelegate <NSObject>
@required

// These are called on the operation's run loop thread and have the same semantics as their 
// NSURLConnection equivalents.  It's important to realise that there is no 
// didCancelAuthenticationChallenge callback (because NSURLConnection doesn't issue one to us).  
// Rather, an authentication delegate is expected to observe the operation and cancel itself 
// if the operation completes while the challenge is running.

- (BOOL)httpOperation:(QHTTPOperation *)operation canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace;
- (void)httpOperation:(QHTTPOperation *)operation didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@end

extern NSString * kQHTTPOperationErrorDomain;

// positive error codes are HTML status codes (when they are not allowed via acceptableStatusCodes)
//
// 0 is, of course, not a valid error code
//
// negative error codes are errors from the module

enum {
    kQHTTPOperationErrorResponseTooLarge = -1, 
    kQHTTPOperationErrorOnOutputStream   = -2, 
    kQHTTPOperationErrorBadContentType   = -3
};
