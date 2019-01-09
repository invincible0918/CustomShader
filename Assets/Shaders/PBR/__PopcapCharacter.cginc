#include "__PopcapCommonFunction.cginc"

#define FRAG_SHADER_LOD_0 _FragLod0
#define FRAG_ADD_SHADER_LOD_0 _FragAddLod0

#define FRAG_SHADER_LOD_1 _FragLod1
#define FRAG_ADD_SHADER_LOD_1 _FragAddLod1


#ifdef _ENABLE_SSS
sampler2D _ThicknessMap;
void _CalculateTranslucencyColor(_VertexOutputForward i, inout FragmentCommonData s, inout half4 color)
{
	// calculate pbs color first
	_CalculateCommonPBS(i, s, color);

	UnityLight mainLight = MainLight();

	// Always use the main light as a background light
	half3 lightDir = -mainLight.dir;
	half3 lightColor = mainLight.color;

	half3 transLightDir = lightDir + s.normalWorld * 0.2;
	half fLTDot = pow(saturate(dot(-s.eyeVec, -transLightDir)), 2) * 6.5;
	half thickness = pow(saturate(1 - tex2D(_ThicknessMap, i.tex.xy).r), 1.85);

	half3 translucencyColor = thickness * s.diffColor * fLTDot * lightColor;
	color.rgb += translucencyColor;
}
#endif

#ifdef _ENABLE_SEMI_TRANSPARENCY 
void _CalculateSemiTransparencyColor(_VertexOutputForward i, inout FragmentCommonData s, inout half4 color)
{
	// calculate pbs color first
	_CalculateCommonPBS(i, s, color);

	s.alpha = 0.5;
}
#endif

#ifdef _ENABLE_MOSAIC 
#define RENDER_TARGET_TEXTURE _GrabScreenPos
sampler2D _GrabScreenRenderTexture;

half4 _GrabScreenPos(half4 pos)
{
	return ComputeGrabScreenPos(pos);
}

void _CalculateMosaicColor(_VertexOutputForward i, inout FragmentCommonData s, inout half4 color)
{
	//_CalculateCommonPBS(i, s, color);	

	half desity = 15;
	half2 c = half2(i.customRT.x * 1.8, i.customRT.y) / i.customRT.w * desity;
	c = floor(c) / 2;

	half randomX = 0.31;
	half randomY = 0.55;
	half mask = frac(c.x * randomX + c.y * randomY) * 2;

	half speed = 3;
	half t = _Time * speed;
	
	half v0 = (sin(mask * t + t) + 1) * 0.5;
	half v1 = (cos(mask * -t) + 1) * 0.5;
	half mask2 = frac(c.x * v0 + c.y * v1) * 2;

	mask+= frac(mask2 + mask2);

	mask = lerp(0.6, 0.95, mask);

	half4 bgc = tex2Dproj(_GrabScreenRenderTexture, i.customRT);

	color.rgb = mask * bgc;
	//color.a = mask * bgc;
	//s.alpha = mask * bgc;
}

void _CalculateMosaicShadowColor(half4 wpos)
{

}
#endif

#ifdef _ENABLE_ICE
#define CALCULATE_POSITION _DilateVertex
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

sampler2D _IceNormalMap;
void _CalculateIceColor(_VertexOutputForward i, inout FragmentCommonData s, inout half4 color)
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
	s.alpha = 0.85;
}
#endif

#ifdef _ENABLE_MATCAP
sampler2D _MatcapMap;
void _CalculateMatcapColor(_VertexOutputForward i, inout FragmentCommonData s, inout half4 color)
{
	half3 normalView = mul((half3x3)UNITY_MATRIX_V, s.normalWorld);
	//normalView = mul(UNITY_MATRIX_IT_MV, i.tex.xyz);
	normalView = normalize(normalView);

	//half3 posView = mul(UNITY_MATRIX_V, half4(s.posWorld, 1)).xyz;

	//half3 v = posView - half3(0, 0, 0.3);
	//half3 r = reflect(v, normalView);

	//half m = 2.0 * sqrt(r.x * r.x + r.y * r.y + (r.z + 1) * (r.z + 1));
	//normalView = (((r / m + 0.5) * 2 - 1) * 0.8 + 1) * 0.5;// *1 / 1.4142;
	//half3 normalView01 = normalView;

	half3 normalView01 = (normalView + 1) * 0.5;
	half3 matcapColor = tex2D(_MatcapMap, normalView01.xy);
	color.rgb = matcapColor;

}

