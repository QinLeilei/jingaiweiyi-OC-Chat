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
#import "NSData+MD5Digest.h"
#pragma mark - +++++++++++++ add import
#import "ICChatHearder.h"

@interface ChatVC () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UITextViewDelegate,UINavigationControllerDelegate, ICChatBoxViewControllerDelegate, ICRecordManagerDelegate>
{
    CGRect _smallRect;
    CGRect _bigRect;
    
    BOOL   _isKeyBoardAppear;     // 键盘是否弹出来了
}

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UITextView *textView;

@property(nonatomic,strong) NSCache *cache;

#pragma mark - +++++++++++++ add property
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) ICChatBoxViewController *chatBoxVC;
@property (nonatomic, strong) UIImageView *currentVoiceIcon;
@property (nonatomic, strong) UIImageView *presentImageView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) ICVoiceHud *voiceHud;
@property (nonatomic, copy) NSString *voicePath;
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
    
    [self addChildViewController:self.chatBoxVC];
    [self.view addSubview:self.chatBoxVC.view];
    [self.view addSubview:self.tableView];

}

- (void)setData {
    [self.fetchedResultsController performFetch:NULL];
    
    [self.fetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(XMPPMessageArchiving_Message_CoreDataObject *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        ICMessage *message = [ICMessage resolveWithXMPPMessageArchiving_Message_CoreDataObject:obj];
        ICMessageFrame *messageF = [ICMessageHelper createMessageFrameWithMessage:message];
        [self addObject:messageF isToBottomAnimation:NO isSender:NO];
    }];
    
}

// 增加数据源并刷新
- (void)addObject:(ICMessageFrame *)messageF isToBottomAnimation:(BOOL)animation isSender:(BOOL)isSender
{
    [self.dataSource addObject:messageF];
    [self.tableView reloadData];
    if (_isKeyBoardAppear || isSender) {
        [self scrollToBottom:animation];
    }
}

- (void)keyboardHidden {
//    [self.inputMessageView resignFirstResponder];
    [self.view endEditing:NO];
}

#pragma mark - ******************** 结果调度器的代理方法
// 内容变化(接收到其他好友的/我发送的消息)的时候，会触发
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    XMPPMessageArchiving_Message_CoreDataObject *obj = self.fetchedResultsController.fetchedObjects.lastObject;
    /**< 此时应该有最新的一个消息～（不管是对方发过来还是我发过去的）自动加入到数据里了，在这里判断，如果是我发送的图片消息~
     */
    ICMessage *message = [ICMessage resolveWithXMPPMessageArchiving_Message_CoreDataObject:obj];
    ICMessageFrame *messageF = [ICMessageHelper createMessageFrameWithMessage:message];

    if (message.isSender) { // 是发送者
        [self.dataSource enumerateObjectsUsingBlock:^(ICMessageFrame *sourceMessageF, NSUInteger idx, BOOL * _Nonnull stop) {
            ICMessage *sourceMessage = sourceMessageF.model.message;
            if ([sourceMessage.localMsgId isEqualToString:message.localMsgId]) {
                sourceMessage.deliveryState = ICMessageDeliveryState_Delivered;
                
                [self.tableView reloadData];
                [self scrollToBottom:NO];
            }
        }];
    } else {
        [self addObject:messageF isToBottomAnimation:NO isSender:YES];
    }

}

