#include "UnityStandardCoreForward.cginc"
// macro defined here

struct _VertexInput
{
    float4 vertex								: POSITION;
    half3 normal								: NORMAL;
    float2 uv0									: TEXCOORD0;
    float2 uv1									: TEXCOORD1;
//#if defined(DYNAMICLIGHTMAP_ON) || defined(UNITY_PASS_META)
//    float2 uv2									: TEXCOORD2;
//#endif
#if defined(_TANGENT_TO_WORLD) || defined(_ENABLE_TANGENT_TO_WORLD)
    half4 tangent								: TANGENT;
#endif
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

//  Base forward pass (directional light, emission, lightmaps, ...)
struct _VertexOutputForward
{
	UNITY_POSITION(pos);
	float4 tex									: TEXCOORD0;
	half3 eyeVec								: TEXCOORD1;
	float4 tangentToWorldAndPackedData[3]		: TEXCOORD2;    // [3x3:tangentToWorld | 1x3:viewDirForParallax or worldPos]
	half4 ambientOrLightmapUV					: TEXCOORD5;    // SH or Lightmap UV
	UNITY_SHADOW_COORDS(6)
		UNITY_FOG_COORDS(7)

		// next ones would not fit into SM2.0 limits, but they are always for SM3.0+
#if UNITY_REQUIRE_FRAG_WORLDPOS && !UNITY_PACK_WORLDPOS_WITH_TANGENT
	float3 posWorld								: TEXCOORD8;
#endif

#ifdef _ENABLE_RENDER_TARGET_TEXTURE
	half4 customRT								: TEXCOORD9;
#endif

	UNITY_VERTEX_INPUT_INSTANCE_ID
	UNITY_VERTEX_OUTPUT_STEREO
};

//  Additive forward pass (one light per pass)
struct _VertexOutputForwardAdd
{
	UNITY_POSITION(pos);
	float4 tex									: TEXCOORD0;
	half3 eyeVec								: TEXCOORD1;
	float4 tangentToWorldAndLightDir[3]			: TEXCOORD2;    // [3x3:tangentToWorld | 1x3:lightDir]
	float3 posWorld								: TEXCOORD5;
	UNITY_SHADOW_COORDS(6)
	UNITY_FOG_COORDS(7)
	// next ones would not fit into SM2.0 limits, but they are always for SM3.0+
#if defined(_PARALLAXMAP)
	half3 viewDirForParallax					: TEXCOORD8;
#endif

#ifdef _ENABLE_RENDER_TARGET_TEXTURE
	half4 customRT								: TEXCOORD9;
#endif

	UNITY_VERTEX_OUTPUT_STEREO
};
