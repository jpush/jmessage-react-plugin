//
//  RCTJMessageModule.m
//  RCTJMessageModule
//
//  Created by oshumini on 2017/8/10.
//  Copyright © 2017年 HXHG. All rights reserved.
//

#import "RCTJMessageModule.h"

#if __has_include(<React/RCTBridge.h>)
#import <React/RCTEventDispatcher.h>
#import <React/RCTRootView.h>
#import <React/RCTBridge.h>
#elif __has_include("RCTBridge.h")
#import "RCTEventDispatcher.h"
#import "RCTRootView.h"
#import "RCTBridge.h"
#elif __has_include("React/RCTBridge.h")
#import "React/RCTEventDispatcher.h"
#import "React/RCTRootView.h"
#import "React/RCTBridge.h"
#endif

#import "JMessageHelper.h"
#import <JMessage/JMessage.h>
#import <AVFoundation/AVFoundation.h>

typedef void (^JMSGConversationCallback)(JMSGConversation *conversation,NSError *error);

@interface RCTJMessageModule ()<JMessageDelegate, JMSGEventDelegate, UIApplicationDelegate>

@property(strong,nonatomic)NSMutableDictionary *SendMsgCallbackDic;//{@"msgid": @"", @"RCTJMessageModule": @[successCallback, failCallback]}
@end

@implementation RCTJMessageModule
RCT_EXPORT_MODULE();
@synthesize bridge = _bridge;

+ (id)allocWithZone:(NSZone *)zone {
    static RCTJMessageModule *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

- (id)init {
    self = [super init];
    [self initNotifications];
    self.SendMsgCallbackDic = @{}.mutableCopy;
    return self;
}

- (void)setBridge:(RCTBridge *)bridge {
    _bridge = bridge;
    JMessageHelper.shareInstance.launchOptions = _bridge.launchOptions;
}

-(void)initNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self
                      selector:@selector(didReceiveJMessageMessage:)
                          name:kJJMessageReceiveMessage
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(didReceiptJMessageMessage:)
                          name:kJJMessageReceiptMessage
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(didReceiveJMessageChatRoomMessage:)
                          name:kJJMessageReceiveChatRoomMessage
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(conversationChanged:)
                          name:kJJMessageConversationChanged
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(didSendMessage:)
                          name:kJJMessageSendMessageRespone
                        object:nil];
    
    //  [defaultCenter addObserver:self
    //                    selector:@selector(unreadChanged:)
    //                        name:kJJMessageUnreadChanged
    //                      object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(loginStateChanged:)
                          name:kJJMessageLoginStateChanged
                        object:nil];
    // have
    [defaultCenter addObserver:self
                      selector:@selector(onContactNotify:)
                          name:kJJMessageContactNotify
                        object:nil];
    // have
    [defaultCenter addObserver:self
                      selector:@selector(didReceiveRetractMessage:)
                          name:kJJMessageRetractMessage
                        object:nil];
    
    // have
    [defaultCenter addObserver:self
                      selector:@selector(onSyncOfflineMessage:)
                          name:kJJMessageSyncOfflineMessage
                        object:nil];
    // have
    [defaultCenter addObserver:self
                      selector:@selector(onSyncRoamingMessage:)
                          name:kJJMessageSyncRoamingMessage
                        object:nil];
    
    
    //    group event
    
    [defaultCenter addObserver:self
                      selector:@selector(groupInfoChanged:)
                          name:kJJMessageGroupInfoChanged
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(didReceiveApplyJoinGroupApproval:)
                          name:kJJMessageReceiveApplyJoinGroupApproval
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(didReceiveGroupAdminReject:)
                          name:kJJMessageReceiveGroupAdminReject
                        object:nil];
    
    [defaultCenter addObserver:self
                      selector:@selector(didReceiveGroupAdminApproval:)
                          name:kJMessageReceiveGroupAdminApproval
                        object:nil];
}

- (void)getConversationWithDictionary:(NSDictionary *)param callback:(JMSGConversationCallback)callback {
    if (param[@"type"] == nil) {
        NSError *error = [NSError errorWithDomain:@"param error!" code: 1 userInfo: nil];
        callback(nil,error);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    JMSGConversationType conversationType = [self convertStringToConvsersationType:param[@"type"]];
    switch (conversationType) {
        case kJMSGConversationTypeSingle:{
            [JMSGConversation createSingleConversationWithUsername:param[@"username"]
                                                            appKey:appKey
                                                 completionHandler:^(id resultObject, NSError *error) {
                                                     if (error) {
                                                         callback(nil, error);
                                                         return;
                                                     }
                                                     
                                                     JMSGConversation *conversation = resultObject;
                                                     callback(conversation,nil);
                                                 }];
            break;
        }
        case kJMSGConversationTypeGroup:{
            [JMSGConversation createGroupConversationWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
                if (error) {
                    callback(nil, error);
                    return;
                }
                
                JMSGConversation *conversation = resultObject;
                callback(conversation,nil);
            }];
            break;
        }
        case kJMSGConversationTypeChatRoom:{
            [JMSGConversation createChatRoomConversationWithRoomId:param[@"roomId"] completionHandler:^(id resultObject, NSError *error) {
                if (error) {
                    callback(nil, error);
                    return;
                }
                
                JMSGConversation *conversation = resultObject;
                callback(conversation,nil);
            }];
            break;
        }
    }
}

- (JMSGMessage *)createMessageWithDictionary:(NSDictionary *)param type:(JMSGContentType)type {
    
    if (param[@"type"] == nil) {
        return nil;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    JMSGOptionalContent *messageSendingOptions = nil;
    if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
        messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
    }
    
    JMSGMessage *message = nil;
    JMSGAbstractContent *content = nil;
    switch (type) {
        case kJMSGContentTypeText:{
            content = [[JMSGTextContent alloc] initWithText:param[@"text"]];
            break;
        }
        case kJMSGContentTypeImage:{
            NSString *mediaPath = param[@"path"];
            if([[NSFileManager defaultManager] fileExistsAtPath: mediaPath]){
                mediaPath = mediaPath;
            } else {
                return nil;
            }
            content = [[JMSGImageContent alloc] initWithImageData: [NSData dataWithContentsOfFile: mediaPath]];
            JMSGImageContent *imgContent = content;
            imgContent.format = [mediaPath pathExtension];
            break;
        }
        case kJMSGContentTypeVoice:{
            NSString *mediaPath = param[@"path"];
            double duration = 0;
            if([[NSFileManager defaultManager] fileExistsAtPath: mediaPath]){
                mediaPath = mediaPath;
                
                NSError *error = nil;
                AVAudioPlayer *avAudioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:mediaPath] error: &error];
                if (error) {
                    return nil;
                }
                
                duration = avAudioPlayer.duration;
                avAudioPlayer = nil;
                
            } else {
                
                return nil;
            }
            content = [[JMSGVoiceContent alloc] initWithVoiceData:[NSData dataWithContentsOfFile: mediaPath] voiceDuration:@(duration)];
            break;
        }
        case kJMSGContentTypeLocation:{
            content = [[JMSGLocationContent alloc] initWithLatitude:param[@"latitude"] longitude:param[@"longitude"] scale:param[@"scale"] address: param[@"address"]];
            break;
        }
        case kJMSGContentTypeFile:{
            NSString *mediaPath = param[@"path"];
            if([[NSFileManager defaultManager] fileExistsAtPath: mediaPath]){
                mediaPath = mediaPath;
            } else {
                return nil;
            }
            
            NSString *fileName = @"";
            if (param[@"fileName"]) {
                fileName = param[@"fileName"];
            }
            
            content = [[JMSGFileContent alloc] initWithFileData:[NSData dataWithContentsOfFile: mediaPath] fileName: fileName];
            JMSGFileContent *fileContent = content;
            fileContent.format =[mediaPath pathExtension];
            break;
        }
        case kJMSGContentTypeCustom:{
            content = [[JMSGCustomContent alloc] initWithCustomDictionary: param[@"customObject"]];
            break;
        }
            
        default:
            return nil;
    }
    
    JMSGConversationType targetType = [self convertStringToConvsersationType:param[@"type"]];
    
    switch (targetType) {
        case kJMSGConversationTypeSingle:{
            message = [JMSGMessage createSingleMessageWithContent:content username:param[@"username"]];
            break;
        }
        case kJMSGConversationTypeGroup:{
            message = [JMSGMessage createGroupMessageWithContent:content groupId:param[@"groupId"]];
            break;
        }
            
        case kJMSGConversationTypeChatRoom:{
            message = [JMSGMessage createChatRoomMessageWithContent:content chatRoomId:param[@"roomId"]];
            break;
        }
    }
    
    if (message) {
        if (param[@"extras"] && [param[@"extras"] isKindOfClass: [NSDictionary class]]) {
            NSDictionary *extras = param[@"extras"];
            for (NSString *key in extras.allKeys) {
                [message.content addStringExtra:extras[key] forKey:key];
            }
        }
        return message;
    } else {
        return nil;
    }
}

