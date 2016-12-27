//
//  ChatVC.m
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/13.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import "ChatVC.h"
#import <CoreData/CoreData.h>
#import "TFRecordTools.h"
#import "ChatCell.h"
#import "UIImage+TFCommon.h"
#import "NSDate+TFCommon.h"
#import "XMPPMessage+Tools.h"
#import "TFHttpTools.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "AFNetworking.h"
#import "MyUpy.h"

#pragma mark - +++++++++++++ add import
#import "ICChatHearder.h"

@interface ChatVC () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UITapGestureRecognizer *_tap;   // 键盘收起手势
    UIPanGestureRecognizer *_pan;
}

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UITextView *textView;

/** 录音文本 */
@property (nonatomic, strong) UITextField *recordText;
/** 输入视图 */
@property (strong, nonatomic) UIView *inputMessageView;
@property(nonatomic,strong) UITableViewCell *nowCell;

@property(nonatomic,strong) NSIndexPath *nowIndexPath;

@property (nonatomic,assign) CGFloat nowHeight;

@property(nonatomic,strong) NSCache *cache;

#pragma mark - +++++++++++++ add property
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.chatJID.user;
    [self setupUI];
    [self setData];
    [self addMothed];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self scrollToBottom:YES];
}

- (void)setupUI {
    
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.inputMessageView];
    
    // 监听键盘变化
    //通知 监听键盘将要出现
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardFramWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    //通知 监听键盘将要消失
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChanged) name:UIKeyboardDidChangeFrameNotification object:nil];
    
    // 键盘收起手势
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHidden)];
    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHidden)];
    
    [self scrollToBottom:NO];
    
}

- (void)setData {
    [self.fetchedResultsController performFetch:NULL];
    NSLog(@"%@", self.fetchedResultsController.fetchedObjects);
    
    [self.fetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(XMPPMessageArchiving_Message_CoreDataObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        ICMessage *message = [ICMessage resolveWithXMPPMessageArchiving_Message_CoreDataObject:obj];
        ICMessageFrame *messageF = [ICMessageHelper createMessageFrameWithMessage:message];
        [self addObject:messageF isSender:NO];
    }];
    
}

// 增加数据源并刷新
- (void)addObject:(ICMessageFrame *)messageF isSender:(BOOL)isSender
{
    [self.dataSource addObject:messageF];
    [self.tableView reloadData];
    if (isSender) {
        [self scrollToBottom:NO];
    }
}

- (void)keyboardHidden {
    [self.inputMessageView resignFirstResponder];
    [self.view endEditing:NO];
}

#pragma mark - ******************** 结果调度器的代理方法
// 内容变化(接收到其他好友的/我发送的消息)的时候，会触发
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    XMPPMessageArchiving_Message_CoreDataObject *obj = self.fetchedResultsController.fetchedObjects.lastObject;
    
    ICMessage *message = [ICMessage resolveWithXMPPMessageArchiving_Message_CoreDataObject:obj];
    ICMessageFrame *messageF = [ICMessageHelper createMessageFrameWithMessage:message];
    [self addObject:messageF isSender:NO];

}

#pragma mark - ******************** textView代理方法
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // 判断按下的是不是回车键。
    if ([text isEqualToString:@"\n"]) {
        
        // 自定义的信息发送方法，传入字符串直接发出去。
        [self sendMessage:textView.text];
        
        self.textView.text = nil;
        
        return NO;
    }
    return YES;
}

#pragma mark - ******************** imgPickerController代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [self uploadDataToHostWithImage:image];
    
//    NSData *data = UIImagePNGRepresentation(image);
//    [self sendMessageWithData:data bodyName:@"image"];
    
}

