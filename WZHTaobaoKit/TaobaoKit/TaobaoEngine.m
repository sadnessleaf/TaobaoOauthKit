//
//  TaobaoEngine.m
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

#import "TaobaoEngine.h"
#import "TaobaoRequest.h"
#import "TBAuthWebViewController.h"

@interface TaobaoEngine () <TBAuthWebViewControllerDelegate,TaobaoRequestDelegate> {
    
}

@property (nonatomic,retain) NSString *appKey;
@property (nonatomic,retain) NSString *appSecret;
@property (nonatomic,retain) NSString *redirectURL;

@property (nonatomic,retain) NSString *accessToken;
@property (nonatomic,retain) NSDate *expirationDate;
@property (nonatomic,retain) NSString *refreshToken;

@property (nonatomic,retain) TaobaoRequest *request;

// Check if user has logged in, or the authorization is expired.
- (BOOL)isLoggedIn;
- (BOOL)isAuthorizeExpired;

//Auth Data Save & Load.
- (void)loadAuthData;
- (void)storeAuthData;
- (void)removeAuthData;

@end

@implementation TaobaoEngine

#pragma mark - Init & Dealloc
- (id)initWithAppKey:(NSString *)appKey
           appSecret:(NSString *)appSecrect
         redirectURL:(NSString *)redirectURL {
    self = [super init];
    
    if (self) {
        self.appKey = appKey;
        self.appSecret = appSecrect;
        self.redirectURL = redirectURL;        
    }
    
    return self;
}
- (void)dealloc {
    [_userID release],_userID = NULL;
    [_userNickName release],_userNickName = NULL;
    
    [_appKey release],_appKey = NULL;
    [_appSecret release],_appSecret = NULL;
    [_redirectURL release],_redirectURL = NULL;
    
    [_accessToken release],_accessToken = NULL;
    [_expirationDate release],_expirationDate = NULL;
    [_refreshToken release],_refreshToken = NULL;
    
    [_request release],_request = NULL;
    
    _delegate = NULL;
    _rootViewController = NULL;
    
    [super dealloc];
}
#pragma mark - Validation
/**
 * @description 判断是否登录
 * @return YES为已登录；NO为未登录
 */
- (BOOL)isLoggedIn {
    return _userID && _accessToken && _expirationDate;
}
/**
 * @description 判断登录是否过期
 * @return YES为已过期；NO为未为期
 */
- (BOOL)isAuthorizeExpired {
    NSDate *now = [NSDate date];
    return ([now compare:_expirationDate] == NSOrderedDescending);
}
/**
 * @description 判断登录是否有效，当已登录并且登录未过期时为有效状态
 * @return YES为有效；NO为无效
 */
- (BOOL)isAuthValid {
    [self loadAuthData];
    
    return ([self isLoggedIn] && ![self isAuthorizeExpired]);
}
- (void)notifyTokenExpired:(id <TaobaoRequestDelegate>)requestDelegate {
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Token expired",NSLocalizedDescriptionKey,nil];
    
    NSError *error = [NSError errorWithDomain:kTaobaoAPIErrorDomain
                                         code:21315
                                     userInfo:userInfo];
    
    if (_delegate && [_delegate respondsToSelector:@selector(engine:accessTokenInvalidOrExpired:)]) {
        [_delegate engine:self accessTokenInvalidOrExpired:error];
    }
    
    if ([requestDelegate respondsToSelector:@selector(request:didFailWithError:)]) {
		[requestDelegate request:nil didFailWithError:error];
	}
}
#pragma mark - Auth Data Save & Load
/**
 * @description 认证信息
 */
- (void)loadAuthData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *info = [defaults objectForKey:kTaobaoOpenPlatOauthData];
    if (info && [info isKindOfClass:[NSDictionary class]]) {
        self.accessToken = [info objectForKey:kTaobaoOpenPlatAccessToken];
        self.expirationDate = [info objectForKey:kTaobaoOpenPlatExpirationDate];
        self.userID = [info objectForKey:kTaobaoOpenPlatUserId];
        self.userNickName = [info objectForKey:kTaobaoOpenPlatUserNickName];
        self.refreshToken = [info objectForKey:kTaobaoOpenPlatRefreshToken];
    }
}
- (void)storeAuthData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.accessToken,kTaobaoOpenPlatAccessToken,
                              self.expirationDate,kTaobaoOpenPlatExpirationDate,
                              self.userID,kTaobaoOpenPlatUserId,
                              self.userNickName,kTaobaoOpenPlatUserNickName,
                              self.refreshToken,kTaobaoOpenPlatRefreshToken, nil];
    
    [defaults setObject:authData forKey:kTaobaoOpenPlatOauthData];
    [defaults synchronize];
}
- (void)removeAuthData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.accessToken = NULL;
    self.expirationDate = NULL;
    self.userID = NULL;
    self.userNickName = NULL;
    self.refreshToken = NULL;
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieJar cookies]) {
        [cookieJar deleteCookie:cookie];
    }
    
    [defaults removeObjectForKey:kTaobaoOpenPlatOauthData];    
    [defaults synchronize];
}
#pragma mark - LogIn / LogOut
/**
 * @description 登录入口，当初始化SinaWeibo对象完成后直接调用此方法完成登录
 */
