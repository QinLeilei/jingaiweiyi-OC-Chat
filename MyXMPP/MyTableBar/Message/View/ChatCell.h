//
//  ChatCell.h
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/19.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import <UIKit/UIKit.h>
extern CGFloat const kTopAndBottomMarginHeight;
extern CGFloat const kMessageLabelTBMarginHeight;
@interface ChatCell : UITableViewCell
@property (nonatomic, assign, getter=isSend) BOOL send;
@property (strong, nonatomic) UIButton *iconButton;
@property (strong, nonatomic) UILabel *messageLabel;

/** 音频的地址 */
@property (nonatomic, strong) NSString *audioPath;
@end
