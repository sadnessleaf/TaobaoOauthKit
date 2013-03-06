//
//  Constants.h
//  WZHTaobaoKit
//
//  Created by sadnessleaf on 13-3-4.
//  Copyright (c) 2013年 sadnessleaf. All rights reserved.
//


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