//
//  Constants.h
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

#define kTaobaoAppKey                           @""
#define kTaobaoAppSecret                        @""
#define kTaobaoCallBackURL                      @""

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