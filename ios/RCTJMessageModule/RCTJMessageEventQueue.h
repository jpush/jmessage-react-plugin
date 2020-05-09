//
//  RCTJMessageEventQueue.h
//  DoubleConversion
//
//  Created by wicked on 2019/9/26.
//

#import <Foundation/Foundation.h>
#import <JMessage/JMessage.h>

@interface RCTJMessageEventQueue : NSObject

+ (nonnull instancetype) sharedInstance;

@property (nonatomic, strong) JMSGConversation * offlineConversation;
@property (nonatomic, strong) NSArray * offlineMsgArray;
@end

