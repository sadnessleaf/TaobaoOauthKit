//
//  TaobaoEngine.h
//  https://github.com/sadnessleaf/TaobaoOauthKit
//  WZHTaobaoKit
//
//  Created by sadnessleaf on 13-3-5.
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

#import <Foundation/Foundation.h>

@class TaobaoEngine;
@class TaobaoRequest;

@protocol TaobaoRequestDelegate;

@protocol TaobaoEngineDelegate <NSObject>

- (void)engineDidLogIn:(TaobaoEngine *)engine;
- (void)engineDidLogOut:(TaobaoEngine *)engine;
- (void)engineLogInDidCancel:(TaobaoEngine *)engine;
- (void)engine:(TaobaoEngine *)engine logInDidFailWithError:(NSError *)error;

@optional
- (void)engine:(TaobaoEngine *)engine accessTokenInvalidOrExpired:(NSError *)error;

@end

@interface TaobaoEngine : NSObject {
    
}

@property (nonatomic,retain) NSString *userID;
@property (nonatomic,retain) NSString *userNickName;

@property (nonatomic,assign) id <TaobaoEngineDelegate> delegate;
@property (nonatomic,assign) UIViewController *rootViewController;

- (id)initWithAppKey:(NSString *)appKey
           appSecret:(NSString *)appSecrect
         redirectURL:(NSString *)redirectURL;

// Log in using OAuth Web authorization.
// If succeed, weiboEngineDidLogIn will be called.
- (void)logIn;

// Log out.
// If succeed, weiboEngineDidLogOut will be called.
- (void)logOut;

// isLoggedIn && isAuthorizeExpired
- (BOOL)isAuthValid;

- (void)clear;

- (TaobaoRequest *)requestWithParams:(NSMutableDictionary *)params
                          httpMethod:(HttpRequestMethod)httpMethod
                            delegate:(id <TaobaoRequestDelegate>)delegate;

@end