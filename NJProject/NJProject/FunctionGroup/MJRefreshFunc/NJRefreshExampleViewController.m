//
//  NJRefreshExampleViewController.m
//  NJProject
//
//  Created by slience on 2017/3/21.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJRefreshExampleViewController.h"

int cellRows = 50;
#define cellID @"cellID"

@interface NJRefreshExampleViewController () <UITableViewDataSource>

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
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    cell.textLabel.text = @(indexPath.row).stringValue;
    
    return cell;
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
    NSLog(@"NJRefresh Dealloc");
}

@end

































