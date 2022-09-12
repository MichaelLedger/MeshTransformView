//
//  MLMeshDemoViewController.m
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 2022/8/30.
//  Copyright © 2022 Gavin Xiang. All rights reserved.
//

#import "MLMeshDemoViewController.h"
//#import "MLMeshMetalRender.h"
#import "MLMeshTriangleRenderer.h"
#import "MLMeshLargeDataRenderer.h"
#import "MLMeshLoadPngImageRenderer.h"
#import "MLMeshPyramidRenderer.h"
@import MetalKit;

@interface MLMeshDemoViewController ()

@property (nonatomic, strong) MTKView *mtkView;// 视图
//@property (nonatomic, strong) MLMeshMetalRender *renderer;// 渲染器
//@property (nonatomic, strong) MLMeshTriangleRenderer *renderer;// 三角形渲染器
//@property (nonatomic, strong) MLMeshLargeDataRenderer *renderer;// 顶点数据达到上限渲染器
//@property (nonatomic, strong) MLMeshLoadTgaImageRenderer *renderer;// 加载TGA文件渲染器
//@property (nonatomic, strong) MLMeshLoadPngImageRenderer *renderer;// 加载PNG文件渲染器
@property (nonatomic, strong) MLMeshPyramidRenderer *renderer;// 金字塔模型渲染器

@property (nonatomic, strong) UISwitch *rotationX;
@property (nonatomic, strong) UISwitch *rotationY;
@property (nonatomic, strong) UISwitch *rotationZ;
@property (nonatomic, strong) UISlider *slider;

@end

@implementation MLMeshDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 1.获取mtkView
//    self.mtkView = (MTKView *)self.view;
    //一个MTLDevice 对象就代表这着一个GPU,通常我们可以调用方法MTLCreateSystemDefaultDevice()来获取代表默认的GPU单个对象.
    id <MTLDevice> device = MTLCreateSystemDefaultDevice();
    _mtkView = [[MTKView alloc] initWithFrame:self.view.bounds device:device];
    //判断是否设置成功
    NSAssert(_mtkView.device, @"Metal is not supported on this device");
    _mtkView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_mtkView];
    
    // 2.为mtkView设置MTLDevice
    self.mtkView.device = MTLCreateSystemDefaultDevice();
    
    // 3.判断是否设置成功
    if (!self.mtkView.device)
    {
        NSLog(@"Metal不支持这个设备");
        return;
    }
    
    // 4. 创建渲染器
    self.renderer = [[MLMeshPyramidRenderer alloc] initWithMetalKitView:self.mtkView];
    
    // 5.判断renderer是否创建成功
    if (!self.renderer)
    {
        NSLog(@"Renderer初始化失败");
        return;
    }
    
    // 6.设置MTKView的代理(由renderer来实现MTKView的代理方法)
    self.mtkView.delegate = self.renderer;
    
    // 7.为视图设置帧速率，默认每秒60帧
    self.mtkView.preferredFramesPerSecond = 60;
    
    // 8.告知 mtkView 的大小（可省略这步）
    [self.renderer mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
    
    [self createSubviews];
    
    [self initializeConfigurations];
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    
    if (@available(iOS 11.0, *)) {
        _mtkView.frame = CGRectMake(0, self.view.safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.height - self.view.safeAreaInsets.top);
    } else {
        // Fallback on earlier versions
    }
}

- (void)createSubviews
{
    UILabel *rotationXLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.f, 650.f, 100, 50)];
    UILabel *rotationYLabel = [[UILabel alloc] initWithFrame:CGRectMake(140.f, 650.f, 100, 50)];
    UILabel *rotationZLabel = [[UILabel alloc] initWithFrame:CGRectMake(260.f, 650.f, 100, 50)];
    rotationXLabel.text = @"绕X轴旋转";
    rotationYLabel.text = @"绕Y轴旋转";
    rotationZLabel.text = @"绕Z轴旋转";
    [self.view addSubview:rotationXLabel];
    [self.view addSubview:rotationYLabel];
    [self.view addSubview:rotationZLabel];
    
    UISwitch *rotationX = [[UISwitch alloc] initWithFrame:CGRectMake(20.f, 720.f, 100, 50.f)];
    [self.view addSubview:rotationX];
    self.rotationX = rotationX;
    
    UISwitch *rotationY = [[UISwitch alloc] initWithFrame:CGRectMake(140.f, 720.f, 100, 50.f)];
    [self.view addSubview:rotationY];
    self.rotationY = rotationY;
    
    UISwitch *rotationZ = [[UISwitch alloc] initWithFrame:CGRectMake(260.f, 720.f, 100, 50.f)];
    [self.view addSubview:rotationZ];
    self.rotationZ = rotationZ;
    
    UILabel *sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.f, 590.f, 100, 50)];
    sliderLabel.text = @"旋转速率";
    [self.view addSubview:sliderLabel];
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(140.f, 590.f, 200, 50.f)];
    slider.minimumValue = -M_PI;
    slider.maximumValue = M_PI;
    [self.view addSubview:slider];
    self.slider = slider;
    
    // Observers
    [self.rotationX addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.rotationY addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.rotationZ addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)initializeConfigurations {
    [self.rotationX setOn:YES];
    [self.rotationY setOn:YES];
    [self.rotationZ setOn:YES];
    [self refreshRotateParams];
}

- (void)sliderValueChanged:(UISlider *)sender {
    NSLog(@"%s", __func__);
    [self refreshRotateParams];
}

- (void)switchValueChanged:(UISwitch *)sender {
    NSLog(@"%s", __func__);
    [self refreshRotateParams];
}

- (void)refreshRotateParams {
    self.renderer.rotationX = self.rotationX.on ? self.slider.value : 0;
    self.renderer.rotationY = self.rotationY.on ? self.slider.value : 0;
    self.renderer.rotationZ = self.rotationZ.on ? self.slider.value : 0;
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