#pragma mark - ******************** 发送消息方法
/** 发送文本信息 */
- (void)sendTextMessage:(NSString *)message
{
    /**< 先创建一条本地文本消息 */
    // 获取当前时间
    NSString *localMsgId = [ICMessageHelper localMsgId:message];
    NSLog(@"localMsgId: %@", localMsgId);
    ICMessageFrame *messageF = [ICMessageHelper createLocalTextMessageFrameWithContent:[NSString stringWithFormat:@"%@%@%@", ICMessageTextHasPrefix, localMsgId,message] from:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:XMPPManagerUserName]] to:self.chatJID.user];
    [self addObject:messageF isToBottomAnimation:NO isSender:YES];
    
    // 发送
    NSString *body = [NSString stringWithFormat:@"%@%@%@", ICMessageTextHasPrefix, localMsgId,message];
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.chatJID];
    [msg addBody:body];
    [[TFXMPPManager shareInstace].xmppStream sendElement:msg];
}
/**< 发送图片消息 */
- (void)sendImageMessage:(UIImage *)image localMediaPath:(NSString *)localMediaPath
{
    
    // fileName
    NSString *nowTime = [NSDate nowDateFormat:TFDateFormatyyyyMMddHHmmss];
    NSString *fileName = [NSString stringWithFormat:@"chatImage%@%@.png",@"1025",nowTime];
    // 文件夹
    NSString *savekey = [NSString stringWithFormat:@"%@%@", @"userinfo/head_pic/", fileName];
    // 下载路径
    NSString *message = [NSString stringWithFormat:@"%@%@",kGetUpy, savekey];
    
    /**< 创建本地消息 */
    NSString *localMsgId = [ICMessageHelper localMsgId:message];
    NSLog(@"localMsgId: %@", localMsgId);
    ICMessageFrame *messageF = [ICMessageHelper createLocalImageMessageFrameWithContent:[NSString stringWithFormat:@"%@%@%@", ICMessageImageHasPrefix, localMsgId, message] from:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:XMPPManagerUserName]] to:self.chatJID.user localMediaPath:localMediaPath];
    [self addObject:messageF isToBottomAnimation:NO isSender:YES];
    
    // 发送upy
    MyUpy *upy = [[MyUpy alloc] init];
    [upy uploadImage:image savekey:savekey];
    [upy setProgress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        //请求成功
        NSLog(@"图片上传成功...");
        //上传成功,发送消息给好友
        NSString *body = [NSString stringWithFormat:@"%@%@%@", ICMessageImageHasPrefix, localMsgId, message];
        XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.chatJID];
        [msg addBody:body];
        [[TFXMPPManager shareInstace].xmppStream sendElement:msg];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"图片上传失败...");
    }];
}
/**< 发送语音消息方法 */
- (void)sendVoiceMessageWithlocalMediaPath:(NSString *)localMediaPath
{
    NSLog(@"localMediaPath: %@", localMediaPath);
    
    // fileName
    NSString *nowTime = [NSDate nowDateFormat:TFDateFormatyyyyMMddHHmmss];
    NSString *fileName = [NSString stringWithFormat:@"chatVoice%@%@.wav",@"1025",nowTime];
    // 文件夹
    NSString *savekey = [NSString stringWithFormat:@"%@%@", @"userinfo/head_pic/", fileName];
    // 下载路径
    NSString *message = [NSString stringWithFormat:@"%@%@",kGetUpy, savekey];
    
    /**< 创建本地消息 */
    NSString *localMsgId = [ICMessageHelper localMsgId:message];
    NSLog(@"localMsgId: %@", localMsgId);
    
    ICMessageFrame *messageF = [ICMessageHelper createLocalVoiceMessageFrameWithContent:[NSString stringWithFormat:@"%@%@%@", ICMessageVoiceHasPrefix, localMsgId, message] from:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:XMPPManagerUserName]] to:self.chatJID.user localMediaPath:localMediaPath];
    [self addObject:messageF isToBottomAnimation:NO isSender:YES];
    
    NSData *voiceData = [[ICRecordManager shareManager] voiceDataWithLocalPath:localMediaPath];
    // 上传
    MyUpy *upy = [[MyUpy alloc] init];
    [upy uploadVoiceData:voiceData savekey:savekey];
    [upy setProgress:^(NSProgress *uploadProgress) {
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        //请求成功
        NSLog(@"语音上传成功...");
        
        //上传成功,发送消息给好友
        NSString *body = [NSString stringWithFormat:@"%@%@%@", ICMessageVoiceHasPrefix, localMsgId, message];
        XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.chatJID];
        [msg addBody:body];
        [[TFXMPPManager shareInstace].xmppStream sendElement:msg];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"语音上传失败...");
    }];

    
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
//    return self.fetchedResultsController.fetchedObjects.count;
    return [self addNumberOfRowsWithTableView:tableView inSection:section];
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
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
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

#pragma mark - ******************** 懒加载
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
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kStatusBar_And_NavigationBar_Height, kScreen_Width, kScreen_Height - HEIGHT_TABBAR - kStatusBar_And_NavigationBar_Height)];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor colorWithWhite:.95 alpha:1];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    _tableView.backgroundColor = [UIColor yellowColor];
    return _tableView;
}
- (UIImageView *)presentImageView
{
    if (!_presentImageView) {
        _presentImageView = [[UIImageView alloc] init];
    }
    return _presentImageView;
}