#pragma mark - ******************** 给服务器上传图片
- (void)uploadDataToHostWithImage:(UIImage *)image {
    //往文件服务器上传图片
    //1.给图片全名
    NSString *username = [TFXMPPManager shareInstace].xmppStream.myJID.user;
    
    // fileName
    NSString *time = [NSDate nowDateFormat:TFDateFormatyyyyMMddHHmmss];
    
    NSString *fileName = [NSString stringWithFormat:@"headImgae%@%@.png",@"1025",time];

    // 文件夹
    NSString *savekey = [NSString stringWithFormat:@"%@%@", @"userinfo/head_pic/", fileName];
    
    // 下载路径
    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",kGetUpy, savekey];
    NSLog(@"下载路径:imageUrl: %@", imageUrl);
    
    MyUpy *upy = [[MyUpy alloc] init];
    [upy uploadImage:image savekey:savekey];
    [upy setProgress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        //请求成功
//        NSLog(@"请求成功：%@",responseObject);
        
        //上传成功,发送消息给好友
        NSString *body = [NSString stringWithFormat:@"imageHttp:%@",imageUrl];
        XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.chatJID];
        [msg addBody:body];
        
        [[TFXMPPManager shareInstace].xmppStream sendElement:msg];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

#pragma mark - ******************** 发送消息方法
/** 发送信息 */
- (void)sendMessage:(NSString *)message
{
    NSString *body = [NSString stringWithFormat:@"text:%@",message];
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.chatJID];
    [msg addBody:body];
    
    [[TFXMPPManager shareInstace].xmppStream sendElement:msg];
}

/** 发送二进制文件 */
- (void)sendMessageWithData:(NSData *)data bodyName:(NSString *)name
{
    NSString *body = [NSString stringWithFormat:@"%@:", name];
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.chatJID];

    [message addBody:body];
    
    // 转换成base64的编码
    NSString *base64str = [data base64EncodedStringWithOptions:0];
    
    // 设置节点内容
    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:base64str];
    
    // 包含子节点
    [message addChild:attachment];
    
    // 发送消息
    [[TFXMPPManager shareInstace].xmppStream sendElement:message];
    
}

#pragma mark - ******************** 和tableView相关的一系列方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    return [self cellWithTableView:tableView andIndexPath:indexPath];
    return [self addCellWithTableView:tableView andIndexPath:indexPath];
}

/** 计算行高方法 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return [self heightWithTableView:tableView andIndexPath:indexPath];
    return [self addHeightWithTableView:tableView andIndexPath:indexPath];
}


/** 预估行高 */
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - ******************** tableView 抽调出来的方法
/** 直接返回一个cell */
- (ChatCell *)cellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath
{
    
//    NSLog(@"调用了几次？");
    
    // 取出当前行的消息
    XMPPMessageArchiving_Message_CoreDataObject *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    // 判断是发出消息还是接收消息
    NSString *ID = ([message.outgoing intValue] == 1) ? @"SendCell" : @"ReciveCell" ;
    
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[ChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    // 如果存进去了，就把字符串转化成简洁的节点后保存
    if ([message.message saveAttachmentJID:self.chatJID.bare timestamp:message.timestamp]) {
        message.messageStr = [message.message compactXMLString];
        
        [[TFXMPPManager shareInstace].xmppMessageArchivingCoreDataStorage.mainThreadManagedObjectContext save:NULL];
    }
    
    //    cell.audioData = nil;
    cell.audioPath = nil;
    
    NSString *path = [message.message pathForAttachment:self.chatJID.bare timestamp:message.timestamp];
    
    NSLog(@"message.body: %@", message.body);
    
    if ([message.body isEqualToString:@"image"]) {
        
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        
        attach.image = [UIImage imageCompressForWidthSourceImage:image targetWidth:200];
        
        NSAttributedString *attachStr = [NSAttributedString attributedStringWithAttachment:attach];
        
        cell.messageLabel.attributedText = attachStr;
        
        [self.view endEditing:YES];
        
    } else if ([message.body hasPrefix:@"imageHttp"]) {
        
        NSString *imageUrl = [message.body substringFromIndex:10];
        NSLog(@"imageUrl: %@", imageUrl);
        
        [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:imageUrl] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
            NSLog(@"图片下载完成!");
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            
            attach.image = [UIImage imageCompressForWidthSourceImage:image targetWidth:200];
            
            NSAttributedString *attachStr = [NSAttributedString attributedStringWithAttachment:attach];
            cell.messageLabel.attributedText = attachStr;
            
            [cell setNeedsLayout];
            
            [self.view endEditing:YES];
        }];
    } else if ([message.body hasPrefix:@"audio"]){
        
        NSString *newstr = [message.body substringFromIndex:6];
        cell.messageLabel.text = newstr;
        
        cell.audioPath = path;
        
    } else {
        
        cell.messageLabel.text = message.body;
    }
    
    return cell;
}