- (void)logIn {
    [self logInWithPush:NO];
}
- (void)logInWithPush:(BOOL)isPush {
    if ([self isAuthValid]) {
        if (_delegate && [_delegate respondsToSelector:@selector(engineDidLogIn:)]) {
            [_delegate engineDidLogIn:self];
        }
    }
    else {
        [self removeAuthData];
        
        TBAuthWebViewController *newViewController = [[TBAuthWebViewController alloc] initWithAppkey:_appKey redirectURL:_redirectURL delegate:self];
        UINavigationController *newNavController = [[UINavigationController alloc] initWithRootViewController:newViewController];
        
        if (isPush) {
            [_rootViewController.navigationController pushViewController:newViewController animated:YES];
        }
        else {
            [_rootViewController presentModalViewController:newNavController animated:YES];
        }
        
        [newNavController release];
        [newViewController release];
    }
}
/**
 * @description 退出方法，需要退出时直接调用此方法
 */
- (void)logOut {
    [self removeAuthData];
    
    if (_delegate && [_delegate respondsToSelector:@selector(engineDidLogOut:)]) {
        [_delegate engineDidLogOut:self];
    }
}
- (void)clear {
    [self removeAuthData];
}
#pragma mark - Send request with token
/**
 * @description 淘宝API的请求接口，方法中自动完成token信息的拼接
 * @param url: 请求的接口
 * @param params: 请求的参数，如发微博所带的文字内容等
 * @param httpMethod: http类型，GET或POST
 * @param _delegate: 处理请求结果的回调的对象，TaobaoRequestDelegate类
 * @return 完成实际请求操作的TaobaoRequest对象
 */

- (TaobaoRequest *)requestWithParams:(NSMutableDictionary *)params
                          httpMethod:(HttpRequestMethod)httpMethod
                            delegate:(id <TaobaoRequestDelegate>)delegate {
    if (params == nil) {
        params = [NSMutableDictionary dictionary];
    }
    
    if ([self isAuthValid]) {        
        TaobaoRequest *request = [TaobaoRequest requestWithAppkey:_appKey
                                                        appSecret:_appSecret
                                                          session:_accessToken
                                                              URL:kTaobaoAPIBaseURL
                                                       httpMethod:GET
                                                           params:params
                                                         delegate:delegate];
        
        request.tbEngine = self;
        self.request = request;
        
        [_request connect];
        
        return _request;
    }
    else {
        //notify token expired in next runloop
        [self performSelectorOnMainThread:@selector(notifyTokenExpired:)
                               withObject:delegate
                            waitUntilDone:NO];
        
        return nil;
    }
}
- (void)requestDidFailWithInvalidToken:(NSError *)error {
    if (_delegate && [_delegate respondsToSelector:@selector(engine:accessTokenInvalidOrExpired:)]) {
        [_delegate engine:self accessTokenInvalidOrExpired:error];
    }
}
#pragma mark - TBAuthWebViewController Delegate Methods
//授权成功回调
- (void)viewController:(TBAuthWebViewController *)viewController didSucceedWithOauthInfo:(NSDictionary *)oauthInfo {
    NSString *access_token = [oauthInfo objectForKey:@"access_token"];
    NSString *expires_in = [oauthInfo objectForKey:@"expires_in"];
    NSString *refresh_token = [oauthInfo objectForKey:@"refresh_token"];
    NSString *taobao_user_id = [oauthInfo objectForKey:@"taobao_user_id"];
    NSString *taobao_user_nick = [oauthInfo objectForKey:@"taobao_user_nick"];

    if (access_token && taobao_user_id) {
        self.accessToken = access_token;

        if (expires_in != nil) {
            int expVal = [expires_in intValue];
            if (expVal == 0) {
                self.expirationDate = [NSDate distantFuture];
            }
            else {
                self.expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
            }
        }
        
        self.refreshToken = refresh_token;
        self.userID = taobao_user_id;
        self.userNickName = taobao_user_nick;
        
        [self storeAuthData];
        
        if (_delegate && [_delegate respondsToSelector:@selector(engineDidLogIn:)]) {
            [_delegate engineDidLogIn:self];
        }
    }
}
//授权失败回调
- (void)viewController:(TBAuthWebViewController *)viewController didFailuredWithError:(NSError *)error {
    if (_delegate && [_delegate respondsToSelector:@selector(engine:logInDidFailWithError:)]) {
        [_delegate engine:self logInDidFailWithError:error];
    }
}
//授权取消回调
- (void)viewControllerDidCancel:(TBAuthWebViewController *)viewController {
    if (_delegate && [_delegate respondsToSelector:@selector(engineLogInDidCancel:)]) {
        [_delegate engineLogInDidCancel:self];
    }
}
@end