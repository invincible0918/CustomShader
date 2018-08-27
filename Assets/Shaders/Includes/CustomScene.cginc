// The main function about scene shader

#define CUSTOM_FRAGMENT_SETUP SceneFragmentSetup
#define CUSTOM_FRAGMENT_SETUP_FWDADD SceneFragmentSetup


#include "CustomStandardInput.cginc"

#ifdef _ENABLE_CHANGED_COLOR
	half4 _ChangedColor;
	sampler2D _ChangedColorMask; 
#endif

void SceneFragmentSetup(half2 uv, float4 tangentToWorld[3], inout FragmentCommonData s)
{
#ifdef _ENABLE_CHANGED_COLOR
	half4 mask = tex2D(_ChangedColorMask,uv);
	s.diffColor = lerp(s.diffColor, s.diffColor * _ChangedColor.rgb, mask.r * _ChangedColor.a);
#endif
}

#ifdef _ENABLE_REALTIME_REFLECTION
	sampler2D _ReflectionTex;	
	fixed _ReflectionScale;

	#define REALTIME_REFLECTION_COLOR CalculateRealtimeReflection

	half3 CalculateRealtimeReflection (half4 refl, FragmentCommonData s)
	{
		// blur reflection
		half3 reflectionTex = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(refl + half4(s.normalWorld.xz * 0.1f, 0, 0))).rgb;
		half3 reflectionColor = reflectionTex * (1.0f - s.oneMinusReflectivity) * s.smoothness * _ReflectionScale;

		return reflectionColor; 
	}
#endif

#ifdef _ENABLE_WATER
	// water surface should re-calculate normal
	#define CUSTOM_FRAGMENT_SETUP WaterFragmentSetup
	#define CUSTOM_FRAGMENT_SETUP_FWDADD WaterFragmentSetup
	#define WATER_COLOR CalculateWaterColor

	
#ifdef _ENABLE_WATER_REFLECTION_AND_REFRACTION
	sampler2D _ReflectionTex;	
	sampler2D _RefractionTex;
#endif

	sampler2D _CausticTex;

	fixed _CausticScale;
	fixed _WaterNormalScaleU;
	fixed _WaterNormalScaleV;
	fixed _WaterNormalIntensity;

	sampler2D _FoamTex;
	sampler2D _NoiseTex;

	half3 _NormalInTangentSpace(float4 texcoords)
	{
		half2 waterNormalScale = half2(_WaterNormalScaleU, _WaterNormalScaleV);
		// calculate normal uv animation
		half2 uv0 = (texcoords.xy * waterNormalScale + half2(_Time.x, _Time.x));
		half3 wave0Normal = UnpackScaleNormal(tex2D (_BumpMap, uv0), _BumpScale * _WaterNormalIntensity);

		half2 uv1 = (texcoords.xy * waterNormalScale - half2(_Time.x, _Time.x));
		half3 wave1Normal = UnpackScaleNormal(tex2D (_BumpMap, uv1), _BumpScale * _WaterNormalIntensity);

		half3 normalTangent = normalize((wave0Normal + wave1Normal) * 0.5f);

	#if _DETAIL && defined(UNITY_ENABLE_DETAIL_NORMALMAP)
		half mask = DetailMask(texcoords.xy);
		half3 detailNormalTangent = UnpackScaleNormal(tex2D (_DetailNormalMap, texcoords.zw), _DetailNormalMapScale);
		#if _DETAIL_LERP
			normalTangent = lerp(
				normalTangent,
				detailNormalTangent,
				mask);
		#else
			normalTangent = lerp(
				normalTangent,
				BlendNormals(normalTangent, detailNormalTangent),
				mask);
		#endif
	#endif

		return normalTangent;
	}

	half3 _PerPixelWorldNormal(half4 i_tex, float4 tangentToWorld[3])
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
		float3 normalWorld = NormalizePerPixelNormal(tangent * normalTangent.x + binormal * normalTangent.y + normal * normalTangent.z); // @TODO: see if we can squeeze this normalize on SM2.0 as well
	#else
		float3 normalWorld = normalize(tangentToWorld[2].xyz);
	#endif
		return normalWorld;
	}

	void WaterFragmentSetup(half4 uv, float4 tangentToWorld[3], inout FragmentCommonData s)
	{
		s.normalWorld = _PerPixelWorldNormal(uv, tangentToWorld);
	}

	void CalculateWaterColor (half2 uv, half4 refl, inout FragmentCommonData s, inout half3 color)
	{
		// sample caustic
		half3 causticColor = tex2D(_CausticTex, uv * _CausticScale).rgb;

		// calculate foam
		half3 noise = tex2D(_NoiseTex, uv - _Time.x).rgb;

		half t01 = (sin(_Time.y) + 1.0f) * 0.5f;

		half scale01 = lerp(1.0f - t01 * 0.05f, 1.0f + t01 * 0.05f, saturate(noise.r));
		half scale02 = lerp(1.0f - t01 * 0.05f, 1.0f + t01 * 0.05f, saturate(noise.g));

		half scaleU = lerp(1.0f - t01 * 0.05f, 1.0f + t01 * 0.05f, t01) * scale01;
		half scaleV = lerp(1.0f - t01 * 0.05f, 1.0f + t01 * 0.05f, t01) * scale02;
		half2 foamUV = uv * half2(scaleU, scaleV);
		half4 foamColor = tex2D(_FoamTex, foamUV);
		color += foamColor.rgb * foamColor.a;

#ifdef _ENABLE_WATER_REFLECTION_AND_REFRACTION
		// sample reflection and refraction color
		half4 normal = half4(s.normalWorld, 0.0f) * 0.1f;

		half3 reflectionColor = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(refl + normal)).rgb;
		half3 refractionColor = tex2Dproj(_RefractionTex, UNITY_PROJ_COORD(refl + normal)).rgb;
		color *= reflectionColor * s.oneMinusReflectivity + refractionColor;
#endif
	}
#endif

#include "CustomStandardVSPS.cginc"