- (JMSGContentType)convertStringToContentType:(NSString *)str {
    if ([str isEqualToString:@"text"]) {
        return kJMSGContentTypeText;
    }
    
    if ([str isEqualToString:@"image"]) {
        return kJMSGContentTypeImage;
    }
    
    if ([str isEqualToString:@"voice"]) {
        return kJMSGContentTypeVoice;
    }
    
    if ([str isEqualToString:@"location"]) {
        return kJMSGContentTypeLocation;
    }
    
    if ([str isEqualToString:@"file"]) {
        return kJMSGContentTypeFile;
    }
    
    if ([str isEqualToString:@"custom"]) {
        return kJMSGContentTypeCustom;
    }
    
    return kJMSGContentTypeUnknown;
}

- (JMSGConversationType)convertStringToConvsersationType:(NSString *)str {
    if ([str isEqualToString:@"group"]) {
        return kJMSGConversationTypeGroup;
    }
    
    if ([str isEqualToString:@"chatRoom"]) {
        return kJMSGConversationTypeChatRoom;
    }
    
    return kJMSGConversationTypeSingle;
}

- (JMSGGroupType)convertStringToGroupType:(NSString *)str {
    if (str == nil) {
        return kJMSGGroupTypePrivate;
    }
    
    if ([str isEqualToString:@"public"]) {
        return kJMSGGroupTypePublic;
    }
    
    return kJMSGGroupTypePrivate;
}

- (NSDictionary *)getParamError {
    return @{@"code": @(1), @"description": @"param error!"};
}

- (NSDictionary *)getErrorWithLog:(NSString *)log {
    return @{@"code": @(1), @"description": log};
}

- (NSDictionary *)getMediafileError {
    return @{@"code": @(2), @"description": @"media file not exit!"};
}

RCT_EXPORT_METHOD(setup:(NSDictionary *)param) {
    [[JMessageHelper shareInstance] initJMessage:param];
}

RCT_EXPORT_METHOD(setDebugMode:(NSDictionary *)param) {
    if (param[@"enable"]) {
        [JMessage setDebugMode];
    } else {
        [JMessage setLogOFF];
    }
}

#pragma mark IM - Notifications - begin
- (void)onSyncOfflineMessage: (NSNotification *) notification {
    [self.bridge.eventDispatcher sendAppEventWithName:syncOfflineMessageEvent body:notification.object];
}

- (void)onSyncRoamingMessage: (NSNotification *) notification {
    [self.bridge.eventDispatcher sendAppEventWithName:syncRoamingMessageEvent body:notification.object];
}

-(void)didSendMessage:(NSNotification *)notification {
    NSDictionary *response = notification.object;
    
    if (!response[@"message"]) {
        return;
    }
    
    NSDictionary *msgDic = response[@"message"];
    NSArray *callBacks = self.SendMsgCallbackDic[msgDic[@"id"]];
    if (response[@"error"] == nil) {
        RCTResponseSenderBlock successCallback = callBacks[0];
        successCallback(@[msgDic]);
    } else {
        NSError *error = response[@"error"];
        RCTResponseSenderBlock failCallback = callBacks[1];
        failCallback(@[@{@"code": @(error.code), @"description": [error description]}]);
    }
    [self.SendMsgCallbackDic removeObjectForKey:msgDic[@"id"]];
}

- (void)loginStateChanged:(NSNotification *)notification{
    [self.bridge.eventDispatcher sendAppEventWithName:loginStateChangedEvent body:notification.object];
}

- (void)onContactNotify:(NSNotification *)notification{
    [self.bridge.eventDispatcher sendAppEventWithName:contactNotifyEvent body:notification.object];
}

- (void)didReceiveRetractMessage:(NSNotification *)notification{
    [self.bridge.eventDispatcher sendAppEventWithName:messageRetractEvent body:notification.object];
}

//didReceiveJMessageMessage change name
- (void)didReceiveJMessageMessage:(NSNotification *)notification {
    [self.bridge.eventDispatcher sendAppEventWithName:receiveMsgEvent body:notification.object];
}

- (void)didReceiptJMessageMessage:(NSNotification *)notification {
    [self.bridge.eventDispatcher sendAppEventWithName:receiptMsgEvent body:notification.object];
}

- (void)didReceiveJMessageChatRoomMessage:(NSNotification *)notification {
    [self.bridge.eventDispatcher sendAppEventWithName:receiveChatRoomMsgEvent body:notification.object];
}


- (void)conversationChanged:(NSNotification *)notification {
    [self.bridge.eventDispatcher sendAppEventWithName:conversationChangeEvent body:notification.object];
}


- (void)groupInfoChanged:(NSNotification *)notification {
    // current not supported
}

- (void)didReceiveApplyJoinGroupApproval:(NSNotification *)notification {
    [self.bridge.eventDispatcher sendAppEventWithName:receiveApplyJoinGroupApprovalEvent body:notification.object];
}

- (void)didReceiveGroupAdminReject:(NSNotification *)notification {
    [self.bridge.eventDispatcher sendAppEventWithName:receiveGroupAdminRejectEvent body:notification.object];
}

- (void)didReceiveGroupAdminApproval:(NSNotification *)notification {
    [self.bridge.eventDispatcher sendAppEventWithName:receiveGroupAdminApprovalEvent body:notification.object];
}


#pragma mark IM - Notifications - end




//#pragma mark IM - User


RCT_EXPORT_METHOD(userRegister:(NSDictionary *)user
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    //  NSDictionary * user = [command argumentAtIndex:0];
    NSLog(@"username %@",user);
    
    [JMSGUser registerWithUsername: user[@"username"] password: user[@"password"] completionHandler:^(id resultObject, NSError *error) {
        if (!error) {
            successCallback(@[@{}]);
        } else {
            failCallback(@[[error errorToDictionary]]);
        }
    }];
}

RCT_EXPORT_METHOD(login:(NSDictionary *)user
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    [JMSGUser loginWithUsername:user[@"username"] password:user[@"password"] completionHandler:^(id resultObject, NSError *error) {
        if (!error) {
            JMSGUser *myInfo = [JMSGUser myInfo];
            [myInfo thumbAvatarData:^(NSData *data, NSString *objectId, NSError *error) {
                successCallback(@[@{}]);
            }];
        } else {
            failCallback(@[[error errorToDictionary]]);
        }
    }];
}

RCT_EXPORT_METHOD(logout) {
    [JMSGUser logout:^(id resultObject, NSError *error) {}];
}

RCT_EXPORT_METHOD(getMyInfo:(RCTResponseSenderBlock)successCallback) {
    JMSGUser *myInfo = [JMSGUser myInfo];
    if (myInfo.username == nil) {
        successCallback(@[@{}]);
    } else {
        successCallback(@[[myInfo userToDictionary]]);
    }
}

RCT_EXPORT_METHOD(getUserInfo:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    if (param[@"username"]) {
        [JMSGUser userInfoArrayWithUsernameArray:@[param[@"username"]] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
            if (!error) {
                NSArray *users = resultObject;
                JMSGUser *user = users[0];
                successCallback(@[[user userToDictionary]]);
            } else {
                failCallback(@[[error errorToDictionary]]);
            }
        }];
    } else {
        failCallback(@[[self getParamError]]);
        
    }
}

RCT_EXPORT_METHOD(updateMyPassword:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    if (param[@"oldPwd"] && param[@"newPwd"]) {
        [JMSGUser updateMyPasswordWithNewPassword:param[@"newPwd"] oldPassword:param[@"oldPwd"] completionHandler:^(id resultObject, NSError *error) {
            if (!error) {
                successCallback(@[@{}]);
            } else {
                failCallback(@[[error errorToDictionary]]);
            }
        }];
    } else {
        failCallback(@[[self getParamError]]);
    }
}


