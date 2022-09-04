//
//  MLShaderTypes.h
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 2022/8/30.
//  Copyright © 2022 Gavin Xiang. All rights reserved.
//

#ifndef MLShaderTypes_h
#define MLShaderTypes_h
#include <simd/simd.h> // 连接OC与Metal之间的桥梁

// 缓存区索引值
typedef enum VertexInputIndex
{
    VertexInputIndexVertices = 0,// 顶点
    VertexInputIndexViewportSize = 1,// 视图大小
    VertexInputIndexDrawImageLayer = 2// 绘制图层
} VertexInputIndex;

// 顶点
typedef struct
{
    vector_float2 position;// 像素空间的位置，比如像素中心点(100,100)
    vector_float4 color;// RGBA颜色，在运行纹理Demo的时候需要注释掉，否则出错 //test
    vector_float2 textureCoordinate;// 2D纹理
} Vertex;

// 纹理索引
typedef enum TextureIndex
{
    TextureIndexBaseColor = 0 //0表示只有一个纹理
} TextureIndex;

/*---- Pyramid Begin ----*/
// 顶点数据结构
typedef struct
{
    vector_float4 position;          //顶点 xyzw
    vector_float3 color;             //颜色 rgb
    vector_float2 textureCoordinate; //纹理坐标 xy
} PyramidVertex;

// 矩阵结构体
typedef struct
{
    matrix_float4x4 projectionMatrix; //投影矩阵
    matrix_float4x4 modelViewMatrix;  //模型视图矩阵
} PyramidMatrix;

// 输入索引
typedef enum PyramidVertexInputIndex
{
    PyramidVertexInputIndexVertices     = 0, //顶点坐标索引
    PyramidVertexInputIndexMatrix       = 1, //矩阵索引
} PyramidVertexInputIndex;

// 片元着色器索引
typedef enum PyramidFragmentInputIndex
{
    PyramidFragmentInputIndexTexture     = 0,//片元输入纹理索引
} PyramidFragmentInputIndex;
/*---- Pyramid End ----*/

#endif /* MLShaderTypes_h */
