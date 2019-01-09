#include "UnityCG.cginc"

#ifndef FRAG_SHADER_LOD_0
	void _FragShaderLod0(_VertexOutputForward i, inout FragmentCommonData s, inout half4 color)
	{
	}
#define FRAG_SHADER_LOD_0 _FragShaderLod0
#endif

#ifndef FRAG_SHADER_LOD_1
	void _FragShaderLod1(_VertexOutputForward i, inout FragmentCommonData s, inout half4 color)
	{
	}
#define FRAG_SHADER_LOD_1 _FragShaderLod1
#endif

#ifndef FRAG_ADD_SHADER_LOD_0
	void _FragAddShaderLod0(_VertexOutputForwardAdd i, inout FragmentCommonData s, inout half4 color)
	{
	}
#define FRAG_ADD_SHADER_LOD_0 _FragAddShaderLod0
#endif

#ifndef FRAG_ADD_SHADER_LOD_1
	void _FragAddShaderLod1(_VertexOutputForwardAdd i, inout FragmentCommonData s, inout half4 color)
	{
	}
#define FRAG_ADD_SHADER_LOD_1 _FragAddShaderLod1
#endif

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
// Inline interface
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////

float4 _TexCoords(_VertexInput v)
{
	float4 texcoord;
    texcoord.xy = TRANSFORM_TEX(v.uv0, _MainTex); // Always source from uv0
    texcoord.zw = TRANSFORM_TEX(((_UVSec == 0) ? v.uv0 : v.uv1), _DetailAlbedoMap);
    return texcoord;
}

inline half4 _VertexGIForward(_VertexInput v, float3 posWorld, half3 normalWorld)
{
    half4 ambientOrLightmapUV = 0;
    // Static lightmaps
    #ifdef LIGHTMAP_ON
        ambientOrLightmapUV.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
        ambientOrLightmapUV.zw = 0;
    // Sample light probe for Dynamic objects only (no static or dynamic lightmaps)
    #elif UNITY_SHOULD_SAMPLE_SH
        #ifdef VERTEXLIGHT_ON
            // Approximated illumination from non-important point lights
            ambientOrLightmapUV.rgb = Shade4PointLights (
                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                unity_4LightAtten0, posWorld, normalWorld);
        #endif

        ambientOrLightmapUV.rgb = ShadeSHPerVertex (normalWorld, ambientOrLightmapUV.rgb);
    #endif

    #ifdef DYNAMICLIGHTMAP_ON
        ambientOrLightmapUV.zw = v.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
    #endif

    return ambientOrLightmapUV;
}

_VertexOutputForward _vertForward(_VertexInput v)
{
	UNITY_SETUP_INSTANCE_ID(v);
	_VertexOutputForward o;
	UNITY_INITIALIZE_OUTPUT(_VertexOutputForward, o);
	UNITY_TRANSFER_INSTANCE_ID(v, o);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

	float4 worldPos = 0;
	float4 clipPos = 0;

#ifdef CALCULATE_POSITION
	CALCULATE_POSITION(v, clipPos, worldPos);
#else
	clipPos = UnityObjectToClipPos(v.vertex);
	worldPos = mul(unity_ObjectToWorld, v.vertex);
#endif
	o.pos = clipPos;

#if UNITY_REQUIRE_FRAG_WORLDPOS
#if UNITY_PACK_WORLDPOS_WITH_TANGENT
	o.tangentToWorldAndPackedData[0].w = worldPos.x;
	o.tangentToWorldAndPackedData[1].w = worldPos.y;
	o.tangentToWorldAndPackedData[2].w = worldPos.z;
#else
	o.posWorld = worldPos.xyz;
#endif
#endif

	o.tex = _TexCoords(v);
	o.eyeVec = NormalizePerVertexNormal(worldPos.xyz - _WorldSpaceCameraPos);
	float3 normalWorld = UnityObjectToWorldNormal(v.normal);
#if defined(_TANGENT_TO_WORLD) || defined(_ENABLE_TANGENT_TO_WORLD)
	float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);

	float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);
	o.tangentToWorldAndPackedData[0].xyz = tangentToWorld[0];
	o.tangentToWorldAndPackedData[1].xyz = tangentToWorld[1];
	o.tangentToWorldAndPackedData[2].xyz = tangentToWorld[2];
#else
	o.tangentToWorldAndPackedData[0].xyz = 0;
	o.tangentToWorldAndPackedData[1].xyz = 0;
	o.tangentToWorldAndPackedData[2].xyz = normalWorld;
#endif

#ifdef _ENABLE_RENDER_TARGET_TEXTURE
	o.customRT = RENDER_TARGET_TEXTURE(o.pos);
#endif

	//We need this for shadow receving
	UNITY_TRANSFER_SHADOW(o, v.uv1);

	o.ambientOrLightmapUV = _VertexGIForward(v, worldPos, normalWorld);

	UNITY_TRANSFER_FOG(o, o.pos);

	return o;
}

