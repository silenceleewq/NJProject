//
//  NJRefreshExampleViewController.m
//  NJProject
//
//  Created by slience on 2017/3/21.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJRefreshExampleViewController.h"
#import "NJCell.h"

int cellRows = 50;
#define cellID @"cellID"

@interface NJRefreshExampleViewController () <UITableViewDataSource, UITableViewDelegate>

/** 事例列表 */
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation NJRefreshExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KSCREENWIDTH, KSCREENHEIGHT) style:UITableViewStylePlain];
        [self initRefreshTableViewController:_tableView headerRefreshAction:@selector(loadNewData) footerRefreshAction:@selector(loadMoreData)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[NJCell class] forCellReuseIdentifier:cellID];
    }
    return _tableView;
}

/** 刷新数据 */
- (void)loadNewData
{
    cellRows = 50;
    [self.tableView.mj_footer resetNoMoreData];
    [self requestData];
}

/** 加载更多 */
- (void)loadMoreData
{
    cellRows += 50;
    [self requestData];
    
}

/** 
 * 等待1.5秒
 */
void doSomeWork(void)
{
    [NSThread sleepForTimeInterval:1.5];
}

#pragma mark - tableview datasource method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cellRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NJCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
//    cell.textLabel.text = @(indexPath.row).stringValue;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"hello");
}

#pragma mark - 模拟网络请求
- (void)requestData
{
 
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            if (cellRows > 150) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
                return;
            }
            [self.tableView reloadData];
        });
    });
    
    
}

- (void)dealloc {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSArray *arr = @[@1, @2, @3, @4, @5, @6, @7, @8];
            NSString *path = NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES).lastObject;
            for (NSInteger i = 0; i < arr.count; i++) {
                NSString *finalPath = [NSString stringWithFormat:@"%@%zd", path, i];
                [arr writeToFile:finalPath atomically:YES];
                NSLog(@"%@", finalPath);
            }
            NSLog(@"写操作完毕");
        });
    });
    
    NSLog(@"NJRefresh Dealloc");
}

@end

































