//
//  NSObject+TFCommon.h
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/28.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TFCommon)

- (NSString *)printObjectAllProperty;
- (NSArray *)getAllProperties;
- (NSDictionary *)dictionaryWithAllProperties;
@end
