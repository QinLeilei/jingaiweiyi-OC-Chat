//
//  NSObject+TFCommon.m
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/28.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import "NSObject+TFCommon.h"
#import <objc/runtime.h>
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

// 打印一个对象的所有属性和值
- (NSString *)printObjectAllProperty {
    NSMutableString* desc = [NSMutableString new];
    /**< 获取所有属性 */
    NSArray* propertyArray = [self getAllProperties];
    [desc appendString:@"{\r"];
    for (NSString* key in propertyArray) {
        [desc appendFormat:@"  %@ : %@\r",key, [self valueForKey:key]];
    }
    [desc appendString:@"\r}"];
    return desc;
}

//获取对象的所有属性
- (NSArray *)getAllProperties
{
    u_int count;
    objc_property_t *properties  =class_copyPropertyList([self class], &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++)
    {
        const char* propertyName =property_getName(properties[i]);
        [propertiesArray addObject: [NSString stringWithUTF8String: propertyName]];
    }
    free(properties);
    return propertiesArray;
}

//Model 转成字典
- (NSDictionary *)dictionaryWithAllProperties
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    free(properties);
    return props;
}


@end
