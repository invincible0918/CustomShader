// define lots of functions here
#ifndef PROCESS_VERTEX
half4 ProcessVertex(_VertexInput v)
{
	return v.vertex;
}
#define PROCESS_VERTEX ProcessVertex
#endif

#ifndef PROCESS_CLIP_POS
half4 ProcessClipPos(_VertexInput v)
{
	return UnityObjectToClipPos(v.vertex);
}
#define PROCESS_CLIP_POS ProcessClipPos
#endif

#ifndef PROCESS_TEXCOORD
void ProcessTexcoord(inout half4 texcoord)
{
}
#define PROCESS_TEXCOORD ProcessTexcoord
#endif

#ifndef RENDER_TARGET_TEXTURE
half4 RenderTargetTexture(half4 vpos)
{
	return half4(0.0f, 0.0f, 0.0f, 0.0f);
}
#define RENDER_TARGET_TEXTURE RenderTargetTexture
#endif

#ifndef PROCESS_FINAL_COLOR
void ProcessFinalColor(_VertexOutputVFX i, FragmentCommonData s, inout half4 color)
{
}
#define PROCESS_FINAL_COLOR ProcessFinalColor
#endif

// vfx vertex shader
_VertexOutputVFX vertVFX(_VertexInput v)
{
	UNITY_SETUP_INSTANCE_ID(v);
	_VertexOutputVFX o;
	UNITY_INITIALIZE_OUTPUT(_VertexOutputVFX, o);
	UNITY_TRANSFER_INSTANCE_ID(v, o);

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

	o.pos = PROCESS_CLIP_POS(v);

	o.tex.xy = TRANSFORM_TEX(v.uv0, _MainTex);
	PROCESS_TEXCOORD(o.tex);

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

#if USING_RENTER_TARGET_TEXTURE
	o.customRT = RENDER_TARGET_TEXTURE(o.pos);
#endif

	//We need this for shadow receving
	UNITY_TRANSFER_SHADOW(o, v.uv1);

	//o.ambientOrLightmapUV = _VertexGIForward(v, posWorld, normalWorld);

	UNITY_TRANSFER_FOG(o, o.pos);

	return o;
}

// vfx pixel shader
half4 fragVFX(_VertexOutputVFX i) : SV_Target
{
	//UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

	//FRAGMENT_SETUP(s)

	//UNITY_SETUP_INSTANCE_ID(i);

	//UnityLight mainLight = MainLight();
	//UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);

	//half occlusion = Occlusion(i.tex.xy);
	//UnityGI gi = FragmentGI(s, occlusion, i.ambientOrLightmapUV, atten, mainLight);

	//half4 c = UNITY_BRDF_PBS (s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect);
	//CUSTOM_BRDF_PBS(i.tex.xy, s, gi.light, gi.indirect, c);
	/*
	// normalize
	fixed3 normalizedLightDir = normalize(_FakeMainLightDirection);
	fixed3 normalizedNormal = normalize(s.normalWorld);
	fixed3 normalizedViewDir = normalize(-s.eyeVec);

	// Calculate diffuse
	half3 diffuseColor = s.diffColor * gi.indirect.diffuse;

	// Calculate ambient
	fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz *  s.diffColor;

	// Calculate specualr
	half3 halfDir = normalize(normalizedViewDir + normalizedLightDir);
	half3 specularColor = _FakeMainLightColor * pow(saturate(dot(halfDir, normalizedNormal)), _FakeShininess) * _FakeSpecualrScale;
	specularColor += s.specColor * gi.indirect.specular;

	// Calculate final color
	half4 c = 0;
	c.rgb = ambientColor + diffuseColor + specularColor;
	c.rgb += Emission(i.tex.xy);
	*/

	half4 c = 0;
	c.rgb = half3(0, 1, 0);
	c.a = 0.5;
	//UNITY_APPLY_FOG(i.fogCoord, c.rgb);
	return c;

	// Process final color
	//half4 finalColor = OutputForward(c, s.alpha);
	//PROCESS_FINAL_COLOR(i, s, finalColor);

	//return finalColor;
}