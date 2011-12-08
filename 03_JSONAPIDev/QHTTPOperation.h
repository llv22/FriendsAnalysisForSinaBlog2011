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

@interface QHTTPOperation : QRunLoopOperation {

}

@end