- (CGFloat)heightWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    NSString *row = [NSString stringWithFormat:@"%ld",indexPath.row];
    
    if ([self.cache objectForKey:row]!=nil) {
        //        NSLog(@"%f",[[self.cache objectForKey:row] floatValue]);
        return [[self.cache objectForKey:row] floatValue];
    }
    
    
    //    NSLog(@"计算行高 %ld",indexPath.row);
    // 拿到Cell，设置数值
    ChatCell *cell = [self cellWithTableView:tableView andIndexPath:indexPath];
    
    // 让cell自动布局
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGFloat height = [cell.messageLabel systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + kTopAndBottomMarginHeight * 2 + kMessageLabelTBMarginHeight * 2;
    
    if (height <= kTopAndBottomMarginHeight * 2 + kMessageLabelTBMarginHeight * 2) {
        [self.cache setObject:@(kTopAndBottomMarginHeight * 2 + kMessageLabelTBMarginHeight * 2 + 20) forKey:row];
        return kTopAndBottomMarginHeight * 2 + kMessageLabelTBMarginHeight * 2 + 20;
    }
    
    [self.cache setObject:@(height) forKey:row];
    return height;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - 录音
- (void)recordStart:(UIButton *)sender
{
    [sender setTitle:@"录制中..." forState:UIControlStateNormal];
    [[TFRecordTools sharedRecorder] startRecord];
}

- (void)recordCancel:(UIButton *)sender
{
    [sender setTitle:@"重新录制" forState:UIControlStateNormal];
    [[TFRecordTools sharedRecorder].recorder stop];
}

- (void)recordFinish:(UIButton *)sender
{
    [sender setTitle:@"录音发送中..." forState:UIControlStateNormal];
    [[TFRecordTools sharedRecorder] stopRecordSuccess:^(NSURL *url, NSTimeInterval time) {
        
        // 发送声音数据
        NSData *data = [NSData dataWithContentsOfURL:url];
        [self sendMessageWithData:data bodyName:[NSString stringWithFormat:@"audio"]];
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.5 *NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [sender setTitle:@"开始录音" forState:UIControlStateNormal];
        });
        
    } andFailed:^{
        
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"时间太短" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];
        [sender setTitle:@"开始录音" forState:UIControlStateNormal];
    }];

}
#pragma mark - ******************** 懒加载
- (UITextField *)recordText {
    if (_recordText == nil) {
        _recordText = [[UITextField alloc] init];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"开始录音" forState:UIControlStateNormal];
        _recordText.inputView = btn;
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(100);
        }];
        
        // 开始
        [btn addTarget:self action:@selector(recordStart:) forControlEvents:UIControlEventTouchDown];
        // 取消
        [btn addTarget:self action:@selector(recordCancel:) forControlEvents: UIControlEventTouchDragExit | UIControlEventTouchUpOutside];
        //完成
        [btn addTarget:self action:@selector(recordFinish:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.inputMessageView addSubview:_recordText];
    }
    return _recordText;
}

- (NSCache *)cache{
    if (_cache == nil) {
        _cache = [[NSCache alloc]init];
    }
    return _cache;
}

- (NSFetchedResultsController *)fetchedResultsController {
    // 推荐写法，减少嵌套的层次
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    // 从自己写的工具类里的属性中得到上下文
    NSManagedObjectContext *ctx = [TFXMPPManager shareInstace].xmppMessageArchivingCoreDataStorage.mainThreadManagedObjectContext;
    NSLog(@"ctx: %@", ctx);
    
    // 打印一下所有的实体
    NSManagedObjectModel *managedObjectModel = [[ctx persistentStoreCoordinator] managedObjectModel];
    NSDictionary *entities = [managedObjectModel entitiesByName];
    NSArray *entityNames = [entities allKeys];
    NSLog(@"All loaded entities are: %@", entityNames);
    
    // 查询请求
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    // 设置实体
    NSEntityDescription *myEntity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:ctx];
    [request setEntity:myEntity];

    // 先确定需要用到哪个实体
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    // 3.排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    // 每一个聊天界面，只关心聊天对象的消息
    request.predicate = [NSPredicate predicateWithFormat:@"bareJidStr = %@", self.chatJID.bare];
    
    // 4.实例化，里面要填上上面的各种参数
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:ctx sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    NSError *error = NULL;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (UITableView *)tableView {
    if (_tableView != nil) {
        return _tableView;
    }
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - 44)];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    // 设置表格的背景图片
//    _tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_bg.jpg"]];

    return _tableView;
}

