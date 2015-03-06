//
//  TwitterClient.m
//  twitterclient
//
//  Created by Naeim Semsarilar on 3/3/15.
//  Copyright (c) 2015 naeim. All rights reserved.
//

#import "TwitterClient.h"
#import "Tweet.h"

NSString * const kTwitterConsumerKey = @"1LtSMWZgOyUP9OCdrGjoSnfc7";
NSString * const kTwitterConsumerSecret = @"ca3BHAqaEuoPFv7v6Ghysy798cLWhZuOCIcLWOZmWAYMCamOHD";
NSString * const kTwitterBaseUrl = @"https://api.twitter.com";

@interface TwitterClient()

@property (nonatomic, strong) void (^loginCompletion)(User *user, NSError *error);

@end

@implementation TwitterClient

+ (TwitterClient *)sharedInstance {
    static TwitterClient *instance = nil;
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:kTwitterBaseUrl] consumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
        }
    });
    
    return instance;
}

-(void)loginWithCompletion:(void (^)(User *user, NSError *error))completion {
    self.loginCompletion = completion;
    
    
    [self.requestSerializer removeAccessToken];
    
    [self fetchRequestTokenWithPath:@"oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"cptwitterdemo://oauth"] scope:nil success:^(BDBOAuth1Credential *requestToken) {
        
        NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token ]];
        
        [[UIApplication sharedApplication] openURL:authURL];
        
    } failure:^(NSError *error) {
        NSLog(@"failed to get the request token!");
        self.loginCompletion(nil, error);
    }];

    
}

-(void)openURL:(NSURL *)url {
    [self fetchAccessTokenWithPath:@"oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query] success:^(BDBOAuth1Credential *accessToken) {
        
        [[TwitterClient sharedInstance].requestSerializer saveAccessToken:accessToken];
        
        [[TwitterClient sharedInstance] GET:@"1.1/account/verify_credentials.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            User *user = [[User alloc] initWithDictionary:responseObject];
            
            [User setCurrentUser:user];
            
            self.loginCompletion(user, nil);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"failed getting current user");
            
            self.loginCompletion(nil, error);
        }];
        
        
//        [[TwitterClient sharedInstance] GET:@"1.1/statuses/home_timeline.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            
//            NSArray *tweets = [Tweet tweetsWithArray:responseObject];
//            for (Tweet *tweet in tweets) {
//                NSLog(@"tweet: %@, created: %@, by: %@", tweet.text, tweet.createdAt, tweet.author.screenName);
//            }
//            
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"failed getting tweets");
//        }];
        
        
    } failure:^(NSError *error) {
        NSLog(@"failed to get the access token!");
        
        self.loginCompletion(nil, error);
    }];
}


-(void)homeTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/statuses/home_timeline.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        
        completion(tweets, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

-(void)setFavoriteWithParams:(NSDictionary *)params completion:(void (^)(Tweet *tweet, NSError *error))completion {
    [self POST:@"1.1/favorites/create.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        Tweet *tweet = [[Tweet alloc] initWithDictionary:responseObject];
        
        completion(tweet, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

-(void)unsetFavoriteWithParams:(NSDictionary *)params completion:(void (^)(Tweet *tweet, NSError *error))completion {
    [self POST:@"1.1/favorites/destroy.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        Tweet *tweet = [[Tweet alloc] initWithDictionary:responseObject];
        
        completion(tweet, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

-(void)retweetWithParams:(NSDictionary *)params tweetId:(NSString *)tweetId completion:(void (^)(Tweet *tweet, NSError *error))completion {
    [self POST:[NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", tweetId] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        Tweet *tweet = [[Tweet alloc] initWithDictionary:responseObject];
        
        completion(tweet, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

-(void)addTweetWithParams:(NSDictionary *)params completion:(void (^)(Tweet *tweet, NSError *error))completion {
    [self POST:@"1.1/statuses/update.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        Tweet *tweet = [[Tweet alloc] initWithDictionary:responseObject];
        
        completion(tweet, nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}



@end
