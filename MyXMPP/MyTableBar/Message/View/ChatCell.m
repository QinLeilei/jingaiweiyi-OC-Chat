//
//  ChatCell.m
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/19.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import "ChatCell.h"
#import "TFRecordTools.h"

CGFloat const kTopAndBottomMarginHeight = 0;
CGFloat const kMessageLabelTBMarginHeight = 10;
CGFloat const kMessageLabelLRMarginHeight = 27;
@interface ChatCell ()
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *chatImageView;
@property (nonatomic, strong) UIImage *sendImage;
@property (nonatomic, strong) UIImage *reciveImage;
@end

@implementation ChatCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        [self setupUI:reuseIdentifier];
    }
    return self;
}

- (void)setupUI:(NSString *)reuseIdentifier {
    
//    self.contentView.backgroundColor = TF_RANDOM_COLOR;
    
    [self.contentView addSubview:self.iconButton];
    [self.contentView addSubview:self.messageLabel];
    [self.contentView addSubview:self.chatImageView];
    [self.contentView addSubview:self.button];
    
    if ([reuseIdentifier isEqualToString:@"ReciveCell"]) {
        [self reciveUI];
    } else if ([reuseIdentifier isEqualToString:@"SendCell"]) {
        [self sendUI];
        self.send = YES;
    }
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.chatImageView.mas_top).offset(kMessageLabelTBMarginHeight);
        make.left.equalTo(self.chatImageView.mas_left).offset(kMessageLabelLRMarginHeight);
        make.bottom.equalTo(self.chatImageView.mas_bottom).offset(-kMessageLabelTBMarginHeight);
        make.right.equalTo(self.chatImageView.mas_right).offset(-kMessageLabelLRMarginHeight);
    }];
    [self.contentView bringSubviewToFront:self.messageLabel];
}

- (void)reciveUI {
    [self.iconButton setImage:[UIImage imageNamed:@"chat_recive_head"] forState:UIControlStateNormal];
    [self.iconButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(kTopAndBottomMarginHeight);
        make.left.equalTo(self.contentView.mas_left).offset(8);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    self.chatImageView.image = self.reciveImage;
    [self.chatImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(kTopAndBottomMarginHeight);
        make.left.equalTo(self.iconButton.mas_right).offset(8);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-kTopAndBottomMarginHeight);
    }];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.chatImageView.mas_right).offset(1);
        make.top.right.bottom.equalTo(@0);
    }];
}
- (void)sendUI {
    [self.iconButton setImage:[UIImage imageNamed:@"chat_send_head"] forState:UIControlStateNormal];
    [self.iconButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(kTopAndBottomMarginHeight);
        make.right.equalTo(self.contentView.mas_right).offset(-8);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    self.chatImageView.image = self.sendImage;
    [self.chatImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(kTopAndBottomMarginHeight);
        make.right.equalTo(self.iconButton.mas_left).offset(-8);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-kTopAndBottomMarginHeight);
    }];
    
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.chatImageView.mas_left).offset(-1);
        make.top.left.bottom.equalTo(@0);
    }];
}

#pragma mark - 懒加载
- (UIButton *)button {
    if (_button != nil) {
        return _button;
    }
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button.backgroundColor = [UIColor clearColor];
    return _button;
}

- (UIButton *)iconButton {
    if (_iconButton != nil) {
        return _iconButton;
    }
    _iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_iconButton setImage:[UIImage imageNamed:@"chat_recive_head"] forState:UIControlStateNormal];
    return _iconButton;
}

- (UIImageView *)chatImageView {
    if (_chatImageView != nil) {
        return _chatImageView;
    }
    _chatImageView = [[UIImageView alloc] init];
    return _chatImageView;
}

- (UILabel *)messageLabel {
    if (_messageLabel != nil) {
        return _messageLabel;
    }
    _messageLabel = [[UILabel alloc] init];
    _messageLabel.numberOfLines = 0;
    _messageLabel.font = [UIFont systemFontOfSize:14];
    return _messageLabel;
}

- (UIImage *)sendImage {
    if (_sendImage != nil) {
        return _sendImage;
    }
    _sendImage = [UIImage imageNamed:@"chat_send_nor"];
    CGSize imageSize = _sendImage.size;
    _sendImage = [_sendImage stretchableImageWithLeftCapWidth:imageSize.width * 0.5 topCapHeight:imageSize.height * 0.5];
    
    return _sendImage;
}
- (UIImage *)reciveImage {
    if (_reciveImage != nil) {
        return _reciveImage;
    }
    _reciveImage = [UIImage imageNamed:@"chat_recive_nor"];
    CGSize imageSize = _reciveImage.size;
    _reciveImage = [_reciveImage stretchableImageWithLeftCapWidth:imageSize.width * 0.5 topCapHeight:imageSize.height * 0.5];
    
    return _reciveImage;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // 如果有音频数据，直接播放音频
    if (self.audioPath != nil) {
        // 播放音频
        self.messageLabel.textColor = [UIColor redColor];
        
        // 如果单例的块代码中包含self，一定使用weakSelf
        __weak ChatCell *weakSelf = self;
        [[TFRecordTools sharedRecorder] playPath:self.audioPath completion:^{
            weakSelf.messageLabel.textColor = [UIColor whiteColor];
        }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