RCT_EXPORT_METHOD(updateMyAvatar:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    if (!param[@"imgPath"]) {
        failCallback(@[[self getParamError]]);
    }
    
    NSString *mediaPath = param[@"imgPath"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath: mediaPath]){
        mediaPath = mediaPath;
        NSData *img = [NSData dataWithContentsOfFile: mediaPath];
        
        [JMSGUser updateMyAvatarWithData:img avatarFormat:[mediaPath pathExtension] completionHandler:^(id resultObject, NSError *error) {
            if (!error) {
                successCallback(@[]);
            } else {
                failCallback(@[[error errorToDictionary]]);
            }
        }];
    } else {
        failCallback(@[[self getParamError]]);
    }
}

RCT_EXPORT_METHOD(updateMyInfo:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    JMSGUserInfo *info = [[JMSGUserInfo alloc] init];
    
    if (param[@"nickname"]) {
        info.nickname = param[@"nickname"];
    }
    
    if (param[@"birthday"]) {
        NSNumber *birthday = param[@"birthday"];
        info.birthday = birthday;
    }
    
    if (param[@"signature"]) {
        info.signature = param[@"signature"];
    }
    
    if (param[@"extras"]) {
        info.extras = param[@"extras"];
    }
    
    if (param[@"gender"]) {
        if ([param[@"gender"] isEqualToString:@"male"]) {
            info.gender = kJMSGUserGenderMale;
        }
        
        if ([param[@"gender"] isEqualToString:@"female"]) {
            info.gender = kJMSGUserGenderFemale;
        }
        
        if ([param[@"gender"] isEqualToString:@"unknow"]) {
            info.gender = kJMSGUserGenderUnknown;
        }
    }
    
    if (param[@"region"]) {
        info.region = param[@"region"];
    }
    
    if (param[@"address"]) {
        info.address = param[@"address"];
    }
    
    [JMSGUser updateMyInfoWithUserInfo:info completionHandler:^(id resultObject, NSError *error) {
        if (!error) {
            successCallback(@[]);
        } else {
            failCallback(@[[error errorToDictionary]]);
        }
    }];
}

- (JMSGOptionalContent *)convertDicToJMSGOptionalContent:(NSDictionary *)dic {
    JMSGCustomNotification *customNotification = [[JMSGCustomNotification alloc] init];
    JMSGOptionalContent *optionlContent = [[JMSGOptionalContent alloc] init];
    
    if(dic[@"isShowNotification"]) {
        NSNumber *isShowNotification = dic[@"isShowNotification"];
        optionlContent.noSaveNotification = ![isShowNotification boolValue];
    }
    
    if(dic[@"isRetainOffline"]) {
        NSNumber *isRetainOffline = dic[@"isRetainOffline"];
        optionlContent.noSaveOffline = ![isRetainOffline boolValue];
    }
    
    if(dic[@"isCustomNotificationEnabled"]) {
        NSNumber *isCustomNotificationEnabled = dic[@"isCustomNotificationEnabled"];
        customNotification.enabled= [isCustomNotificationEnabled boolValue];
    }
    
    if(dic[@"notificationTitle"]) {
        customNotification.title = dic[@"notificationTitle"];
    }
    
    if(dic[@"notificationText"]) {
        customNotification.alert = dic[@"notificationText"];
    }
    
    if(dic[@"needReadReceipt"]) {
        NSNumber *needRead = dic[@"needReadReceipt"];
        optionlContent.needReadReceipt = needRead.boolValue;
    }
    
    optionlContent.customNotification = customNotification;
    
    return optionlContent;
}


RCT_EXPORT_METHOD(sendTextMessage:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    JMSGOptionalContent *messageSendingOptions = nil;
    if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
        messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
    }
    
    JMSGMessage *message = [self createMessageWithDictionary:param type:kJMSGContentTypeText];
    
    if (!message) {
        NSError *error = [NSError errorWithDomain:@"cannot create message, check your params!" code:1 userInfo:nil];
        failCallback(@[[error errorToDictionary]]);
        return;
    }
    
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        self.SendMsgCallbackDic[message.msgId] = @[successCallback,failCallback];
        if (messageSendingOptions) {
            [conversation sendMessage:message optionalContent:messageSendingOptions];
        } else {
            [conversation sendMessage:message];
        }
    }];
    
}

RCT_EXPORT_METHOD(sendImageMessage:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    JMSGOptionalContent *messageSendingOptions = nil;
    if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
        messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
    }
    
    JMSGMessage *message = [self createMessageWithDictionary:param type:kJMSGContentTypeImage];
    
    if (!message) {
        NSError *error = [NSError errorWithDomain:@"cannot create message, check your params!" code:1 userInfo:nil];
        failCallback(@[[error errorToDictionary]]);
        return;
    }
    
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        self.SendMsgCallbackDic[message.msgId] = @[successCallback,failCallback];
        if (messageSendingOptions) {
            [conversation sendMessage:message optionalContent:messageSendingOptions];
        } else {
            [conversation sendMessage:message];
        }
    }];
}

RCT_EXPORT_METHOD(sendVoiceMessage:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    JMSGOptionalContent *messageSendingOptions = nil;
    if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
        messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
    }
    
    JMSGMessage *message = [self createMessageWithDictionary:param type:kJMSGContentTypeVoice];
    
    if (!message) {
        NSError *error = [NSError errorWithDomain:@"cannot create message, check your params!" code:1 userInfo:nil];
        failCallback(@[[error errorToDictionary]]);
        return;
    }
    
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        self.SendMsgCallbackDic[message.msgId] = @[successCallback,failCallback];
        if (messageSendingOptions) {
            [conversation sendMessage:message optionalContent:messageSendingOptions];
        } else {
            [conversation sendMessage:message];
        }
    }];
}

RCT_EXPORT_METHOD(sendCustomMessage:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    JMSGOptionalContent *messageSendingOptions = nil;
    if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
        messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
    }
    
    JMSGMessage *message = [self createMessageWithDictionary:param type:kJMSGContentTypeCustom];
    
    if (!message) {
        NSError *error = [NSError errorWithDomain:@"cannot create message, check your params!" code:1 userInfo:nil];
        failCallback(@[[error errorToDictionary]]);
        return;
    }
    
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        self.SendMsgCallbackDic[message.msgId] = @[successCallback,failCallback];
        if (messageSendingOptions) {
            [conversation sendMessage:message optionalContent:messageSendingOptions];
        } else {
            [conversation sendMessage:message];
        }
    }];
}

RCT_EXPORT_METHOD(sendLocationMessage:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    JMSGOptionalContent *messageSendingOptions = nil;
    if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
        messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
    }
    
    JMSGMessage *message = [self createMessageWithDictionary:param type:kJMSGContentTypeLocation];
    
    if (!message) {
        NSError *error = [NSError errorWithDomain:@"cannot create message, check your params!" code:1 userInfo:nil];
        failCallback(@[[error errorToDictionary]]);
        return;
    }
    
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        self.SendMsgCallbackDic[message.msgId] = @[successCallback,failCallback];
        if (messageSendingOptions) {
            [conversation sendMessage:message optionalContent:messageSendingOptions];
        } else {
            [conversation sendMessage:message];
        }
    }];
}

RCT_EXPORT_METHOD(sendFileMessage:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    JMSGOptionalContent *messageSendingOptions = nil;
    if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
        messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
    }
    
    JMSGMessage *message = [self createMessageWithDictionary:param type:kJMSGContentTypeFile];
    
    if (!message) {
        NSError *error = [NSError errorWithDomain:@"cannot create message, check your params!" code:1 userInfo:nil];
        failCallback(@[[error errorToDictionary]]);
        return;
    }
    
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        self.SendMsgCallbackDic[message.msgId] = @[successCallback,failCallback];
        if (messageSendingOptions) {
            [conversation sendMessage:message optionalContent:messageSendingOptions];
        } else {
            [conversation sendMessage:message];
        }
    }];
}

RCT_EXPORT_METHOD(getHistoryMessages:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    if (param[@"type"] == nil ||
        param[@"from"] == nil ||
        param[@"limit"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    BOOL isDescend = false;
    if (param[@"isDescend"]) {
        NSNumber *number = param[@"isDescend"];
        isDescend = [number boolValue];
    }
    
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        NSArray *messageArr = [conversation messageArrayFromNewestWithOffset:param[@"from"] limit:param[@"limit"]];
        NSArray *messageDicArr = [messageArr mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            JMSGMessage *message = obj;
            return [message messageToDictionary];
        }];
        
        if (!messageArr) {
            successCallback(@[@[]]);
            return;
        }
        
        if (isDescend) {
            messageDicArr = [[messageDicArr reverseObjectEnumerator] allObjects];
        }
        
        successCallback(@[messageDicArr]);
    }];
}

