//
//  MLMutableMeshTransform+Convenience.h
//  MLMeshTransformView
//
//  Created by Gavin Xiang on 24/04/14.
//  Copyright (c) 2014 Gavin Xiang. All rights reserved.
//

#import "MLMeshTransform.h"

extern const CGFloat kDoublePhotoPanelGapWidth;

@interface MLMutableMeshTransform (Convenience)

// Creates rectangular mesh transform with facesRows by facesColumns faces and equally spread vertices.
// Created transform is an identity transform – it doesn't introduce any distrubances.
// Number of rows and columns must be larger or equal to 1.
+ (instancetype)identityMeshTransformWithNumberOfRows:(NSUInteger)rowsOfFaces
                                      numberOfColumns:(NSUInteger)columnsOfFaces;


+ (instancetype)meshTransformWithVertexCount:(NSUInteger)vertexCount
                             vertexGenerator:(MLMeshVertex (^)(NSUInteger vertexIndex))vertexGenerator
                                   faceCount:(NSUInteger)faceCount
                               faceGenerator:(MLMeshFace (^)(NSUInteger faceIndex))faceGenerator;

// Enumerates over vertices and maps them to some other vertices
- (void)mapVerticesUsingBlock:(MLMeshVertex (^)(MLMeshVertex vertex, NSUInteger vertexIndex))block;

+ (instancetype)doublePanel;

+ (instancetype)doublePanelSeperated;

@end
