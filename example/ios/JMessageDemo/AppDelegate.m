/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"
#import "RCTJMessageModule.h"

#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  
  [JMessage setupJMessage:launchOptions
                   appKey:@"e58a32cb3e4469ebf31867e5"
                  channel:@""
         apsForProduction:false
                 category:nil
           messageRoaming:true];
  
  [JMessage addDelegate:self withConversation:nil];
  
  // Required - 注册 APNs 通知
  if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
      //可以添加自定义categories
      [JMessage registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound |
                                                        UIUserNotificationTypeAlert)
                                            categories:nil];
  } else {
      //categories 必须为nil
      [JMessage registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                        UIRemoteNotificationTypeSound |
                                                        UIRemoteNotificationTypeAlert)
                                            categories:nil];
  }
  
  NSURL *jsCodeLocation;

  NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
  NSLog(@"mainBundlePath: %@",mainBundlePath);
  
  NSString *LibraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
  NSString *UserDirectory = [NSSearchPathForDirectoriesInDomains(NSUserDirectory, NSUserDomainMask, YES) lastObject];
  NSString *ApplicationDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES) lastObject];

  NSLog(@"LibraryDirectory: %@",LibraryDirectory);
  NSLog(@"UserDirectory: %@",UserDirectory);
  NSLog(@"ApplicationDirectory: %@",ApplicationDirectory);
  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];
//  jsCodeLocation = [NSURL URLWithString:@"http://192.168.10.155:8081/index.ios.bundle?platform=ios&dev=true"];
  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"ReactJChat"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Required - 注册token
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@",deviceToken);
    [JMessage registerDeviceToken:deviceToken];
}

//JMessage 离线消息
- (void)onSyncOfflineMessageConversation:(JMSGConversation *)conversation
                         offlineMessages:(NSArray JMSG_GENERIC ( __kindof JMSGMessage *) *)offlineMessages {
  [RCTJMessageEventQueue sharedInstance].offlineConversation = conversation;
  [RCTJMessageEventQueue sharedInstance].offlineMsgArray = offlineMessages;
}

@end
