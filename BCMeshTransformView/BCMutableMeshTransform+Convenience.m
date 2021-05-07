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
    NSUInteger columnsOfFaces = 5;
    NSUInteger rowsOfFaces = 20;
    
    NSParameterAssert(rowsOfFaces >= 1);
    NSParameterAssert(columnsOfFaces >= 1);
    
//    BCMutableMeshTransform *transform0 = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:rowsOfFaces numberOfColumns:columnsOfFaces];
//    return transform0;
    
    BCMutableMeshTransform *transform = [BCMutableMeshTransform new];
    

    for (int row = 0; row <= rowsOfFaces; row++) {
        
        for (int col = 0; col <= columnsOfFaces; col++) {
            CGFloat x,y;
            if (col < columnsOfFaces / 2) {
                x = (CGFloat)col/(columnsOfFaces - 1);
                y = (CGFloat)row/(rowsOfFaces);
            } else if (col == columnsOfFaces / 2 || col == columnsOfFaces / 2 + 1){
                x = 0.5;
                y = (CGFloat)row/(rowsOfFaces);
            } else {
                x = (CGFloat)col/(columnsOfFaces - 1);
                y = (CGFloat)row/(rowsOfFaces);
            }
            
            
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
//        NSInteger row = vertexIndex / (columnsOfFaces + 1);
        NSInteger column = vertexIndex % (columnsOfFaces + 1);
//        NSLog(@"row:%ld,column:%ld", row, column);
//        if (row < rowsOfFaces / 2) {
//            if (column < columnsOfFaces / 2) {
//                vertex.to.y = vertex.from.y + 0.1 / (columnsOfFaces - 1) * column;
//            } else if (column == columnsOfFaces / 2 || column == columnsOfFaces / 2 + 1){
//                vertex.to.y = vertex.from.y + 0.1 / (columnsOfFaces - 1) * columnsOfFaces / 2.0;
//            } else {
//                vertex.to.y = vertex.from.y + 0.1 / (columnsOfFaces - 1) * (columnsOfFaces - column - 1);
//            }
//        } else if (row == rowsOfFaces / 2) {
//            vertex.to.y = vertex.from.y;
//        } else if (row > rowsOfFaces / 2) {
//            if (column < columnsOfFaces / 2) {
//                vertex.to.y = vertex.from.y - 0.1 / (columnsOfFaces - 1) * column;
//            } else if (column == columnsOfFaces / 2 || column == columnsOfFaces / 2 + 1){
//                vertex.to.y = vertex.from.y - 0.1 / (columnsOfFaces - 1) * columnsOfFaces / 2.0;
//            } else {
//                vertex.to.y = vertex.from.y - 0.1 / (columnsOfFaces - 1) * (columnsOfFaces - column - 1);
//            }
//        }
        
        if (column <= columnsOfFaces / 2 && column > 0) {
            vertex.to.x = vertex.from.x - 1.0 / columnsOfFaces / 2.0;
        }
        if (column >= columnsOfFaces / 2 + 1 && column < columnsOfFaces) {
            vertex.to.x = vertex.from.x + 1.0 / columnsOfFaces / 2.0;
        }
        return vertex;
    }];
    return transform;
}

@end
