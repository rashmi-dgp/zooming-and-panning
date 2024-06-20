#include "mtlm.h"
#include <math.h>

//definition of the math functions we will use
simd::float4x4 mtlm::identity() {
    simd_float4 col0 = {1.0f, 0.0f, 0.0f, 0.0f};
    simd_float4 col1 = {0.0f, 1.0f, 0.0f, 0.0f};
    simd_float4 col2 = {0.0f, 0.0f, 1.0f, 0.0f};
    simd_float4 col3 = {0.0f, 0.0f, 0.0f, 1.0f};
    return simd_matrix(col0, col1, col2, col3);
}

simd::float4x4 mtlm::translation(simd::float3 dPos) {
    simd_float4 col0 = {1.0f, 0.0f, 0.0f, 0.0f};
    simd_float4 col1 = {0.0f, 1.0f, 0.0f, 0.0f};
    simd_float4 col2 = {0.0f, 0.0f, 1.0f, 0.0f};
    simd_float4 col3 = {dPos[0], dPos[1], dPos[2], 1.0f};
    return simd_matrix(col0, col1, col2, col3);
}

simd::float4x4 mtlm::z_rotation(float theta) {
    theta = theta * M_PI / 180.0f;
    float c = cosf(theta);
    float s = sinf(theta);
    simd_float4 col0 = {   c,    s, 0.0f, 0.0f};
    simd_float4 col1 = {  -s,    c, 0.0f, 0.0f};
    simd_float4 col2 = {0.0f, 0.0f, 1.0f, 0.0f};
    simd_float4 col3 = {0.0f, 0.0f, 0.0f, 1.0f};
    return simd_matrix(col0, col1, col2, col3);
}

simd::float4x4 mtlm::scale(float factor) {
    simd_float4 col0 = {factor,   0.0f,   0.0f, 0.0f};
    simd_float4 col1 = {  0.0f, factor,   0.0f, 0.0f};
    simd_float4 col2 = {  0.0f,   0.0f, factor, 0.0f};
    simd_float4 col3 = {  0.0f,   0.0f,   0.0f, 1.0f};
    return simd_matrix(col0, col1, col2, col3);
}
// Added lookAt function
simd::float4x4 mtlm::lookAt(simd::float3 eye, simd::float3 center, simd::float3 up) {
    simd::float3 f = simd::normalize(center - eye);
    simd::float3 s = simd::normalize(simd::cross(f, up));
    simd::float3 u = simd::cross(s, f);

    return simd::float4x4(
        simd::float4{s.x, u.x, -f.x, 0.0f},
        simd::float4{s.y, u.y, -f.y, 0.0f},
        simd::float4{s.z, u.z, -f.z, 0.0f},
        simd::float4{-simd::dot(s, eye), -simd::dot(u, eye), simd::dot(f, eye), 1.0f}
    );
}

// Added perspective function
simd::float4x4 mtlm::perspective(float fovy, float aspect, float near, float far) {
    float tanHalfFovy = std::tan(fovy / 2.0f);
    return simd::float4x4(
        simd::float4{1.0f / (aspect * tanHalfFovy), 0.0f, 0.0f, 0.0f},
        simd::float4{0.0f, 1.0f / tanHalfFovy, 0.0f, 0.0f},
        simd::float4{0.0f, 0.0f, -(far + near) / (far - near), -1.0f},
        simd::float4{0.0f, 0.0f, -(2.0f * far * near) / (far - near), 0.0f}
    );
}

// Added radians function
float mtlm::radians(float degrees) {
    return degrees * M_PI / 180.0f;
}
