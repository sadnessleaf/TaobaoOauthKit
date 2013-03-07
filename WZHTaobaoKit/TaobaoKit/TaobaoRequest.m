//
//  TaobaoRequest.m
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

#import "TaobaoRequest.h"
#import "TaobaoEngine.h"
#import "JSONKit.h"
#import <CommonCrypto/CommonDigest.h>

#define kTaobaoRequestTimeOutInterval 60.0

@interface NSString (URLEncode)

- (NSString *)URLEncodedString;

@end

@implementation NSString (URLEncode)

- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding {
    return [(NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[[self mutableCopy] autorelease], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), encoding) autorelease];
}
- (NSString *)URLEncodedString {
	return [self URLEncodedStringWithCFStringEncoding:kCFStringEncodingUTF8];
}

@end

@interface TaobaoEngine (TaobaoRequest)

- (void)requestDidFailWithInvalidToken:(NSError *)error;

@end

@interface NSDate (TaobaoRequest)

+ (NSString *)currentTimeStamp;

@end

@implementation NSDate (TaobaoRequest)

+ (NSString *)currentTimeStamp {
    NSString *curTimeStamp = NULL;
        
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
	[formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
	NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
	[formatter setTimeZone:timeZone];
	curTimeStamp = [formatter stringFromDate:[NSDate date]];
    
    NSLog(@"currentTimeStamp: %@",curTimeStamp);
    
    return curTimeStamp;
}

@end

@interface TaobaoRequest () {
    
}

@property (nonatomic,retain) NSString *url;
@property (nonatomic,assign) HttpRequestMethod httpMethod;
@property (nonatomic,retain) NSDictionary *params;

@property (nonatomic,retain) NSURLConnection *connection;
@property (nonatomic,retain) NSMutableData *responseData;

@property (nonatomic, assign) id <TaobaoRequestDelegate> delegate;

/* 上传图片
- (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString;
- (NSMutableData *)postBodyHasRawData:(BOOL *)hasRawData;
*/

- (void)handleResponseData:(NSData *)data;
- (id)parseJSONData:(NSData *)data error:(NSError **)error;

- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo;
- (void)failedWithError:(NSError *)error;

@end

@implementation TaobaoRequest

#pragma mark - TaobaoRequest Life Circle
- (void)dealloc {
    [_url release],_url = NULL;
    [_params release],_params = NULL;
    
    [_responseData release],_responseData = NULL;
    
    [_connection cancel];
    [_connection release],_connection = NULL;
    
    _tbEngine = NULL;
    _delegate = NULL;
    
    [super dealloc];
}
/* 上传图片
#pragma mark - TaobaoRequest Private Methods
- (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString {
    [body appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
}
- (NSMutableData *)postBodyHasRawData:(BOOL *)hasRawData {
    NSString *bodyPrefixString = [NSString stringWithFormat:@"--%@\r\n", kSinaWeiboRequestStringBoundary];
    NSString *bodySuffixString = [NSString stringWithFormat:@"\r\n--%@--\r\n", kSinaWeiboRequestStringBoundary];
    
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
    
    NSMutableData *body = [NSMutableData data];
    [self appendUTF8Body:body dataString:bodyPrefixString];
    
    for (id key in [params keyEnumerator])
    {
        if (([[params valueForKey:key] isKindOfClass:[UIImage class]]) || ([[params valueForKey:key] isKindOfClass:[NSData class]]))
        {
            [dataDictionary setObject:[params valueForKey:key] forKey:key];
            continue;
        }
        
        [self appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", key, [params valueForKey:key]]];
        [self appendUTF8Body:body dataString:bodyPrefixString];
    }
    
    if ([dataDictionary count] > 0)
    {
        *hasRawData = YES;
        for (id key in dataDictionary)
        {
            NSObject *dataParam = [dataDictionary valueForKey:key];
            
            if ([dataParam isKindOfClass:[UIImage class]])
            {
                NSData* imageData = UIImagePNGRepresentation((UIImage *)dataParam);
                [self appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file\"\r\n", key]];
                [self appendUTF8Body:body dataString:[NSString stringWithString:@"Content-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n"]];
                [body appendData:imageData];
            }
            else if ([dataParam isKindOfClass:[NSData class]])
            {
                [self appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file\"\r\n", key]];
                [self appendUTF8Body:body dataString:[NSString stringWithString:@"Content-Type: content/unknown\r\nContent-Transfer-Encoding: binary\r\n\r\n"]];
                [body appendData:(NSData*)dataParam];
            }
            [self appendUTF8Body:body dataString:bodySuffixString];
        }
    }
    
    return body;
}
 */
- (void)handleResponseData:(NSData *)data {
    if (_delegate && [_delegate respondsToSelector:@selector(request:didReceiveRawData:)]) {
        [_delegate request:self didReceiveRawData:data];
    }
	
	NSError *error = nil;
	id result = [self parseJSONData:data error:&error];
	
	if (error) {
		[self failedWithError:error];
	}
	else {
        BOOL hasError = NO;
        NSDictionary *error_dic = NULL;
        
        if ([result isKindOfClass:[NSDictionary class]]) {
            error_dic = [result valueForKey:@"error_response"];
            hasError = [error_dic isKindOfClass:[NSDictionary class]];
        }
        
        if (hasError) {
            NSLog(@"error_dic: %@",error_dic);
            
            NSString *error_msg = [error_dic objectForKey:@"msg"];
            NSInteger error_code = [[error_dic objectForKey:@"code"] intValue];
            
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      error_msg, NSLocalizedDescriptionKey, nil];
            
            NSString *sub_code = [error_dic valueForKey:@"sub_code"];
            NSString *sub_msg = [error_dic valueForKey:@"sub_msg"];
            
            if (sub_code.length > 0) {
                [userInfo setValue:sub_code forKey:@"sub_code"];
            }
            
            if (sub_msg.length > 0) {
                [userInfo setValue:sub_msg forKey:@"sub_msg"];

            }
            
            NSError *error = [NSError errorWithDomain:kTaobaoAPIErrorDomain
                                                 code:error_code
                                             userInfo:userInfo];
            
            if (error_code == 21314     //Token已经被使用 无效
                || error_code == 21315  //Token已经过期 无效
                || error_code == 44     //Token不合法 有效
                || error_code == 21317  //Token不合法 无效
                || error_code == 53     //token过期 有效
                || error_code == 21332) //Token不合法 无效
            {
                [_tbEngine requestDidFailWithInvalidToken:error];
            }
            else {
                [self failedWithError:error];
            }
        }
        else {
            if (_delegate && [_delegate respondsToSelector:@selector(request:didFinishLoadingWithResult:)]) {
                [_delegate request:self didFinishLoadingWithResult:(result == nil ? data : result)];
            }
        }
	}
}
- (id)parseJSONData:(NSData *)data error:(NSError **)error {
    NSError *parseError = nil;
	id result = [data objectFromJSONDataWithParseOptions:JKParseOptionStrict error:&parseError];
	
	if (parseError && (error != nil)) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  parseError, @"error",
                                  @"Data parse error", NSLocalizedDescriptionKey, nil];
        *error = [self errorWithCode:500
                            userInfo:userInfo];
	}
	
	return result;
}
- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo {
    return [NSError errorWithDomain:kTaobaoAPIErrorDomain code:code userInfo:userInfo];
}
- (void)failedWithError:(NSError *)error {
	if (_delegate && [_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
		[_delegate request:self didFailWithError:error];
	}
}
#pragma mark - TaobaoRequest Public Methods
+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(HttpRequestMethod)httpMethod {
    NSURL *parsedURL = [NSURL URLWithString:baseURL];
    NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
    
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in [params keyEnumerator]) {
        if (([[params objectForKey:key] isKindOfClass:[UIImage class]]) || ([[params objectForKey:key] isKindOfClass:[NSData class]])) {
            if (httpMethod == GET) {
                NSLog(@"can not use GET to upload a file");
            }
            
            continue;
        }
        
        NSString *escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                      NULL, /* allocator */
                                                                                      (CFStringRef)[params objectForKey:key],
                                                                                      NULL, /* charactersToLeaveUnescaped */
                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                      kCFStringEncodingUTF8);
        
        [pairs addObject:[NSString stringWithFormat:@"%@=%@",key,escaped_value]];
        [escaped_value release];
    }
    
    NSString *query = [pairs componentsJoinedByString:@"&"];
    
    return [NSString stringWithFormat:@"%@%@%@",baseURL,queryPrefix,query];
}
+ (NSString *)md5:(NSString *)str {
	NSLog(@"description: %@",[str description]);
	
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [[NSString stringWithFormat:
			 @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			 result[0], result[1], result[2], result[3],
			 result[4], result[5], result[6], result[7],
			 result[8], result[9], result[10], result[11],
			 result[12], result[13], result[14], result[15]
			 ] uppercaseString];
}
+ (NSDictionary *)serializedParams:(NSDictionary *)param appSecret:(NSString *)appSecret {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:param];
    NSMutableArray *pairs = [NSMutableArray array];
    
    for (NSString *key in [dic keyEnumerator]) {
        if (([[dic objectForKey:key] isKindOfClass:[UIImage class]]) || ([[dic objectForKey:key] isKindOfClass:[NSData class]])) {
            //参数为data的时候 不需要加密
            continue;
        }
        
        [pairs addObject:[NSString stringWithFormat:@"%@%@",key,[dic valueForKey:key]]];
    }
            
    pairs = [NSMutableArray arrayWithArray:[pairs sortedArrayUsingSelector:@selector(compare:)]];
    
    [pairs insertObject:appSecret atIndex:0];
    [pairs addObject:appSecret];
    
    NSString *query = [pairs componentsJoinedByString:@""];
    NSString *sign = [TaobaoRequest md5:query];
    
    [dic setValue:sign forKey:@"sign"];
    
    NSLog(@"new param: %@",dic);
    
    return [NSDictionary dictionaryWithDictionary:dic];
}
+ (TaobaoRequest *)requestWithURL:(NSString *)url
                       httpMethod:(HttpRequestMethod)httpMethod
                           params:(NSDictionary *)params
                         delegate:(id <TaobaoRequestDelegate>)delegate {
    TaobaoRequest *request = [[[TaobaoRequest alloc] init] autorelease];
    
    request.url = url;
    request.httpMethod = httpMethod;
    request.params = params;
    request.delegate = delegate;
    
    return request;
}
+ (TaobaoRequest *)requestWithAppkey:(NSString *)appKey
                           appSecret:(NSString *)appSecret
                             session:(NSString *)accessToken
                                 URL:(NSString *)url
                          httpMethod:(HttpRequestMethod)httpMethod
                              params:(NSDictionary *)params
                            delegate:(id <TaobaoRequestDelegate>)delegate {
    // add the access token field
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParams setValue:accessToken forKey:@"session"];
    [mutableParams setValue:[NSDate currentTimeStamp] forKey:@"timestamp"];
    [mutableParams setValue:@"json" forKey:@"format"];
    [mutableParams setValue:appKey forKey:@"app_key"];
    [mutableParams setValue:@"2.0" forKey:@"v"];
    [mutableParams setValue:@"md5" forKey:@"sign_method"];

    NSDictionary *param = [TaobaoRequest serializedParams:mutableParams appSecret:appSecret];
    
    return [TaobaoRequest requestWithURL:url
                              httpMethod:httpMethod
                                  params:param
                                delegate:delegate];
}
- (void)connect {
    NSString *urlString = [[self class] serializeURL:_url params:_params httpMethod:_httpMethod];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:kTaobaoRequestTimeOutInterval];
    [request setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]]];
    [request setHTTPMethod:self.httpMethod == GET ? @"GET" : @"POST"];
    
    /* 上传图片
    if (self.httpMethod == POST) {
        BOOL hasRawData = NO;
        
        [request setHTTPBody:[self postBodyHasRawData:&hasRawData]];
        
        if (hasRawData) {
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kSinaWeiboRequestStringBoundary];
            [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        }
    }
     */
    
    self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES] autorelease];
}
- (void)disconnect {
    self.responseData = NULL;
    
    [_connection cancel];
    self.connection = NULL;
}
#pragma mark - NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	self.responseData = [[[NSMutableData alloc] init] autorelease];
	
	if (_delegate && [_delegate respondsToSelector:@selector(request:didReceiveResponse:)]) {
		[_delegate request:self didReceiveResponse:response];
	}
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_responseData appendData:data];
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
	return nil;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection {
	[self handleResponseData:_responseData];
    
	self.responseData = NULL;
    
    [_connection cancel];
    self.connection = NULL;    
}
- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error {
	[self failedWithError:error];
	
	self.responseData = NULL;
    
    [_connection cancel];
    self.connection = NULL;    
}
@end