//
//  TweetsViewController.m
//  twitterclient
//
//  Created by Naeim Semsarilar on 3/3/15.
//  Copyright (c) 2015 naeim. All rights reserved.
//

#import "TweetsViewController.h"
#import "User.h"
#import "Tweet.h"
#import "TwitterClient.h"
#import "TweetCell.h"
#import "DetailViewController.h"
#import "ComposeViewController.h"

@interface TweetsViewController () <UITableViewDataSource, UITableViewDelegate, TweetCellDelegate, DetailViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *tweets;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation TweetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 86;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    
    // refresh control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    [self.refreshControl removeConstraints:self.refreshControl.constraints];

    // nav bar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Compose" style:UIBarButtonItemStylePlain target:self action:@selector(onCompose)];
    
    self.navigationItem.title = @"Home";

    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:107./255. green:179./255. blue:255./255. alpha:1];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    // get some data
    [self onRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLogout {
    [User logout];
}

- (void)onCompose {
    ComposeViewController *vc = [[ComposeViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)onRefresh {
    [[TwitterClient sharedInstance] homeTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        self.tweets = tweets;
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - Table view methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.delegate = self;
    
    Tweet *tweet = self.tweets[indexPath.row];
    [cell populateFromTweet:tweet];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DetailViewController *vc = [[DetailViewController alloc] init];
    vc.delegate = self;
    vc.tweet = self.tweets[indexPath.row];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - Tweet Cell methods
-(void)replyInvoked:(TweetCell *)tweetCell {
    NSInteger row = [self.tableView indexPathForCell:tweetCell].row;

    Tweet *tweet = self.tweets[row];
    
    [self replyToTweet:tweet];
}

-(void)replyToTweet:(Tweet *)tweet {
    ComposeViewController *vc = [[ComposeViewController alloc] init];
    [vc prepareForReplyWithTweetId:tweet.tweetId authorScreenName:tweet.author.screenName];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

-(void)toggleFavorite:(Tweet*)tweet completion:(void (^)(Tweet *newTweet, NSError *error))completion {
    if(tweet.favorited) {
        [[TwitterClient sharedInstance] unsetFavoriteWithParams:@{@"id": tweet.tweetId} completion:^(Tweet *newTweet, NSError *error) {
            if (newTweet) {
                tweet.favorited = NO;
            }
            completion(newTweet, error);
        }];
    } else {
        [[TwitterClient sharedInstance] setFavoriteWithParams:@{@"id": tweet.tweetId} completion:^(Tweet *newTweet, NSError *error) {
            if (newTweet) {
                tweet.favorited = YES;
            }
            completion(newTweet, error);
        }];
    }
}

-(void)retweet:(Tweet*)tweet completion:(void (^)(Tweet *newTweet, NSError *error))completion {
    if (tweet.retweeted) {
        completion(nil, nil);
    } else {
        [[TwitterClient sharedInstance] retweetWithParams:nil tweetId:tweet.tweetId completion:^(Tweet *newTweet, NSError *error) {
            if (newTweet) {
                tweet.retweeted = YES;
                completion(newTweet, error);
            }
        }];
    }
}

-(void)favoriteInvoked:(TweetCell *)tweetCell {
    NSInteger row = [self.tableView indexPathForCell:tweetCell].row;
    
    [self toggleFavorite:self.tweets[row] completion:^(Tweet *newTweet, NSError *error) {
        if (newTweet) {
            [tweetCell populateFromTweet:newTweet];
        }
    }];
}

-(void)retweetInvoked:(TweetCell *)tweetCell {
    NSInteger row = [self.tableView indexPathForCell:tweetCell].row;
    [self retweet:self.tweets[row] completion:^(Tweet *newTweet, NSError *error) {
        if (newTweet) {
            [tweetCell populateFromTweet:self.tweets[row]];
        }
    }];
}

#pragma mark - Detail View Controller methods

-(NSInteger)getTweetRow:(Tweet*)tweet {
    return [self.tweets indexOfObject:tweet];
}

-(void)detailReplyInvoked:(DetailViewController *)detailViewController {
    [self replyToTweet:detailViewController.tweet];
}


-(void)detailFavoriteInvoked:(DetailViewController *)detailViewController {
    [self toggleFavorite:detailViewController.tweet completion:^(Tweet *newTweet, NSError *error) {
        if (!error) {
            
            [(TweetCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self getTweetRow:detailViewController.tweet] inSection:0]] populateFromTweet:detailViewController.tweet];
            
            detailViewController.tweet = detailViewController.tweet;
        }
    }];
}

-(void)detailRetweetInvoked:(DetailViewController *)detailViewController {
    [self retweet:detailViewController.tweet completion:^(Tweet *newTweet, NSError *error) {
        if (!error) {
            [(TweetCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self getTweetRow:detailViewController.tweet] inSection:0]] populateFromTweet:detailViewController.tweet];
            
            detailViewController.tweet = detailViewController.tweet;
        }
    }];
}

@end

