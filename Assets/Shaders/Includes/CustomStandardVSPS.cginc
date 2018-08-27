
#ifndef PROCESS_VERTEX
	float4 ProcessVertex (_VertexInput v)
	{
		return v.vertex;
	}
    #define PROCESS_VERTEX ProcessVertex
#endif

#ifdef _ENABLE_REALTIME_REFLECTION
#ifndef REALTIME_REFLECTION_COLOR
	half3 RealtimeReflectionColor (half4 refl, inout FragmentCommonData s)
	{
		return 0;
	}
    #define REALTIME_REFLECTION_COLOR RealtimeReflectionColor
#endif
#endif

#ifdef _ENABLE_WATER
#ifndef WATER_COLOR
	WaterColor (half2 uv, half4 refl, inout FragmentCommonData s, inout half3 color)
	{
	}
    #define WATER_COLOR WaterColor
#endif
#endif

#ifndef CUSTOM_FRAGMENT_SETUP
	void CustomFragmentSetup(half4 uv, float4 tangentToWorld[3], inout FragmentCommonData s)
	{
		;
	}
	#define CUSTOM_FRAGMENT_SETUP CustomFragmentSetup
#endif

#ifndef CUSTOM_BRDF_PBS
	void CustomBRDFPBS(half2 uv, FragmentCommonData s, UnityLight light, UnityIndirect indirect, inout half4 c)
	{
		;
	}
	#define CUSTOM_BRDF_PBS CustomBRDFPBS
#endif

#ifndef CUSTOM_FRAGMENT_SETUP_FWDADD
	void CustomFragmentSetupFwdAdd(half4 uv, float4 tangentToWorld[3], inout FragmentCommonData s)
	{
		;
	}
	#define CUSTOM_FRAGMENT_SETUP_FWDADD CustomFragmentSetupFwdAdd
#endif

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
// Inline interface
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
// Forward Vertex Segment
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
//  Base forward pass (directional light, emission, lightmaps, ...)
struct _VertexOutputForward
{
    UNITY_POSITION(pos);
    float4 tex                          : TEXCOORD0;
    half3 eyeVec                        : TEXCOORD1;
    float4 tangentToWorldAndPackedData[3]    : TEXCOORD2;    // [3x3:tangentToWorld | 1x3:viewDirForParallax or worldPos]
    half4 ambientOrLightmapUV           : TEXCOORD5;    // SH or Lightmap UV
    UNITY_SHADOW_COORDS(6)
    UNITY_FOG_COORDS(7)

#ifdef USE_VERTEX_COLOR
	half4 color                         : COLOR;
#endif

    // next ones would not fit into SM2.0 limits, but they are always for SM3.0+
    #if UNITY_REQUIRE_FRAG_WORLDPOS && !UNITY_PACK_WORLDPOS_WITH_TANGENT
        float3 posWorld                 : TEXCOORD8;
    #endif

#ifdef _ENABLE_REALTIME_REFLECTION
	half4 refl							: TEXCOORD9;
#elif _ENABLE_WATER
	half4 refl							: TEXCOORD9;
#endif

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

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

_VertexOutputForward _vertForward (_VertexInput v)
{
    UNITY_SETUP_INSTANCE_ID(v);
    _VertexOutputForward o;
    UNITY_INITIALIZE_OUTPUT(_VertexOutputForward, o);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

	v.vertex = PROCESS_VERTEX(v);
    float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
	
    #if UNITY_REQUIRE_FRAG_WORLDPOS
        #if UNITY_PACK_WORLDPOS_WITH_TANGENT
            o.tangentToWorldAndPackedData[0].w = posWorld.x;
            o.tangentToWorldAndPackedData[1].w = posWorld.y;
            o.tangentToWorldAndPackedData[2].w = posWorld.z;
        #else
            o.posWorld = posWorld.xyz;
        #endif
    #endif
    o.pos = UnityObjectToClipPos(v.vertex);

    o.tex = _TexCoords(v);
    o.eyeVec = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos);
    float3 normalWorld = UnityObjectToWorldNormal(v.normal);
    #ifdef _TANGENT_TO_WORLD
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

#ifdef USE_VERTEX_COLOR
	// Transfer vertex color
	//o.color = v.color;
#endif

#ifdef _ENABLE_REALTIME_REFLECTION
	o.refl = ComputeScreenPos (o.pos);
#elif _ENABLE_WATER
	o.refl = ComputeScreenPos (o.pos);
#endif

