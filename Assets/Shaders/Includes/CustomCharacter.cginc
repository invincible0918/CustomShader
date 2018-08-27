// The main function about character shader

#define CUSTOM_BRDF_PBS characterBRDFPBS

#include "CustomStandardInput.cginc"

sampler2D   _ThicknessMap;
half _ThicknessScale;

half3 _BackgroundLightDirection;
half3 _BackgroundLightColor;
half _BackgroundLightScale;

half _Distortion;
half _LTPower;
half _LTScale;

half3 calculateTranslucency(half3 diffColor, half3 normal, half3 viewDir, half2 uv)
{
	half3 lightDir = _BackgroundLightDirection;
	half3 lightColor = _BackgroundLightColor * _BackgroundLightScale;

	half3 transLightDir = lightDir + normal * _Distortion;
	half fLTDot = pow(saturate(dot(viewDir, -transLightDir)), _LTPower);
	half thickness = saturate(1-tex2D(_ThicknessMap, uv).r) * _ThicknessScale;

	half3 color = (_LTScale + thickness) * diffColor * fLTDot * lightColor;

	return color;
}

void characterBRDFPBS(half2 uv, FragmentCommonData s, UnityLight light, UnityIndirect indirect, inout half4 c)
{
#ifdef _ENABLE_SSS
	half3 translucency = calculateTranslucency(s.diffColor, s.normalWorld, -s.eyeVec, uv);
	c.rgb += translucency;
#endif
}

#include "CustomStandardVSPS.cginc"