- (UIView *)inputMessageView {
    if (_inputMessageView != nil) {
        return _inputMessageView;
    }
    _inputMessageView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height - 44, kScreen_Width, 44)];
    // 录音
    UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordButton setBackgroundImage:[UIImage imageNamed:@"chat_bottom_voice_nor"] forState:UIControlStateNormal];
    [_inputMessageView addSubview:recordButton];
    
    [recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_inputMessageView.mas_bottom).offset(-5);
        make.size.mas_equalTo(CGSizeMake(34, 34));
        make.left.equalTo(_inputMessageView.mas_left).offset(8);
    }];
    
    [recordButton handleClickEvent:UIControlEventTouchUpInside withClickBlock:^(UIButton *sender) {
        if (![self.recordText isFirstResponder]) {
            // 切换焦点，弹出录音按钮
            [self.recordText becomeFirstResponder];
        } else {
            [self.recordText resignFirstResponder];
        }
    }];
    
    // 文本
    [_inputMessageView addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(recordButton.mas_right).offset(8);
        make.bottom.equalTo(_inputMessageView.mas_bottom).offset(-7);
        make.height.mas_equalTo(30);
    }];
    
    // 表情
    UIButton *emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [emojiButton setBackgroundImage:[UIImage imageNamed:@"chat_bottom_smile_nor"] forState:UIControlStateNormal];
    [_inputMessageView addSubview:emojiButton];
    
    [emojiButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_inputMessageView.mas_bottom).offset(-5);
        make.size.mas_equalTo(CGSizeMake(34, 34));
        make.left.equalTo(self.textView.mas_right).offset(8);
    }];
    
    // 添加
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setBackgroundImage:[UIImage imageNamed:@"chat_bottom_up_nor"] forState:UIControlStateNormal];
    [_inputMessageView addSubview:addButton];
    
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_inputMessageView.mas_bottom).offset(-5);
        make.size.mas_equalTo(CGSizeMake(34, 34));
        make.left.equalTo(emojiButton.mas_right).offset(8);
        make.right.equalTo(_inputMessageView.mas_right).offset(-8);
    }];
    
    [addButton handleClickEvent:UIControlEventTouchUpInside withClickBlock:^(UIButton *sender) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        
        picker.delegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }];
    
//    _inputMessageView.backgroundColor = [UIColor whiteColor];
    _inputMessageView.backgroundColor = [UIColor whiteColor];
    return _inputMessageView;
}

- (UITextView *)textView {
    if (_textView != nil) {
        return _textView;
    }
    _textView = [[UITextView alloc] init];
    _textView.font = [UIFont systemFontOfSize:14];
    _textView.layer.masksToBounds = YES;
    _textView.layer.borderColor = [RGBCOLOR_I(150, 150, 150) CGColor];
    _textView.layer.borderWidth = 1;
    _textView.layer.cornerRadius = 5;
    _textView.delegate = self;
    [_textView resignFirstResponder];
    return _textView;
}

#pragma mark - ******************** 监听键盘弹出的方法
#pragma mark - 键盘相关
/// 键盘出现
- (void)keyBoardFramWillChange:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // tableView insets
    UIEdgeInsets insets = self.tableView.contentInset;
    self.tableView.contentInset = UIEdgeInsetsMake(insets.top, insets.left, endFrame.size.height, insets.right);

    
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        CGRect frame = self.inputMessageView.frame;
        frame.origin = CGPointMake(0, endFrame.origin.y - frame.size.height);
        self.inputMessageView.frame = frame;
    } completion:nil];
    
    
    [self.view addGestureRecognizer:_tap];
    [self.view addGestureRecognizer:_pan];
    [self.tableView setUserInteractionEnabled:NO];
}

