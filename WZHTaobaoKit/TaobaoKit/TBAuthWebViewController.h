//
//  TBAuthWebViewController.h
//  https://github.com/sadnessleaf/TaobaoOauthKit
//  WZHTaobaoKit
//
//  Created by sadnessleaf on 13-3-4.
//  Copyright (c) 2013年 Shenzhen WangZhi technology Co., LTD. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//
//  THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//	INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
//	PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//	OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