void _CalculateMatcapAddColor(_VertexOutputForwardAdd i, inout FragmentCommonData s, inout half4 color)
{
}
#endif

#ifdef _ENABLE_DISSOLVE
sampler2D _NoiseTex;
void _CalculateDissolveColor(_VertexOutputForward i, inout FragmentCommonData s, inout half4 color)
{
	_CalculateCommonPBS(i, s, color);
	
	half value01 = (sin(_Time * 20) + 1) * 0.5;
	half melt = saturate(tex2D(_NoiseTex, i.tex.xy).r * 8.0 - 8.0 + value01 * 9.0);
	melt = melt * melt;

	color.a = saturate(melt * 2.0 - 1.0);

	half4 edge = half4(1, 0, 0, 1);
	edge.a = 1.0 - abs(melt * 2.0 - 1.0);

	color.rgb = color.rgb * color.a + edge.rgb * edge.a * 2.0;
	color.a = saturate(edge.a + color.a);	

	clip(color.a - 0.1);
	
}
#endif

#ifdef _ENABLE_ADVANCED_DISSOLVE
half _CalculateAdvancedDissolveValue()
{
	half v01 = (sin(_Time * 10) + 1) * 0.5;
	half value = lerp(-0.1, 1.1, v01);
	return value;
}

void _CalculateRampColor(half wPosY, half value, inout half4 color)
{
	half3 edge = half3(0.1, 0.95, 0.8);

	half width = 0.04;
	if (wPosY < value + width)
		color.rgb += 20 * edge * (value + width - wPosY);
}

void _CalculateAdvancedDissolveColor(_VertexOutputForward i, inout FragmentCommonData s, inout half4 color)
{
	_CalculateCommonPBS(i, s, color);
	half value = _CalculateAdvancedDissolveValue();

	// clip mesh
	clip(s.posWorld.y - value);

	// add ramp color
	_CalculateRampColor(s.posWorld.y, value, color);
}

void _CalculateAdvancedDissolveAddColor(_VertexOutputForwardAdd i, inout FragmentCommonData s, inout half4 color)
{
	_CalculateCommonAddPBS(i, s, color);
	half value = _CalculateAdvancedDissolveValue();

	// clip mesh
	clip(s.posWorld.y - value);

	// add ramp color
	_CalculateRampColor(s.posWorld.y, value, color);
}	

void _CalculateAdvancedDissolveShadowColor(half4 wpos)
{
	half value = _CalculateAdvancedDissolveValue();

	if (wpos.y < value)
		clip(-1);
}	
#endif

////////////////////////////////////////////////////////////////////////////////
/////////////////////////// Main Fragment Shader ///////////////////////////////
////////////////////////////////////////////////////////////////////////////////
void _FragLod0(_VertexOutputForward i, inout FragmentCommonData s, inout half4 color)
{	
#ifdef _ENABLE_DISSOLVE
	_CalculateDissolveColor(i, s, color);
	return;
#endif

#ifdef _ENABLE_ADVANCED_DISSOLVE
	_CalculateAdvancedDissolveColor(i, s, color);
	return;
#endif

#ifdef _ENABLE_SSS
	_CalculateTranslucencyColor(i, s, color);
	return;
#endif

#ifdef _ENABLE_SEMI_TRANSPARENCY 
	_CalculateSemiTransparencyColor(i, s, color);
	return;
#endif

#ifdef _ENABLE_MOSAIC 
	_CalculateMosaicColor(i, s, color);
	return;
#endif

#ifdef _ENABLE_ICE
	_CalculateIceColor(i, s, color);
	return;
#endif

#ifdef _ENABLE_DISSOLVE
	_CalculateDissolveColor(i, s, color);
	return;
#endif

#ifdef _ENABLE_MATCAP
	_CalculateMatcapColor(i, s, color);
	return;
#endif

	_CalculateCommonPBS(i, s, color);
}

void _FragAddLod0(_VertexOutputForwardAdd i, inout FragmentCommonData s, inout half4 color)
{
//#ifdef _ENABLE_DISSOLVE
//	_CalculateAddDissolveColor(i, s, color);
//	return;
//#endif

#ifdef _ENABLE_ADVANCED_DISSOLVE
	_CalculateAdvancedDissolveAddColor(i, s, color);
	return;
#endif

#ifdef _ENABLE_MATCAP
	_CalculateMatcapAddColor(i, s, color);
	return;
#endif
	_CalculateCommonAddPBS(i, s, color);
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