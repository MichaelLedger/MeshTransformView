//
//  MLDemoViewController.m
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 11/05/14.
//  Copyright (c) 2014 Gavin Xiang. All rights reserved.
//

#import "MLDemoViewController.h"
#import "MLMeshTransformView.h"

@interface MLDemoViewController ()

@end

@implementation MLDemoViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _transformView = [[MLMeshTransformView alloc] initWithFrame:self.view.bounds];
    _transformView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    [self.view addSubview:_transformView];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    
    if (@available(iOS 11.0, *)) {
        _transformView.frame = CGRectMake(0, self.view.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.height - self.view.safeAreaInsets.top);
        _transformView.contentView.frame = _transformView.bounds;
    } else {
        // Fallback on earlier versions
    }
}

@end
