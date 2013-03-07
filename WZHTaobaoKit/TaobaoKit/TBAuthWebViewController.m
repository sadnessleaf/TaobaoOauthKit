//
//  TBAuthWebViewController.m
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

#import "TBAuthWebViewController.h"

@interface NSString (URLEncoding)

- (NSString *)URLEncodedString;
- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding;

@end

@implementation NSString (URLEncoding)

- (NSString *)URLEncodedString {
	return [self URLEncodedStringWithCFStringEncoding:kCFStringEncodingUTF8];
}
- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding {
	return [(NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[[self mutableCopy] autorelease], NULL, CFSTR("￼!*'();:@&=+$,/?%#[]"), encoding) autorelease];
}

@end

@interface TBAuthWebViewController () <UIWebViewDelegate> {
    UIActivityIndicatorView *indicatorView;
	UIWebView *webView;
    
    BOOL hasCode;
}

@property (nonatomic,assign) id <TBAuthWebViewControllerDelegate> delegate;
@property (nonatomic,retain) NSString *appkey;
@property (nonatomic,retain) NSString *redirectURL;
@property (nonatomic,retain) NSDictionary *oauthInfo;
@property (nonatomic,retain) NSError *error;

@end

@implementation TBAuthWebViewController

#pragma mark - Methods
- (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params requestMethod:(HttpRequestMethod)requestMethod {
    if (requestMethod == POST) {
        return baseURL;
    }
    
    NSURL *parsedURL = [NSURL URLWithString:baseURL];
    NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
    NSString *query = [self stringFromDictionary:params];
    
    return [NSString stringWithFormat:@"%@%@%@",baseURL,queryPrefix,query];
}
- (NSString *)stringFromDictionary:(NSDictionary *)dict {
    NSMutableArray *pairs = [NSMutableArray array];
	for (NSString *key in [dict keyEnumerator]){
		if (!([[dict valueForKey:key] isKindOfClass:[NSString class]])) {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [dict objectForKey:key]]];
		}
        else {
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [[dict objectForKey:key] URLEncodedString]]];
        }
	}
	
	return [pairs componentsJoinedByString:@"&"];
}
- (NSString *)getParamValueFromUrl:(NSString *)url paramName:(NSString *)paramName {
    if (![paramName hasSuffix:@"="]) {
        paramName = [NSString stringWithFormat:@"%@=",paramName];
    }
    
    NSString *str = nil;
    NSRange start = [url rangeOfString:paramName];
    if (start.location != NSNotFound) {
        // confirm that the parameter is not a partial name match
        unichar c = '?';
        if (start.location != 0) {
            c = [url characterAtIndex:start.location - 1];
        }
        
        if (c == '?' || c == '&' || c == '#') {
            NSRange end = [[url substringFromIndex:start.location + start.length] rangeOfString:@"&"];
            NSUInteger offset = start.location + start.length;
            str = end.location == NSNotFound ? [url substringFromIndex:offset] : [url substringWithRange:NSMakeRange(offset, end.location)];
            str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }
    
    return str;
}
#pragma mark - Dealloc & Init
- (void)dealloc {
    _delegate = NULL;
    
    [_appkey release],_appkey = NULL;
    [_redirectURL release],_redirectURL = NULL;
    [_oauthInfo release],_oauthInfo = NULL;
    [_error release],_error = NULL;
    
    [indicatorView release],indicatorView = NULL;
    [webView release],webView = NULL;
    
    [super dealloc];
}
- (id)initWithAppkey:(NSString *)appkey redirectURL:(NSString *)redirectURL delegate:(id <TBAuthWebViewControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        // Custom initialization
        self.appkey = appkey;
        self.redirectURL = redirectURL;
        self.delegate = delegate;
    }
    return self;
}
#pragma mark - View Control Methods
- (void)dismissModalViewController {
    [self dismissModalViewControllerAnimated:YES];
}
- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    view.backgroundColor = [UIColor whiteColor];
    self.view = view;
    [view release];
    
    webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.delegate = self;
    [self.view addSubview:webView];
    
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView setCenter:CGPointMake(webView.frame.size.width / 2.0f, webView.frame.size.height / 2.0f - 22)];
    indicatorView.hidesWhenStopped = YES;
    [self.view addSubview:indicatorView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (!self.navigationItem.leftBarButtonItem) {
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModalViewController)] autorelease];
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:@"token" forKey:@"response_type"];
    [param setValue:_appkey forKey:@"client_id"];
    [param setValue:_redirectURL forKey:@"redirect_uri"];
    //[param setValue:@"" forKey:@"state"]; 可选参数
    //[param setValue:@"" forKey:@"scope"]; 可选参数
    [param setValue:@"wap" forKey:@"view"];

    NSString *requestURL = [self serializeURL:kTaobaoAuthURL params:param requestMethod:GET];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestURL]
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:60.0];
    
    [webView loadRequest:request];
}
- (void)viewWillDisappear:(BOOL)animated {
    if (hasCode) {
        if (_delegate && [_delegate respondsToSelector:@selector(viewController:didSucceedWithOauthInfo:)]) {
            [_delegate viewController:self didSucceedWithOauthInfo:_oauthInfo];
        }
    }
    else {
        if (_error) {
            if (_delegate && [_delegate respondsToSelector:@selector(viewController:didFailuredWithError:)]) {
                [_delegate viewController:self didFailuredWithError:_error];
            }
        }
        else {
            if (_delegate && [_delegate respondsToSelector:@selector(viewControllerDidCancel:)]) {
                [_delegate viewControllerDidCancel:self];
            }
        }
    }
    
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UIWebViewDelegate Methods
- (void)webViewDidStartLoad:(UIWebView *)aWebView {
	[indicatorView startAnimating];
}
- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	[indicatorView stopAnimating];
}
- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
    [indicatorView stopAnimating];
}
- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *url = [[request URL] absoluteString];
    NSLog(@"url: %@",url);
    
    NSString *_appRedirectURI = _redirectURL;
    NSString *siteRedirectURI = [NSString stringWithFormat:@"%@#%@", kTaobaoAuthURL, _redirectURL];
    
    if ([url hasPrefix:_appRedirectURI] || [url hasPrefix:siteRedirectURI]) {
        NSString *error = [self getParamValueFromUrl:url paramName:@"error"];
        
        if (error) {
            NSString *error_description = [self getParamValueFromUrl:url paramName:@"error_description"];
            
            NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       error, @"error",
                                       error_description, NSLocalizedDescriptionKey, nil];
            
            NSError *aError = [NSError errorWithDomain:kTaobaoAPIErrorDomain code:TaobaoAPIErrorCodeAccessError userInfo:errorInfo];
            self.error = aError;
            
            hasCode = NO;
            [self dismissModalViewController];
        }
        else {
            NSString *access_token = [self getParamValueFromUrl:url paramName:@"access_token"];
            if (access_token) {                
                NSString *expires_in = [self getParamValueFromUrl:url paramName:@"expires_in"];
                NSString *refresh_token = [self getParamValueFromUrl:url paramName:@"refresh_token"];
                NSString *taobao_user_id = [self getParamValueFromUrl:url paramName:@"taobao_user_id"];
                NSString *taobao_user_nick = [self getParamValueFromUrl:url paramName:@"taobao_user_nick"];
                
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                [dic setValue:access_token forKey:@"access_token"];
                [dic setValue:expires_in forKey:@"expires_in"];
                [dic setValue:refresh_token forKey:@"refresh_token"];
                [dic setValue:taobao_user_id forKey:@"taobao_user_id"];
                [dic setValue:taobao_user_nick forKey:@"taobao_user_nick"];
                self.oauthInfo = [NSDictionary dictionaryWithDictionary:dic];
                
                hasCode = YES;
                [self dismissModalViewController];
            }
        }
        
        return NO;
    }
    
    return YES;
}
@end