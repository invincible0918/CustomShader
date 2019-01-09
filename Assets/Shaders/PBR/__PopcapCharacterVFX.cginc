#include "__PopcapCommonFunction.cginc"

#define FRAG_SHADER_LOD_0 _FragLod0

#ifdef _ENABLE_ICE
#define CALCULATE_POSITION _DilateVertex

sampler2D _IceNormalMap;

void _DilateVertex(_VertexInput v, inout half4 clipPos, inout half4 worldPos)
{
	half4 wPos = mul(UNITY_MATRIX_M, v.vertex);
	half4 wNormal = mul(UNITY_MATRIX_M, v.normal);

	half theta = dot(wNormal.xyz, half3(0, -1, 0));
	theta = max(0, theta);

	wPos.xyz += wNormal.xyz * 0.02f;
	wPos.y -= theta * 0.3f * frac(1000 * v.uv0.x);
	
	clipPos = mul(UNITY_MATRIX_VP, wPos);
	worldPos = wPos;
}

void _IceColor(_VertexOutputForward i, FragmentCommonData s, inout half4 color)
{
	half3 _IceColor0 = half3(0.39f, 0.57f, 0.83f);
	half3 _IceColor1 = half3(0.08f, 0.16f, 0.21f);

	half3 iceNormal = UnpackNormal(tex2D(_IceNormalMap, i.tex.xy)).rgb;
	half3 glitterNormal = UnpackNormal(tex2D(_IceNormalMap, 10.0 * i.tex.xy)).rgb;

	half3 tangent = i.tangentToWorldAndPackedData[0].xyz;
	half3 binormal = i.tangentToWorldAndPackedData[1].xyz;
	half3 normal = i.tangentToWorldAndPackedData[2].xyz;
	
	half3 iceWorldNormal = NormalizePerPixelNormal(tangent * iceNormal.x + binormal * iceNormal.y + normal * iceNormal.z); // @TODO: see if we can squeeze this normalize on SM2.0 as well
	half3 glitterWorldNormal = NormalizePerPixelNormal(tangent * glitterNormal.x + binormal * glitterNormal.y + normal * glitterNormal.z); // @TODO: see if we can squeeze this normalize on SM2.0 as well

	half3 normalizedNormal = normalize(s.normalWorld + 15.0 * iceWorldNormal);
	half3 normalizedViewDir = normalize(-s.eyeVec);

	// Calculate ice color
	UnityLight mainLight = MainLight();

	half ndv = dot(normalizedNormal, normalizedViewDir);
	half ndl = dot(normalizedNormal, -mainLight.dir);
	half v = pow(saturate(ndv), 2);
	half3 iceColor = saturate(ndl) * 0.75 + lerp(_IceColor0, _IceColor1, v);

	// Calculate specualr color
	half3 specularColor = pow(saturate(1 - ndv), 2.5) * 0.5f;

	// Glitter specular
	half ndv2 = dot(glitterWorldNormal, normalizedViewDir);
	half glitterSpecualr = pow(saturate(ndv2), 100);

	color.rgb = iceColor + specularColor + glitterSpecualr;
	color.a = 0.85;
}
#endif

void _FragLod0(_VertexOutputForward i, FragmentCommonData s, inout half4 color)
{
#ifdef _ENABLE_ICE
	_IceColor(i, s, color);
#endif

#ifdef _ENABLE_SEMI_TRANSPARENCY
	_CalculateCommonPBS(i, s, color);
	color.a = 0.75f;
#endif
}


#include "__PopcapVFXVSPS.cginc"