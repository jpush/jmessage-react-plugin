//
//  RCTJMessageModule.h
//  RCTJMessageModule
//
//  Created by oshumini on 2017/8/10.
//  Copyright © 2017年 HXHG. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JMessageHelper.h"

#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#elif __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#elif __has_include("React/RCTBridgeModule.h")
#import "React/RCTBridgeModule.h"
#endif


#define receiveMsgEvent @"JMessage.ReceiveMsgEvent" // 接收到消息事件
#define receiptMsgEvent @"JMessage.ReceiptMsgEvent" // 接收到已读消息回执事件
#define receiveChatRoomMsgEvent @"JMessage.ReceiveChatRoomMsgEvent" // 接收到消息事件
#define conversationChangeEvent @"JMessage.conversationChange" // 会话变更事件
#define loginStateChangedEvent @"JMessage.LoginStateChanged" // 登录状态变更通知
#define clickMessageNotificationEvent @"JMessage.ClickMessageNotification" // 点击推送 Android Only
#define syncOfflineMessageEvent @"JMessage.SyncOfflineMessage" // 同步离线消息事件
#define syncRoamingMessageEvent @"JMessage.SyncRoamingMessage" // 同步漫游消息事件
#define messageRetractEvent  @"JMessage.MessageRetract" // 消息撤回事件
#define contactNotifyEvent  @"JMessage.ContactNotify" // 收到好友请求消息事件
#define uploadProgressEvent @"JMessage.UploadProgress" // 上传进度

#define receiveApplyJoinGroupApprovalEvent  @"JMessage.ReceiveApplyJoinGroupApprovalEvent" // 接收入群申请事件
#define receiveGroupAdminRejectEvent @"JMessage.ReceiveGroupAdminRejectEvent" // 接收拒绝入群申请事件
#define receiveGroupAdminApprovalEvent @"JMessage.ReceiveGroupAdminApprovalEvent"


@interface RCTJMessageModule : NSObject<RCTBridgeModule>
@property(strong, nonatomic)NSDictionary *launchOptions;
@end
