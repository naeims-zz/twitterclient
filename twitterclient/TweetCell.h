//
//  TweetCell.h
//  twitterclient
//
//  Created by Naeim Semsarilar on 3/3/15.
//  Copyright (c) 2015 naeim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class TweetCell;

@protocol TweetCellDelegate <NSObject>

-(void)replyInvoked:(TweetCell *)tweetCell;
-(void)favoriteInvoked:(TweetCell *)tweetCell;
-(void)retweetInvoked:(TweetCell *)tweetCell;

@end

@interface TweetCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorHandleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UIImageView *replyButton;
@property (weak, nonatomic) IBOutlet UIImageView *retweetButton;
@property (weak, nonatomic) IBOutlet UIImageView *favoriteButton;

-(void)populateFromTweet:(Tweet*)tweet;

@property (nonatomic, weak) id<TweetCellDelegate> delegate;

@end
