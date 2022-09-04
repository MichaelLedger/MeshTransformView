//
//  MLMeshPyramidRenderer.h
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 2022/8/30.
//  Copyright © 2022 Gavin Xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@interface MLMeshPyramidRenderer : NSObject<MTKViewDelegate>

@property (nonatomic, assign) float rotationX;
@property (nonatomic, assign) float rotationY;
@property (nonatomic, assign) float rotationZ;

- (id)initWithMetalKitView:(MTKView *)mtkView;

@end

NS_ASSUME_NONNULL_END