RCT_EXPORT_METHOD(sendInvitationRequest:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    if (param[@"username"] == nil ||
        param[@"reason"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGFriendManager sendInvitationRequestWithUsername:param[@"username"]
                                                  appKey:appKey
                                                  reason:param[@"reason"]
                                       completionHandler:^(id resultObject, NSError *error) {
                                           if (error) {
                                               failCallback(@[[error errorToDictionary]]);
                                               return;
                                           }
                                           successCallback(@[]);
                                       }];
}

RCT_EXPORT_METHOD(acceptInvitation:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    //  NSDictionary * param = [command argumentAtIndex:0];
    if (param[@"username"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGFriendManager acceptInvitationWithUsername:param[@"username"]
                                             appKey:appKey
                                  completionHandler:^(id resultObject, NSError *error) {
                                      if (error) {
                                          failCallback(@[[error errorToDictionary]]);
                                          return ;
                                      }
                                      successCallback(@[]);
                                  }];
}

RCT_EXPORT_METHOD(declineInvitation:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    if (param[@"username"] == nil ||
        param[@"reason"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    [JMSGFriendManager rejectInvitationWithUsername:param[@"username"]
                                             appKey:appKey
                                             reason:param[@"reason"]
                                  completionHandler:^(id resultObject, NSError *error) {
                                      if (error) {
                                          failCallback(@[[error errorToDictionary]]);
                                          return ;
                                      }
                                      successCallback(@[]);
                                  }];
}

RCT_EXPORT_METHOD(removeFromFriendList:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    if (param[@"username"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGFriendManager removeFriendWithUsername:param[@"username"] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        successCallback(@[]);
    }];
}

RCT_EXPORT_METHOD(updateFriendNoteName:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    if (param[@"username"] == nil ||
        param[@"noteName"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGUser userInfoArrayWithUsernameArray:@[param[@"username"]] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        
        NSArray *userArr = resultObject;
        if (userArr.count < 1) {
            failCallback(@[[self getErrorWithLog:@"cann't find user by usernaem"]]);
        } else {
            JMSGUser *user = resultObject[0];
            [user updateNoteName:param[@"noteName"] completionHandler:^(id resultObject, NSError *error) {
                if (error) {
                    failCallback(@[[error errorToDictionary]]);
                    return ;
                }
                successCallback(@[]);
            }];
        }
    }];
}

RCT_EXPORT_METHOD(updateFriendNoteText:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    if (param[@"username"] == nil ||
        param[@"noteText"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    [JMSGUser userInfoArrayWithUsernameArray:@[param[@"username"]] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        
        NSArray *userArr = resultObject;
        if (userArr.count < 1) {
            failCallback(@[[self getErrorWithLog:@"cann't find user by usernaem"]]);
        } else {
            JMSGUser *user = resultObject[0];
            
            [user updateNoteName:param[@"noteText"] completionHandler:^(id resultObject, NSError *error) {
                if (error) {
                    failCallback(@[[error errorToDictionary]]);
                    return ;
                }
                successCallback(@[]);
            }];
        }
    }];
}

RCT_EXPORT_METHOD(getFriends:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    [JMSGFriendManager getFriendList:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        
        NSArray *userList = resultObject;
        NSMutableArray *userDicList = @[].mutableCopy;
        for (JMSGUser *user in userList) {
            [userDicList addObject: [user userToDictionary]];
        }
        successCallback(@[userDicList]);
    }];
}

RCT_EXPORT_METHOD(createGroup:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    NSString *groupName = @"";
    NSString *descript = @"";
    
    if (param[@"name"] != nil) {
        groupName = param[@"name"];
    }
    
    if (param[@"desc"] != nil) {
        descript = param[@"desc"];
    }
    
    JMSGGroupType type = [self convertStringToGroupType:param[@"groupType"]] ;
    JMSGGroupInfo *groupInfo = [[JMSGGroupInfo alloc] init];
    groupInfo.name = groupName;
    groupInfo.groupType = type;
    groupInfo.desc = descript;
    
    [JMSGGroup createGroupWithGroupInfo:groupInfo memberArray:nil completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        
        JMSGGroup *group = resultObject;
        successCallback(@[group.gid]);
    }];
}

RCT_EXPORT_METHOD(getGroupIds:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    [JMSGGroup myGroupArray:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        
        NSArray *groudIdList = resultObject;
        successCallback(@[groudIdList]);
    }];
}

RCT_EXPORT_METHOD(getGroupInfo:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    if (param[@"id"] == nil) {
        failCallback(@[[self getParamError]]);
    }
    
    [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        
        JMSGGroup *group = resultObject;
        successCallback(@[[group groupToDictionary]]);
    }];
}

RCT_EXPORT_METHOD(updateGroupInfo:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    if (param[@"id"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    if (param[@"newName"] == nil && param[@"newDesc"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        
        JMSGGroup *group = resultObject;
        NSString *newName = group.displayName;
        NSString *newDesc = group.desc;
        
        if (param[@"newName"]) {
            newName = param[@"newName"];
        }
        
        if (param[@"newDesc"]) {
            newDesc = param[@"newDesc"];
        }
        
        [JMSGGroup updateGroupInfoWithGroupId:group.gid name:newName desc:newDesc completionHandler:^(id resultObject, NSError *error) {
            if (!error) {
                successCallback(@[]);
            } else {
                failCallback(@[[error errorToDictionary]]);
            }
        }];
    }];
}

RCT_EXPORT_METHOD(addGroupMembers:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    if (param[@"id"] == nil ||
        param[@"usernameArray"] == nil) {
        failCallback(@[[self getParamError]]);
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        
        JMSGGroup *group = resultObject;
        [group addMembersWithUsernameArray:param[@"usernameArray"] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
                return ;
            }
            
            successCallback(@[]);
        }];
    }];
}

RCT_EXPORT_METHOD(removeGroupMembers:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    //  NSDictionary * param = [command argumentAtIndex:0];
    if (param[@"id"] == nil ||
        param[@"usernameArray"] == nil) {
        failCallback(@[[self getParamError]]);
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        
        JMSGGroup *group = resultObject;
        [group removeMembersWithUsernameArray:param[@"usernameArray"] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
                return ;
            }
            successCallback(@[]);
        }];
    }];
}

RCT_EXPORT_METHOD(exitGroup:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    if (param[@"id"] == nil) {
        failCallback(@[[self getParamError]]);
    }
    
    [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        
        JMSGGroup *group = resultObject;
        [group exit:^(id resultObject, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
                return ;
            }
            successCallback(@[]);
        }];
    }];
}

RCT_EXPORT_METHOD(getGroupMembers:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    if (param[@"id"] == nil) {
        failCallback(@[[self getParamError]]);
    }
    
    [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        
        JMSGGroup *group = resultObject;
        
        [group memberInfoList:^(id resultObject, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
                return ;
            }
            
            NSArray *memberList = resultObject;
            NSMutableArray *memberInfoList = @[].mutableCopy;
            for (JMSGGroupMemberInfo *member in memberList) {
                [memberInfoList addObject:[member memberToDictionary]];
            }
            
            successCallback(@[memberInfoList]);
        }];
    }];
}

RCT_EXPORT_METHOD(addUsersToBlacklist:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    if (param[@"usernameArray"] == nil) {
        failCallback(@[[self getParamError]]);
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGUser addUsersToBlacklist:param[@"usernameArray"] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
        if (!error) {
            successCallback(@[]);
        } else {
            failCallback(@[[error errorToDictionary]]);
        }
    }];
}

RCT_EXPORT_METHOD(removeUsersFromBlacklist:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    if (param[@"usernameArray"] == nil) {
        failCallback(@[[self getParamError]]);
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    
    [JMSGUser delUsersFromBlacklist:param[@"usernameArray"] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
        if (!error) {
            successCallback(@[]);
        } else {
            failCallback(@[[error errorToDictionary]]);
        }
    }];
}

RCT_EXPORT_METHOD(getBlacklist:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    [JMessage blackList:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        
        NSArray *userList = resultObject;
        NSMutableArray *userDicList = @[].mutableCopy;
        for (JMSGUser *user in userList) {
            [userDicList addObject:[user userToDictionary]];
        }
        successCallback(@[userDicList]);
    }];
}

