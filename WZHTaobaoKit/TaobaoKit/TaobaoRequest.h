//
//  TaobaoRequest.h
//  WZHTaobaoKit
//
//  Created by sadnessleaf on 13-3-5.
//  Copyright (c) 2013年 sadnessleaf. All rights reserved.
//

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