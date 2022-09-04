#include <metal_stdlib>
using namespace metal;

/*==== Shader-Mesh ====*/
typedef struct {
    float4 position [[ position ]];
    float2 textureCoordinate;
} TextureViewFragmentIn;

constant float2 vertices[] = {
    { -1.0f,  1.0f },
    { -1.0f, -1.0f },
    {  1.0f,  1.0f },
    {  1.0f, -1.0f }
};

vertex TextureViewFragmentIn textureViewVertex(constant float4x4& projectionMatrix [[ buffer(0) ]],
                                               uint vertexID [[ vertex_id ]]) {
    float2 texCoord = vertices[vertexID];
    texCoord.y *= -1.0f;
    return {
        projectionMatrix * float4(vertices[vertexID], 0.0f, 1.0f),
        fma(texCoord, 0.5f, 0.5f)
    };
}

fragment float4 textureViewFragment(TextureViewFragmentIn in [[stage_in]],
                                    texture2d<float, access::sample> source [[ texture(0) ]]) {
    constexpr sampler s(coord::normalized,
                        address::clamp_to_zero,
                        filter::linear);
    const auto position = float3(in.textureCoordinate, 1.0f).xy;
    return source.sample(s, position);
}

/*==== Shader-Sphere ====*/
/*
struct VertexIn {
  float4 position [[ attribute(0) ]];
};
vertex float4 vertex_main(const VertexIn vertex_in [[ stage_in ]]) {
  return vertex_in.position;
}
fragment float4 fragment_main() {
  return float4(1, 0, 0, 1);
}
 */

#import "MLShaderTypes.h"
/*==== Shader-Triangle ====*/
/*
// 顶点着色器输出数据和片段着色器输入数据
typedef struct
{
    // 处理空间的顶点信息 position指的是顶点裁剪后的位置
    float4 clipSpacePosition [[position]];
    float4 color;// float4表示4维向量 颜色

} RasterizerData;

// 顶点着色函数
vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
             constant Vertex *vertices [[buffer(VertexInputIndexVertices)]],
             constant vector_uint2 *viewportSizePointer [[buffer(VertexInputIndexViewportSize)]])
{
    // 定义out
    RasterizerData out;

    // 初始化输出剪辑空间位置
    out.clipSpacePosition = vector_float4(0.0, 0.0, 0.0, 1.0);

    // 索引到我们的数组位置以获得当前顶点
    float2 pixelSpacePosition = vertices[vertexID].position.xy;

    // 将vierportSizePointer从verctor_uint2转换为vector_float2类型
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);

    // 计算和写入 XY 值到我们的剪辑空间的位置
    out.clipSpacePosition.xy = pixelSpacePosition / (viewportSize / 2.0);

    // 把我们输入的颜色直接赋值给输出颜色
    out.color = vertices[vertexID].color;

    // 完成! 将结构体传递到管道中下一个阶段
    return out;
}

// 片元函数
fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    // 返回输入的片元的颜色
    return in.color;
}
 */

// 一个项目里面只能有一个Tga文件
//=============加载Tga文件的修改版==========
/*==== Shader-TGA ====*/
/*
// 顶点着色器输出数据和片段着色器输入数据
typedef struct
{
    // 处理空间的顶点信息 position指的是顶点裁剪后的位置
    float4 clipSpacePosition [[position]];
    float2 textureCoordinate;// 2维纹理坐标

} RasterizerData;

// 顶点着色函数
vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
             constant Vertex *vertices [[buffer(VertexInputIndexVertices)]],
             constant vector_uint2 *viewportSizePointer [[buffer(VertexInputIndexViewportSize)]])
{
    // 定义out
    RasterizerData out;

    // 初始化输出剪辑空间位置
    out.clipSpacePosition = vector_float4(0.0, 0.0, 0.0, 1.0);

    // 索引到我们的数组位置以获得当前顶点
    float2 pixelSpacePosition = vertices[vertexID].position.xy;

    // 将vierportSizePointer从verctor_uint2转换为vector_float2类型
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);

    // 计算和写入 XYZW 值到我们的剪辑空间的位置
    out.clipSpacePosition.xy = pixelSpacePosition / (viewportSize / 2.0);
    out.clipSpacePosition.z = 0.0f;
    out.clipSpacePosition.w = 1.0f;
    
    // 把输入的纹理坐标直接赋值给输出纹理坐标
    out.textureCoordinate = vertices[vertexID].textureCoordinate;

    // 完成! 将结构体传递到管道中下一个阶段
    return out;
}

// 片元函数
fragment float4 fragmentShader(RasterizerData in [[stage_in]],
                               texture2d<half> colorTexture [[texture(TextureIndexBaseColor)]])
{
    // 设置纹理的属性。放大和缩小的过滤方式为线性（非邻近过滤）
    constexpr sampler textureSampler(mag_filter::linear,
                                     min_filter::linear);
    // 获取对应坐标下的纹理颜色值
    const half4 colorSampler = colorTexture.sample(textureSampler,in.textureCoordinate);
    
    // 输出颜色值
    return float4(colorSampler);
}
*/

/*==== Shader-Pyramid ====*/
typedef struct
{
    // 处理空间的顶点信息。position是默认属性修饰符，用来指定顶点
    float4 clipSpacePosition [[position]];
    // 颜色
    float3 pixelColor;
    // 纹理坐标
    float2 textureCoordinate;
} RasterizerData;

// 顶点函数
vertex RasterizerData
vertexShader(uint vertexID [[ vertex_id ]],
             constant PyramidVertex *vertexArray [[ buffer(PyramidVertexInputIndexVertices) ]],
             constant PyramidMatrix *matrix [[ buffer(PyramidVertexInputIndexMatrix) ]])
{
    // 定义输出
    RasterizerData out;
    // 计算裁剪空间坐标 = 投影矩阵 * 模型视图矩阵 * 顶点
    out.clipSpacePosition = matrix->projectionMatrix * matrix->modelViewMatrix * vertexArray[vertexID].position;
    // 纹理坐标
    out.textureCoordinate = vertexArray[vertexID].textureCoordinate;
    // 像素颜色值
    out.pixelColor = vertexArray[vertexID].color;
    
    return out;
}

// 片元函数
fragment float4
samplingShader(RasterizerData input [[stage_in]],
               texture2d<half> textureColor [[ texture(PyramidFragmentInputIndexTexture) ]])
{
    // 颜色值 从三维变量RGB -> 四维变量RGBA
    // half4 colorTex = half4(input.pixelColor.x, input.pixelColor.y, input.pixelColor.z, 1);
 
    constexpr sampler textureSampler (mag_filter::linear ,min_filter::linear);
    half4 colorTex = textureColor.sample(textureSampler, input.textureCoordinate);
    
    // 返回颜色
    return float4(colorTex);
}