RCT_EXPORT_METHOD(setNoDisturb:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    NSNumber *isNoDisturb;
    if (param[@"type"] == nil ||
        param[@"isNoDisturb"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    isNoDisturb = param[@"isNoDisturb"];
    
    if ([param[@"type"] isEqualToString:@"single"]) {
        if (param[@"username"] == nil) {
            failCallback(@[[self getParamError]]);
            return;
        }
    } else {
        if ([param[@"type"] isEqualToString:@"group"]) {
            if (param[@"groupId"] == nil) {
                failCallback(@[[self getParamError]]);
                return;
            }
        } else {
            failCallback(@[[self getParamError]]);
            return;
        }
        
    }
    
    if ([param[@"type"] isEqualToString:@"single"]) {
        
        NSString *appKey = nil;
        if (param[@"appKey"]) {
            appKey = param[@"appKey"];
        } else {
            appKey = [JMessageHelper shareInstance].JMessageAppKey;
        }
        
        [JMSGUser userInfoArrayWithUsernameArray:@[param[@"username"]] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
                return ;
            }
            
            NSArray *userList = resultObject;
            if (userList.count < 1) {
                successCallback(@[]);
                return;
            }
            
            JMSGUser *user = userList[0];
            [user setIsNoDisturb:[isNoDisturb boolValue] handler:^(id resultObject, NSError *error) {
                if (error) {
                    failCallback(@[[error errorToDictionary]]);
                    return ;
                }
                successCallback(@[]);
            }];
        }];
    }
    
    if ([param[@"type"] isEqualToString:@"group"]) {
        [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
                return ;
            }
            
            JMSGGroup *group = resultObject;
            [group setIsNoDisturb:[isNoDisturb boolValue] handler:^(id resultObject, NSError *error) {
                if (error) {
                    failCallback(@[[error errorToDictionary]]);
                }
                
                successCallback(@[]);
            }];
        }];
    }
}

RCT_EXPORT_METHOD(getNoDisturbList:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    [JMessage noDisturbList:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        NSArray *disturberList = resultObject;
        NSMutableArray *userDicList = @[].mutableCopy;
        NSMutableArray *groupDicList = @[].mutableCopy;
        for (id disturber in disturberList) {
            if ([disturber isKindOfClass:[JMSGUser class]]) {
                
                [userDicList addObject:[disturber userToDictionary]];
            }
            
            if ([disturber isKindOfClass:[JMSGGroup class]]) {
                [groupDicList addObject:[disturber groupToDictionary]];
            }
        }
        successCallback(@[@{@"userInfos": userDicList, @"groupInfos": groupDicList}]);
    }];
}

RCT_EXPORT_METHOD(setNoDisturbGlobal:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    if (param[@"isNoDisturb"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    [JMessage setIsGlobalNoDisturb:[param[@"isNoDisturb"] boolValue] handler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        successCallback(@[]);
    }];
}

RCT_EXPORT_METHOD(isNoDisturbGlobal:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    BOOL isNodisturb = [JMessage isSetGlobalNoDisturb];
    successCallback(@[@{@"isNoDisturb": @(isNodisturb)}]);
}

RCT_EXPORT_METHOD(downloadThumbUserAvatar:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    if (param[@"username"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGUser userInfoArrayWithUsernameArray:@[param[@"username"]] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        
        NSArray *userList = resultObject;
        if (userList.count < 1) {
            successCallback(@[]);
            return;
        }
        
        JMSGUser *user = userList[0];
        [user thumbAvatarData:^(NSData *data, NSString *objectId, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
                return ;
            }
            
            successCallback(@[@{@"username": user.username,
                                @"appKey": user.appKey,
                                @"filePath": [user thumbAvatarLocalPath] ?: @""}]);
        }];
    }];
}

RCT_EXPORT_METHOD(downloadOriginalUserAvatar:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    if (param[@"username"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGUser userInfoArrayWithUsernameArray:@[param[@"username"]] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        
        NSArray *userList = resultObject;
        if (userList.count < 1) {
            successCallback(@[]);
            return;
        }
        
        JMSGUser *user = userList[0];
        [user largeAvatarData:^(NSData *data, NSString *objectId, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
                return ;
            }
            
            successCallback(@[@{@"username": user.username,
                                @"appKey": user.appKey ?: @"",
                                @"filePath": [user largeAvatarLocalPath] ?: @""}]);
        }];
    }];
    
}

RCT_EXPORT_METHOD(downloadOriginalImage:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    if (param[@"messageId"] == nil ||
        param[@"type"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    if ([param[@"type"] isEqual: @"single"] && param[@"username"] != nil) {
        
    } else {
        if ([param[@"type"] isEqual: @"group"] && param[@"groupId"] != nil) {
        } else {
            failCallback(@[[self getParamError]]);
            return;
        }
    }
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGMessage *message = [conversation messageWithMessageId:param[@"messageId"]];
        if (message == nil) {
            failCallback(@[[self getErrorWithLog:@"cann't find this message"]]);
            return;
        }
        
        if (message.contentType != kJMSGContentTypeImage) {
            failCallback(@[[self getErrorWithLog:@"It is not voice message"]]);
            return;
        } else {
            JMSGImageContent *content = (JMSGImageContent *) message.content;
            [content largeImageDataWithProgress:^(float percent, NSString *msgId) {
                
            } completionHandler:^(NSData *data, NSString *objectId, NSError *error) {
                if (error) {
                    failCallback(@[[error errorToDictionary]]);
                    return;
                }
                
                JMSGMediaAbstractContent *mediaContent = (JMSGMediaAbstractContent *) message.content;
                successCallback(@[@{@"messageId": message.msgId,
                                    @"filePath": [mediaContent originMediaLocalPath] ?: @""}]);
            }];
        }
    }];
}

RCT_EXPORT_METHOD(downloadThumbImage:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    if (param[@"messageId"] == nil ||
        param[@"type"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    if ([param[@"type"] isEqual: @"single"] && param[@"username"] != nil) {
        
    } else {
        if ([param[@"type"] isEqual: @"group"] && param[@"groupId"] != nil) {
        } else {
            failCallback(@[[self getParamError]]);
            return;
        }
    }
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGMessage *message = [conversation messageWithMessageId:param[@"messageId"]];
        if (message == nil) {
            failCallback(@[[self getErrorWithLog:@"cann't find this message"]]);
            return;
        }
        
        if (message.contentType != kJMSGContentTypeImage) {
            failCallback(@[[self getErrorWithLog:@"It is not voice message"]]);
            return;
        } else {
            JMSGImageContent *content = (JMSGImageContent *) message.content;
            [content thumbImageData:^(NSData *data, NSString *objectId, NSError *error) {
                if (error) {
                    failCallback(@[[error errorToDictionary]]);
                    return;
                }
                
                JMSGMediaAbstractContent *mediaContent = (JMSGMediaAbstractContent *) message.content;
                successCallback(@[@{@"messageId": message.msgId,
                                    @"filePath": [content thumbImageLocalPath] ?: @""}]);
            }];
        }
    }];
}

RCT_EXPORT_METHOD(downloadVoiceFile:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    if (param[@"messageId"] == nil ||
        param[@"type"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    if ([param[@"type"] isEqual: @"single"] && param[@"username"] != nil) {
        
    } else {
        if ([param[@"type"] isEqual: @"group"] && param[@"groupId"] != nil) {
            
        } else {
            failCallback(@[[self getParamError]]);
            return;
        }
    }
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGMessage *message = [conversation messageWithMessageId:param[@"messageId"]];
        
        if (message == nil) {
            failCallback(@[[self getErrorWithLog:@"cann't find this message"]]);
            return;
        }
        
        if (message.contentType != kJMSGContentTypeVoice) {
            failCallback(@[[self getErrorWithLog:@"It is not image message"]]);
            return;
        } else {
            JMSGVoiceContent *content = (JMSGVoiceContent *) message.content;
            [content voiceData:^(NSData *data, NSString *objectId, NSError *error) {
                if (error) {
                    failCallback(@[[error errorToDictionary]]);
                    return;
                }
                
                JMSGMediaAbstractContent *mediaContent = (JMSGMediaAbstractContent *) message.content;
                successCallback(@[@{@"messageId": message.msgId,
                                    @"filePath": [mediaContent originMediaLocalPath] ?: @""}]);
            }];
        }
    }];
}

