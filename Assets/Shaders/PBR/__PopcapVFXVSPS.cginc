// define lots of functions here
#ifndef FRAG_SHADER_LOD_0
void _FragShaderLod0(_VertexOutputForward i, FragmentCommonData s, inout half4 color)
{
}
#define FRAG_SHADER_LOD_0 _FragShaderLod0
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

// vfx vertex shader
_VertexOutputForward vertVFX(_VertexInput v)
{
	UNITY_SETUP_INSTANCE_ID(v);
	_VertexOutputForward o;
	UNITY_INITIALIZE_OUTPUT(_VertexOutputForward, o);
	UNITY_TRANSFER_INSTANCE_ID(v, o);

	float4 worldPos = 0;
	float4 clipPos = 0;

#ifdef CALCULATE_POSITION
	CALCULATE_POSITION(v, clipPos, worldPos);
#else
	clipPos = UnityObjectToClipPos(v.vertex);
	worldPos = mul(unity_ObjectToWorld, v.vertex);
#endif
	o.pos = clipPos;

#if UNITY_REQUIRE_FRAG_WORLDPOS
#if UNITY_PACK_WORLDPOS_WITH_TANGENT
	o.tangentToWorldAndPackedData[0].w = worldPos.x;
	o.tangentToWorldAndPackedData[1].w = worldPos.y;
	o.tangentToWorldAndPackedData[2].w = worldPos.z;
#else
	o.posWorld = worldPos.xyz;
#endif
#endif	

	o.tex.xy = TRANSFORM_TEX(v.uv0, _MainTex);
	PROCESS_TEXCOORD(o.tex);

	o.eyeVec = NormalizePerVertexNormal(worldPos.xyz - _WorldSpaceCameraPos);
	float3 normalWorld = UnityObjectToWorldNormal(v.normal);
#if defined(_TANGENT_TO_WORLD) || defined(_ENABLE_TANGENT_TO_WORLD)
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

	UNITY_TRANSFER_FOG(o, o.pos);

	return o;
}

// vfx pixel shader
half4 fragVFX(_VertexOutputForward i) : SV_Target
{
	UNITY_APPLY_DITHER_CROSSFADE(i.pos.xy);

	FRAGMENT_SETUP(s);

	UNITY_SETUP_INSTANCE_ID(i);
	UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

	half4 color = 0;

#ifdef _SHADER_TIER_0
	FRAG_SHADER_LOD_0(i, s, color);
#else
#ifdef _SHADER_TIER_1
	FRAG_SHADER_LOD_1(i, s, color);
#else
	FRAG_SHADER_LOD_0(i, s, color);
#endif
#endif

	return color;
	//return OutputForward(color, color.a);
}