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
    float2 position [[attribute(0)]];
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
    frag.position = float4(vertex_in.position, 0.0, 1.0);
    frag.texCoord = vertex_in.texCoord;
    return frag;
}

fragment float4 fragmentShader(Fragment frag [[stage_in]],
                               constant float3& tint [[buffer(0)]],
                               texture2d<float> puzzleTexture [[texture(0)]],
                               sampler puzzleSampler [[sampler(0)]])
{
    float3 color = tint * float3(puzzleTexture.sample(puzzleSampler, frag.texCoord));
    float alpha = puzzleTexture.sample(puzzleSampler, frag.texCoord).a;
    
    return float4(color, alpha);
}
