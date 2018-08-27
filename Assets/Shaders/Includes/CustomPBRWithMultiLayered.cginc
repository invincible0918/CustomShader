#define FRAGMENT_SETUP_WITH_MULTI_LAYERED(x) FragmentCommonData x = \
    FragmentSetupWithMultiLayered(i.tex, i.eyeVec, IN_VIEWDIR4PARALLAX(i), i.tangentToWorldAndPackedData, IN_WORLDPOS(i));

UNITY_DECLARE_TEX2D(_MainTex1);
float4 _MainTex1_ST;

UNITY_DECLARE_TEX2D_NOSAMPLER(_MainTex2);

#ifdef _ENABLE_THIRD_LAYER_MAPS
	UNITY_DECLARE_TEX2D_NOSAMPLER(_MainTex3);

	#ifdef _ENABLE_FOURTH_LAYER_MAPS
		UNITY_DECLARE_TEX2D_NOSAMPLER(_MainTex4);
	#endif
#endif

#ifdef _SPECGLOSSMAP
	sampler2D _SpecGlossMap1;
	sampler2D _SpecGlossMap2;

	#ifdef _ENABLE_THIRD_LAYER_MAPS
		sampler2D _SpecGlossMap3;
		
		#ifdef _ENABLE_FOURTH_LAYER_MAPS
			sampler2D _SpecGlossMap4;
		#endif
	#endif
#endif

#ifdef _METALLICGLOSSMAP
	sampler2D _MetallicGlossMap1;
	sampler2D _MetallicGlossMap2;

	#ifdef _ENABLE_THIRD_LAYER_MAPS
		sampler2D _MetallicGlossMap3;
	
		#ifdef _ENABLE_FOURTH_LAYER_MAPS
			sampler2D _MetallicGlossMap4;
		#endif
	#endif
#endif

sampler2D _Mask;

sampler2D _MeshNormal;

sampler2D _BumpMap1;
sampler2D _BumpMap2;

#ifdef _ENABLE_THIRD_LAYER_MAPS
	sampler2D _BumpMap3;
	
	#ifdef _ENABLE_FOURTH_LAYER_MAPS
		sampler2D _BumpMap4;
	#endif
#endif

float _MaterialScale1;
float _MaterialScale2;

#ifdef _ENABLE_THIRD_LAYER_MAPS
	float _MaterialScale3;
	
	#ifdef _ENABLE_FOURTH_LAYER_MAPS
		float _MaterialScale4;
	#endif
#endif


half4 _CombineMainTex(half2 uv)
{
	half3 maskColor = tex2D(_Mask, uv).rgb;

	half4 c1 = UNITY_SAMPLE_TEX2D_SAMPLER(_MainTex1, _MainTex1, uv * _MaterialScale1);
	half4 c2 = UNITY_SAMPLE_TEX2D_SAMPLER(_MainTex2, _MainTex1, uv * _MaterialScale2);

	half4 c = lerp(c1, c2, maskColor.r);

#ifdef _ENABLE_THIRD_LAYER_MAPS
	half4 c3 = UNITY_SAMPLE_TEX2D_SAMPLER(_MainTex3, _MainTex1, uv * _MaterialScale3);
	c = lerp(c, c3, maskColor.g);

	#ifdef _ENABLE_FOURTH_LAYER_MAPS
		half4 c4 = UNITY_SAMPLE_TEX2D_SAMPLER(_MainTex4, _MainTex1, uv * _MaterialScale4);
		c = lerp(c, c4, maskColor.b);
	#endif
#endif

	return c;
}

half4 _CombineSpecGlossMap(half2 uv)
{
#ifdef _SPECGLOSSMAP
	half3 maskColor = tex2D(_Mask, uv).rgb;

	half4 c1 = tex2D(_SpecGlossMap1, uv * _MaterialScale1);
	half4 c2 = tex2D(_SpecGlossMap2, uv * _MaterialScale2);

	half4 c = lerp(c1, c2, maskColor.r);

#ifdef _ENABLE_THIRD_LAYER_MAPS
	half4 c3 = tex2D(_SpecGlossMap3, uv * _MaterialScale3);
	c = lerp(c, c3, maskColor.g);

	#ifdef _ENABLE_FOURTH_LAYER_MAPS
		half4 c4 = tex2D(_SpecGlossMap4, uv * _MaterialScale4);
		c = lerp(c, c4, maskColor.b);
	#endif
#endif

	return c;
#else
	return 1;
#endif
}


