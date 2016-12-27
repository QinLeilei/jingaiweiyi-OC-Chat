//
//  ChatMessageBaseCell.h
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/22.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatMessageBaseCell;
@protocol BaseCellDelegate <NSObject>

- (void)longPress:(UILongPressGestureRecognizer *)longRecognizer;

@optional
- (void)headImageClicked:(NSString *)eId;
- (void)reSendMessage:(ChatMessageBaseCell *)baseCell;

@end

@interface ChatMessageBaseCell : UITableViewCell

// 消息模型
@property (nonatomic, strong) ICMessageFrame *modelFrame;
// 头像
@property (nonatomic, strong) ICHeadImageView *headImageView;
// 内容气泡视图
@property (nonatomic, strong) UIImageView *bubbleView;
// 菊花视图所在的view
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
// 重新发送
@property (nonatomic, strong) UIButton *retryButton;

@end
