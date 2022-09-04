//
//  MLMeshTransform+Interpolation.h
//  MLMeshTransformView
//
//  Copyright (c) 2014 Gavin Xiang. All rights reserved.
//

#import "MLMeshTransform.h"

@interface MLMeshTransform (PrivateInterpolation)

- (BOOL)isCompatibleWithTransform:(MLMeshTransform *)otherTransform error:(NSError **)error;
- (MLMeshTransform *)interpolateToTransform:(MLMeshTransform *)otherTransform withProgress:(double)progress;

@end