// work for Metallic / Smoothness (drieved from Metallic Alpha)
half4 _CombineMetallicGlossMap(half2 uv)
{
#ifdef _METALLICGLOSSMAP
	half3 maskColor = tex2D(_Mask, uv).rgb;

	half4 c1 = tex2D(_MetallicGlossMap1, uv * _MaterialScale1);
	half4 c2 = tex2D(_MetallicGlossMap2, uv * _MaterialScale2);
	
	half4 c = lerp(c1, c2, maskColor.r);

	#ifdef _ENABLE_THIRD_LAYER_MAPS
		half4 c3 = tex2D(_MetallicGlossMap3, uv * _MaterialScale3);
		c = lerp(c, c3, maskColor.g);
	
		#ifdef _ENABLE_FOURTH_LAYER_MAPS
			half4 c4 = tex2D(_MetallicGlossMap4, uv * _MaterialScale4);
			c = lerp(c, c4, maskColor.b);
		#endif
	#endif

	return c;
#else
	return 1;
#endif
}

float3 _CombineNormal (float2 uv)
{
	float3 n1 = UnpackNormal(tex2D(_BumpMap1, uv * _MaterialScale1));
	float3 n2 = UnpackNormal(tex2D(_BumpMap2, uv * _MaterialScale2));

	half3 maskColor = tex2D(_Mask, uv).rgb;

	float3 n = lerp (n1, n2, maskColor.r);

	#ifdef _ENABLE_THIRD_LAYER_MAPS
		float3 n3 = UnpackNormal(tex2D(_BumpMap3, uv * _MaterialScale3));
		n = lerp (n, n3, maskColor.g);

		#ifdef _ENABLE_FOURTH_LAYER_MAPS
			float3 n4 = UnpackNormal(tex2D(_BumpMap4, uv * _MaterialScale4));
			n = lerp (n, n4, maskColor.b);
		#endif
	#endif

	return n;
}


#ifdef _NORMALMAP
half3 _NormalInTangentSpace(float4 texcoords)
{
    half3 meshNormal = UnpackNormal(tex2D(_MeshNormal, texcoords.xy));
	
	float3 normal = meshNormal;
	float3 combineNormals = _CombineNormal (texcoords.xy);

	//UDN combine method
	normal.xyz = normalize (float3 (combineNormals.xy + meshNormal.xy, meshNormal.z));

#if _DETAIL && defined(UNITY_ENABLE_DETAIL_NORMALMAP)
    half mask = DetailMask(texcoords.xy);
    half3 detailNormalTangent = UnpackScaleNormal(tex2D (_DetailNormalMap, texcoords.zw), _DetailNormalMapScale);
    #if _DETAIL_LERP
        normal = lerp(
            normal,
            detailNormalTangent,
            mask);
    #else
        normal = lerp(
            normal,
            BlendNormals(normal, detailNormalTangent),
            mask);
    #endif
#endif

    return normal;
}
#endif

half3 _PerPixelWorldNormal(float4 i_tex, half4 tangentToWorld[3])
{
#ifdef _NORMALMAP
    half3 tangent = tangentToWorld[0].xyz;
    half3 binormal = tangentToWorld[1].xyz;
    half3 normal = tangentToWorld[2].xyz;

    #if UNITY_TANGENT_ORTHONORMALIZE
        normal = NormalizePerPixelNormal(normal);

        // ortho-normalize Tangent
        tangent = normalize (tangent - normal * dot(tangent, normal));

        // recalculate Binormal
        half3 newB = cross(normal, tangent);
        binormal = newB * sign (dot (newB, binormal));
    #endif

    half3 normalTangent = _NormalInTangentSpace(i_tex);
    half3 normalWorld = NormalizePerPixelNormal(tangent * normalTangent.x + binormal * normalTangent.y + normal * normalTangent.z); // @TODO: see if we can squeeze this normalize on SM2.0 as well
#else
    half3 normalWorld = normalize(tangentToWorld[2].xyz);
#endif
    return normalWorld;
}


