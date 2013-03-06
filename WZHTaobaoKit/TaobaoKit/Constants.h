//
//  Constants.h
//  WZHTaobaoKit
//
//  Created by sadnessleaf on 13-3-4.
//  Copyright (c) 2013年 sadnessleaf. All rights reserved.
//
#define kTaobaoAppKey                           @"12520064"
#define kTaobaoAppSecret                        @"0c724b73083ad5dd9102e48f52e2ed3a"
#define kTaobaoCallBackURL                      @"lmbang://"

//initWithAppKey:@"12691944" appSecret:@"3d418c393fcf4b815a0f4cc452608851" redirectURL:@"http://open.lmbang.com/top/callback"

#define kTaobaoAuthURL                          @"https://oauth.taobao.com/authorize"
#define kTaobaoAPIBaseURL                       @"http://gw.api.taobao.com/router/rest"
#define kTaobaoAPIErrorDomain                   @"TaobaoAPIErrorDomain"

#define kTaobaoOpenPlatAccessToken              @"TaobaoOpenPlatAccessToken"
#define kTaobaoOpenPlatExpirationDate           @"TaobaoOpenPlatExpirationDate"
#define kTaobaoOpenPlatUserId                   @"TaobaoOpenPlatUserId"
#define kTaobaoOpenPlatUserNickName             @"TaobaoOpenPlatUserNickName"
#define kTaobaoOpenPlatRefreshToken             @"TaobaoOpenPlatRefreshToken"
#define kTaobaoOpenPlatOauthData                @"TaobaoOpenPlatOauthData"

typedef enum {
    GET = 0,
    POST = 1,
} HttpRequestMethod;

typedef enum {
	TaobaoAPIErrorCodeParseError        = 200,     //解析错误
	TaobaoAPIErrorCodeRequestError      = 201,     //请求错误
	TaobaoAPIErrorCodeAccessError       = 202,     //返回accesstoken错误
	TaobaoAPIErrorCodeAuthorizeError    = 203,     //认证错误
    TaobaoAPIErrorCodeUserCancelled     = 204,     //用户取消
} TaobaoAPIErrorCode;