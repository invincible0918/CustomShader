// The main function about shadow pass
#include "UnityCG.cginc"
#include "UnityShaderVariables.cginc"
#include "UnityStandardConfig.cginc"
#include "UnityStandardUtils.cginc"
#include "__PopcapCharacter.cginc"

struct _VertexOutputShadowCaster
{
	V2F_SHADOW_CASTER_NOPOS

#ifdef _ENABLE_SHADOW_WORLD_POSITION
	half4 worldPos	: TEXCOORD0;
#endif

#if defined(UNITY_STANDARD_USE_SHADOW_UVS)
		float2 tex : TEXCOORD1;

#if defined(_PARALLAXMAP)
	half4 tangentToWorldAndParallax[3]: TEXCOORD2;  // [3x3:tangentToWorld | 1x3:viewDirForParallax]
#endif
#endif

};

void vertShadow(_VertexInput v, out float4 opos : SV_POSITION, out _VertexOutputShadowCaster o)
{
	UNITY_SETUP_INSTANCE_ID(v);
	TRANSFER_SHADOW_CASTER_NOPOS(o, opos)

#ifdef _ENABLE_SHADOW_WORLD_POSITION
	o.worldPos = mul(unity_ObjectToWorld, v.vertex);
#endif

#if defined(UNITY_STANDARD_USE_SHADOW_UVS)
	o.tex = TRANSFORM_TEX(v.uv0, _MainTex);

#ifdef _PARALLAXMAP
	TANGENT_SPACE_ROTATION;
	half3 viewDirForParallax = mul(rotation, ObjSpaceViewDir(v.vertex));
	o.tangentToWorldAndParallax[0].w = viewDirForParallax.x;
	o.tangentToWorldAndParallax[1].w = viewDirForParallax.y;
	o.tangentToWorldAndParallax[2].w = viewDirForParallax.z;
#endif
#endif
}

half4 fragShadow(UNITY_POSITION(vpos), _VertexOutputShadowCaster i) : SV_Target
{
#ifdef _ENABLE_MOSAIC
	//_CalculateAdvancedDissolveShadowColor(i.worldPos);
#endif

#ifdef _ENABLE_ADVANCED_DISSOLVE	
	_CalculateAdvancedDissolveShadowColor(i.worldPos);
#endif

	#if defined(UNITY_STANDARD_USE_SHADOW_UVS)
		#if defined(_PARALLAXMAP) && (SHADER_TARGET >= 30)
	//On d3d9 parallax can also be disabled on the fwd pass when too many    sampler are used. See EXCEEDS_D3D9_SM3_MAX_SAMPLER_COUNT. Ideally we should account for that here as well.
	half3 viewDirForParallax = normalize(half3(i.tangentToWorldAndParallax[0].w,i.tangentToWorldAndParallax[1].w,i.tangentToWorldAndParallax[2].w));
	fixed h = tex2D(_ParallaxMap, i.tex.xy).g;
	half2 offset = ParallaxOffset1Step(h, _Parallax, viewDirForParallax);
	i.tex.xy += offset;
#endif

half alpha = tex2D(_MainTex, i.tex).a * _Color.a;

#if defined(_ALPHATEST_ON)
	clip(alpha - _Cutoff);
#endif
#if defined(_ALPHABLEND_ON) || defined(_ALPHAPREMULTIPLY_ON)
	#if defined(_ALPHAPREMULTIPLY_ON)
		half outModifiedAlpha;
		PreMultiplyAlpha(half3(0, 0, 0), alpha, SHADOW_ONEMINUSREFLECTIVITY(i.tex), outModifiedAlpha);
		alpha = outModifiedAlpha;
	#endif
	#if defined(UNITY_STANDARD_USE_DITHER_MASK)
		// Use dither mask for alpha blended shadows, based on pixel position xy
		// and alpha level. Our dither texture is 4x4x16.
		#ifdef LOD_FADE_CROSSFADE
			#define _LOD_FADE_ON_ALPHA
			alpha *= unity_LODFade.y;
		#endif
		half alphaRef = tex3D(_DitherMaskLOD, float3(vpos.xy*0.25,alpha*0.9375)).a;
		clip(alphaRef - 0.01);
	#else
		clip(alpha - _Cutoff);
	#endif
#endif
#endif // #if defined(UNITY_STANDARD_USE_SHADOW_UVS)

#ifdef LOD_FADE_CROSSFADE
	#ifdef _LOD_FADE_ON_ALPHA
		#undef _LOD_FADE_ON_ALPHA
	#else
		UnityApplyDitherCrossFade(vpos.xy);
	#endif
#endif

SHADOW_CASTER_FRAGMENT(i)
}
