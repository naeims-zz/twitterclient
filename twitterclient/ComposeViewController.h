//
//  ComposeViewController.h
//  twitterclient
//
//  Created by Naeim Semsarilar on 3/5/15.
//  Copyright (c) 2015 naeim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComposeViewController : UIViewController

- (void)prepareForReplyWithTweetId:(NSString *)tweetId authorScreenName:(NSString *)authorScreenName;

@end