RCT_EXPORT_METHOD(downloadFile:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    if (param[@"messageId"] == nil ||
        param[@"type"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    if ([param[@"type"] isEqual: @"single"] && param[@"username"] != nil) {
        
    } else {
        if ([param[@"type"] isEqual: @"group"] && param[@"groupId"] != nil) {
            
        } else {
            failCallback(@[[self getParamError]]);
            return;
        }
    }
    
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGMessage *message = [conversation messageWithMessageId:param[@"messageId"]];
        
        if (message == nil) {
            failCallback(@[[self getErrorWithLog:@"cann't find this message"]]);
            return;
        }
        
        if (message.contentType != kJMSGContentTypeFile) {
            failCallback(@[[self getErrorWithLog:@"It is not file message"]]);
            return;
        } else {
            JMSGFileContent *content = (JMSGFileContent *) message.content;
            [content fileData:^(NSData *data, NSString *objectId, NSError *error) {
                if (error) {
                    failCallback(@[[error errorToDictionary]]);
                    return;
                }
                JMSGFileContent *fileContent = (JMSGFileContent *) message.content;
                successCallback(@[@{@"messageId": message.msgId,
                                    @"filePath":[fileContent originMediaLocalPath] ?: @"" }]);
            }];
        }
    }];
}

RCT_EXPORT_METHOD(createConversation:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        successCallback(@[[conversation conversationToDictionary]]);
    }];
}

RCT_EXPORT_METHOD(deleteConversation:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    if (param[@"type"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    if (([param[@"type"] isEqual: @"single"] && param[@"username"] != nil) ||
        ([param[@"type"] isEqual: @"group"] && param[@"groupId"] != nil)   ||
        ([param[@"type"] isEqual: @"chatRoom"] && param[@"roomId"] != nil)) {
        
    } else {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    JMSGConversationType type =  [self convertStringToConvsersationType:param[@"type"]];
    switch (type) {
        case kJMSGConversationTypeSingle: {
            [JMSGConversation deleteSingleConversationWithUsername:param[@"username"] appKey:appKey];
            break;
        }
        case kJMSGConversationTypeGroup: {
            [JMSGConversation deleteGroupConversationWithGroupId:param[@"groupId"]];
            break;
        }
        case kJMSGConversationTypeChatRoom: {
            [JMSGConversation deleteChatRoomConversationWithRoomId:param[@"roomId"]];
            break;
        }
    }
    
    successCallback(@[]);
}

RCT_EXPORT_METHOD(getConversation:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        successCallback(@[[conversation conversationToDictionary]]);
    }];
}

RCT_EXPORT_METHOD(getConversations:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    [JMSGConversation allConversations:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        NSArray *conversationList = resultObject;
        NSMutableArray *conversationDicList = @[].mutableCopy;
        
        if (conversationList.count < 1) {
            successCallback(@[@[]]);
        } else {
            for (JMSGConversation *conversation in conversationList) {
                [conversationDicList addObject:[conversation conversationToDictionary]];
            }
            successCallback(@[conversationDicList]);
        }
    }];
}

RCT_EXPORT_METHOD(resetUnreadMessageCount:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        [conversation clearUnreadCount];
        successCallback(@[]);
    }];
}

RCT_EXPORT_METHOD(retractMessage:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallback:(RCTResponseSenderBlock)failCallback) {
    
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGMessage *message = [conversation messageWithMessageId:param[@"messageId"]];
        if (message == nil) {
            failCallback(@[[self getErrorWithLog:@"cann't found this message"]]);
            return;
        }
        
        [conversation retractMessage:message completionHandler:^(id resultObject, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
                return;
            }
            
            successCallback(@[]);
        }];
    }];
}

RCT_EXPORT_METHOD(createSendMessage:(NSDictionary *)param
                  callback:(RCTResponseSenderBlock)callback) {
    
    if (!param[@"type"]) {
        callback(@[]);
        return;
    }
    
    NSString *mediaPath = @"";
    if ([param[@"messageType"] isEqualToString:@"image"] ||
        [param[@"messageType"] isEqualToString:@"voice"] ||
        [param[@"messageType"] isEqualToString:@"file"]) {
        mediaPath = param[@"path"];
        if([[NSFileManager defaultManager] fileExistsAtPath: mediaPath]){
            mediaPath = mediaPath;
        } else {
            callback(@[[self getMediafileError]]);//TODO: fix
        }
    }
    
    JMSGAbstractContent *content = nil;
    if ([param[@"messageType"] isEqualToString:@"text"]) {
        content = [[JMSGTextContent alloc] initWithText:param[@"text"]];
    }
    
    if ([param[@"messageType"] isEqualToString:@"image"]) {
        JMSGImageContent *imgContent = [[JMSGImageContent alloc] initWithImageData: [NSData dataWithContentsOfFile: mediaPath]];
        imgContent.format = [mediaPath pathExtension];
        content = imgContent;
    }
    
    if ([param[@"messageType"] isEqualToString:@"voice"]) {
        double duration = 0;
        if([[NSFileManager defaultManager] fileExistsAtPath: mediaPath]) {
            mediaPath = mediaPath;
            
            NSError *error = nil;
            AVAudioPlayer *avAudioPlayer = [[AVAudioPlayer alloc] initWithData:[NSData dataWithContentsOfFile:mediaPath] error: &error];
            if (error) {
                callback(@[[self getMediafileError]]);
                return;
            }
            
            duration = avAudioPlayer.duration;
            avAudioPlayer = nil;
            
        } else {
            callback(@[[self getMediafileError]]);
            return;
        }
        
        content = [[JMSGVoiceContent alloc] initWithVoiceData:[NSData dataWithContentsOfFile: mediaPath] voiceDuration:@(duration)];
        
        
    }
    
    if ([param[@"messageType"] isEqualToString:@"location"]) {
        
        
        content = [[JMSGLocationContent alloc] initWithLatitude:param[@"latitude"]
                                                      longitude:param[@"longitude"]
                                                          scale:param[@"scale"]
                                                        address:param[@"address"]];
        
        
    }
    
    if ([param[@"messageType"] isEqualToString:@"file"]) {
        
        content = [[JMSGFileContent alloc] initWithFileData:[NSData dataWithContentsOfFile: mediaPath]
                                                   fileName: param[@"fileName"]];
        ((JMSGFileContent *)content).format = [mediaPath pathExtension];
        
    }
    
    if ([param[@"messageType"] isEqualToString:@"custom"]) {
        content = [[JMSGCustomContent alloc] initWithCustomDictionary: param[@"customObject"]];
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            callback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGMessage *message = [conversation createMessageWithContent:content];
        if (param[@"extras"] && [param[@"extras"] isKindOfClass: [NSDictionary class]]) {
            NSDictionary *extras = param[@"extras"];
            for (NSString *key in extras.allKeys) {
                [message.content addStringExtra:extras[key] forKey:key];
            }
        }
        callback(@[[message messageToDictionary]]);
    }];
}

RCT_EXPORT_METHOD(sendMessage:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGMessage *message = [conversation messageWithMessageId: param[@"id"]];
        
        if (!message) {
            failCallback(@[[self getErrorWithLog:@"cann't find the message from this id"]]);
            return;
        }
        
        if ([message.content isKindOfClass:[JMSGMediaAbstractContent class]]) {
            JMSGMediaAbstractContent *content = (JMSGMediaAbstractContent *)message.content;
            content.uploadHandler = ^(float percent, NSString *msgID) {
                
                [self.bridge.eventDispatcher sendAppEventWithName:uploadProgressEvent body:@{@"messageId": msgID,
                                                                                             @"progress": @(percent)}];
            };
        }
        
        JMSGOptionalContent *messageSendingOptions = nil;
        if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
            messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
        }
        
        self.SendMsgCallbackDic[message.msgId] = @[successCallback,failCallback];
        
        if (param[@"extras"] && [param[@"extras"] isKindOfClass: [NSDictionary class]]) {
            NSDictionary *extras = param[@"extras"];
            for (NSString *key in extras.allKeys) {
                [message.content addStringExtra:extras[key] forKey:key];
            }
        }
        
        if (messageSendingOptions) {
            [conversation sendMessage:message optionalContent:messageSendingOptions];
        } else {
            [conversation sendMessage:message];
        }
    }];
}

