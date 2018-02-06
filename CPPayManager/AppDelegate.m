//
//  AppDelegate.m
//  CPPayManager
//
//  Created by AIR on 2018/2/6.
//  Copyright © 2018年 com.onlytimer. All rights reserved.
//

#import "AppDelegate.h"
#import "CPPayManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //向微信注册;
    [CPPAYMANAGER registerApp:@"wxb4ba3c02aa476ea1"];
    
    return YES;
}

//ios9.0
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    return [CPPAYMANAGER payHandleUrl:url];
}
// < ios9.0
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [CPPAYMANAGER payHandleUrl:url];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
    return [CPPAYMANAGER payHandleUrl:url];
}



@end