half3 _Albedo(float4 texcoords)
{
    half3 albedo = _CombineMainTex(texcoords.xy).rgb;
#if _DETAIL
    #if (SHADER_TARGET < 30)
        // SM20: instruction count limitation
        // SM20: no detail mask
        half mask = 1;
    #else
        half mask = DetailMask(texcoords.xy);
    #endif
    half3 detailAlbedo = tex2D (_DetailAlbedoMap, texcoords.zw).rgb;
    #if _DETAIL_MULX2
        albedo *= LerpWhiteTo (detailAlbedo * unity_ColorSpaceDouble.rgb, mask);
    #elif _DETAIL_MUL
        albedo *= LerpWhiteTo (detailAlbedo, mask);
    #elif _DETAIL_ADD
        albedo += detailAlbedo * mask;
    #elif _DETAIL_LERP
        albedo = lerp (albedo, detailAlbedo, mask);
    #endif
#endif
    return albedo;
}


half4 _SpecularGloss(float2 uv)
{
    half4 sg;
#ifdef _SPECGLOSSMAP
    #if defined(_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A)
		sg.rgb = _CombineSpecGlossMap(uv).rgb;
        sg.a = _CombineMainTex(uv).a;
    #else
        sg = _CombineSpecGlossMap(uv);
    #endif
    sg.a *= _GlossMapScale;
#else
    sg.rgb = _SpecColor.rgb;
    #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        sg.a = _CombineMainTex(uv).a * _GlossMapScale;
    #else
        sg.a = _Glossiness;
    #endif
#endif
    return sg;
}

half2 _MetallicGloss(float2 uv)
{
    half2 mg;

#ifdef _METALLICGLOSSMAP
    #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        mg.r = _CombineMetallicGlossMap(uv).r;
        mg.g = _CombineMainTex(uv).a;
    #else
        mg = _CombineMetallicGlossMap(uv).ra;
    #endif
    mg.g *= _GlossMapScale;
#else
    mg.r = _Metallic;
    #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
        mg.g = _CombineMainTex(uv).a * _GlossMapScale;
    #else
        mg.g = _Glossiness;
    #endif
#endif

    return mg;
}

half2 _MetallicRough(float2 uv)
{
    half2 mg;
#ifdef _METALLICGLOSSMAP
    mg.r = _CombineMetallicGlossMap(uv).r;
#else
    mg.r = _Metallic;
#endif

#ifdef _SPECGLOSSMAP
    mg.g = 1.0f - _CombineSpecGlossMap(uv).r;
#else
    mg.g = 1.0f - _Glossiness;
#endif
    return mg;
}

#ifndef Custom_SETUP_BRDF_INPUT
    #define Custom_SETUP_BRDF_INPUT SpecularSetupWithMultiLayered
#endif

inline FragmentCommonData SpecularSetupWithMultiLayered (float4 i_tex)
{
    half4 specGloss = _SpecularGloss(i_tex.xy);
    half3 specColor = specGloss.rgb;
    half smoothness = specGloss.a;

    half oneMinusReflectivity;
    half3 diffColor = EnergyConservationBetweenDiffuseAndSpecular (_Albedo(i_tex), specColor, /*out*/ oneMinusReflectivity);

    FragmentCommonData o = (FragmentCommonData)0;
    o.diffColor = diffColor;
    o.specColor = specColor;
    o.oneMinusReflectivity = oneMinusReflectivity;
    o.smoothness = smoothness;
    return o;
}

