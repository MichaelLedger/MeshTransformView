//
//  MLDemoTableViewController.m
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 11/05/14.
//  Copyright (c) 2014 Gavin Xiang. All rights reserved.
//

#import "MLDemoTableViewController.h"

#import "MLZoomDemoViewController.h"
#import "MLCurtainDemoViewController.h"
#import "MLJellyDemoViewController.h"
#import "MLSplitSkewViewController.h"
#import "MLMeshDemoViewController.h"

static NSString * const MLNameKey = @"name";
static NSString * const MLClassKey = @"class";

static NSString * const MLCellReuseIdentifier = @"MLCellReuseIdentifier";

@interface MLDemoTableViewController ()

@property (nonatomic, strong) NSArray *demoViewControllersDicts;

@end


@implementation MLDemoTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Demos";
        self.demoViewControllersDicts =
        @[
          @{MLNameKey: @"Curtain", MLClassKey : [MLCurtainDemoViewController class]},
          @{MLNameKey: @"Zoom", MLClassKey : [MLZoomDemoViewController class]},
          @{MLNameKey: @"Jelly",  MLClassKey : [MLJellyDemoViewController class]},
          @{MLNameKey: @"SplitSkew",  MLClassKey : [MLSplitSkewViewController class]},
          @{MLNameKey: @"Metal",  MLClassKey : [MLMeshDemoViewController class]}
          ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MLCellReuseIdentifier];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.demoViewControllersDicts.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MLCellReuseIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = self.demoViewControllersDicts[indexPath.row][MLNameKey];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class class = self.demoViewControllersDicts[indexPath.row][MLClassKey];
    UIViewController *demoController = [class new];
    demoController.title = self.demoViewControllersDicts[indexPath.row][MLNameKey];
    
    [self.navigationController pushViewController:demoController animated:YES];
}

@end
