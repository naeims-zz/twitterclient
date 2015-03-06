//
//  DetailViewController.m
//  twitterclient
//
//  Created by Naeim Semsarilar on 3/5/15.
//  Copyright (c) 2015 naeim. All rights reserved.
//

#import "DetailViewController.h"
#import "TweetCell.h"
#import "TwitterClient.h"

@interface DetailViewController () <UITableViewDataSource, UITableViewDelegate, TweetCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 86;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    
    // nav bar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reply" style:UIBarButtonItemStylePlain target:self action:@selector(onReply)];
    
    self.navigationItem.title = @"Tweet";
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:107./255. green:179./255. blue:255./255. alpha:1];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onReply {
    [self.delegate detailReplyInvoked:self];
}

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    
    TweetCell *cell = (TweetCell *) [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    [cell populateFromTweet:tweet];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    
    [cell populateFromTweet:self.tweet];
    cell.delegate = self;
    
    return cell;
}

#pragma mark - Tweet Cell methods

-(void)replyInvoked:(TweetCell *)tweetCell {
    [self.delegate detailReplyInvoked:self];
}

-(void)favoriteInvoked:(TweetCell *)tweetCell {

    [self.delegate detailFavoriteInvoked:self];
}

-(void)retweetInvoked:(TweetCell *)tweetCell {
    [self.delegate detailRetweetInvoked:self];
}

@end