/** 录音时，提示的View */
- (ICVoiceHud *)voiceHud
{
    if (!_voiceHud) {
        _voiceHud = [[ICVoiceHud alloc] initWithFrame:CGRectMake(0, 0, 155, 155)];
        _voiceHud.hidden = YES;
        [self.view addSubview:_voiceHud];
        _voiceHud.center = CGPointMake(App_Frame_Width/2, APP_Frame_Height/2);
    }
    return _voiceHud;
}

/** 录音计算时间 */
- (NSTimer *)timer
{
    if (!_timer) {
        _timer =[NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(progressChange) userInfo:nil repeats:YES];
    }
    return _timer;
}
#pragma mark - ******************** 为了方便抽出来的方法
// 滚动到表格的末尾，显示最新的聊天内容
- (void)scrollToBottom:(BOOL)animation {
    
    // 1. indexPath，应该是最末一行的indexPath
//    NSInteger count = self.fetchedResultsController.fetchedObjects.count;
    NSInteger count = self.dataSource.count;
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

#pragma mark - ++++++++++++++++ 增加的方法
- (void)addMothed {
    [self registerCell];
}


/**
 注册cell，注册ID为类型
 */
- (void)registerCell {
    [self.tableView registerClass:[ICChatMessageTextCell class] forCellReuseIdentifier:TypeText];
    [self.tableView registerClass:[ICChatMessageImageCell class] forCellReuseIdentifier:TypePic];
    [self.tableView registerClass:[ICChatMessageVideoCell class] forCellReuseIdentifier:TypeVideo];
    [self.tableView registerClass:[ICChatMessageVoiceCell class] forCellReuseIdentifier:TypeVoice];
    [self.tableView registerClass:[ICChatMessageFileCell class] forCellReuseIdentifier:TypeFile];
}

- (UITableViewCell *)addCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"indexPath.row: %zd", indexPath.row);
    
    id obj                            = self.dataSource[indexPath.row];
    
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
        cell.currIndexPath = indexPath;
//        cell.longPressDelegate         = self;
        cell.modelFrame                = modelFrame;
        // 媒体刷新
        cell.mediaRefreshBlock = ^(NSIndexPath *currIndexPath) {
            NSLog(@"刷新...");
            id obj                            = self.dataSource[indexPath.row];
            if ([obj isKindOfClass:[NSString class]]) {
                return;
            } else {
                ICMessageFrame *modelFrame     = (ICMessageFrame *)obj;
                [modelFrame refreshFrame:modelFrame.model];
            }
            
            [self.tableView reloadData];
            
        };
        
        return cell;
    }
}

