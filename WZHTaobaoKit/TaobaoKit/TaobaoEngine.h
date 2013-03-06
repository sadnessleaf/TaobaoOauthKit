//
//  TaobaoEngine.h
//  WZHTaobaoKit
//
//  Created by sadnessleaf on 13-3-5.
//  Copyright (c) 2013年 sadnessleaf. All rights reserved.
//

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