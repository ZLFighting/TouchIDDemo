//
//  ViewController.m
//  TouchIDDemo
//
//  Created by ZL on 2017/3/7.
//  Copyright © 2017年 ZL. All rights reserved.
//

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor orangeColor];
    
    [self authenticateUser];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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


- (void)evaluateAuthenticate
{
    //初始化上下文对象
    LAContext* context = [[LAContext alloc] init];
    //错误对象
    NSError* error = nil;
    NSString* result = @"请验证指纹,用于解锁"; // Authentication is needed to access your notes.
    
    // 首先使用canEvaluatePolicy 判断设备支持状态
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        // 支持指纹验证
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:result reply:^(BOOL success, NSError *error) {
            if (success) { // 验证成功，主线程处理UI
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // Update UI in UI thread here
                    NSLog(@"验证成功 刷新主界面");
                });
                
            } else {
                NSLog(@"%@",error.localizedDescription);
                
                switch (error.code) {
                    case LAErrorSystemCancel:
                    {
                        NSLog(@"Authentication was cancelled by the system-取消验证Touch ID");
                        // 系统取消授权取消验证Touch ID，如其他APP切入
                        break;
                    }
                    case LAErrorUserCancel:
                    {
                        NSLog(@"Authentication was cancelled by the user-用户取消验证Touch ID");
                        //用户取消验证Touch ID
                        break;
                    }
                    case LAErrorUserFallback:
                    {
                        NSLog(@"User selected to enter custom password-用户选择输入密码");
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //用户选择输入密码其他验证方式，切换主线程处理
                        }];
                        break;
                    }
                    default:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            //其他情况，切换主线程处理
                        }];
                        break;
                    }
                }
            }
        }];
    }
    else
    {
        //不支持指纹识别，LOG出错误详情
        
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
        
        NSLog(@"%@", error.localizedDescription);
       // [self showPasswordAlert];
    }  
}

/**
 *
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
 */
@end
