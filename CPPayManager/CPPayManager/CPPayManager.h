//
//  CPPayManager.h
//  CPPayManager
//
//  Created by AIR on 2018/2/6.
//  Copyright © 2018年 com.onlytimer. All rights reserved.
// 仅适用于（支付宝+微信）支付方式，其他方式暂不支持！

/*==============================使用说明===================================*/
/*
 ①在Xcode中，选择你的工程设置项，选中“TARGETS”一栏，在“info”标签栏的“URL type“添加“URL scheme”和“Identifier”.【支付宝和微信均必须添加！】
 > 微信必须设置“URL scheme”为注册时的appID， Identifier无要求，建议设置为"weixin";
 > 支付宝建议设置Identifier为“zhifubao”，"URL scheme"建议设置与app相关字符串.
 
 ![微信添加 URL scheme](https://res.wx.qq.com/open/zh_CN/htmledition/res/img/pic/app-access-guide/ios/image0042168b9.jpg)
 
 ②【在“info”标签栏的“LSApplicationQueriesSchemes“添加weixin】
 
 点击info.plist->右键->Open As->Source Code->添加下面的代码
 
 <key>LSApplicationQueriesSchemes</key>
 <array>
 <string>weixin</string>
 </array>

 ![微信白名单设置](http://mmbiz.qpic.cn/mmbiz_png/PiajxSqBRaEJsqKkSJGg4TLAxEIvWjtTfrHSbhE3zfbPzuuGzadu9FsWJuBNELsk1IuQucfx91ialTfpPhAF0grA/0?wx_fmt=png)
 */

/*==============================特殊说明===================================*/

/* 如若想重写微信未安装情况，需要先实现
- (void)weChatUninstalledHandler:(void(^)(void))blcok 方法，
然后再实现“发起支付”方法
- (void)payWithOrderInfomation:(id)orderInfo completionHander:(CPCompletionHandler) completion; */

/*=====================================================================*/


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WXApi.h"

/**
 单例宏
 */
#define CPPAYMANAGER  [CPPayManager shareManager]

/**
 callBack statue code

 - CPErrCodeSucess: sucess
 - CPErrCodeFailure: failure
 - CPErrCodeCancel: cancel
 */
typedef NS_ENUM(NSUInteger, CPErrCode) {
    CPErrCodeSucess,        //成功
    CPErrCodeFailure,       //失败
    CPErrCodeCancel,        //取消
};

/**
 result handler // 回调结果处理
 状态码和错误信息，用户可根据实际情况做页面跳转及其他处理
 */
typedef void(^CPCompletionHandler)(NSString *errStr, CPErrCode errCode);


/**
 payManager // 支付管理类
 */
@interface CPPayManager : NSObject


/**
 singleton // 单例管理
 */
+ (instancetype)shareManager;


/**
 微信支付注册，需要在 didFinishLaunchingWithOptions 中调用

 @param appid 商户AppID
 注 ：此处仅微信需要注册，appid为微信注册id
 */
- (void)registerApp:(NSString *)appid;


/**
 处理跳转url，回到应用，需要在delegate中实现
 */
- (BOOL)payHandleUrl:(NSURL *)url;


/**
 发起支付

 @param orderInfo 传入订单信息,如果是字符串，则对应是跳转支付宝支付；如果传入PayReq 对象，这跳转微信支付,注意，不能传入空字符串或者nil
 @param completion 回调，有返回状态信息
 */
- (void)payWithOrderInfomation:(id)orderInfo completionHander:(CPCompletionHandler) completion;

/**
 未安装微信的处理

 @param blcok 处理block
 */
- (void)weChatUninstalledHandler:(void(^)(void))blcok;
@end
