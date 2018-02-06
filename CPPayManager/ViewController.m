//
//  ViewController.m
//  CPPayManager
//
//  Created by AIR on 2018/2/6.
//  Copyright © 2018年 com.onlytimer. All rights reserved.
//

#import "ViewController.h"
#import "CPPayManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
//微信支付
- (IBAction)wxPay:(id)sender {
    
    PayReq * req = [[PayReq alloc] init];
    req.partnerId           = @"1900000109";
    req.prepayId            = @"WX1217752501201407033233368018";
    req.nonceStr            = @"5K8264ILTKCH16CQ2502SI8ZNMTM67VS";
    req.timeStamp           = 1412000000;
    req.package             = @"Sign=WXPay";
    req.sign                = @"9A0A8659F005D6984697E2CA0A9CF3B7";
    
    //发起支付
    [CPPAYMANAGER payWithOrderInfomation:req completionHander:^(NSString *errStr, CPErrCode errCode) {
        NSLog(@"WeChat errStr : %@ errCode : %lu", errStr, (unsigned long)errCode);
    }];
    
}
- (IBAction)aliPay:(id)sender {
    
    //数据来自支付宝
    NSString *orderMessage = @"app_id=2015052600090779&biz_content=%7B%22timeout_express%22%3A%2230m%22%2C%22seller_id%22%3A%22%22%2C%22product_code%22%3A%22QUICK_MSECURITY_PAY%22%2C%22total_amount%22%3A%220.02%22%2C%22subject%22%3A%221%22%2C%22body%22%3A%22%E6%88%91%E6%98%AF%E6%B5%8B%E8%AF%95%E6%95%B0%E6%8D%AE%22%2C%22out_trade_no%22%3A%22314VYGIAGG7ZOYY%22%7D&charset=utf-8&method=alipay.trade.app.pay&sign_type=RSA&timestamp=2016-08-15%2012%3A12%3A15&version=1.0&sign=MsbylYkCzlfYLy9PeRwUUIg9nZPeN9SfXPNavUCroGKR5Kqvx0nEnd3eRmKxJuthNUx4ERCXe552EV9PfwexqW%2B1wbKOdYtDIb4%2B7PL3Pc94RZL0zKaWcaY3tSL89%2FuAVUsQuFqEJdhIukuKygrXucvejOUgTCfoUdwTi7z%2BZzQ%3D";
    
    [CPPAYMANAGER payWithOrderInfomation:orderMessage completionHander:^(NSString *errStr, CPErrCode errCode) {
        NSLog(@"Alipay errStr : %@ errCode : %lu", errStr, (unsigned long)errCode);
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
