//
//  MLMutableMeshTransform+Convenience.m
//  MLMeshTransformView
//
//  Copyright (c) 2014 Bartosz Ciechanowski. All rights reserved.
//

#import "MLMutableMeshTransform+Convenience.h"

const CGFloat kDoublePhotoPanelGapWidth = 0.1f;

@implementation MLMutableMeshTransform (Convenience)

+ (instancetype)identityMeshTransformWithNumberOfRows:(NSUInteger)rowsOfFaces
                                      numberOfColumns:(NSUInteger)columnsOfFaces
{
    NSParameterAssert(rowsOfFaces >= 1);
    NSParameterAssert(columnsOfFaces >= 1);
    
    MLMutableMeshTransform *transform = [MLMutableMeshTransform new];
    

    for (int row = 0; row <= rowsOfFaces; row++) {
        
        for (int col = 0; col <= columnsOfFaces; col++) {
            
            CGFloat x = (CGFloat)col/(columnsOfFaces);
            CGFloat y = (CGFloat)row/(rowsOfFaces);
            
            MLMeshVertex vertex = {
                .from = {x, y},
                .to = {x, y, 0.0f}
            };
            
            [transform addVertex:vertex];
        }
    }
    
    for (int row = 0; row < rowsOfFaces; row++) {
        for (int col = 0; col < columnsOfFaces; col++) {
            MLMeshFace face = {
                .indices = {
                    (unsigned int)((row + 0) * (columnsOfFaces + 1) + col),
                    (unsigned int)((row + 0) * (columnsOfFaces + 1) + col + 1),
                    (unsigned int)((row + 1) * (columnsOfFaces + 1) + col + 1),
                    (unsigned int)((row + 1) * (columnsOfFaces + 1) + col)
                }
            };
            
            [transform addFace:face];
        }
    }
    
    transform.depthNormalization = kMLDepthNormalizationAverage;
    return transform;
}


+ (instancetype)meshTransformWithVertexCount:(NSUInteger)vertexCount
                             vertexGenerator:(MLMeshVertex (^)(NSUInteger vertexIndex))vertexGenerator
                                   faceCount:(NSUInteger)faceCount
                                       faceGenerator:(MLMeshFace (^)(NSUInteger faceIndex))faceGenerator
{
    MLMutableMeshTransform *transform = [MLMutableMeshTransform new];
    
    for (int i = 0; i < vertexCount; i++) {
        [transform addVertex:vertexGenerator(i)];
    }
    
    for (int i = 0; i < faceCount; i++) {
        [transform addFace:faceGenerator(i)];
    }
    
    return transform;
}




- (void)mapVerticesUsingBlock:(MLMeshVertex (^)(MLMeshVertex vertex, NSUInteger vertexIndex))block
{
    NSUInteger count = self.vertexCount;
    for (int i = 0; i < count; i++) {
        [self replaceVertexAtIndex:i withVertex:block([self vertexAtIndex:i], i)];
    }
}

+ (instancetype)doublePanel
{
    NSUInteger columnsOfFaces = 10 + 1;
    NSUInteger rowsOfFaces = 3;
//    MLMutableMeshTransform *transform = [MLMutableMeshTransform identityMeshTransformWithNumberOfRows:rows numberOfColumns:columns];
    
    NSParameterAssert(rowsOfFaces >= 1);
    NSParameterAssert(columnsOfFaces >= 1);
    
    MLMutableMeshTransform *transform = [MLMutableMeshTransform new];
    

    for (int row = 0; row <= rowsOfFaces; row++) {
        
        for (int col = 0; col <= columnsOfFaces; col++) {
            
            CGFloat x = (CGFloat)col/(columnsOfFaces);
            CGFloat y = (CGFloat)row/(rowsOfFaces);
            
            MLMeshVertex vertex = {
                .from = {x, y},
                .to = {x, y, 0.0f}
            };
            
            [transform addVertex:vertex];
        }
    }
    
    for (int row = 0; row < rowsOfFaces; row++) {
        for (int col = 0; col < columnsOfFaces; col++) {
            MLMeshFace face = {
                .indices = {
                    (unsigned int)((row + 0) * (columnsOfFaces + 1) + col),
                    (unsigned int)((row + 0) * (columnsOfFaces + 1) + col + 1),
                    (unsigned int)((row + 1) * (columnsOfFaces + 1) + col + 1),
                    (unsigned int)((row + 1) * (columnsOfFaces + 1) + col)
                }
            };
            
            [transform addFace:face];
        }
    }
    
    transform.depthNormalization = kMLDepthNormalizationAverage;
    
    [transform mapVerticesUsingBlock:^MLMeshVertex(MLMeshVertex vertex, NSUInteger vertexIndex) {
        NSInteger row = vertexIndex / (columnsOfFaces + 1);
        NSInteger column = vertexIndex % (columnsOfFaces + 1);
        if (row == 0) {
            if (column <= columnsOfFaces / 2) {
                vertex.to.y = vertex.from.y + 0.2 / columnsOfFaces * column;
            } else {
                vertex.to.y = vertex.from.y + 0.2 / columnsOfFaces * (columnsOfFaces - column);
            }
        }
        if (row == columnsOfFaces) {
            if (column <= columnsOfFaces / 2) {
                vertex.to.y = vertex.from.y - 0.2 / columnsOfFaces * column;
            } else {
                vertex.to.y = vertex.from.y - 0.2 / columnsOfFaces * (columnsOfFaces - column);
            }
        }
        return vertex;
    }];
    return transform;
}

