//
//  VCJSLinkHandler.m
//  VCFinances
//
//  Created by chen liang on 2017/12/26.
//  Copyright © 2017年 weiclicai. All rights reserved.
//

#import "VCJSLinkHandler.h"
#import "NSURL+VCUrlCompoent.h"

@interface VCJSLinkHandler ()
@property (nonatomic, strong) NSMutableDictionary *callBackHandlers;
@property (nonatomic, strong) NSMutableArray *registerUrlArrays;
@end

@implementation VCJSLinkHandler
- (instancetype)init {
    self = [super init];
    _callBackHandlers = @{}.mutableCopy;
    _registerUrlArrays = @[].mutableCopy;
    return self;
}
- (void)registUrlString:(NSString *)urlString handler:(VCJSUrlkHandler)handler  {
    if (urlString) {
        self.callBackHandlers[urlString] = handler;
        [self.registerUrlArrays addObject:urlString];
    } else {
        NSLog(@"url error plase check you register url");
    }
}
- (void)removeUrlString:(NSURL *)urlString {
    [self.registerUrlArrays removeObject:urlString];
    [self.callBackHandlers removeObjectForKey:urlString];
}
- (BOOL)handler:(NSURL *)url urlRegular:(NSString *)urlRegual{
    VCJSUrlkHandler handler = self.callBackHandlers[url.noQueryString];
    if (handler) {
        handler(url.queryParams);
        return YES;
    }
    return NO;
}
@end
