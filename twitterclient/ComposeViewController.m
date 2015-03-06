//
//  ComposeViewController.m
//  twitterclient
//
//  Created by Naeim Semsarilar on 3/5/15.
//  Copyright (c) 2015 naeim. All rights reserved.
//

#import "ComposeViewController.h"
#import "User.h"
#import "UIImageView+NSAdditions.h"
#import "TwitterClient.h"

@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) NSString* replyTweetId;
@property (strong, nonatomic) NSString* replyAuthorScreenName;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    User *currentUser = [User currentUser];
    
    [self.profileImageView fadeInImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:currentUser.profileImageUrl]] placeholderImage:nil];
    
    self.nameLabel.text = currentUser.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", currentUser.screenName];

    if (self.replyAuthorScreenName) {
        self.textView.text = [NSString stringWithFormat:@"@%@ ", self.replyAuthorScreenName];
    } else {
        self.textView.text = @"";
    }
    
    [self.textView becomeFirstResponder];
    
    // nav bar
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweet)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    
    self.navigationItem.title = @"";
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:107./255. green:179./255. blue:255./255. alpha:1];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)prepareForReplyWithTweetId:(NSString *)tweetId authorScreenName:(NSString *)authorScreenName {
    self.replyTweetId = tweetId;
    self.replyAuthorScreenName = authorScreenName;
}


- (void)onTweet {
    NSDictionary *params;
    
    if (self.replyTweetId) {
        params = @{@"status": self.textView.text,
                   @"in_reply_to_status_id": self.replyTweetId};
    } else {
        params = @{@"status": self.textView.text};
    }
    
    [[TwitterClient sharedInstance] addTweetWithParams:params completion:^(Tweet *tweet, NSError *error) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)onCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
