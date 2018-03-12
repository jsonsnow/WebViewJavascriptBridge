//
//  VCJSLinkHandler.h
//  VCFinances
//
//  Created by chen liang on 2017/12/26.
//  Copyright © 2017年 chen liang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^VCJSUrlkHandler)(NSDictionary *params);
@interface VCJSLinkHandler : NSObject
- (void)registUrlString:(NSString *)urlString handler:(VCJSUrlkHandler)handler;
- (void)removeUrlString:(NSURL *)urlString;
- (BOOL)handler:(NSURL *)url urlRegular:(NSString *)urlRegual;
@end
