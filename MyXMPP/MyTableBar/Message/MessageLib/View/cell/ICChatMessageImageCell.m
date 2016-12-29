//
//  ICChatMessageImageCell.m
//  XZ_WeChat
//
//  Created by 郭现壮 on 16/3/13.
//  Copyright © 2016年 gxz All rights reserved.
//

#import "ICChatMessageImageCell.h"
#import "ICMediaManager.h"
#import "ICMessageModel.h"
#import "ICMessage.h"
#import "ICFileTool.h"
#import "ICMessageHelper.h"

@interface ICChatMessageImageCell ()
@property (nonatomic, strong) UIButton *imageBtn;
@property (nonatomic, strong) UIImageView *imageV;
@property (nonatomic, strong) UIActivityIndicatorView *photoActivityView;
@end

@implementation ICChatMessageImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.imageV];
    }
    return self;
}



#pragma mark - Private Method

/**
 设置模型

 @param modelFrame 下载数据
 */
- (void)setModelFrame:(ICMessageFrame *)modelFrame
{
    [super setModelFrame:modelFrame];
    ICMediaManager *manager = [ICMediaManager sharedManager];
    NSString *srcUrl = modelFrame.model.mediaPath;
    
    self.imageV.image = nil;
    
    // 没有存过大小就下载，然后保存图片真实大小，再刷新;
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:srcUrl] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {

        if (image) {
            // 如果以前没有保存过
            if (![[ImageSizeManager shareManager] hasSrc:srcUrl]) {
                [[ImageSizeManager shareManager] saveImage:srcUrl size:image.size];
                if (self.mediaRefreshBlock) {
                    self.mediaRefreshBlock(self.currIndexPath);
                }
            }
#pragma mark - ------------------
            // 取图片
            self.imageV.frame = modelFrame.picViewF;
            self.bubbleView.image = nil;
            if (modelFrame.model.isSender) {    // 发送者
                UIImage *arrowImage = [manager arrowMeImage:image size:modelFrame.picViewF.size mediaPath:modelFrame.model.mediaPath isSender:modelFrame.model.isSender];
                self.imageV.image = arrowImage;
            } else { /**< 接收者 */
                NSString *orgImgPath = [manager originImgPath:modelFrame];
                if ([ICFileTool fileExistsAtPath:orgImgPath]) {
                    UIImage *orgImg = [manager imageWithLocalPath:orgImgPath];
                    UIImage *arrowImage = [manager arrowMeImage:orgImg size:modelFrame.picViewF.size mediaPath:orgImgPath isSender:modelFrame.model.isSender];
                    self.imageV.image = arrowImage;
                } else {
                    UIImage *arrowImage = [manager arrowMeImage:image size:modelFrame.picViewF.size mediaPath:modelFrame.model.mediaPath isSender:modelFrame.model.isSender];
                    self.imageV.image = arrowImage;
                }
            }
#pragma mark - ------------------
            
        }
    }];
}

- (void)imageBtnClick:(UIButton *)btn
{
    if (btn.currentBackgroundImage == nil) {
        return;
    }
    CGRect smallRect = [ICMessageHelper photoFramInWindow:btn];
    CGRect bigRect   = [ICMessageHelper photoLargerInWindow:btn];
    NSValue *smallValue = [NSValue valueWithCGRect:smallRect];
    NSValue *bigValue   = [NSValue valueWithCGRect:bigRect];
    [self routerEventWithName:GXRouterEventImageTapEventName
                     userInfo:@{MessageKey   : self.modelFrame,
                                @"smallRect" : smallValue,
                                @"bigRect"   : bigValue
                                }];
}

#pragma mark - Getter

- (UIButton *)imageBtn
{
    if (nil == _imageBtn) {
        _imageBtn = [[UIButton alloc] init];
        [_imageBtn addTarget:self action:@selector(imageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _imageBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _imageBtn.layer.masksToBounds = YES;
        _imageBtn.layer.cornerRadius = 5;
        _imageBtn.clipsToBounds = YES;
    }
    return _imageBtn;
}

- (UIActivityIndicatorView *)photoActivityView {
    if (_photoActivityView == nil) {
        _photoActivityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _photoActivityView;
}


- (UIImageView *)imageV {
    if (_imageV != nil) {
        return _imageV;
    }
    _imageV = [[UIImageView alloc] init];
    _imageV.layer.masksToBounds = YES;
    _imageV.userInteractionEnabled = YES;
    _imageV.layer.cornerRadius = 5;
    _imageV.clipsToBounds = YES;
    return _imageV;
}


@end
