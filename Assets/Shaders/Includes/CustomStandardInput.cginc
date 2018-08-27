struct _VertexInput
{
    float4 vertex   : POSITION;
    half3 normal    : NORMAL;
#ifdef USE_VERTEX_COLOR
	half4 color     : COLOR;
#endif
    float2 uv0      : TEXCOORD0;
    float2 uv1      : TEXCOORD1;
#if defined(DYNAMICLIGHTMAP_ON) || defined(UNITY_PASS_META)
    float2 uv2      : TEXCOORD2;
#endif
#ifdef _TANGENT_TO_WORLD
    half4 tangent   : TANGENT;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};