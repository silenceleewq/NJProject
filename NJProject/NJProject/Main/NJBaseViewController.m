//
//  NJBaseViewController.m
//  NJProject
//
//  Created by slience on 2017/3/21.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJBaseViewController.h"

@interface NJBaseViewController ()

@end

@implementation NJBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)initRefreshTableViewController:(UITableView *)tableView headerRefreshAction:(SEL)loadNewData footerRefreshAction:(SEL)loadMoreData
{
    MJRefreshStateHeader *header = [MJRefreshStateHeader headerWithRefreshingTarget:self refreshingAction:loadNewData];
    tableView.mj_header = header;
    
    MJRefreshAutoStateFooter *footer = [MJRefreshAutoStateFooter footerWithRefreshingTarget:self refreshingAction:loadMoreData];
    tableView.mj_footer = footer;
}

@end