- (NSInteger)addNumberOfRowsWithTableView:(UITableView *)tableView inSection:(NSInteger )section {
    return self.dataSource.count;
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

#pragma mark - public method

// 路由响应
- (void)routerEventWithName:(NSString *)eventName
                   userInfo:(NSDictionary *)userInfo
{
    /**< 获取 modelFrame */
    ICMessageFrame *modelFrame = [userInfo objectForKey:MessageKey];
    /**< 根据eventName来响应对应的事件 */
    if ([eventName isEqualToString:GXRouterEventTextUrlTapEventName]) {
        NSLog(@"处理外部url点击事件...");
        
    } else if ([eventName isEqualToString:GXRouterEventImageTapEventName]) {
        NSLog(@"处理图片点击事件...");
        _smallRect             = [[userInfo objectForKey:@"smallRect"] CGRectValue];
        _bigRect               =  [[userInfo objectForKey:@"bigRect"] CGRectValue];
        NSLog(@"_smallRect: %@, _bigRect: %@", NSStringFromCGRect(_smallRect), NSStringFromCGRect(_bigRect));
        
        
    } else if ([eventName isEqualToString:GXRouterEventVoiceTapEventName]) {
        
        NSLog(@"处理语音点击事件...");
        UIImageView *imageView = (UIImageView *)userInfo[VoiceIcon];
        UIView *redView        = (UIView *)userInfo[RedView];
        [self chatVoiceTaped:modelFrame voiceIcon:imageView redView:redView];

    } else if ([eventName isEqualToString:GXRouterEventURLSkip]) {
        
        NSLog(@"处理url点击事件...");
        
    }
}

/** 下面输入框的 VC */
- (ICChatBoxViewController *) chatBoxVC
{
    if (_chatBoxVC == nil) {
        _chatBoxVC = [[ICChatBoxViewController alloc] init];
        [_chatBoxVC.view setFrame:CGRectMake(0,APP_Frame_Height-HEIGHT_TABBAR, App_Frame_Width, APP_Frame_Height)];
        _chatBoxVC.delegate = self;
    }
    return _chatBoxVC;
}

#pragma mark - ICChatBoxViewControllerDelegate
/** chatBox页面弹起时，改变的高度 代理方法*/
- (void) chatBoxViewController:(ICChatBoxViewController *)chatboxViewController
        didChangeChatBoxHeight:(CGFloat)height
{
    self.chatBoxVC.view.top = self.view.bottom - height;
    self.tableView.height = HEIGHT_SCREEN - height - HEIGHT_NAVBAR-HEIGHT_STATUSBAR;
    if (height == HEIGHT_TABBAR) {
        [self.tableView reloadData];
        _isKeyBoardAppear  = NO;
        [self scrollToBottom];
    } else {
        [self scrollToBottom];
        _isKeyBoardAppear  = YES;
    }
    if (self.textView == nil) {
        self.textView = chatboxViewController.chatBox.textView;
    }
}

/** 录制视频, 弹出videoView 代理方法 */
- (void)chatBoxViewController:(ICChatBoxViewController *)chatboxViewController didVideoViewAppeared:(ICVideoView *)videoView
{
    [_chatBoxVC.view setFrame:CGRectMake(0, HEIGHT_SCREEN-HEIGHT_TABBAR, App_Frame_Width, APP_Frame_Height)];
    videoView.hidden = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.height = HEIGHT_SCREEN - videwViewH - HEIGHT_NAVBAR-HEIGHT_STATUSBAR;
        self.chatBoxVC.view.frame = CGRectMake(0, videwViewX+HEIGHT_NAVBAR+HEIGHT_STATUSBAR, App_Frame_Width, videwViewH);
        [self scrollToBottom];
    } completion:^(BOOL finished) { // 状态改变
        self.chatBoxVC.chatBox.status = ICChatBoxStatusShowVideo;
        // 在这里创建视频设配
        UIView *videoLayerView = [videoView viewWithTag:1000];
        UIView *placeholderView = [videoView viewWithTag:1001];
        [[ICVideoManager shareManager] setVideoPreviewLayer:videoLayerView];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(videoPreviewLayerWillAppear:) userInfo:placeholderView repeats:NO];
        
    }];
}

/**
 发送图片消息 代理方法
 
 @param chatboxViewController <#chatboxViewController description#>
 @param image 压缩后到图片
 @param imgPath 压缩后图片存储到路径
 */
- (void) chatBoxViewController:(ICChatBoxViewController *)chatboxViewController
              sendImageMessage:(UIImage *)image
                     imagePath:(NSString *)imgPath
{
    if (image && imgPath) {
        [self sendImageMessage:image localMediaPath:imgPath];
    }
}


/** 发送语音消息 代理方法 */
- (void) chatBoxViewController:(ICChatBoxViewController *)chatboxViewController sendVoiceMessage:(NSString *)voicePath
{
    [self timerInvalue]; // 销毁定时器
    self.voiceHud.hidden = YES;
    if (voicePath) {
        [self sendVoiceMessageWithlocalMediaPath:voicePath];
    }
}

/** 发送视频消息 代理方法 */
- (void)chatBoxViewController:(ICChatBoxViewController *)chatboxViewController sendVideoMessage:(NSString *)videoPath
{
    /**< 需要创建本地发送视频消息 */
}

/** 发送文件消息 代理方法 */
- (void) chatBoxViewController:(ICChatBoxViewController *)chatboxViewController sendFileMessage:(NSString *)fileName
{
    /**< 需要创建本地发送文件消息 */
}

/** 发送文本消息 代理方法 */
- (void) chatBoxViewController:(ICChatBoxViewController *)chatboxViewController
               sendTextMessage:(NSString *)messageStr
{
    if (messageStr && messageStr.length > 0) {
        [self sendTextMessage:messageStr];
    }
}

