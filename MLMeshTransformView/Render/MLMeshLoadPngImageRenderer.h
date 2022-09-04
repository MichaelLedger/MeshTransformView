//
//  MLMeshLoadPngImageRenderer.h
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 2022/8/30.
//  Copyright © 2022 Gavin Xiang. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MetalKit;

NS_ASSUME_NONNULL_BEGIN

@interface MLMeshLoadPngImageRenderer : NSObject<MTKViewDelegate>

- (id)initWithMetalKitView:(MTKView *)mtkView;

@end

NS_ASSUME_NONNULL_END
