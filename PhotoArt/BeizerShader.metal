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

vertex VertexOut bezierVertex(constant BeizerSpline *allParams[[buffer(0)]],
                              constant float &k [[buffer(1)]],
                               uint vertexId[[vertex_id]],
                               uint instanceId[[instance_id]])
{
    float t = (float) floor(vertexId / 2.0) / 200.0 * 2.0;

    BeizerSpline params = allParams[instanceId];

    float deltaSize = params.endSize - params.startSize;

    float lineWidth = (1 - (((float) (vertexId % 2)) * 2.0)) * (params.startSize + deltaSize * t);

    float2 a = params.startPoint;
    float2 b = params.endPoint;

    float2 p1 = params.p1 * 3.0;
    float2 p2 = params.p2 * 3.0;

    float nt = 1.0f - t;

    float nt_2 = nt * nt;
    float nt_3 = nt_2 * nt;

    float t_2 = t * t;
    float t_3 = t_2 * t;

    float2 point = a * nt_3 + p1 * nt_2 * t + p2 * nt * t_2 + b * t_3;
    float2 tangent = -3.0 * a * nt_2 + p1 * (1.0 - 4.0 * t + 3.0 * t_2) + p2 * (2.0 * t - 3.0 * t_2) + 3 * b * t_2;

    tangent = normalize(float2(-tangent.y, tangent.x));

    VertexOut vo;

    vo.pos.xy = point + (tangent * (lineWidth / 2.0f));
    vo.pos.y /= k;
    vo.pos.zw = float2(0, 1);
    vo.color = params.color;

    return vo;
}

fragment half4 bezierFragment(VertexOut params[[stage_in]])
{
    return half4(params.color);
}


vertex VertexOut bezierDebugVertex(constant BeizerSpline *allParams[[buffer(0)]],
                              constant float &k [[buffer(1)]],
                               uint vertexId[[vertex_id]],
                               uint instanceId[[instance_id]])
{
    BeizerSpline params = allParams[instanceId];

    float2 point = vertexId == 0 ? params.startPoint : 0;
    point = vertexId == 1 ? params.p1 : point;

    point = vertexId == 2 ? params.p2 : point;
    point = vertexId == 3 ? params.endPoint : point;

    VertexOut vo;

    vo.pos.xy = point;
    vo.pos.y /= k;
    vo.pos.zw = float2(0, 1);
    vo.color = params.color;

    return vo;
}

fragment half4 bezierDebugFragment(VertexOut params[[stage_in]])
{
    return half4(0,1,0,1);
}
