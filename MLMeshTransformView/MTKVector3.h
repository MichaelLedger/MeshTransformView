//
//  MTKConvertHelper.h
//  MLMeshTransformViewDemo
//
//  Created by Gavin Xiang on 2022/8/18.
//  Copyright © 2022 Bartosz Ciechanowski. All rights reserved.
//

#ifndef MTKConvertHelper_h
#define MTKConvertHelper_h

#include <stdbool.h>
#include <math.h>

#include <simd/vector_types.h>
#include <simd/vector_make.h>
#if SIMD_COMPILER_HAS_REQUIRED_FEATURES

#ifdef __cplusplus
extern "C" {
#endif

#pragma mark -
#pragma mark Prototypes
#pragma mark -

#define MTK_INLINE static inline
    
MTK_INLINE simd_float3 simd_float3_make(float x, float y, float z);
MTK_INLINE simd_float3 simd_float3_make_with_array(float values[3]);

MTK_INLINE simd_float3 simd_float3_negate(simd_float3 vector);

MTK_INLINE simd_float3 simd_float3_add(simd_float3 vectorLeft, simd_float3 vectorRight);
MTK_INLINE simd_float3 simd_float3_subtract(simd_float3 vectorLeft, simd_float3 vectorRight);
MTK_INLINE simd_float3 simd_float3_multiply(simd_float3 vectorLeft, simd_float3 vectorRight);
MTK_INLINE simd_float3 simd_float3_divide(simd_float3 vectorLeft, simd_float3 vectorRight);

MTK_INLINE simd_float3 simd_float3_add_scalar(simd_float3 vector, float value);
MTK_INLINE simd_float3 simd_float3_subtract_scalar(simd_float3 vector, float value);
MTK_INLINE simd_float3 simd_float3_multiply_scalar(simd_float3 vector, float value);
MTK_INLINE simd_float3 simd_float3_divide_scalar(simd_float3 vector, float value);

/*
 Returns a vector whose elements are the larger of the corresponding elements of the vector arguments.
 */
MTK_INLINE simd_float3 simd_float3_maximum(simd_float3 vectorLeft, simd_float3 vectorRight);
/*
 Returns a vector whose elements are the smaller of the corresponding elements of the vector arguments.
 */
MTK_INLINE simd_float3 simd_float3_minimum(simd_float3 vectorLeft, simd_float3 vectorRight);

/*
 Returns true if all of the first vector's elements are equal to all of the second vector's arguments.
 */
MTK_INLINE bool simd_float3_all_equal_to_simd_float3(simd_float3 vectorLeft, simd_float3 vectorRight);
/*
 Returns true if all of the vector's elements are equal to the provided value.
 */
MTK_INLINE bool simd_float3_all_equal_to_scalar(simd_float3 vector, float value);
/*
 Returns true if all of the first vector's elements are greater than all of the second vector's arguments.
 */
MTK_INLINE bool simd_float3_all_greater_than_simd_float3(simd_float3 vectorLeft, simd_float3 vectorRight);
/*
 Returns true if all of the vector's elements are greater than the provided value.
 */
MTK_INLINE bool simd_float3_all_greater_than_scalar(simd_float3 vector, float value);
/*
 Returns true if all of the first vector's elements are greater than or equal to all of the second vector's arguments.
 */
MTK_INLINE bool simd_float3_all_greater_than_or_equal_to_simd_float3(simd_float3 vectorLeft, simd_float3 vectorRight);
/*
 Returns true if all of the vector's elements are greater than or equal to the provided value.
 */
MTK_INLINE bool simd_float3_all_greater_than_or_equal_to_scalar(simd_float3 vector, float value);

MTK_INLINE simd_float3 simd_float3_normalize(simd_float3 vector);

MTK_INLINE float simd_float3_dot_product(simd_float3 vectorLeft, simd_float3 vectorRight);
MTK_INLINE float simd_float3_length(simd_float3 vector);
MTK_INLINE float simd_float3_distance(simd_float3 vectorStart, simd_float3 vectorEnd);

MTK_INLINE simd_float3 simd_float3_lerp(simd_float3 vectorStart, simd_float3 vectorEnd, float t);

MTK_INLINE simd_float3 simd_float3_cross_product(simd_float3 vectorLeft, simd_float3 vectorRight);

/*
 Project the vector, vectorToProject, onto the vector, projectionVector.
 */
MTK_INLINE simd_float3 simd_float3_project(simd_float3 vectorToProject, simd_float3 projectionVector);

#pragma mark -
#pragma mark Implementations
#pragma mark -

MTK_INLINE simd_float3 simd_float3_make(float x, float y, float z)
{
    simd_float3 v = simd_make_float3(x, y, z);
    return v;
}

MTK_INLINE simd_float3 simd_float3_make_with_array(float values[3])
{
    simd_float3 v = simd_float3_make(values[0], values[1], values[2]);
    return v;
}

MTK_INLINE simd_float3 simd_float3_negate(simd_float3 vector)
{
    simd_float3 v = simd_float3_make(-vector.x, -vector.y, -vector.z);
    return v;
}

MTK_INLINE simd_float3 simd_float3_add(simd_float3 vectorLeft, simd_float3 vectorRight)
{
    simd_float3 v = simd_float3_make(vectorLeft.x + vectorRight.x,
                                     vectorLeft.y + vectorRight.y,
                                     vectorLeft.z + vectorRight.z);
    return v;
}

MTK_INLINE simd_float3 simd_float3_subtract(simd_float3 vectorLeft, simd_float3 vectorRight)
{
    simd_float3 v = simd_float3_make(vectorLeft.x - vectorRight.x,
                                     vectorLeft.y - vectorRight.y,
                                     vectorLeft.z - vectorRight.z);
    return v;
}

MTK_INLINE simd_float3 simd_float3_multiply(simd_float3 vectorLeft, simd_float3 vectorRight)
{
    simd_float3 v = simd_float3_make(vectorLeft.x * vectorRight.x,
                                     vectorLeft.y * vectorRight.y,
                                     vectorLeft.z * vectorRight.z);
    return v;
}

MTK_INLINE simd_float3 simd_float3_divide(simd_float3 vectorLeft, simd_float3 vectorRight)
{
    simd_float3 v = simd_float3_make(vectorLeft.x / vectorRight.x,
                                     vectorLeft.y / vectorRight.y,
                                     vectorLeft.z / vectorRight.z);
    return v;
}

MTK_INLINE simd_float3 simd_float3_add_scalar(simd_float3 vector, float value)
{
    simd_float3 v = simd_float3_make(vector.x + value,
                                     vector.y + value,
                                     vector.z + value);
    return v;
}

MTK_INLINE simd_float3 simd_float3_subtract_scalar(simd_float3 vector, float value)
{
    simd_float3 v = simd_float3_make(vector.x - value,
                                     vector.y - value,
                                     vector.z - value);
    return v;
}

MTK_INLINE simd_float3 simd_float3_multiply_scalar(simd_float3 vector, float value)
{
    simd_float3 v = simd_float3_make(vector.x * value,
                                     vector.y * value,
                                     vector.z * value);
    return v;
}

MTK_INLINE simd_float3 simd_float3_divide_scalar(simd_float3 vector, float value)
{
    simd_float3 v = simd_float3_make(vector.x / value,
                                     vector.y / value,
                                     vector.z / value);
    return v;
}

MTK_INLINE simd_float3 simd_float3_maximum(simd_float3 vectorLeft, simd_float3 vectorRight)
{
    simd_float3 max = vectorLeft;
    if (vectorRight.x > vectorLeft.x)
        max.x = vectorRight.x;
    if (vectorRight.y > vectorLeft.y)
        max.y = vectorRight.y;
    if (vectorRight.z > vectorLeft.z)
        max.z = vectorRight.z;
    return max;
}

MTK_INLINE simd_float3 simd_float3_minimum(simd_float3 vectorLeft, simd_float3 vectorRight)
{
    simd_float3 min = vectorLeft;
    if (vectorRight.x < vectorLeft.x)
        min.x = vectorRight.x;
    if (vectorRight.y < vectorLeft.y)
        min.y = vectorRight.y;
    if (vectorRight.z < vectorLeft.z)
        min.z = vectorRight.z;
    return min;
}

MTK_INLINE bool simd_float3_all_equal_to_simd_float3(simd_float3 vectorLeft, simd_float3 vectorRight)
{
    bool compare = false;
    if (vectorLeft.x == vectorRight.x &&
        vectorLeft.y == vectorRight.y &&
        vectorLeft.z == vectorRight.z)
        compare = true;
    return compare;
}

MTK_INLINE bool simd_float3_all_equal_to_scalar(simd_float3 vector, float value)
{
    bool compare = false;
    if (vector.x == value &&
        vector.y == value &&
        vector.z == value)
        compare = true;
    return compare;
}

MTK_INLINE bool simd_float3_all_greater_than_simd_float3(simd_float3 vectorLeft, simd_float3 vectorRight)
{
    bool compare = false;
    if (vectorLeft.x > vectorRight.x &&
        vectorLeft.y > vectorRight.y &&
        vectorLeft.z > vectorRight.z)
        compare = true;
    return compare;
}

MTK_INLINE bool simd_float3_all_greater_than_scalar(simd_float3 vector, float value)
{
    bool compare = false;
    if (vector.x > value &&
        vector.y > value &&
        vector.z > value)
        compare = true;
    return compare;
}

MTK_INLINE bool simd_float3_all_greater_than_or_equal_to_simd_float3(simd_float3 vectorLeft, simd_float3 vectorRight)
{
    bool compare = false;
    if (vectorLeft.x >= vectorRight.x &&
        vectorLeft.y >= vectorRight.y &&
        vectorLeft.z >= vectorRight.z)
        compare = true;
    return compare;
}

MTK_INLINE bool simd_float3_all_greater_than_or_equal_to_scalar(simd_float3 vector, float value)
{
    bool compare = false;
    if (vector.x >= value &&
        vector.y >= value &&
        vector.z >= value)
        compare = true;
    return compare;
}

MTK_INLINE simd_float3 simd_float3_normalize(simd_float3 vector)
{
    float scale = 1.0f / simd_float3_length(vector);
    simd_float3 v = simd_float3_make(vector.x * scale, vector.y * scale, vector.z * scale);
    return v;
}

MTK_INLINE float simd_float3_dot_product(simd_float3 vectorLeft, simd_float3 vectorRight)
{
    return vectorLeft.x * vectorRight.x + vectorLeft.y * vectorRight.y + vectorLeft.z * vectorRight.z;
}

MTK_INLINE float simd_float3_length(simd_float3 vector)
{
    return sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z);
}