RCT_EXPORT_METHOD(forwardMessage:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGMessage *message = [conversation messageWithMessageId: param[@"id"]];
        
        if ([message.content isKindOfClass:[JMSGMediaAbstractContent class]]) {
            JMSGMediaAbstractContent *content = (JMSGMediaAbstractContent *)message.content;
            content.uploadHandler = ^(float percent, NSString *msgID) {
                
                [self.bridge.eventDispatcher sendAppEventWithName:uploadProgressEvent body:@{@"messageId": msgID,
                                                                                             @"progress": @(percent)}];
            };
        }
        
        JMSGOptionalContent *messageSendingOptions = nil;
        if (param[@"messageSendingOptions"] && [param[@"messageSendingOptions"] isKindOfClass: [NSDictionary class]]) {
            messageSendingOptions = [self convertDicToJMSGOptionalContent:param[@"messageSendingOptions"]];
        }
        
        NSDictionary *target = nil;
        if (param[@"target"]) {
            target = param[@""];
        } else {
            failCallback(@[[self getParamError]]);
            return;
        }
        
        if ([target[@"type"] isEqualToString:@"chatRoom"]) {
            failCallback(@[[self getErrorWithLog:@"cann't forward message to chat room"]]);
            return;
        }
        
        if ([target[@"type"] isEqualToString:@"group"]) {
            [JMSGGroup groupInfoWithGroupId:target[@"id"] completionHandler:^(id resultObject, NSError *error) {
                if (error) {
                    failCallback(@[[error errorToDictionary]]);
                    return ;
                }
                JMSGGroup *group = resultObject;
                [JMSGMessage forwardMessage:message target:group optionalContent:messageSendingOptions];
            }];
        } else {
            NSString *targetAppkey = nil;
            if (target[@"appKey"]) {
                targetAppkey = target[@"appKey"];
            }
            [JMSGUser userInfoArrayWithUsernameArray:@[target[@"user"]] appKey:targetAppkey completionHandler:^(id resultObject, NSError *error) {
                if (error) {
                    failCallback(@[[error errorToDictionary]]);
                    return ;
                }
                
                NSArray *userArr = resultObject;
                if (userArr.count < 1) {
                    failCallback(@[[self getErrorWithLog:@"cann't find user by usernaem"]]);
                } else {
                    JMSGUser *user = resultObject[0];
                    [JMSGMessage forwardMessage:message target:user optionalContent:messageSendingOptions];
                }
            }];
        }
    }];
    
}

RCT_EXPORT_METHOD(blockGroupMessage:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    
    if (!param[@"id"] || !param[@"isBlock"]) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSNumber *isBlock = param[@"isBlock"];
    
    [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGGroup *group = resultObject;
        [group setIsShield:[isBlock boolValue] handler:^(id resultObject, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
            } else {
                successCallback(@[]);
            }
        }];
    }];
}

RCT_EXPORT_METHOD(isGroupBlocked:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    
    if (!param[@"id"]) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGGroup *group = resultObject;
        successCallback(@[@{@"isBlocked": @(group.isShieldMessage)}]);
    }];
}

RCT_EXPORT_METHOD(getBlockedGroupList:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    [JMSGGroup shieldList:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
        }
        
        NSArray *groupArr = resultObject;
        NSMutableArray *groupList = @[].mutableCopy;
        
        for (JMSGGroup *group in groupArr) {
            [groupList addObject:[group groupToDictionary]];
        }
        
        successCallback(@[groupList]);
    }];
}

RCT_EXPORT_METHOD(updateGroupAvatar:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    
    if (!param[@"id"]) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *mediaPath = param[@"imgPath"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath: mediaPath]){
        mediaPath = mediaPath;
        NSData *img = [NSData dataWithContentsOfFile: mediaPath];
        
        [JMSGGroup updateGroupAvatarWithGroupId:param[@"id"] avatarData:img avatarFormat:[mediaPath pathExtension] completionHandler:^(id resultObject, NSError *error) {
            if (!error) {
                successCallback(@[]);
            } else {
                failCallback(@[[error errorToDictionary]]);
            }
        }];
    } else {
        failCallback(@[[self getParamError]]);
    }
}

RCT_EXPORT_METHOD(downloadThumbGroupAvatar:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    
    if (!param[@"id"]) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        
        JMSGGroup *group = resultObject;
        [group thumbAvatarData:^(NSData *data, NSString *objectId, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
                return ;
            }
            
            successCallback(@[@{@"id": objectId, @"filePath": group.thumbAvatarLocalPath ?: @""}]);
        }];
    }];
}

RCT_EXPORT_METHOD(downloadOriginalGroupAvatar:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    if (!param[@"id"]) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    [JMSGGroup groupInfoWithGroupId:param[@"id"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return ;
        }
        
        JMSGGroup *group = resultObject;
        [group largeAvatarData:^(NSData *data, NSString *objectId, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
                return ;
            }
            
            successCallback(@[@{@"id": objectId, @"filePath": group.largeAvatarLocalPath  ?: @""}]);
        }];
    }];
}


RCT_EXPORT_METHOD(setConversationExtras:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    
    if (!param[@"type"]) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    if (!param[@"extras"]) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        NSDictionary *extras = param[@"extras"];
        for (NSString *key in extras) {
            [conversation setExtraValue:extras[key] forKey:key];
        }
        successCallback(@[[conversation conversationToDictionary]]);
    }];
}



/**
 * 查询当前 AppKey 下的聊天室信息
 * @param {object} param = {
 *  "start": number,  // 起始位置
 *  "count": number,  // 获取个数
 * }
 * ChatRoomInfo = {
 *  "roomId": String,
 *  "roomName": String,
 *  "appKey": String,
 *  "maxMemberCount": number,
 *  "totalMemberCount": number,
 *  "owner": UserInfo,
 *  "description": String,
 *  "createTime": number,
 * }
 * @param {function} success = function([{chatRoomInfo}])
 * @param {function} error = function ({'code': '错误码', 'description': '错误信息'}) {}
 */
//static getChatRoomListByApp(param, success, error) {
RCT_EXPORT_METHOD(getChatRoomListByApp:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    NSNumber *start = nil;
    NSNumber *count = nil;
    if (!param[@"start"]) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    if (!param[@"count"]) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    start = param[@"start"];
    count = param[@"count"];
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGChatRoom getChatRoomListWithAppKey:appKey start:[start integerValue] count:[count integerValue] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        NSArray *chatRoomArr = resultObject;
        NSArray *chatRoomDicArr = [chatRoomArr mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            JMSGChatRoom *chatRoom = obj;
            return [chatRoom chatRoomToDictionary];
        }];
        
        successCallback(@[chatRoomDicArr]);
    }];
}

/**
 * 获取当前用户所加入的所有聊天室信息
 * @param {function} success = function([{ChatRoomInfo}])
 * @param {function} error = function ({'code': '错误码', 'description': '错误信息'}) {}
 */
//static getChatRoomListByUser(success, error) {
RCT_EXPORT_METHOD(getChatRoomListByUser:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    [JMSGChatRoom getMyChatRoomListCompletionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        NSArray *chatRoomArr = resultObject;
        NSArray *chatRoomDicArr = [chatRoomArr mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            JMSGChatRoom *chatRoom = obj;
            return [chatRoom chatRoomToDictionary];
        }];
        successCallback(@[chatRoomDicArr]);
    }];
    
}

/**
 * 查询指定 roomId 聊天室信息
 * @param {Array} param = [String]
 * @param {function} success = function([{ChatRoomInfo}])
 * @param {function} error = function ({'code': '错误码', 'description': '错误信息'}) {}
 */
//static getChatRoomInfos(param, success, error) {
RCT_EXPORT_METHOD(getChatRoomInfos:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    if (!param[@"roomIds"]) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    [JMSGChatRoom getChatRoomInfosWithRoomIds:param[@"roomIds"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        NSArray *chatRoomArr = resultObject;
        NSArray *chatRoomDicArr = [chatRoomArr mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            JMSGChatRoom *chatRoom = obj;
            return [chatRoom chatRoomToDictionary];
        }];
        
        successCallback(@[chatRoomDicArr]);
    }];
}

/**
 * 进入聊天室，进入后才能收到聊天室信息及发言
 * @param {String} roomId
 * @param {function} success = function({conversation})
 * @param {function} error = function ({'code': '错误码', 'description': '错误信息'}) {}
 */
//static enterChatRoom(roomId, success, error) {
RCT_EXPORT_METHOD(enterChatRoom:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    if (!param[@"roomId"]) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    [JMSGChatRoom enterChatRoomWithRoomId:param[@"roomId"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGConversation *conversation = resultObject;
        successCallback(@[[conversation conversationToDictionary]]);
    }];
}

