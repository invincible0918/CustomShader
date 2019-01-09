#include "__PopcapCommonFunction.cginc"

// pond water start
#ifdef _ENABLE_POND_WATER
#define RENDER_TARGET_TEXTURE _ComputeScreenPos
#define CALCULATE_POSITION _PondWaterClipPosition
void _PondWaterClipPosition(_VertexInput v, inout half4 clipPos, inout half4 worldPos)
{
	worldPos = mul(unity_ObjectToWorld, v.vertex);
	worldPos.y += sin(_Time * 100 + v.vertex.x * v.vertex.z * 50) * 0.05f;
	worldPos.xz += sin(_Time * 2 + v.vertex.x * v.vertex.z * 10) * 0.1f;
	clipPos = mul(UNITY_MATRIX_VP, worldPos);
}

sampler2D_float _CameraDepthTexture;
half4 _CameraDepthTexture_TexelSize;
void _PondShoreFadeColor(half4 uv, inout FragmentCommonData s, inout half4 color)
{
	half depth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(uv)));
	half foamLine = saturate(1 - 0.85 * (depth - uv.w));

	half l = 0.4 * saturate(1 - 0.9 * (depth - uv.w));
	color.rgb = lerp(color.rgb, 1, l);
}
#endif
// pond water end

#ifdef _ENABLE_REALTIME_REFLECTION
#define RENDER_TARGET_TEXTURE _ComputeScreenPos

sampler2D _ReflectionTex;
half _ReflectionScale;
void _RealtimeReflectionColor(_VertexOutputForward i, inout FragmentCommonData s, inout half4 color)
{
	// blur reflection
	half3 reflectionTex = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(i.customRT + half4(s.normalWorld.xz * 0.1f, 0, 0))).rgb;
	half3 reflectionColor = reflectionTex * (1.0f - s.oneMinusReflectivity) * s.smoothness * _ReflectionScale;

	color.rgb += reflectionColor;
}
#endif


#define FRAG_SHADER_LOD_0 _FragLod0
#define FRAG_ADD_SHADER_LOD_0 _FragAddLod0

#define FRAG_SHADER_LOD_1 _FragLod1
#define FRAG_ADD_SHADER_LOD_1 _FragAddLod1

void _FragLod0(_VertexOutputForward i, inout FragmentCommonData s, inout half4 color)
{
#define _USE_DEFAULT_PBS 1

#ifdef _ENABLE_REALTIME_REFLECTION
	#define _USE_DEFAULT_PBS 0
	_RealtimeReflectionColor(i, s, color);
#endif

#ifdef _ENABLE_POND_WATER
	#define _USE_DEFAULT_PBS 0
	_PondShoreFadeColor(i.customRT, s, color);
#endif

#ifdef _USE_DEFAULT_PBS
	_CalculateCommonPBS(i, s, color);
#endif
}

void _FragAddLod0(_VertexOutputForwardAdd i, inout FragmentCommonData s, inout half4 color)
{
#define _USE_DEFAULT_PBS 1

#ifdef _ENABLE_POND_WATER
	#define _USE_DEFAULT_PBS 0
	_PondShoreFadeColor(i.customRT, s, color);
#endif

#ifdef _USE_DEFAULT_PBS
	_CalculateCommonAddPBS(i, s, color);
#endif
}

half3 _FakeMainLightDirection;
half3 _FakeMainLightColor;
half _FakeShininess;
half _FakeSpecualrScale;
void _FragLod1(_VertexOutputForward i, inout FragmentCommonData s, inout half4 color)
{
	// normalize
	half3 normalizedLightDir = normalize(_FakeMainLightDirection);
	half3 normalizedNormal = normalize(s.normalWorld);
	half3 normalizedViewDir = normalize(-s.eyeVec);

	// Calculate diffuse
	half3 diffuseColor = s.diffColor; /* *gi.indirect.diffuse */;

	// Calculate ambient
	half3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz *  s.diffColor;

	// Calculate specualr
	half3 halfDir = normalize(normalizedViewDir + normalizedLightDir);
	half3 specularColor = _FakeMainLightColor * pow(saturate(dot(halfDir, normalizedNormal)), _FakeShininess) * _FakeSpecualrScale;
	specularColor += s.specColor; /* *gi.indirect.specular */;

	// Calculate final color
	color.rgb = ambientColor + diffuseColor + specularColor;
}

void _FragAddLod1(_VertexOutputForwardAdd i, inout FragmentCommonData s, inout half4 color)
{
	color = 0;
}

#include "__PopcapStandardVSPS.cginc"
