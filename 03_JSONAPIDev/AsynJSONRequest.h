//
//  AsynJSONRequest.h
//  03_JSONAPIDev
//
//  Created by orlando ding on 12/5/11.
//  Copyright 2011 MakeDreamToFact. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AsynJSONRequest : NSObject {	
	//TODO : Application status & recordset for setting
	BOOL                            _isDone;
    NSError *                       _nseError;		
    NSMutableSet *                  _nmsetRetrievedURLs;
    NSMutableDictionary *           _nsmdicFoundImageURLToPathMap;
	
	//TODO : User setting and url infor.
	NSURL *						_nstrInitialURL;
	NSString *						_nstrUserName;
	NSString *						_nstrPassword;
}

#pragma mark - Initialization Segement :: static ctor&wrapper ctor
+ (id)initWithURL:(NSString*)nstrInitialURL username:(NSString*)nstrUserName password:(NSString*)nstrPassword;

- (id)initWithURL:(NSURL*)url userName:(NSString*)nstrUserName password:(NSString*)nstrPassword;

@end
