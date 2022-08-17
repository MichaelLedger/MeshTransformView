//
//  BCSplitSkewViewController.m
//  BCMeshTransformViewDemo
//
//  Created by Gavin Xiang on 2021/4/29.
//  Copyright © 2021 Bartosz Ciechanowski. All rights reserved.
//

#import "BCSplitSkewViewController.h"
#import "BCMeshTransformView.h"
#import "BCMeshTransform+DemoTransforms.h"

@interface BCSplitSkewViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation BCSplitSkewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"strawberry.jpeg"]];//circle.jpg、picture@2x.jpg、strawberry.jpeg
//    imageView.center = CGPointMake(CGRectGetMidX(self.transformView.contentView.bounds),
//                                   CGRectGetMidY(self.transformView.contentView.bounds));
    imageView.backgroundColor = [UIColor grayColor];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.borderColor = [UIColor systemPinkColor].CGColor;
    imageView.layer.borderWidth = 1.f;
    imageView.clipsToBounds = YES;
    _imageView = imageView;
    
    [self.transformView.contentView addSubview:imageView];
    
    UISwitch *switchBtn = [[UISwitch alloc] init];
    [self.transformView.contentView addSubview:switchBtn];
    [switchBtn addTarget:self action:@selector(switchBtnClicked:) forControlEvents:UIControlEventValueChanged];
    switchBtn.center = CGPointMake(self.view.center.x, switchBtn.center.y);
    
    // we don't want any shading on this one
    self.transformView.diffuseLightFactor = 0.0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.transformView.meshTransform = [BCMutableMeshTransform doublePanelSeperated];
    });
    
//    [self meshBuldgeAtPoint:imageView.center];
    
//    NSInteger columns = 3;
//    for (NSInteger i = 0; i < columns; i ++) {
//        UIView *seperatedView = [[UIView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width / columns) * i, 0, self.view.bounds.size.width / columns, self.view.bounds.size.height)];
//        seperatedView.backgroundColor = [UIColor colorWithRed:arc4random() % 255 / 255.0
//                                                        green:arc4random() % 255 / 255.0
//                                                         blue:arc4random() % 255 / 255.0
//                                                        alpha:0.1];
//        seperatedView.layer.borderColor = [UIColor grayColor].CGColor;
//        seperatedView.layer.borderWidth = 0.5f;
//        seperatedView.userInteractionEnabled = NO;
//        [self.view addSubview:seperatedView];
//    }
    
    UIView *seperatedView = [[UIView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width * (1 - kDoublePhotoPanelGapWidth)) / 2.0, 0, self.view.bounds.size.width * kDoublePhotoPanelGapWidth, self.view.bounds.size.height)];
    seperatedView.backgroundColor = [UIColor colorWithRed:arc4random() % 255 / 255.0
                                                    green:arc4random() % 255 / 255.0
                                                     blue:arc4random() % 255 / 255.0
                                                    alpha:0.5];
    seperatedView.layer.borderColor = [UIColor grayColor].CGColor;
    seperatedView.layer.borderWidth = 0.5f;
    seperatedView.userInteractionEnabled = NO;
    [self.view addSubview:seperatedView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event]; // ugly
    
//    self.transformView.meshTransform = [BCMutableMeshTransform doublePanel];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self.transformView];

//    [self meshBuldgeAtPoint:point];
}

- (void)meshBuldgeAtPoint:(CGPoint)point
{
//    self.transformView.meshTransform = [BCMutableMeshTransform buldgeMeshTransformAtPoint:point withRadius:120.0 boundsSize:self.transformView.bounds.size];
    self.transformView.meshTransform = [BCMutableMeshTransform splitSkewTransromAtPoint:point boundsSize:self.transformView.bounds.size];

}

- (void)switchBtnClicked:(UISwitch *)sender {
//    self.transformView.meshTransform = [BCMutableMeshTransform doublePanel];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];

//    _imageView.center = self.view.center;
    _imageView.frame = self.transformView.contentView.bounds;
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
