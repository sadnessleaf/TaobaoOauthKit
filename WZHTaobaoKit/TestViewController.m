//
//  TestViewController.m
//  WZHTaobaoKit
//
//  Created by sadnessleaf on 13-3-4.
//  Copyright (c) 2013年 sadnessleaf. All rights reserved.
//

#import "TestViewController.h"
#import "TaobaoEngine.h"
#import "TaobaoRequest.h"

@interface TestViewController () <TaobaoEngineDelegate,TaobaoRequestDelegate> {
    UIButton *authBtn;
    UIButton *userInfoBtn;
    UIButton *logoutBtn;
}

@property (nonatomic,retain) TaobaoEngine *tbEngine;

@end

@implementation TestViewController

#pragma mark - Methods
- (void)auth {
    /*
     需要修改
     kTaobaoAppKey
     kTaobaoAppSecret
     kTaobaoCallBackURL
     为你申请的应用的对应值
     */
    TaobaoEngine *tbEngine = [[TaobaoEngine alloc] initWithAppKey:kTaobaoAppKey appSecret:kTaobaoAppSecret redirectURL:kTaobaoCallBackURL];
    tbEngine.delegate = self;
    tbEngine.rootViewController = self;
    self.tbEngine = tbEngine;
    [tbEngine release];
    
    [_tbEngine logIn];
}
- (void)getUserInfo {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:@"taobao.user.seller.get" forKey:@"method"];
    [param setValue:@"user_id,nick,sex,seller_credit,type,has_more_pic,item_img_num,item_img_size,prop_img_num,prop_img_size,auto_repost,promoted_type,status,alipay_bind,consumer_protection,avatar,liangpin,sign_food_seller_promise,has_shop,is_lightning_consignment,has_sub_stock,is_golden_seller,vip_info,magazine_subscribe,vertical_market,online_gaming" forKey:@"fields"];//,tsc,cid,cat_name,props,props_str,binds_str,sale_props_str,name,binds,sale_props,price,desc,pic_url,modified,product_imgs,product_prop_imgs,status,vertical_market,customer_props,property_alias
    
    [_tbEngine requestWithParams:param httpMethod:GET delegate:self];
}
- (void)logout {
    [_tbEngine logOut];
}
#pragma mark - Dealloc & Init
- (void)dealloc {
    [_tbEngine release],_tbEngine = NULL;
    
    [super dealloc];
}
- (id)init {
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - View Control Methods
- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    view.backgroundColor = [UIColor whiteColor];
    self.view = view;
    [view release];
    
    CGRect frame = CGRectZero;
    frame.origin = CGPointMake(110, 100);
    frame.size = CGSizeMake(100, 42);
    
    authBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    authBtn.frame = frame;
    [authBtn setTitle:@"授权" forState:UIControlStateNormal];
    [authBtn addTarget:self action:@selector(auth) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:authBtn];
    
    frame.origin = CGPointMake(110, 160);
    
    userInfoBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    userInfoBtn.frame = frame;
    [userInfoBtn setTitle:@"用户信息" forState:UIControlStateNormal];
    [userInfoBtn addTarget:self action:@selector(getUserInfo) forControlEvents:UIControlEventTouchUpInside];
    userInfoBtn.hidden = YES;
    [self.view addSubview:userInfoBtn];
    
    frame.origin = CGPointMake(110, 210);
    
    logoutBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    logoutBtn.frame = frame;
    [logoutBtn setTitle:@"登出" forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    logoutBtn.hidden = YES;
    [self.view addSubview:logoutBtn];
}
- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - TaobaoEngine Delegate Methods
- (void)engineDidLogIn:(TaobaoEngine *)engine {
    NSLog(@"engineDidLogIn");
    
    authBtn.hidden = YES;
    userInfoBtn.hidden = NO;
    logoutBtn.hidden = NO;
}
- (void)engineDidLogOut:(TaobaoEngine *)engine {
    NSLog(@"engineDidLogOut");
    
    authBtn.hidden = NO;
    userInfoBtn.hidden = YES;
    logoutBtn.hidden = YES;
}
- (void)engineLogInDidCancel:(TaobaoEngine *)engine {
    NSLog(@"engineLogInDidCancel");

    authBtn.hidden = NO;
    userInfoBtn.hidden = YES;
    logoutBtn.hidden = YES;
}
- (void)engine:(TaobaoEngine *)engine logInDidFailWithError:(NSError *)error {
    NSLog(@"logInDidFailWithError");
    NSLog(@"%@",error);

    authBtn.hidden = NO;
    userInfoBtn.hidden = YES;
    logoutBtn.hidden = YES;
}
- (void)engine:(TaobaoEngine *)engine accessTokenInvalidOrExpired:(NSError *)error {
    NSLog(@"accessTokenInvalidOrExpired");
    NSLog(@"%@",error);

    authBtn.hidden = NO;
    userInfoBtn.hidden = YES;
    logoutBtn.hidden = YES;
    
    [engine clear];
}
#pragma mark - TaobaoRequest Delegate Methods
- (void)request:(TaobaoRequest *)request didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
}
- (void)request:(TaobaoRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog(@"%@",error);
}
- (void)request:(TaobaoRequest *)request didFinishLoadingWithResult:(id)result {
    NSLog(@"didFinishLoadingWithResult");
    if ([result isKindOfClass:[NSDictionary class]]) {
        NSLog(@"%@",(NSDictionary *)result);
    }
}
@end