MTK_INLINE float simd_float3_distance(simd_float3 vectorStart, simd_float3 vectorEnd)
{
    return simd_float3_length(simd_float3_subtract(vectorEnd, vectorStart));
}

MTK_INLINE simd_float3 simd_float3_lerp(simd_float3 vectorStart, simd_float3 vectorEnd, float t)
{
    simd_float3 v = simd_float3_make(vectorStart.x + ((vectorEnd.x - vectorStart.x) * t),
                                     vectorStart.y + ((vectorEnd.y - vectorStart.y) * t),
                                     vectorStart.z + ((vectorEnd.z - vectorStart.z) * t));
    return v;
}

MTK_INLINE simd_float3 simd_float3_cross_product(simd_float3 vectorLeft, simd_float3 vectorRight)
{
    simd_float3 v = simd_float3_make(vectorLeft.y * vectorRight.z - vectorLeft.z * vectorRight.y,
                                     vectorLeft.z * vectorRight.x - vectorLeft.x * vectorRight.z,
                                     vectorLeft.x * vectorRight.y - vectorLeft.y * vectorRight.x);
    return v;
}

MTK_INLINE simd_float3 simd_float3_project(simd_float3 vectorToProject, simd_float3 projectionVector)
{
    float scale = simd_float3_dot_product(projectionVector, vectorToProject) / simd_float3_dot_product(projectionVector, projectionVector);
    simd_float3 v = simd_float3_multiply_scalar(projectionVector, scale);
    return v;
}

#ifdef __cplusplus
}
#endif /* __cplusplus */
#endif /* SIMD_COMPILER_HAS_REQUIRED_FEATURES */
#endif /* MTKConvertHelper_h */
