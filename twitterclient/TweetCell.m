//
//  TweetCell.m
//  twitterclient
//
//  Created by Naeim Semsarilar on 3/3/15.
//  Copyright (c) 2015 naeim. All rights reserved.
//

#import "TweetCell.h"
#import "UIImageView+NSAdditions.h"
#import "NSDate+DateTools.h"

@interface TweetCell()

@end


@implementation TweetCell


- (void)awakeFromNib {
    self.tweetLabel.preferredMaxLayoutWidth = self.tweetLabel.frame.size.width;

    [self.retweetButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onRetweet:)]];
    [self.replyButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onReply:)]];
    [self.favoriteButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onFavorite:)]];
    
    // Initialization code
}

-(void)populateFromTweet:(Tweet*)tweet {
    self.tweetLabel.text = tweet.text;

    if (tweet.favorited) {
        self.favoriteButton.image = [UIImage imageNamed:@"favorite_on"];
    } else {
        self.favoriteButton.image = [UIImage imageNamed:@"favorite"];
    }
    
    if (tweet.retweeted) {
        self.retweetButton.image = [UIImage imageNamed:@"retweet_on"];
    } else {
        self.retweetButton.image = [UIImage imageNamed:@"retweet"];
    }
    
    self.authorLabel.text = tweet.author.name;
    self.authorHandleLabel.text = [NSString stringWithFormat:@"@%@", tweet.author.screenName];
    
    [self.profileImageView fadeInImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tweet.author.profileImageUrl]] placeholderImage:nil];
    
    self.timeLabel.text = tweet.createdAt.shortTimeAgoSinceNow;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.tweetLabel.preferredMaxLayoutWidth = self.tweetLabel.frame.size.width;
}

- (void)onReply:(UITapGestureRecognizer *)sender {
    [self.delegate replyInvoked:self];
}

- (void)onRetweet:(UITapGestureRecognizer *)sender {
    [self.delegate retweetInvoked:self];
}

- (void)onFavorite:(UITapGestureRecognizer *)sender {
    [self.delegate favoriteInvoked:self];
}
@end
