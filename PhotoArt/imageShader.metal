//
//  imageShader.metal
//  PhotoArt
//
//  Created by Rustam Khakhuk on 09.10.2022.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float2 position;
};

struct VertexOut {
    float4 pos [[position]];
};

struct canvasState {
    float4 offset;
    float scale;
};

vertex VertexOut canvasVertex(const device Vertex *vertexArray [[buffer(0)]],
                              constant canvasState &state [[buffer(1)]],
                              constant float &k [[buffer(2)]],
                              unsigned int vid [[vertex_id]]) {
    Vertex v = vertexArray[vid];

    VertexOut result = VertexOut();

    result.pos = float4((v.position.x * state.scale + state.offset.x) * 2.0 - 1.0,
                        (v.position.y * state.scale + 1 - k - state.offset.y) * 2.0 - 1.0,
                        0,1);

    return result;
}

fragment half4 canvasFragment(VertexOut v [[stage_in]],
                                    constant canvasState &state [[buffer(0)]],
                                    texture2d<half, access::read> top [[texture(0)]]) {
    float2 position = float2(floor((v.pos.x - state.offset.x) / state.scale),floor((v.pos.y - state.offset.y) / state.scale));

    return top.read(ushort2(position.x, position.y));
}