/**
 * 离开聊天室
 * @param {String} roomId
 * @param {function} success = function(0)
 * @param {function} error = function ({'code': '错误码', 'description': '错误信息'}) {}
 */
//static leaveChatRoom(roomId, success, error) {
RCT_EXPORT_METHOD(leaveChatRoom:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    if (!param[@"roomId"]) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    [JMSGChatRoom leaveChatRoomWithRoomId:param[@"roomId"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        successCallback(@[]);
    }];
}

/**
 * 从本地获取用户的聊天室会话列表，没有则返回为空的列表
 * @param {function} callback = function([{Conversation}])
 *
 */
//static getChatRoomConversationList(callback) {
RCT_EXPORT_METHOD(getChatRoomConversationList:(RCTResponseSenderBlock)successCallback) {
    [JMSGConversation allChatRoomConversation:^(id resultObject, NSError *error) {
        if (error) {
            successCallback(@[@[]]);
            return;
        }
        
        NSArray *conversationArr = resultObject;
        NSArray *conversationDicArr = [conversationArr mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            JMSGConversation *conversation = obj;
            return [conversation conversationToDictionary];
        }];
        successCallback(@[conversationDicArr]);
    }];
}

RCT_EXPORT_METHOD(getChatRoomOwner:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    if (!param[@"roomId"]) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    [JMSGChatRoom getChatRoomInfosWithRoomIds:@[param[@"roomId"]] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        NSArray *chatRoomArr = resultObject;
        if (chatRoomArr == nil || chatRoomArr.count == 0) {
            failCallback(@[[self getErrorWithLog:@"cann't found chat room from this roomId!"]]);
            return;
        }
        JMSGChatRoom *chatRoom = chatRoomArr[0];
        [chatRoom getChatRoomOwnerInfo:^(id resultObject, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
                return;
            }
            JMSGUser *user = resultObject;
            successCallback(@[[user userToDictionary]]);
        }];
    }];
}

RCT_EXPORT_METHOD(setBadge:(NSInteger)value callback:(RCTResponseSenderBlock)callback) {// ->Bool
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:value];
    NSNumber *badgeNumber = [NSNumber numberWithBool:[JMessage setBadge: value]];
    callback(@[badgeNumber]);
}

RCT_EXPORT_METHOD(getAllUnreadCount:(RCTResponseSenderBlock)callback) {
    callback(@[[JMSGConversation getAllUnreadCount]]);
}

RCT_EXPORT_METHOD(addGroupAdmins:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    if (param[@"groupId"] == nil ||
        param[@"usernames"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGGroup *group = resultObject;
        [group addGroupAdminWithUsernames:param[@"usernames"] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
                return;
            }
            successCallback(@[]);
        }];
    }];
    
}

RCT_EXPORT_METHOD(removeGroupAdmins:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    if (param[@"groupId"] == nil ||
        param[@"usernames"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGGroup *group = resultObject;
        [group deleteGroupAdminWithUsernames:param[@"usernames"] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
                return;
            }
            successCallback(@[]);
        }];
    }];
}

RCT_EXPORT_METHOD(changeGroupType:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    if (param[@"groupId"] == nil ||
        param[@"type"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGGroup *group = resultObject;
        JMSGGroupType type = [self convertStringToGroupType:param[@"type"]];
        [group changeGroupType:type handler:^(id resultObject, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
                return;
            }
            successCallback(@[]);
        }];
    }];
}

RCT_EXPORT_METHOD(getPublicGroupInfos:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    if (param[@"start"] == nil ||
        param[@"count"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGGroup getPublicGroupInfoWithAppKey:appKey start:[param[@"start"] integerValue] count:[param[@"count"] integerValue] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        NSArray *groupInfoArr = resultObject;
        NSArray *groupDicArr = [groupInfoArr mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            JMSGGroupInfo *groupInfo = obj;
            return [groupInfo groupToDictionary];
        }];
        successCallback(@[groupDicArr]);
    }];
}

RCT_EXPORT_METHOD(applyJoinGroup:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    if (param[@"groupId"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    [JMSGGroup applyJoinGroupWithGid:param[@"groupId"] reason:param[@"reason"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        successCallback(@[]);
    }];
}

RCT_EXPORT_METHOD(processApplyJoinGroup:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    if (param[@"events"] == nil ||
        param[@"isAgree"] == nil ||
        param[@"isRespondInviter"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    [JMSGGroup processApplyJoinGroupEvents:param[@"events"]
                                   isAgree:[param[@"isAgree"] boolValue]
                                    reason:param[@"reason"]
                               sendInviter:[param[@"isRespondInviter"] boolValue]
                                   handler:^(id resultObject, NSError *error) {
                                       if (error) {
                                           failCallback(@[[error errorToDictionary]]);
                                           return;
                                       }
                                       
                                       successCallback(@[]);
                                   }];
}

RCT_EXPORT_METHOD(dissolveGroup:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    if (param[@"groupId"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    [JMSGGroup dissolveGroupWithGid:param[@"groupId"] handler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        successCallback(@[]);
    }];
}


RCT_EXPORT_METHOD(transferGroupOwner:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    
    if (param[@"groupId"] == nil ||
        param[@"username"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGGroup *group = resultObject;
        [group transferGroupOwnerWithUsername:param[@"username"] appKey:appKey completionHandler:^(id resultObject, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
                return;
            }
            successCallback(@[]);
        }];
    }];
}


RCT_EXPORT_METHOD(setGroupMemberSilence:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    
    if (param[@"groupId"] == nil ||
        param[@"username"] == nil ||
        param[@"isSilence"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGGroup *group = resultObject;
        [group setGroupMemberSilence:[param[@"isSilence"] boolValue] username:param[@"username"] appKey:appKey handler:^(id resultObject, NSError *error) {
            if (error) {
                failCallback(@[[error errorToDictionary]]);
                return;
            }
            successCallback(@[]);
        }];
    }];
}


RCT_EXPORT_METHOD(isSilenceMember:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    
    if (param[@"groupId"] == nil ||
        param[@"username"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGGroup *group = resultObject;
        
        BOOL isSilence = [group isSilenceMemberWithUsername:param[@"username"] appKey:appKey];
        successCallback(@[@{@"isSilence": @(isSilence)}]);
    }];
}

RCT_EXPORT_METHOD(groupSilenceMembers:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    if (param[@"groupId"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGGroup *group = resultObject;
        NSArray *silenceMembers = [group groupSilenceMembers];
        NSArray *silenceUserDicArr = [silenceMembers mapObjectsUsingBlock:^id(id obj, NSUInteger idx) {
            JMSGUser *user = obj;
            return [user userToDictionary];
        }];
        successCallback(@[silenceUserDicArr]);
    }];
}

RCT_EXPORT_METHOD(setGroupNickname:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    
    if (param[@"groupId"] == nil ||
        param[@"username"] == nil ||
        param[@"nickName"] == nil) {
        failCallback(@[[self getParamError]]);
        return;
    }
    
    NSString *appKey = nil;
    if (param[@"appKey"]) {
        appKey = param[@"appKey"];
    } else {
        appKey = [JMessageHelper shareInstance].JMessageAppKey;
    }
    
    [JMSGGroup groupInfoWithGroupId:param[@"groupId"] completionHandler:^(id resultObject, NSError *error) {
        if (error) {
            failCallback(@[[self getParamError]]);
            return;
        }
        
        JMSGGroup *group = resultObject;
        
        [group setGroupNickname:param[@"nickName"] username:param[@"username"] appKey:appKey handler:^(id resultObject, NSError *error) {
            if (error) {
                failCallback(@[[self getParamError]]);
                return;
            }
            
            successCallback(@[]);
        }];
    }];
}


RCT_EXPORT_METHOD(setMsgHaveRead:(NSDictionary *)param
                  successCallback:(RCTResponseSenderBlock)successCallback
                  failCallBack:(RCTResponseSenderBlock)failCallback) {
    
    
    [self getConversationWithDictionary:param callback:^(JMSGConversation *conversation, NSError *error) {
        if (error) {
            failCallback(@[[error errorToDictionary]]);
            return;
        }
        
        JMSGMessage *message =  [conversation messageWithMessageId:param[@"id"]];
        
        [message setMessageHaveRead:^(id resultObject, NSError *error) {
            if (!error) {
                successCallback(@[@{}]);
            } else {
                failCallback(@[[error errorToDictionary]]);
            }
        }];
        
    }];
}



@end