+ (instancetype)doublePanelSeperated
{
    NSUInteger columnsOfFaces = 3;
    NSUInteger rowsOfFaces = 20;
    
    NSParameterAssert(rowsOfFaces >= 1);
    NSParameterAssert(columnsOfFaces >= 1);
    
//    MLMutableMeshTransform *transform0 = [MLMutableMeshTransform identityMeshTransformWithNumberOfRows:rowsOfFaces numberOfColumns:columnsOfFaces];
//    return transform0;
    
    MLMutableMeshTransform *transform = [MLMutableMeshTransform new];
    
    for (int row = 0; row <= rowsOfFaces; row++) {
        
        for (int col = 0; col <= columnsOfFaces; col++) {
            //CGFloat x = (CGFloat)col/(columnsOfFaces-1);
            //CGFloat y = (CGFloat)row/(rowsOfFaces);
            
            CGFloat x,y;
            if (col == 0) {
                x = 0;
                y = (CGFloat)row/(rowsOfFaces);
            } else if (col == columnsOfFaces) {
                x = 1;
                y = (CGFloat)row/(rowsOfFaces);
            } else if (col < columnsOfFaces / 2) {
                x = (CGFloat)col/(columnsOfFaces - 1);
                y = (CGFloat)row/(rowsOfFaces);
            } else if (col == columnsOfFaces / 2 || col == columnsOfFaces / 2 + 1){
                x = 0.5;
                y = (CGFloat)row/(rowsOfFaces);
            } else {
                x = (CGFloat)col/(columnsOfFaces - 1);
                y = (CGFloat)row/(rowsOfFaces);
            }
            MLMeshVertex vertex = {
                .from = {x, y},
                .to = {x, y, 0.0f}
            };
            
            [transform addVertex:vertex];
        }
    }
    
    for (int row = 0; row < rowsOfFaces; row++) {
        for (int col = 0; col < columnsOfFaces; col++) {
            MLMeshFace face = {
                .indices = {
                    (unsigned int)((row + 0) * (columnsOfFaces + 1) + col),
                    (unsigned int)((row + 0) * (columnsOfFaces + 1) + col + 1),
                    (unsigned int)((row + 1) * (columnsOfFaces + 1) + col + 1),
                    (unsigned int)((row + 1) * (columnsOfFaces + 1) + col)
                }
            };
            
            [transform addFace:face];
        }
    }
    
    transform.depthNormalization = kMLDepthNormalizationAverage;
    
    [transform mapVerticesUsingBlock:^MLMeshVertex(MLMeshVertex vertex, NSUInteger vertexIndex) {
        NSInteger row = vertexIndex / (columnsOfFaces + 1);// 0 ~ 20 (rowsOfFaces)
        NSInteger column = vertexIndex % (columnsOfFaces + 1);// 0 ~ 11 (columnsOfFaces)
        
        CGFloat offsetX = 0.f;
        CGFloat offsetY = 0.f;
        CGFloat zPositon = 0.f;
        
        if (row <= rowsOfFaces / 2 - 1 && column == columnsOfFaces / 2) {
            offsetX = - kDoublePhotoPanelGapWidth / 2.0;
            offsetY = 0.1 /  (rowsOfFaces / 2) * (rowsOfFaces / 2 - row);
//            zPositon = 0.1;
        } else if (row <= rowsOfFaces / 2 - 1 && column == columnsOfFaces / 2 + 1) {
            offsetX = kDoublePhotoPanelGapWidth / 2.0;
            offsetY = 0.1 /  (rowsOfFaces / 2) * (rowsOfFaces / 2 - row);
//            zPositon = 0.1;
        } else if (row >= rowsOfFaces / 2 && column == columnsOfFaces / 2) {
            offsetX = - kDoublePhotoPanelGapWidth / 2.0;
            offsetY = - 0.1 /  (rowsOfFaces / 2) * (row - rowsOfFaces / 2);
//            zPositon = -0.1;
        } else if (row >= rowsOfFaces / 2 && column == columnsOfFaces / 2 + 1) {
            offsetX = kDoublePhotoPanelGapWidth / 2.0;
            offsetY = - 0.1 /  (rowsOfFaces / 2) * (row - rowsOfFaces / 2);
//            zPositon = -0.1;
        }
        
        vertex.to.x = vertex.from.x + offsetX;
        vertex.to.y = vertex.from.y + offsetY;
        vertex.to.z = zPositon;
        
        NSLog(@"position==row:%ld,column:%ld", row, column);
        NSLog(@"vertex.from==x:%f,y:%f", vertex.from.x, vertex.from.y);
        NSLog(@"vertex.to==x:%f,y:%f", vertex.to.x, vertex.to.y);
        return vertex;
    }];
    return transform;
}

@end
