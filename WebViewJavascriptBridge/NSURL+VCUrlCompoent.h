//
//  NSURL+VCUrlCompoent.h
//  VCFinances
//
//  Created by chen liang on 2017/12/26.
//  Copyright © 2017年 weiclicai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (VCUrlCompoent)
@property (nonatomic, strong) NSString *noQueryString;
@property (nonatomic, strong) NSDictionary *queryParams;

@end