	//We need this for shadow receving
    UNITY_TRANSFER_SHADOW(o, v.uv1);

    o.ambientOrLightmapUV = _VertexGIForward(v, posWorld, normalWorld);

    UNITY_TRANSFER_FOG(o,o.pos);

    return o;
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
// Forward Pixel Segment
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
half4 _fragForward (_VertexOutputForward i)
{
    UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

    FRAGMENT_SETUP(s)
	CUSTOM_FRAGMENT_SETUP(i.tex, i.tangentToWorldAndPackedData, s);

    UNITY_SETUP_INSTANCE_ID(i);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    UnityLight mainLight = MainLight ();
    UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);

    half occlusion = Occlusion(i.tex.xy);
    UnityGI gi = FragmentGI (s, occlusion, i.ambientOrLightmapUV, atten, mainLight);

    half4 c = UNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect);
    CUSTOM_BRDF_PBS(i.tex.xy, s, gi.light, gi.indirect, c);

	c.rgb += Emission(i.tex.xy);

#ifdef _ENABLE_REALTIME_REFLECTION
	half3 realtimeReflectionColor = REALTIME_REFLECTION_COLOR(i.refl, s);
	c.rgb += realtimeReflectionColor;
#endif

#ifdef _ENABLE_WATER
	WATER_COLOR(i.tex.xy, i.refl, s, c.rgb);
#endif

    UNITY_APPLY_FOG(i.fogCoord, c.rgb);
    return OutputForward (c, s.alpha);
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
// Additive Forward Vextex Segment
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
//  Additive forward pass (one light per pass)
struct _VertexOutputForwardAdd
{
    UNITY_POSITION(pos);
    float4 tex                          : TEXCOORD0;
    half3 eyeVec                        : TEXCOORD1;
    float4 tangentToWorldAndLightDir[3]  : TEXCOORD2;    // [3x3:tangentToWorld | 1x3:lightDir]
    float3 posWorld                     : TEXCOORD5;
    UNITY_SHADOW_COORDS(6)
    UNITY_FOG_COORDS(7)
#ifdef USE_VERTEX_COLOR
	half4 color                         : COLOR;
#endif
    // next ones would not fit into SM2.0 limits, but they are always for SM3.0+
#if defined(_PARALLAXMAP)
    half3 viewDirForParallax            : TEXCOORD8;
#endif

    UNITY_VERTEX_OUTPUT_STEREO
};	

_VertexOutputForwardAdd _vertForwardAdd (_VertexInput v)
{
    UNITY_SETUP_INSTANCE_ID(v);
    _VertexOutputForwardAdd o;
    UNITY_INITIALIZE_OUTPUT(_VertexOutputForwardAdd, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    float4 posWorld = mul(unity_ObjectToWorld, v.vertex);
    o.pos = UnityObjectToClipPos(v.vertex);

    o.tex = _TexCoords(v);
    o.eyeVec = NormalizePerVertexNormal(posWorld.xyz - _WorldSpaceCameraPos);
    o.posWorld = posWorld.xyz;
    float3 normalWorld = UnityObjectToWorldNormal(v.normal);
    #ifdef _TANGENT_TO_WORLD
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

#ifdef USE_VERTEX_COLOR
	// Transfer vertex color
	o.color = v.color;
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
        o.viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
    #endif

    UNITY_TRANSFER_FOG(o,o.pos);
    return o;
}

////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
// Additive Forward Pixel Segment
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
half4 _fragForwardAdd (_VertexOutputForwardAdd i)
{
    UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

    FRAGMENT_SETUP_FWDADD(s)
	CUSTOM_FRAGMENT_SETUP_FWDADD(i.tex, i.tangentToWorldAndLightDir, s);

    UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld)
    UnityLight light = AdditiveLight (IN_LIGHTDIR_FWDADD(i), atten);
    UnityIndirect noIndirect = ZeroIndirect ();

    half4 c = UNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, light, noIndirect);
    CUSTOM_BRDF_PBS(i.tex.xy, s, light, noIndirect, c);

	UNITY_APPLY_FOG_COLOR(i.fogCoord, c.rgb, half4(0,0,0,0)); // fog towards black in additive pass

    return OutputForward (c, s.alpha);
}
