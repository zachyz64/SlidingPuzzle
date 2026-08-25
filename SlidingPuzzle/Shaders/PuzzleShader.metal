//
//  PuzzleShader.metal
//  SlidingPuzzle
//
//  Created by Zach Zaborowski on 8/25/26.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn
{
    float3 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct Fragment
{
    float4 position [[position]];
    float2 texCoord;
};

vertex Fragment vertexShader(const VertexIn vertex_in [[stage_in]])
{
    Fragment frag;
    frag.position = float4(vertex_in.position, 1.0);
    frag.texCoord = vertex_in.texCoord;
    return frag;
}

fragment float4 fragmentShader(Fragment frag [[stage_in]], texture2d<float> puzzleTexture [[texture(0)]], sampler puzzleSampler [[sampler(0)]])
{
    float3 color = float3(1.0);
    float alpha = 1.0;
    
    return float4(color, alpha);
}
