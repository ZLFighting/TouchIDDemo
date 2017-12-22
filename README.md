# TouchIDDemo
指纹解锁

>软硬件支持:
指纹验证功能的最低硬件支持为iPhone5s,iPad 6，iPad mini 3这些有touch ID硬件支持的设备，并且操作系统最低为iOS8.0，因为touch ID是在iOS8.0之后才开放的一类api，实现了指纹验证的功能。

一直想实现指纹解锁的功能, 今天抽空翻阅下文档写个Demo。该功能实现起来是很简单的，因为苹果都已经帮我们封装好了，只需要实现几个方法就可以了。

>**软硬件支持:**
指纹验证功能的最低硬件支持为iPhone5s,iPad 6，iPad mini 3这些有touch ID硬件支持的设备，并且操作系统最低为iOS8.0，因为touch ID是在iOS8.0之后才开放的一类api，实现了指纹验证的功能。

**效果图如下:**
![指纹解锁](https://github.com/ZLFighting/TouchIDDemo/blob/master/TouchIDDemo/WechatIMG36.jpeg)

![输入密码解锁](https://github.com/ZLFighting/TouchIDDemo/blob/master/TouchIDDemo/WechatIMG37.jpeg)

## 实现流程:

#### step1: 引入依赖框架(指纹解锁必须的头文件):
```
#import <LocalAuthentication/LocalAuthentication.h>
```

#### step2: 指纹验证的实现的两个主要方法:

```
这个方法是判断设备是否支持TouchID的。
- (BOOL)canEvaluatePolicy:(LAPolicy)policy error:(NSError * __autoreleasing *)
error __attribute__((swift_error(none)));
```

```
这个是用来验证TouchID的，会有弹出框出来。
- (void)evaluatePolicy:(LAPolicy)policy
localizedReason:(NSString *)localizedReason
reply:(void(^)(BOOL success, NSError * __nullable error))reply;

```

#### step3: 主要回调方法:
```
typedef NS_ENUM(NSInteger, LAError)
{
// 授权失败
LAErrorAuthenticationFailed = kLAErrorAuthenticationFailed,

// 用户取消Touch ID授权
LAErrorUserCancel           = kLAErrorUserCancel,

// 用户选择输入密码
LAErrorUserFallback         = kLAErrorUserFallback,

// 系统取消授权(例如其他APP切入)
LAErrorSystemCancel         = kLAErrorSystemCancel,

// 系统未设置密码
LAErrorPasscodeNotSet       = kLAErrorPasscodeNotSet,

// 设备Touch ID不可用，例如未打开
LAErrorTouchIDNotAvailable  = kLAErrorTouchIDNotAvailable,

// 设备Touch ID不可用，例如未打开
LAErrorTouchIDNotEnrolled = kLAErrorTouchIDNotEnrolled,

// 触摸ID现在锁定 验证是不成功的，因为有太多的失败的尝试和触摸ID
LAErrorTouchIDLockout   NS_ENUM_AVAILABLE(10_11, 9_0) __WATCHOS_AVAILABLE(3.0) __TVOS_AVAILABLE(10.0) = kLAErrorTouchIDLockout,

// 认证被取消的应用（如无效而认证进行调用）。
LAErrorAppCancel        NS_ENUM_AVAILABLE(10_11, 9_0) = kLAErrorAppCancel,

/// LAContext passed to this call has been previously invalidated.
// LAContext通过这个电话已经失效
LAErrorInvalidContext   NS_ENUM_AVAILABLE(10_11, 9_0) = kLAErrorInvalidContext
}
```

核心代码如下:
```
// 验证指纹
- (void)authenticateUser {
//创建LAContext
LAContext *context = [[LAContext alloc] init];
// 这个属性是设置指纹输入失败之后的弹出框的选项
context.localizedFallbackTitle = @"请输入密码";

NSError *error = nil;
if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
NSLog(@"支持指纹识别");
// localizedReason: 用于设置提示语，表示为什么要使用Touch ID
[context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"请按home键指纹解锁" reply:^(BOOL success, NSError * _Nullable error) {
if (success) {

dispatch_sync(dispatch_get_main_queue(), ^{
// Update UI in UI thread here
NSLog(@"验证成功 刷新主界面");
});
}else{
NSLog(@"%@",error.localizedDescription);
switch (error.code) {
case LAErrorSystemCancel:
{
NSLog(@"系统取消授权，如其他APP切入");
break;
}
case LAErrorUserCancel:
{
NSLog(@"用户取消验证Touch ID");
break;
}
case LAErrorAuthenticationFailed:
{
NSLog(@"授权失败");
break;
}
case LAErrorPasscodeNotSet:
{
NSLog(@"系统未设置密码");
break;
}
case LAErrorTouchIDNotAvailable:
{
NSLog(@"设备Touch ID不可用，例如未打开");
break;
}
case LAErrorTouchIDNotEnrolled:
{
NSLog(@"设备Touch ID不可用，用户未录入");
break;
}
case LAErrorUserFallback: // 用于设置左边的按钮的名称，默认是Enter Password
{
[[NSOperationQueue mainQueue] addOperationWithBlock:^{
NSLog(@"用户选择输入密码，切换主线程处理");
}];
break;
}
default:
{
[[NSOperationQueue mainQueue] addOperationWithBlock:^{
NSLog(@"其他情况，切换主线程处理");
}];
break;
}
}
}
}];
}else{
NSLog(@"不支持指纹识别");
switch (error.code) {
case LAErrorTouchIDNotEnrolled:
{
NSLog(@"TouchID is not enrolled");
break;
}
case LAErrorPasscodeNotSet:
{
NSLog(@"A passcode has not been set");
break;
}
default:
{
NSLog(@"TouchID not available");
break;
}
}

NSLog(@"%@",error.localizedDescription);
}
}
```

项目中若有了指纹解锁这种解锁方式, 瞬间有木有觉得自己的项目高大上了一丢丢呢。

**如果需要手势解锁方式,请移步: [iOS-高仿支付宝手势解锁(九宫格)](https://github.com/ZLFighting/GestureLockDemo)**

您的支持是作为程序媛的我最大的动力, 如果觉得对你有帮助请送个Star吧,谢谢啦