/// 键盘消失
- (void)keyBoardWillDisappear:(NSNotification *)notification {
    
    UIEdgeInsets insets = self.tableView.contentInset;
    self.tableView.contentInset = UIEdgeInsetsMake(insets.top, insets.left, 0, insets.right);
    
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:^{
        CGRect frame = self.inputMessageView.frame;
        frame.origin = CGPointMake(0,self.view.bounds.size.height - frame.size.height);
        self.inputMessageView.frame = frame;
    } completion:nil];
    


    [self.view removeGestureRecognizer:_tap];
    [self.view removeGestureRecognizer:_pan];
    [self.tableView setUserInteractionEnabled:YES];
}

- (void)keyboardChanged:(NSNotification *)notification {
    // 先打印
    // UIKeyboardFrameEndUserInfoKey ＝》将要变化的大小
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    NSLog(@"keyboardRect: %@", NSStringFromCGRect(keyboardRect));
    // 设置约束
    CGRect inputRect = self.inputMessageView.frame;
    inputRect.origin.y = (kScreen_Height - keyboardRect.size.height) - inputRect.size.height;
    self.inputMessageView.frame = inputRect;
    
    NSTimeInterval time = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    
    [UIView animateWithDuration:time animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardDidChanged {
    
    [self scrollToBottom:NO];
}

#pragma mark - ******************** 为了方便抽出来的方法
// 滚动到表格的末尾，显示最新的聊天内容
- (void)scrollToBottom:(BOOL)animation {
    
    // 1. indexPath，应该是最末一行的indexPath
    NSInteger count = self.fetchedResultsController.fetchedObjects.count;
    if (count == 0)
        return;
    
    [self.tableView
     scrollToRowAtIndexPath:[NSIndexPath
                             indexPathForRow:count - 1
                             inSection:0]
     atScrollPosition:UITableViewScrollPositionBottom
     animated:animation];
}

/*!
 
 * @brief 把格式化的JSON格式的字符串转换成字典
 
 * @param jsonString JSON格式的字符串
 
 * @return 返回字典
 
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        return nil;
    }
    NSLog(@"jsonString: %@", jsonString);
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, kScreen_Width, 0, 0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, kScreen_Width, 0, 0)];
    }
}

#pragma mark - ++++++++++++++++ 增加的方法

- (void)addMothed {
    [self registerCell];
}

- (void)registerCell {
    [self.tableView registerClass:[ICChatMessageTextCell class] forCellReuseIdentifier:TypeText];
    [self.tableView registerClass:[ICChatMessageImageCell class] forCellReuseIdentifier:TypePic];
    [self.tableView registerClass:[ICChatMessageVideoCell class] forCellReuseIdentifier:TypeVideo];
    [self.tableView registerClass:[ICChatMessageVoiceCell class] forCellReuseIdentifier:TypeVoice];
    [self.tableView registerClass:[ICChatMessageFileCell class] forCellReuseIdentifier:TypeFile];
}

- (UITableViewCell *)addCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    id obj                            = self.dataSource[indexPath.row];
    
    NSLog(@"obj: %@", obj);
    
    if ([obj isKindOfClass:[NSString class]]) {
        return nil;
    } else {
        ICMessageFrame *modelFrame     = (ICMessageFrame *)obj;
        
        
        NSString *ID                   = modelFrame.model.message.type;
        NSLog(@"ID: %@", ID);
        
        if ([ID isEqualToString:TypeSystem]) {
            ICChatSystemCell *cell = [ICChatSystemCell cellWithTableView:tableView reusableId:ID];
            cell.messageF              = modelFrame;
            return cell;
        }
        ICChatMessageBaseCell *cell    = [tableView dequeueReusableCellWithIdentifier:ID];
//        cell.longPressDelegate         = self;
        [[ICMediaManager sharedManager] clearReuseImageMessage:cell.modelFrame.model];
        cell.modelFrame                = modelFrame;
        return cell;
    }
}

- (CGFloat)addHeightWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row >= self.dataSource.count) {
        return 0;
    }
    
    ICMessageFrame *messageF = [self.dataSource objectAtIndex:indexPath.row];
    return messageF.cellHight;
}

- (NSMutableArray *)dataSource {
    if (_dataSource != nil) {
        return _dataSource;
    }
    _dataSource = [[NSMutableArray alloc] init];
    return _dataSource;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
