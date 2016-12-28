//
//  NSObject+TFCommon.m
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/28.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import "NSObject+TFCommon.h"

@implementation NSObject (TFCommon)
-(NSString *)nameOfClass {
    return [NSString stringWithUTF8String:class_getName([self class])];
}
- (NSDictionary *)propertyDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    unsigned count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        [dict setObject:key forKey:key];
    }
    
    free(properties);
    
    // Add all superclass properties as well, until it hits NSObject
    NSString *superClassName = [[self superclass] nameOfClass];
    if (![superClassName isEqualToString:@"NSObject"]) {
        for (NSString *property in [[[self superclass] propertyDictionary] allKeys]) {
            [dict setObject:property forKey:property];
        }
    }
    
    return dict;
}

- (NSString *)printObjectAllProperty {
    NSMutableString* desc = [NSMutableString new];
    NSArray* propertyArray = [[self propertyDictionary] allKeys];
    [desc appendString:@"{\r"];
    
    for (NSString* key in propertyArray) {
        [desc appendFormat:@"  %@ : %@\r",key,[self valueForKey:key]];
    }
    [desc appendString:@"\r}"];
    return desc;
}

@end
