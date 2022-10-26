//
//  BeizerShader.metal
//  PhotoArt
//
//  Created by Rustam Khakhuk on 20.10.2022.
//

#include <metal_stdlib>
using namespace metal;

struct BeizerSpline {
    float2 startPoint;
    float2 endPoint;

    float2 p1;
    float2 p2;

    float startSize;
    float endSize;
    float4 color;
};

struct VertexOut {
    float4 pos[[position]];
    float4 color;
};

float2 pointForCap(float2 center, float radius, float progress, int vertexId) {
    return vertexId % 2 == 0 ? center : center + float2(sin(progress * M_PI_F * 2), -cos(progress * M_PI_F * 2)) * radius;
}

float2 pointForLine(BeizerSpline spline, float progress, int vertexId) {
    float t = progress;

    float deltaSize = spline.endSize - spline.startSize;

    float lineWidth = (1 - (((float) (vertexId % 2)) * 2.0)) * (spline.startSize + deltaSize * t);

    float2 a = spline.startPoint;
    float2 b = spline.endPoint;

    float2 p1 = spline.p1 * 3.0;
    float2 p2 = spline.p2 * 3.0;

    float nt = 1.0f - t;

    float nt_2 = nt * nt;
    float nt_3 = nt_2 * nt;

    float t_2 = t * t;
    float t_3 = t_2 * t;

    float2 point = a * nt_3 + p1 * nt_2 * t + p2 * nt * t_2 + b * t_3;
    float2 tangent = -3.0 * a * nt_2 + p1 * (1.0 - 4.0 * t + 3.0 * t_2) + p2 * (2.0 * t - 3.0 * t_2) + 3 * b * t_2;

    tangent = normalize(float2(-tangent.y, tangent.x));

    return point + (tangent * (lineWidth / 2.0));
}

vertex VertexOut bezierVertex(constant BeizerSpline *allParams[[buffer(0)]],
                              constant float &k [[buffer(1)]],
                               uint vertexId[[vertex_id]],
                               uint instanceId[[instance_id]]) {
    const uint pointsPerCap = 100;
    const uint pointsPerLine = 200;
    BeizerSpline curve = allParams[instanceId];

    float2 point = vertexId < pointsPerCap ?
    pointForCap(curve.startPoint, curve.startSize / 2.0, vertexId / (float)(pointsPerCap - 2), vertexId) :
    vertexId > pointsPerCap + pointsPerLine ?
    pointForCap(curve.endPoint, curve.endSize / 2.0, (vertexId - pointsPerCap - pointsPerLine) / (float)(pointsPerCap - 2), vertexId) :
    pointForLine(curve, (vertexId - pointsPerCap) / (float)(pointsPerLine), vertexId);

    VertexOut vo;

    vo.pos.xy = point;
    vo.pos.y /= k;
    vo.pos.zw = float2(0, 1);
    vo.color = curve.color;

    return vo;
}

fragment half4 bezierFragment(VertexOut params[[stage_in]])
{
    return half4(params.color);
}


vertex VertexOut bezierCapVertex(constant BeizerSpline *allParams[[buffer(0)]],
                              constant float &k [[buffer(1)]],
                               uint vertexId[[vertex_id]],
                               uint instanceId[[instance_id]])
{
    float width = instanceId % 2 == 0 ? allParams[instanceId / 2].startSize : allParams[instanceId / 2].endSize;
    float2 point = instanceId % 2 == 0 ? allParams[instanceId / 2].startPoint : allParams[instanceId / 2].endPoint;

    float angle = (vertexId / 49.0) * M_PI_F * 2;

    float2 position = vertexId % 2 == 0 ? point : point + float2(sin(angle), -cos(angle)) * width / 2;

    VertexOut vo;
    vo.pos.xy = position;
    vo.pos.y /= k;
    vo.pos.zw = float2(0, 1);
    vo.color = allParams[instanceId / 2].color;

    return vo;
}

fragment half4 bezierCapFragment(VertexOut params[[stage_in]])
{
    return half4(params.color);
}
