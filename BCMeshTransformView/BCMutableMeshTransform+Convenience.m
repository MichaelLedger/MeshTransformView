//
//  BCMutableMeshTransform+Convenience.m
//  BCMeshTransformView
//
//  Copyright (c) 2014 Bartosz Ciechanowski. All rights reserved.
//

#import "BCMutableMeshTransform+Convenience.h"

@implementation BCMutableMeshTransform (Convenience)



+ (instancetype)identityMeshTransformWithNumberOfRows:(NSUInteger)rowsOfFaces
                                      numberOfColumns:(NSUInteger)columnsOfFaces
{
    NSParameterAssert(rowsOfFaces >= 1);
    NSParameterAssert(columnsOfFaces >= 1);
    
    BCMutableMeshTransform *transform = [BCMutableMeshTransform new];
    

    for (int row = 0; row <= rowsOfFaces; row++) {
        
        for (int col = 0; col <= columnsOfFaces; col++) {
            
            CGFloat x = (CGFloat)col/(columnsOfFaces);
            CGFloat y = (CGFloat)row/(rowsOfFaces);
            
            BCMeshVertex vertex = {
                .from = {x, y},
                .to = {x, y, 0.0f}
            };
            
            [transform addVertex:vertex];
        }
    }
    
    for (int row = 0; row < rowsOfFaces; row++) {
        for (int col = 0; col < columnsOfFaces; col++) {
            BCMeshFace face = {
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
    
    transform.depthNormalization = kBCDepthNormalizationAverage;
    return transform;
}


+ (instancetype)meshTransformWithVertexCount:(NSUInteger)vertexCount
                             vertexGenerator:(BCMeshVertex (^)(NSUInteger vertexIndex))vertexGenerator
                                   faceCount:(NSUInteger)faceCount
                                       faceGenerator:(BCMeshFace (^)(NSUInteger faceIndex))faceGenerator
{
    BCMutableMeshTransform *transform = [BCMutableMeshTransform new];
    
    for (int i = 0; i < vertexCount; i++) {
        [transform addVertex:vertexGenerator(i)];
    }
    
    for (int i = 0; i < faceCount; i++) {
        [transform addFace:faceGenerator(i)];
    }
    
    return transform;
}




- (void)mapVerticesUsingBlock:(BCMeshVertex (^)(BCMeshVertex vertex, NSUInteger vertexIndex))block
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
//    BCMutableMeshTransform *transform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:rows numberOfColumns:columns];
    
    NSParameterAssert(rowsOfFaces >= 1);
    NSParameterAssert(columnsOfFaces >= 1);
    
    BCMutableMeshTransform *transform = [BCMutableMeshTransform new];
    

    for (int row = 0; row <= rowsOfFaces; row++) {
        
        for (int col = 0; col <= columnsOfFaces; col++) {
            
            CGFloat x = (CGFloat)col/(columnsOfFaces);
            CGFloat y = (CGFloat)row/(rowsOfFaces);
            
            BCMeshVertex vertex = {
                .from = {x, y},
                .to = {x, y, 0.0f}
            };
            
            [transform addVertex:vertex];
        }
    }
    
    for (int row = 0; row < rowsOfFaces; row++) {
        for (int col = 0; col < columnsOfFaces; col++) {
            BCMeshFace face = {
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
    
    transform.depthNormalization = kBCDepthNormalizationAverage;
    
    [transform mapVerticesUsingBlock:^BCMeshVertex(BCMeshVertex vertex, NSUInteger vertexIndex) {
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
    NSUInteger rowsOfFaces = 1;
    
    NSParameterAssert(rowsOfFaces >= 1);
    NSParameterAssert(columnsOfFaces >= 1);
    
//    BCMutableMeshTransform *transform0 = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:rowsOfFaces numberOfColumns:columnsOfFaces];
//    return transform0;
    
    BCMutableMeshTransform *transform = [BCMutableMeshTransform new];
    

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
            
            NSLog(@"from==x:%f,y:%f", x, y);
            
            BCMeshVertex vertex = {
                .from = {x, y},
                .to = {x, y, 0.0f}
            };
            
            [transform addVertex:vertex];
        }
    }
    
    for (int row = 0; row < rowsOfFaces; row++) {
        for (int col = 0; col < columnsOfFaces; col++) {
            BCMeshFace face = {
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
    
    transform.depthNormalization = kBCDepthNormalizationAverage;
    
    CGFloat gapWidth = 0.05;
    
    [transform mapVerticesUsingBlock:^BCMeshVertex(BCMeshVertex vertex, NSUInteger vertexIndex) {
        NSInteger row = vertexIndex / (columnsOfFaces + 1);// 0 ~ 20 (rowsOfFaces)
        NSInteger column = vertexIndex % (columnsOfFaces + 1);// 0 ~ 11 (columnsOfFaces)
        
        CGFloat offsetX = 0.f;
        CGFloat offsetY = 0.f;
        CGFloat zPositon = 0.f;
        
        if (row == 0 && column == columnsOfFaces / 2) {
            offsetX = - gapWidth / 2.0;
            offsetY = 0.1;
//            zPositon = 0.1;
        } else if (row == 0 && column == columnsOfFaces / 2 + 1) {
            offsetX = gapWidth / 2.0;
            offsetY = 0.1;
//            zPositon = 0.1;
        } else if (row == rowsOfFaces && column == columnsOfFaces / 2) {
            offsetX = - gapWidth / 2.0;
            offsetY = -0.1;
//            zPositon = 0.1;
        } else if (row == rowsOfFaces && column == columnsOfFaces / 2 + 1) {
            offsetX = gapWidth / 2.0;
            offsetY = -0.1;
//            zPositon = 0.1;
        }
        
        
//        if (row < rowsOfFaces / 2) {
//            if (column < columnsOfFaces / 2) {
//                offsetY = 0.1 / (columnsOfFaces - 1) * 2 * column;
//            } else if (column == columnsOfFaces / 2 || column == columnsOfFaces / 2 + 1){
//                offsetY = 0.1 / (columnsOfFaces - 1) * 2 * (columnsOfFaces - 1) / 2.0;
//            } else {
//                offsetY = 0.1 / (columnsOfFaces - 1) * 2 * (columnsOfFaces - column);
//            }
//        }
//        else if (row == rowsOfFaces / 2) {
//            offsetY = 0.f;
//        }
//        else if (row > rowsOfFaces / 2) {
//            if (column < columnsOfFaces / 2) {
//                offsetY = - 0.1 / (columnsOfFaces - 1) * 2 * column;
//            } else if (column == columnsOfFaces / 2 || column == columnsOfFaces / 2 + 1){
//                offsetY = - 0.1 / (columnsOfFaces - 1) * 2 * columnsOfFaces / 2.0;
//            } else {
//                offsetY = - 0.1 / (columnsOfFaces - 1) * 2 * (columnsOfFaces - column);
//            }
//        }
        
        vertex.to.x = vertex.from.x + offsetX;
        vertex.to.y = vertex.from.y + offsetY;
        vertex.to.z = zPositon;
        
//        CGFloat offsetX = 0.f;
//        if (column <= columnsOfFaces / 2 && column > 0) {
//            offsetX = - 1.0 / (columnsOfFaces - 1) / 2.0;
//        }
//        if (column >= columnsOfFaces / 2 + 1 && column < columnsOfFaces) {
//            offsetX = 1.0 / (columnsOfFaces - 1) / 2.0;
//        }
//        vertex.to.x = vertex.from.x + offsetX;
        
//        NSLog(@"replaced==row:%ld,column:%ld==offsetX:%f,offsetY,%f", row, column, offsetX, offsetY);
        
        NSLog(@"position==row:%ld,column:%ld", row, column);
        NSLog(@"vertex.from==x:%f,y:%f", vertex.from.x, vertex.from.y);
        NSLog(@"vertex.to==x:%f,y:%f", vertex.to.x, vertex.to.y);
        return vertex;
    }];
    return transform;
}

@end
