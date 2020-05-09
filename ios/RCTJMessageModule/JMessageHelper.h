//
//  JMessageHelper.h
//  RCTJMessageModule
//
//  Created by oshumini on 2017/8/16.
//  Copyright © 2017年 HXHG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JMessage/JMessage.h>
#import "RCTJMessageEventQueue.h"

#define kJJMessageReceiveMessage     @"kJJMessageReceiveMessage"
#define kJJMessageReceiptMessage     @"kJJMessageReceiptMessage"
#define kJJMessageReceiveChatRoomMessage     @"kJJMessageReceiveChatRoomMessage"
#define kJJMessageSendMessageRespone @"kJJMessageSendMessageRespone"
#define kJJMessageTransparentEvent     @"kJJMessageTransparentEvent"

//Conversation 回调
#define kJJMessageConversationChanged @"kJJMessageConversationChanged"
#define kJJMessageUnreadChanged       @"kJJMessageUnreadChanged"

//离线消息
#define kJJMessageSyncOfflineMessage @"kJJMessageSyncOfflineMessage"

// 漫游消息同步

#define kJJMessageSyncRoamingMessage @"kJJMessageSyncRoamingMessage"

//Group 回调
#define kJJMessageGroupInfoChanged @"kJJMessageGroupInfoChanged"
#define kJJMessageReceiveApplyJoinGroupApproval @"kJJMessageReceiveApplyJoinGroupApproval"
#define kJJMessageReceiveGroupAdminReject @"kJJMessageReceiveGroupAdminReject"
#define kJMessageReceiveGroupAdminApproval @"kJMessageReceiveGroupAdminApproval"

//User 回调
#define kJJMessageLoginUserKicked  @"kJJMessageLoginUserKicked"
#define kJJMessageLoginStateChanged  @"kJJMessageLoginStateChanged"
#define kJJMessageContactNotify  @"kJJMessageContactNotify"
#define kJJMessageRetractMessage  @"kJJMessageretractMessage"

@interface JMessageHelper : NSObject<JMessageDelegate>
@property(nonatomic, strong)NSString *JMessageAppKey;
@property(strong,nonatomic)NSDictionary *launchOptions;
+ (JMessageHelper *)shareInstance;

-(void)initJMessage:(NSDictionary*)launchOptions;

@end


@interface NSArray (JMessage)
- (NSArray *)mapObjectsUsingBlock:(id (^)(id obj, NSUInteger idx))block;
@end

@interface NSDictionary (JMessage)
-(NSString*)toJsonString;
@end

@interface NSString (JMessage)
-(NSDictionary*)toDictionary;
@end

@interface JMSGConversation (JMessage)
-(NSMutableDictionary*)conversationToDictionary;
@end

@interface JMSGUser (JMessage)
-(NSMutableDictionary*)userToDictionary;
@end

@interface JMSGGroup (JMessage)
-(NSMutableDictionary*)groupToDictionary;
@end

@interface JMSGGroupInfo (JMessage)
-(NSMutableDictionary*)groupToDictionary;
@end

@interface JMSGGroupMemberInfo (JMessage)
- (NSMutableDictionary *)memberToDictionary;
@end

@interface JMSGMessage (JMessage)
- (NSMutableDictionary *)messageToDictionary;
@end

@interface NSError (JMessage)
- (NSDictionary *)errorToDictionary;
@end

@interface JMSGChatRoom (JMessage)
- (NSMutableDictionary *)chatRoomToDictionary;
@end

@interface JMSGApplyJoinGroupEvent (JMessage)
- (NSMutableDictionary *)eventToDictionary;
@end

@interface JMSGGroupAdminRejectApplicationEvent (JMessage)
- (NSMutableDictionary *)eventToDictionary;
@end

@interface JMSGGroupAdminApprovalEvent (JMessage)
- (NSMutableDictionary *)eventToDictionary;
@end

