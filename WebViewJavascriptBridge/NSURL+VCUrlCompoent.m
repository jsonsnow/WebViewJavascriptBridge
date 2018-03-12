//
//  NSURL+VCUrlCompoent.m
//  VCFinances
//
//  Created by chen liang on 2017/12/26.
//  Copyright © 2017年 chen liang. All rights reserved.
//

#import "NSURL+VCUrlCompoent.h"

@implementation NSURL (VCUrlCompoent)
@dynamic noQueryString;
@dynamic queryParams;
- (NSString *)noQueryString {
    NSString *urlString = self.absoluteString;
    NSRange range = [urlString rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return urlString;
    }
    NSString *urlKey = [urlString substringToIndex:range.location];
    return urlKey;
}

- (NSDictionary *)queryParams {
    NSMutableDictionary *params = @{}.mutableCopy;
    NSString *queryString = self.query;
    if (!queryString) return nil;
    if ([queryString rangeOfString:@"&"].location != NSNotFound) {
        NSArray *pairs = [queryString componentsSeparatedByString:@"&"];
        for (NSString *pair in pairs) {
            NSArray *elements = [pair componentsSeparatedByString:@"="];
            NSString *key = [[elements objectAtIndex:0] stringByRemovingPercentEncoding];
            NSString * value = [[elements objectAtIndex:1] stringByRemovingPercentEncoding];
            [params setObject:value forKey:key];
        }
    } else if ([queryString rangeOfString:@"="].location != NSNotFound) {
        NSArray *elements = [queryString componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByRemovingPercentEncoding];
        NSString *value = [[elements objectAtIndex:1] stringByRemovingPercentEncoding];
        [params setObject:value forKey:key];
    }
    return params;
}

@end
