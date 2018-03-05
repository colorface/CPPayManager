# CPPayManager

/*==============================使用说明===================================*/


 ①在`Xcode`中，选择你的工程`设置项`，选中`TARGETS`一栏，在`info`标签栏的`URL type`添加`URL scheme`和`Identifier`.**【支付宝和微信均必须添加！】**
 
 > 微信必须设置`URL scheme`为注册时的`appID`， `Identifier`无要求，建议设置为`weixin`;
 
 > 支付宝建议设置`Identifier`为`zhifubao`，`URL scheme`建议设置与app相关字符串.
 
 ![微信添加 URL scheme](https://res.wx.qq.com/open/zh_CN/htmledition/res/img/pic/app-access-guide/ios/image0042168b9.jpg)
 
 ②【在`info`标签栏的`LSApplicationQueriesSchemes`添加`weixin`】
 
 点击`info.plist`->右键->Open As->Source Code->添加下面的代码
 
 ```
 <key>LSApplicationQueriesSchemes</key>
 <array>
 <string>weixin</string>
 </array>
 ```
 
 ![微信白名单设置](http://mmbiz.qpic.cn/mmbiz_png/PiajxSqBRaEJsqKkSJGg4TLAxEIvWjtTfrHSbhE3zfbPzuuGzadu9FsWJuBNELsk1IuQucfx91ialTfpPhAF0grA/0?wx_fmt=png)
 
