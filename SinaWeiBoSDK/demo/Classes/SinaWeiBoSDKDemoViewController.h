//
//  SinaWeiBoSDKDemoViewController.h
//  SinaWeiBoSDKDemo
//
//  Created by Wu WenYong on 11-5-30.
//  Copyright 2011 Sina. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WBConnect.h"

@interface SinaWeiBoSDKDemoViewController : UIViewController
                                           <WBSessionDelegate,WBSendViewDelegate,WBRequestDelegate>{
	WeiBo* weibo;
	
	UIButton* buttonSend;
	UIButton* buttonLogout;
	UIButton* buttonGetFeed;
}

@property (nonatomic,assign,readonly) WeiBo* weibo;

@end

