//
//  NJBaseViewController.h
//  NJProject
//
//  Created by slience on 2017/3/21.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NJBaseViewController : UIViewController


/** 初始化MJRefresh */
- (void)initRefreshTableViewController:(UITableView *)tableView headerRefreshAction:(SEL)loadNewData footerRefreshAction:(SEL)loadMoreData;

@end
