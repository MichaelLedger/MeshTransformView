//
//  MLZoomDemoViewController.m
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 11/05/14.
//  Copyright (c) 2014 Gavin Xiang. All rights reserved.
//

#import "MLZoomDemoViewController.h"
#import "MLMeshTransformView.h"
#import "MLMeshTransform+DemoTransforms.h"

@interface MLZoomDemoViewController ()

@end

@implementation MLZoomDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture.jpg"]];
//    imageView.center = CGPointMake(CGRectGetMidX(self.transformView.contentView.bounds),
//                                   CGRectGetMidY(self.transformView.contentView.bounds));
    imageView.frame = self.view.bounds;
    
    [self.transformView.contentView addSubview:imageView];
    
    // we don't want any shading on this one
    self.transformView.diffuseLightFactor = 0.0;
    
    [self meshBuldgeAtPoint:imageView.center];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event]; // ugly
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.transformView];

    [self meshBuldgeAtPoint:point];
}

- (void)meshBuldgeAtPoint:(CGPoint)point
{
    self.transformView.meshTransform = [MLMutableMeshTransform buldgeMeshTransformAtPoint:point withRadius:120.0 boundsSize:self.transformView.bounds.size];

}

@end
