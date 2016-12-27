//
//  TFRecordTools.h
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/19.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface TFRecordTools : NSObject
/** 录音器 */
@property(nonatomic,strong) AVAudioRecorder *recorder;
+ (instancetype)sharedRecorder;

/** 开始录音 */
- (void)startRecord;

/** 停止录音 */
- (void)stopRecordSuccess:(void (^)(NSURL *url,NSTimeInterval time))success andFailed:(void (^)())failed;

/** 播放声音数据 */
- (void)playData:(NSData *)data completion:(void(^)())completion;

/** 播放声音文件 */
- (void)playPath:(NSString *)path completion:(void(^)())completion;
@end
