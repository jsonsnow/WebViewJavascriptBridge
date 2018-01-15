//
//  VCWKWebViewController.m
//  VCFinances
//
//  Created by chenwanwei on 2017/12/25.
//  Copyright © 2017年 weiclicai. All rights reserved.
//

#import "VCWKWebViewController.h"

#import "WebViewJavascriptBridge.h"
#import "VCJSLinkHandler.h"

static UIColor * colorWithHexString(NSString *color)
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:1.0];
}
@interface VCWKWebViewController ()<WKNavigationDelegate>

@property WebViewJavascriptBridge* bridge;
@property (nonatomic, strong) VCJSLinkHandler *linkBridge;
@property (nonatomic, assign) BOOL isHideStatusBar;

@end

@implementation VCWKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_bridge) { return; }
    
    WKWebView* webView = [[NSClassFromString(@"WKWebView") alloc] initWithFrame:self.view.bounds];
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    [WebViewJavascriptBridge enableLogging];
    _bridge = [WebViewJavascriptBridge bridgeForWebView:webView];
    [_bridge setWebViewDelegate:self];
    
    [_bridge registerHandler:@"getUser" handler:^(id data, WVJBResponseCallback responseCallback) {
       // DDLogDebug(@"getUserLog: %@", data);
        responseCallback(@"UserData");
    }];
    
    [_bridge registerHandler:@"setTitlebar" handler:^(id data, WVJBResponseCallback responseCallback) {
       // DDLogDebug(@"TitlebarColorLog: %@", data);
        [self jsCallOCForTitlebarSetUpWithData:data];
        responseCallback(@"success"); //success或fail
    }];
    
    [_bridge registerHandler:@"share" handler:^(id data, WVJBResponseCallback responseCallback) {
       // DDLogDebug(@"shareDataLog: %@", data);
        responseCallback(@"shareData");
    }];
    
    [_bridge registerHandler:@"openPage" handler:^(id data, WVJBResponseCallback responseCallback) {
       // DDLogDebug(@"openPageLog: %@", data);
        responseCallback(@"openPage");
    }];

    [self.linkBridge registUrlString:@"weic://apath" handler:^(NSDictionary *params) {
       
        NSLog(@"-------accept a link message------------:%@",params);
    }];
    [self loadVCH5Page:webView];
    
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationSlide;
}

- (BOOL)prefersStatusBarHidden {
    return self.isHideStatusBar;
}


/**
 导航栏等设置
 
 @param data js传递的参数
 @return 返回参数有效性告知是否成功
 */
- (BOOL)jsCallOCForTitlebarSetUpWithData:(id)data{
    
    NSDictionary *dic = (NSDictionary *)data;
    BOOL result = [self parameterValidCheckForParameter:dic];
    
    if (dic[@"titlebarColor"]) {
        NSString *colorStr = [self getHexColorStrFromString:[dic[@"titlebarColor"] description]];
        self.navigationController.navigationBar.barTintColor = colorWithHexString(colorStr);
    }
    if (dic[@"title"]&&(![dic[@"title"] isEqualToString:@""])) {
        self.navigationItem.title = dic[@"title"];
    }
    if (dic[@"titleColor"]) {
        NSString *colorStr = [self getHexColorStrFromString:[dic[@"titleColor"] description]];
        [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:colorWithHexString(colorStr)}];
    }
    if (dic[@"isShowTitleBar"]) {
        BOOL isBack = (BOOL)dic[@"isShowTitleBar"];
        self.navigationController.navigationBarHidden = !isBack;
    }
    if (dic[@"isBack"]) {
        BOOL isBack = (BOOL)dic[@"isBack"];
        [self.navigationController.navigationBar.backItem setHidesBackButton:isBack];
        if (!isBack) {
            self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@""] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonAction:)];
        }
    }
    if (dic[@"statusBar"]) {
        NSString *colorStr = [self getHexColorStrFromString:[dic[@"statusBar"] description]];
        UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
            statusBar.backgroundColor = colorWithHexString(colorStr);
        }
    }
    if (dic[@"isHideStatusBar"]) {
        self.isHideStatusBar = (BOOL)dic[@"isHideStatusBar"];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    if (dic[@"isShowTabbar"]) {
        BOOL isBack = (BOOL)dic[@"isShowTabbar"];
        self.tabBarController.tabBar.hidden = !isBack;
    }
    
    return result;
}

- (BOOL)parameterValidCheckForParameter:(NSDictionary *)parameter{
    
    NSArray *dicKeys = parameter.allKeys;
    NSArray *needParameters = @[@"titlebarColor",@"title",@"titleColor",@"isShowTitleBar",@"isBack",@"statusBar",@"isHideStatusBar",@"isShowTabbar"];
    
    NSSet *setdicKeys = [NSSet setWithArray:dicKeys];
    NSSet *setneedParameters = [NSSet setWithArray:needParameters];
    
    if ([setneedParameters isSubsetOfSet:setdicKeys]) {
        return YES;
    } else {
        return NO;
    }
}


- (NSString *)getHexColorStrFromString:(NSString *)colorString
{
    int colorInt=[colorString intValue];
    if(colorInt<=0){
        return @"000000";
    }
    
    NSString *nLetterValue;
    NSString *colorString16 =@"";
    int ttmpig;
    for (int i = 0; i<9; i++)
    {
        ttmpig=colorInt%16;
        colorInt=colorInt/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:nLetterValue=[[NSString alloc]initWithFormat:@"%i",ttmpig];
        }
        colorString16 = [nLetterValue stringByAppendingString:colorString16];
        if (colorInt == 0)
            break;
    }
    colorString16 = [[colorString16 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString]; //去掉前后空格换行符
    return colorString16;
}


#pragma mark - webViewNavigation delegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([self.linkBridge handler:navigationAction.request.URL urlRegular:nil]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidStartLoad");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"webViewDidFinishLoad");
}

- (void)loadVCH5Page:(WKWebView*)webView {
    
//    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
//    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
//    NSURL *baseURL = [NSURL fileURLWithPath:htmlPath];

    NSURLRequest *requset = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    
    [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id result, NSError *error) {
        //DDLogDebug(@"userAgent：%@",result);
        NSString *userAgent = result;
        if (![userAgent containsString:@"vcuseragen_ios"]) {
            NSString *newUserAgent = [userAgent stringByAppendingString:@"/vcuseragen_ios"];
            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:newUserAgent, @"UserAgent", nil];
            [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [webView setCustomUserAgent:newUserAgent];
        }
//        [webView loadHTMLString:appHtml baseURL:baseURL];
        [webView loadRequest:requset];
    }];
}
#pragma mark -- getter and setter
- (VCJSLinkHandler *)linkBridge {
    if (!_linkBridge) {
        _linkBridge = [[VCJSLinkHandler alloc] init];
    }
    return _linkBridge;
}

@end
