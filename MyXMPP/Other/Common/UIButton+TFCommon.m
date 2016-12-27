//
//  UIButton+TFCommon.m
//  YunShangShiJi
//
//  Created by jingaiweiyi on 2016/11/28.
//  Copyright © 2016年 ios-1. All rights reserved.
//

#import "UIButton+TFCommon.h"
#import <objc/runtime.h>

static const char btnKey;
@implementation UIButton (TFCommon)

-(void)handleClickEvent:(UIControlEvents)aEvent withClickBlock:(ButtonClickBlock)block
{
    if (block) {
        objc_setAssociatedObject(self, &btnKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self addTarget:self action:@selector(buttonClick:) forControlEvents:aEvent];
    }
}

-(void)buttonClick:(UIButton *)sender
{
    ButtonClickBlock blockClick = objc_getAssociatedObject(self, &btnKey);
    if (blockClick != nil) {
        blockClick(sender);
    }
}

@end
