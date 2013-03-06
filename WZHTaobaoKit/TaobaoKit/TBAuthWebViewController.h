//
//  TBAuthWebViewController.h
//  WZHTaobaoKit
//
//  Created by sadnessleaf on 13-3-4.
//  Copyright (c) 2013年 sadnessleaf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TBAuthWebViewController;

@protocol TBAuthWebViewControllerDelegate <NSObject>

//授权成功回调
- (void)viewController:(TBAuthWebViewController *)viewController didSucceedWithOauthInfo:(NSDictionary *)oauthInfo;
//授权失败回调
- (void)viewController:(TBAuthWebViewController *)viewController didFailuredWithError:(NSError *)error;
//授权取消回调
- (void)viewControllerDidCancel:(TBAuthWebViewController *)viewController;

@end

@interface TBAuthWebViewController : UIViewController {
    
}

- (id)initWithAppkey:(NSString *)appkey redirectURL:(NSString *)redirectURL delegate:(id <TBAuthWebViewControllerDelegate>)delegate;

@end