// parallax transformed texcoord is used to sample occlusion
inline FragmentCommonData _FragmentSetup(inout float4 i_tex, float3 i_eyeVec, half3 i_viewDirForParallax, float4 tangentToWorld[3], float3 i_posWorld)
{
	i_tex = Parallax(i_tex, i_viewDirForParallax);

	half alpha = Alpha(i_tex.xy);
#if defined(_ALPHATEST_ON)
	clip(alpha - _Cutoff);
#endif

	FragmentCommonData o = UNITY_SETUP_BRDF_INPUT(i_tex);
	o.normalWorld = PerPixelWorldNormal(i_tex, tangentToWorld);
	o.eyeVec = NormalizePerPixelNormal(i_eyeVec);
	o.posWorld = i_posWorld;

	// NOTE: shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
	o.diffColor = PreMultiplyAlpha(o.diffColor, alpha, o.oneMinusReflectivity, /*out*/ o.alpha);
	return o;
}

half4 _fragForward(_VertexOutputForward i)
{
	UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

	FRAGMENT_SETUP(s);
	//FragmentCommonData s = _FragmentSetup(i.tex, i.eyeVec, IN_VIEWDIR4PARALLAX(i), i.tangentToWorldAndPackedData, IN_WORLDPOS(i));

	UNITY_SETUP_INSTANCE_ID(i);
	UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

	half4 color = 0;

#ifdef _SHADER_TIER_0
	FRAG_SHADER_LOD_0(i, s, color);
#else
	#ifdef _SHADER_TIER_1
		FRAG_SHADER_LOD_1(i, s, color);
	#else
		FRAG_SHADER_LOD_0(i, s, color);
	#endif
#endif
	return OutputForward(color, s.alpha);
}

_VertexOutputForwardAdd _vertForwardAdd(_VertexInput v)
{
	UNITY_SETUP_INSTANCE_ID(v);
	_VertexOutputForwardAdd o;
	UNITY_INITIALIZE_OUTPUT(_VertexOutputForwardAdd, o);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

	float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
#ifdef CALCULATE_CLIP_POSITION
	o.pos = CALCULATE_CLIP_POSITION(v);
#else
	o.pos = UnityObjectToClipPos(v.vertex);
#endif

	o.tex = _TexCoords(v);
	o.eyeVec = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos);
	o.posWorld = posWorld.xyz;
	float3 normalWorld = UnityObjectToWorldNormal(v.normal);
#if defined(_TANGENT_TO_WORLD) || defined(_ENABLE_TANGENT_TO_WORLD)
	float4 tangentWorld = float4(UnityObjectToWorldDir(v.tangent.xyz), v.tangent.w);

	float3x3 tangentToWorld = CreateTangentToWorldPerVertex(normalWorld, tangentWorld.xyz, tangentWorld.w);
	o.tangentToWorldAndLightDir[0].xyz = tangentToWorld[0];
	o.tangentToWorldAndLightDir[1].xyz = tangentToWorld[1];
	o.tangentToWorldAndLightDir[2].xyz = tangentToWorld[2];
#else
	o.tangentToWorldAndLightDir[0].xyz = 0;
	o.tangentToWorldAndLightDir[1].xyz = 0;
	o.tangentToWorldAndLightDir[2].xyz = normalWorld;
#endif

	//We need this for shadow receiving
	UNITY_TRANSFER_SHADOW(o, v.uv1);

	float3 lightDir = _WorldSpaceLightPos0.xyz - posWorld.xyz * _WorldSpaceLightPos0.w;
#ifndef USING_DIRECTIONAL_LIGHT
	lightDir = NormalizePerVertexNormal(lightDir);
#endif
	o.tangentToWorldAndLightDir[0].w = lightDir.x;
	o.tangentToWorldAndLightDir[1].w = lightDir.y;
	o.tangentToWorldAndLightDir[2].w = lightDir.z;

#ifdef _PARALLAXMAP
	TANGENT_SPACE_ROTATION;
	o.viewDirForParallax = mul(rotation, ObjSpaceViewDir(v.vertex));
#endif

#ifdef _ENABLE_RENDER_TARGET_TEXTURE
	o.customRT = RENDER_TARGET_TEXTURE(o.pos);
#endif

	UNITY_TRANSFER_FOG(o, o.pos);
	return o;
}
	
// Additive Forward Pixel Segment
half4 _fragForwardAdd(_VertexOutputForwardAdd i)
{
	UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

	FRAGMENT_SETUP_FWDADD(s);

	half4 color = 0;

#ifdef _SHADER_TIER_0
	FRAG_ADD_SHADER_LOD_0(i, s, color);
#else
	#ifdef _SHADER_TIER_1
		FRAG_ADD_SHADER_LOD_1(i, s, color);
	#else
		FRAG_ADD_SHADER_LOD_0(i, s, color);
	#endif
#endif

	return OutputForward(color, s.alpha);
}