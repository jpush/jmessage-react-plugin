//
//  RCTJMessageEventQueue.m
//  DoubleConversion
//
//  Created by wicked on 2019/9/26.
//

#import "RCTJMessageEventQueue.h"

@implementation RCTJMessageEventQueue

+ (instancetype)sharedInstance {
    static RCTJMessageEventQueue *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    return self;
}


@end