// work for roughness shader
inline FragmentCommonData RoughnessSetupWithMultiLayered (float4 i_tex)
{
    half2 metallicGloss = _MetallicRough(i_tex.xy);

    half metallic = metallicGloss.x;
    half smoothness = metallicGloss.y; // this is 1 minus the square root of real roughness m.

    half oneMinusReflectivity;
    half3 specColor;
    half3 diffColor = DiffuseAndSpecularFromMetallic(_Albedo(i_tex), metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

    FragmentCommonData o = (FragmentCommonData)0;
    o.diffColor = diffColor;
    o.specColor = specColor;
    o.oneMinusReflectivity = oneMinusReflectivity;
    o.smoothness = smoothness;
    return o;
}

// work for standard shader
inline FragmentCommonData MetallicSetupWithMultiLayered (float4 i_tex)
{
    half2 metallicGloss = _MetallicGloss(i_tex.xy);
    half metallic = metallicGloss.x;
    half smoothness = metallicGloss.y; // this is 1 minus the square root of real roughness m.

    half oneMinusReflectivity;
    half3 specColor;
    half3 diffColor = DiffuseAndSpecularFromMetallic (_Albedo(i_tex), metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);

    FragmentCommonData o = (FragmentCommonData)0;
    o.diffColor = diffColor;
    o.specColor = specColor;
    o.oneMinusReflectivity = oneMinusReflectivity;
    o.smoothness = smoothness;
    return o;
}

// parallax transformed texcoord is used to sample occlusion
inline FragmentCommonData FragmentSetupWithMultiLayered (inout float4 i_tex, half3 i_eyeVec, half3 i_viewDirForParallax, half4 tangentToWorld[3], float3 i_posWorld)
{
    i_tex = Parallax(i_tex, i_viewDirForParallax);

    half alpha = Alpha(i_tex.xy);
    #if defined(_ALPHATEST_ON)
        clip (alpha - _Cutoff);
    #endif

    FragmentCommonData o = Custom_SETUP_BRDF_INPUT (i_tex);
    o.normalWorld = _PerPixelWorldNormal(i_tex, tangentToWorld);
    o.eyeVec = NormalizePerPixelNormal(i_eyeVec);
    o.posWorld = i_posWorld;

    // NOTE: shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
    o.diffColor = PreMultiplyAlpha (o.diffColor, alpha, o.oneMinusReflectivity, /*out*/ o.alpha);
    return o;
}

//  Base forward pass (directional light, emission, lightmaps, ...)
struct VertexOutputForwardBaseWithMultiLayered
{
    UNITY_POSITION(pos);
    float4 tex                          : TEXCOORD0;
    half3 eyeVec                        : TEXCOORD1;
    half4 tangentToWorldAndPackedData[3]    : TEXCOORD2;    // [3x3:tangentToWorld | 1x3:viewDirForParallax or worldPos]
    half4 ambientOrLightmapUV           : TEXCOORD5;    // SH or Lightmap UV
    UNITY_SHADOW_COORDS(6)
    UNITY_FOG_COORDS(7)

    // next ones would not fit into SM2.0 limits, but they are always for SM3.0+
    #if UNITY_REQUIRE_FRAG_WORLDPOS && !UNITY_PACK_WORLDPOS_WITH_TANGENT
        float3 posWorld                 : TEXCOORD8;
    #endif
	//float4 tex2                          : TEXCOORD9;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};


float4 _TexCoords(VertexInput v)
{
    float4 texcoord;
    texcoord.xy = TRANSFORM_TEX(v.uv0, _MainTex1); // Always source from uv0
    texcoord.zw = TRANSFORM_TEX(((_UVSec == 0) ? v.uv0 : v.uv1), _DetailAlbedoMap);
    return texcoord;
}

VertexOutputForwardBaseWithMultiLayered vertForwardBaseWithMultiLayered (VertexInput v)
{
    UNITY_SETUP_INSTANCE_ID(v);
    VertexOutputForwardBaseWithMultiLayered o;
    UNITY_INITIALIZE_OUTPUT(VertexOutputForwardBaseWithMultiLayered, o);
    UNITY_TRANSFER_INSTANCE_ID(v, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

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

    //We need this for shadow receving
    UNITY_TRANSFER_SHADOW(o, v.uv1);

    o.ambientOrLightmapUV = VertexGIForward(v, posWorld, normalWorld);

    #ifdef _PARALLAXMAP
        TANGENT_SPACE_ROTATION;
        half3 viewDirForParallax = mul (rotation, ObjSpaceViewDir(v.vertex));
        o.tangentToWorldAndPackedData[0].w = viewDirForParallax.x;
        o.tangentToWorldAndPackedData[1].w = viewDirForParallax.y;
        o.tangentToWorldAndPackedData[2].w = viewDirForParallax.z;
    #endif

    UNITY_TRANSFER_FOG(o,o.pos);
    return o;
}

half4 fragForwardBaseInternalWithMultiLayered (VertexOutputForwardBaseWithMultiLayered i)
{
    UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

    FRAGMENT_SETUP_WITH_MULTI_LAYERED(s)	
    //FRAGMENT_SETUP(s)	

    UNITY_SETUP_INSTANCE_ID(i);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

    UnityLight mainLight = MainLight ();
    UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);

    half occlusion = Occlusion(i.tex.xy);
    UnityGI gi = FragmentGI (s, occlusion, i.ambientOrLightmapUV, atten, mainLight);

    half4 c = UNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect);
    c.rgb += Emission(i.tex.xy);

    UNITY_APPLY_FOG(i.fogCoord, c.rgb);
    return OutputForward (c, s.alpha);
}

half4 fragForwardBaseWithMultiLayered (VertexOutputForwardBaseWithMultiLayered i) : SV_Target     // backward compatibility (this used to be the fragment entry function)
{
    return fragForwardBaseInternalWithMultiLayered(i);
}	
