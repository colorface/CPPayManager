//
//  CPPayManager.m
//  CPPayManager
//
//  Created by AIR on 2018/2/6.
//  Copyright © 2018年 com.onlytimer. All rights reserved.
//

#import "CPPayManager.h"
#import <AlipaySDK/AlipaySDK.h>

//区分返回渠道，微信返回 or 支付宝返回
static NSString * const host_wx = @"pay";
static NSString * const host_alipay = @"safepay";

typedef void(^CPWXAppInstalledBlock)(void);

@interface CPPayManager()<WXApiDelegate>
{
    NSString *aliScheme; //支付宝对应URL Scheme
    NSString *wxScheme;  //微信对应URL Scheme
}
@property (nonatomic, copy) CPCompletionHandler completionHandler;
@property (nonatomic, copy) CPWXAppInstalledBlock unInstallBlock;
@end

@implementation CPPayManager

+ (instancetype)shareManager
{
    static CPPayManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}
- (void)registerApp:(NSString *)appid
{
    NSAssert(appid, @"appid不能为空");
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *urlTypes = dict[@"CFBundleURLTypes"];
    NSAssert(urlTypes, @"请先在Info.plist 添加 URL Type");
    for (NSDictionary *urlTypeDict in urlTypes) {
        NSArray *urlSchemes = urlTypeDict[@"CFBundleURLSchemes"];
        NSString *urlScheme = urlSchemes.lastObject;
        NSAssert(urlScheme, @"URL Scheme 信息缺失，请检查URL Type");
        if (![urlScheme isEqualToString:appid]) {
            wxScheme = appid;
            aliScheme = urlScheme;
        }
    }
    
    [WXApi registerApp:appid];
}

- (BOOL)payHandleUrl:(NSURL *)url
{
    if ([url.host isEqualToString:host_wx]) {
        
        return  [WXApi handleOpenURL:url delegate:self];
    }
    if ([url.host isEqualToString:host_alipay]) {

        // 支付跳转支付宝钱包进行支付，处理支付结果(在app被杀模式下，通过这个方法获取支付结果）
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            
            NSUInteger codeStatue = [resultDic[@"resultStatus"] integerValue];
            NSString *errStr = resultDic[@"memo"];
            CPErrCode errCode;
            
            switch (codeStatue) {
                case 9000:
                    errCode = CPErrCodeSucess;
                    break;
                case 6001:
                    errCode = CPErrCodeCancel;
                    break;
                default:
                    errCode = CPErrCodeFailure;
                    break;
            }
            if (self.completionHandler) {
                self.completionHandler(errStr, errCode);
            }
            
        }];
        
        //授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
            
        }];
    }
    return YES;
}

- (void)payWithOrderInfomation:(id)orderInfo completionHander:(CPCompletionHandler)completion
{
    if (completion) {
        self.completionHandler = completion;
    }
    //微信发起支付
    if ([orderInfo isKindOfClass:[PayReq class]]) {
        
        if ([WXApi isWXAppInstalled]) {
            [WXApi sendReq:(PayReq *)orderInfo];
        }else {

            !self.unInstallBlock ? [self actionMethod] : self.unInstallBlock();
        }
    }
    //支付宝
    if ([orderInfo isKindOfClass:[NSString class]]) {
        
        [[AlipaySDK defaultService] payOrder:orderInfo fromScheme:aliScheme callback:^(NSDictionary *resultDic) {
            
            NSUInteger codeStatue = [resultDic[@"resultStatus"] integerValue];
            NSString *errStr = resultDic[@"memo"];
            CPErrCode errCode;
            
            switch (codeStatue) {
                case 9000:
                    errCode = CPErrCodeSucess;
                    break;
                case 6001:
                    errCode = CPErrCodeCancel;
                    break;
                default:
                    errCode = CPErrCodeFailure;
                    break;
            }
            if (self.completionHandler) {
                self.completionHandler(errStr, errCode);
            }
        }];
    }
}


-(void) onResp:(BaseResp*)resp
{
    //微信支付回调
    if ([resp isKindOfClass:[PayResp class]]) {
        
        NSString *errStr;
        CPErrCode errCode;
        switch (resp.errCode) {
            case WXSuccess:
                errCode = CPErrCodeSucess;
                errStr = @"订单支付成功";
                break;
            case WXErrCodeUserCancel:
                errCode = CPErrCodeCancel;
                errStr = @"用户中途取消";
                break;
            default:
                errCode = CPErrCodeFailure;
                errStr = resp.errStr;
                break;
        }
        
        if (self.completionHandler) {
            self.completionHandler(errStr, errCode);
        }
    }
}

- (void)weChatUninstalledHandler:(void(^)(void))blcok
{
    self.unInstallBlock = blcok;
}

#pragma - private Method
//未安装微信默认弹窗
- (void)actionMethod
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"微信未安装" message:@"是否从apple store下载?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:nil];
    
    __weak UIAlertController *weakAlert = alert;
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakAlert dismissViewControllerAnimated:YES completion:^{
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[WXApi getWXAppInstallUrl]] options:@{} completionHandler:nil];
        }];
        
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end
