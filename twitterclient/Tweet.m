//
//  Tweet.m
//  twitterclient
//
//  Created by Naeim Semsarilar on 3/3/15.
//  Copyright (c) 2015 naeim. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

-(id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        
        NSLog(@"%@", dictionary);
        
        self.author = [[User alloc] initWithDictionary: dictionary[@"user"]];
        self.text = dictionary[@"text"];
        self.favorited = [dictionary[@"favorited"] boolValue];
        self.retweeted = [dictionary[@"retweeted"] boolValue];
        
        NSString *createdAtString = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        self.createdAt = [formatter dateFromString:createdAtString];
        
        self.tweetId = [dictionary[@"id"] stringValue];
        
    }
    return self;
}


+ (NSArray *)tweetsWithArray:(NSArray *)array {
    NSMutableArray *tweets = [NSMutableArray array];
    
    for (NSDictionary *dictionary in array) {
        [tweets addObject:[[Tweet alloc] initWithDictionary:dictionary]];
        
    }
    return tweets;
}

@end