#pragma mark - private
- (void) scrollToBottom
{
    if (self.dataSource.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

/**< chatBoxVC 注销活动状态 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.chatBoxVC resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.chatBoxVC resignFirstResponder];
}

- (void)timerInvalue
{
    [_timer invalidate];
    _timer  = nil;
}

#pragma mark - voice & video

- (void)voiceDidCancelRecording
{
    [self timerInvalue];
    self.voiceHud.hidden = YES;
}
- (void)voiceDidStartRecording
{
    [self timerInvalue];
    self.voiceHud.hidden = NO;
    [self timer];
}

// 向外或向里移动
- (void)voiceWillDragout:(BOOL)inside
{
    if (inside) {
        [_timer setFireDate:[NSDate distantPast]];
        _voiceHud.image  = [UIImage imageNamed:@"voice_1"];
    } else {
        [_timer setFireDate:[NSDate distantFuture]];
        self.voiceHud.animationImages  = nil;
        self.voiceHud.image = [UIImage imageNamed:@"cancelVoice"];
    }
}
/** 录音进度改变  progress*/
- (void)progressChange
{
    AVAudioRecorder *recorder = [[ICRecordManager shareManager] recorder] ;
    [recorder updateMeters];
    float power= [recorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0,声音越大power绝对值越小
    CGFloat progress = (1.0/160)*(power + 160);
    self.voiceHud.progress = progress;
}

- (void)voiceRecordSoShort
{
    [self timerInvalue];
    self.voiceHud.animationImages = nil;
    self.voiceHud.image = [UIImage imageNamed:@"voiceShort"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.voiceHud.hidden = YES;
    });
}

// play voice
- (void)chatVoiceTaped:(ICMessageFrame *)messageFrame
             voiceIcon:(UIImageView *)voiceIcon
               redView:(UIView *)redView
{
    ICRecordManager *recordManager = [ICRecordManager shareManager];
    recordManager.playDelegate = self;
    
    NSLog(@"mediaPath: %@", messageFrame.model.mediaPath);
    NSLog(@"localMediaPath: %@", messageFrame.model.localMediaPath);
    
    // 文件路径
    NSString *voicePath;
    if (messageFrame.model.localMediaPath) {
        voicePath = [self mediaPath:messageFrame.model.localMediaPath];
    } else {
        voicePath = [self mediaPath:messageFrame.model.mediaPath];
    }

    NSLog(@"voicePath: %@", voicePath);
    
    NSString *amrPath   = [[voicePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"amr"];
    NSLog(@"amrPath: %@", amrPath);
    
    if (self.voicePath) { /**< 如果正在播放 */
        if ([self.voicePath isEqualToString:voicePath]) { // the same recoder
            /**< 是相同的就停止 */
            self.voicePath = nil;
            [[ICRecordManager shareManager] stopPlayRecorder:voicePath];
            [voiceIcon stopAnimating];
            self.currentVoiceIcon = nil;
            return;
        } else {
            /**< 否则点击其他的播放，当前的停止动画 */
            [self.currentVoiceIcon stopAnimating];
            self.currentVoiceIcon = nil;
        }
    }
    /**< 没有播放的，就创建新的播放 */
    [[ICRecordManager shareManager] startPlayRecorder:voicePath];
    [voiceIcon startAnimating];
    self.voicePath = voicePath;
    self.currentVoiceIcon = voiceIcon;
}
// 移除录视频时的占位图片
- (void)videoPreviewLayerWillAppear:(NSTimer *)timer
{
    UIView *placeholderView = (UIView *)[timer userInfo];
    [placeholderView removeFromSuperview];
}

// 文件路径
- (NSString *)mediaPath:(NSString *)originPath
{
    // 这里文件路径重新给，根据文件名字来拼接
    NSString *name = [[originPath lastPathComponent] stringByDeletingPathExtension];
    return [[ICRecordManager shareManager] receiveVoicePathWithFileKey:name];
}

#pragma mark - ICRecordManagerDelegate
- (void)voiceDidPlayFinished
{
    self.voicePath = nil;
    ICRecordManager *manager = [ICRecordManager shareManager];
    manager.playDelegate = nil;
    [self.currentVoiceIcon stopAnimating];
    self.currentVoiceIcon = nil;
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
