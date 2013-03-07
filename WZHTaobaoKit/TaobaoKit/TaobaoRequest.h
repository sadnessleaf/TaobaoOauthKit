//
//  TaobaoRequest.h
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

@protocol TaobaoRequestDelegate <NSObject>

@optional
- (void)request:(TaobaoRequest *)request didReceiveResponse:(NSURLResponse *)response;
- (void)request:(TaobaoRequest *)request didReceiveRawData:(NSData *)data;
- (void)request:(TaobaoRequest *)request didFailWithError:(NSError *)error;
- (void)request:(TaobaoRequest *)request didFinishLoadingWithResult:(id)result;

@end

@interface TaobaoRequest : NSObject {
    
}

@property (nonatomic,assign) TaobaoEngine *tbEngine;

+ (TaobaoRequest *)requestWithURL:(NSString *)url
                       httpMethod:(HttpRequestMethod)httpMethod
                           params:(NSDictionary *)params
                         delegate:(id <TaobaoRequestDelegate>)delegate;

+ (TaobaoRequest *)requestWithAppkey:(NSString *)appKey
                           appSecret:(NSString *)appSecret
                             session:(NSString *)accessToken
                                 URL:(NSString *)url
                          httpMethod:(HttpRequestMethod)httpMethod
                              params:(NSDictionary *)params
                            delegate:(id <TaobaoRequestDelegate>)delegate;

- (void)connect;
- (void)disconnect;

@end