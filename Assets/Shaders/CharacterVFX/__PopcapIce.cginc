#include "__PopcapVFXVSPS.cginc"

#ifdef POPCAP_ICE
#define PROCESS_CLIP_POS _DilateVertex
#define PROCESS_FINAL_COLOR _IceColor

half4 _DilateVertex(_VertexInput v)
{
	half4 wPos = mul(UNITY_MATRIX_M, v.vertex);
	half4 wNormal = mul(UNITY_MATRIX_M, v.normal);

	half theta = dot(wNormal.xyz, half3(0, -1, 0));
	theta = max(0, theta);

	wPos.xyz += wNormal.xyz * 0.02f;
	wPos.y -= theta * 0.3f * frac(wPos.x * wPos.y * wPos.z);

	return mul(UNITY_MATRIX_VP, wPos);
}

void _IceColor(_VertexOutputVFX i, FragmentCommonData s, inout half4 color)
{
	half3 _IceColor0 = half3(0.39f, 0.57f, 0.83f);
	half3 _IceColor1 = half3(0.08f, 0.16f, 0.21f);

	half3 normalizedNormal = normalize(s.normalWorld);
	half3 normalizedViewDir = normalize(-s.eyeVec);

	// Calculate ice color
	half ndv = dot(normalizedNormal, normalizedViewDir);
	half v = saturate(pow(ndv, 10));
	half3 iceColor = lerp(_IceColor0, _IceColor1, v);

	// Calculate specualr color
	half3 specularColor = saturate(pow(1.0f - ndv, 10)) * 0.85f;
	
	color.rgb = iceColor + specularColor;
	color.a = 0.85f;
}

#endif

#include "__PopcapVFX.cginc"
	