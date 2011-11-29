//
//  _0_NewVerifyAppDelegate.h
//  00_NewVerify
//
//  Created by orlando ding on 11/26/11.
//  Copyright 2011 MakeDreamToFact. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface _0_NewVerifyAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
