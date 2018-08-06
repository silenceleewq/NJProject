//
//  NJNavigatorController.m
//  NJProject
//
//  Created by slience on 2017/6/19.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJNavigatorController.h"

@interface NJExample : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *vcName;

@end

@implementation NJExample

+ (instancetype)exampleWithTitle:(NSString *)title controllerName:(NSString *)vcName {
    NJExample *example = [[self class] new];
    
    example.title = title;
    example.vcName = vcName;
    
    return example;
}

@end

@interface NJNavigatorController ()

@property (nonatomic, strong) NSArray <NJExample *> * vcArray;

@end

@implementation NJNavigatorController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"导航";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"example"];
    
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.vcArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"example" forIndexPath:indexPath];
    
    NJExample *example = self.vcArray[indexPath.section];
    
    cell.textLabel.text = example.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NJExample *example = self.vcArray[indexPath.section];
    Class vcClass = NSClassFromString(example.vcName);
    UIViewController *vc = (UIViewController *)[[vcClass alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)loadData {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Controllers.plist" ofType:nil];
    NSArray *vcNames = [NSArray arrayWithContentsOfFile:filePath];
    NSMutableArray *tempArrM = [NSMutableArray array];
    for (int i = 0; i < vcNames.count; ++i) {
        NSDictionary *dict = vcNames[i];
        [tempArrM addObject:[NJExample exampleWithTitle:dict[@"Title"] controllerName:dict[@"Name"]]];
    }
    self.vcArray = [tempArrM copy];
    [self.tableView reloadData];
}


@end
