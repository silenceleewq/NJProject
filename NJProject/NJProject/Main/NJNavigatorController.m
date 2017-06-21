//
//  NJNavigatorController.m
//  NJProject
//
//  Created by slience on 2017/6/19.
//  Copyright © 2017年 Ninja. All rights reserved.
//

#import "NJNavigatorController.h"
#import "NJPhotosController.h"
#import "NJRefreshExampleViewController.h"
#import "NJQRCodeScanOC.h"
#import "QRCodeScanViewController.h"
#import "NJSDWebImageTest.h"

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
    
    self.vcArray = @[
                     [NJExample exampleWithTitle:@"NJRefreshExample" controllerName:@"NJRefreshExampleViewController"],
                     [NJExample exampleWithTitle:@"NJPhotos" controllerName:@"NJPhotosController"],
                     [NJExample exampleWithTitle:@"二维码扫描" controllerName:@"QRCodeScanViewController"],
                     [NJExample exampleWithTitle:@"NJSDWebImageTest" controllerName:@"NJSDWebImageTest"]
                     ];
    
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


@end
