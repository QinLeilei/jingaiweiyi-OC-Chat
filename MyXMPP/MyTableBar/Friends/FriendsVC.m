//
//  FriendsVC.m
//  MyXMPP
//
//  Created by jingaiweiyi on 2016/12/12.
//  Copyright © 2016年 yunshangshiji. All rights reserved.
//

#import "FriendsVC.h"
#import <CoreData/CoreData.h>
#import "AddFriendVC.h"
#import "ChatVC.h"

#import "TestVC.h"
@interface FriendsVC () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>
@property(nonatomic,strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FriendsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
    
    // 查询数据
    [self.fetchedResultsController performFetch:NULL];
    
    NSLog(@"friends: %@", self.fetchedResultsController.fetchedObjects);
    
}

- (void)setupUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIBarButtonItem *loginOutBtn = [[UIBarButtonItem alloc] initWithTitle:@"注销" style:UIBarButtonItemStylePlain target:self action:@selector(logOutBackClick:)];
    self.navigationItem.leftBarButtonItem = loginOutBtn;
    
    UIBarButtonItem *AddFriendBtn = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addFriendsClick:)];
    self.navigationItem.rightBarButtonItem = AddFriendBtn;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(kStatusBar_And_NavigationBar_Height);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-49);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    TestVC *testVC = [[TestVC alloc] init];
//    testVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:testVC animated:YES];
//    return;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatVC *chatVC = [[ChatVC alloc] init];
    
    XMPPUserCoreDataStorageObject *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    chatVC.chatJID = user.jid;
    chatVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVC animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fetchedResultsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"ContactCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    XMPPUserCoreDataStorageObject *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSLog(@"user: %@", user);
    
    NSLog(@"%zd %@ %@ %@", user.section, user.sectionName, user.sectionNum, user.jidStr);
    
    // subscription
    // 如果是none表示对方还没有确认
    // to   我关注对方
    // from 对方关注我
    // both 互粉
    
    NSString *str = [user.jidStr stringByAppendingFormat:@" | %@",user.subscription];
    
    cell.textLabel.text = str ;
    cell.detailTextLabel.backgroundColor = [UIColor grayColor];
    cell.detailTextLabel.text = [self userStatusWithSection:user.section];
    
    return cell;
}

- (NSString *)userStatusWithSection:(NSInteger)section {
    //    NSLog(@"%zd",section);
    // section
    // 0 在线
    // 1 离开
    // 2 离线
    switch (section) {
        case 0:
            return @"在线";
            break;
        case 1:
            return @"离开";
            break;
        case 2:
            return @"离线";
            break;
        default:
            return @"未知";
            break;
    }
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}
- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return  _fetchedResultsController;
    }
    // 添加上下文
    //使用CoreData获取数据
    // 1.上下文【关联到数据库XMPPRoster.sqlite】
    NSManagedObjectContext *ctx = [TFXMPPManager shareInstace].xmppRosterCoreDataStorage.mainThreadManagedObjectContext;
    
    // 指定查询的实体
    // 2.FetchRequest【查哪张表】
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    
    // 3.设置过滤和排序
    // 过滤当前登录用户的好友
    
    // 在线状态排序
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"sectionNum" ascending:YES];
    // 显示的名称排序
    NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    
    // 添加排序
    request.sortDescriptors = @[sort1,sort2];
    
    // 过滤当前登录用户的好友
    // 添加谓词过滤器
    request.predicate = [NSPredicate predicateWithFormat:@"!(subscription CONTAINS 'none')"];
    
    // 4.执行请求获取数据
    
    // 实例化结果控制器
    _fetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:ctx sectionNameKeyPath:nil cacheName:nil];
    
    // 设置他的代理
    _fetchedResultsController.delegate = self;
    
    /**< 注意：使用NSFetchedResultsController并设置代理，如果数据库的内容发生了变化，这个类会自动通知代理，就可以设置界面的数据，做到实时更新。*/
    
    return _fetchedResultsController;
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"上下文改变");
    [self.tableView reloadData];
}

- (void)logOutBackClick:(UIBarButtonItem *)sender {
    [[TFXMPPManager  shareInstace] logout];
    
    // 切换界面
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPManagerLoginResultNotification object:@(NO)];
}

- (void)addFriendsClick:(UIBarButtonItem *)sender {
    AddFriendVC *VC = [[AddFriendVC alloc] init];
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
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
