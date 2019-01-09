#include "__PopcapStandardInput.cginc"

half4 _ComputeScreenPos(half4 pos)
{
	return ComputeScreenPos(pos);
}

// Used for fragment shader in forward render pipeline
void _CalculateCommonPBS(_VertexOutputForward i, FragmentCommonData s, inout half4 color)
{
	UnityLight mainLight = MainLight();
	UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);

	half occlusion = Occlusion(i.tex.xy);
	UnityGI gi = FragmentGI(s, occlusion, i.ambientOrLightmapUV, atten, mainLight);

	color = UNITY_BRDF_PBS(s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, gi.light, gi.indirect);
	color.rgb += Emission(i.tex.xy);

	UNITY_APPLY_FOG(i.fogCoord, color.rgb);
}

// Used for fragment shader in forward add render pipeline
void _CalculateCommonAddPBS(_VertexOutputForwardAdd i, FragmentCommonData s, inout half4 color)
{
	UNITY_LIGHT_ATTENUATION(atten, i, s.posWorld);

	UnityLight light = AdditiveLight(IN_LIGHTDIR_FWDADD(i), atten);
	UnityIndirect noIndirect = ZeroIndirect();

	color = UNITY_BRDF_PBS(s.diffColor, s.specColor, s.oneMinusReflectivity, s.smoothness, s.normalWorld, -s.eyeVec, light, noIndirect);

	UNITY_APPLY_FOG_COLOR(i.fogCoord, color.rgb, half4(0, 0, 0, 0)); // fog towards black in additive pass
}

struct vertexInput
{
	float4 vertex : POSITION;
	half2 texcoord : TEXCOORD0;
};

struct v2f
{
	float4 pos : POSITION;

	// right up
	half4 uv20 : TEXCOORD0;
	// left down
	half4 uv21 : TEXCOORD1;
	// right down
	half4 uv22 : TEXCOORD2;
	// left up
	half4 uv23 : TEXCOORD3;
};

// gauss Weight  
static const half4 gaussWeight[7] =
{
	half4(0.0205,0.0205,0.0205,0),
	half4(0.0855,0.0855,0.0855,0),
	half4(0.232,0.232,0.232,0),
	half4(0.324,0.324,0.324,1),
	half4(0.232,0.232,0.232,0),
	half4(0.0855,0.0855,0.0855,0),
	half4(0.0205,0.0205,0.0205,0)
};

sampler2D _GrabTexture;
half4 _GrabTexture_TexelSize;
//vertex Shader Function  
v2f vert_DownSample(vertexInput v)
{
	v2f o;

	o.pos = UnityObjectToClipPos(v.vertex);
	half4 screenPos = ComputeGrabScreenPos(o.pos);

	// down sample, up, down, left, right pixel
	half bias = 20;
	o.uv20 = screenPos + _GrabTexture_TexelSize * half4(bias, bias, 0, 0);
	o.uv21 = screenPos + _GrabTexture_TexelSize * half4(-bias, -bias, 0, 0);
	o.uv22 = screenPos + _GrabTexture_TexelSize * half4(bias, -bias, 0, 0);
	o.uv23 = screenPos + _GrabTexture_TexelSize * half4(-bias, bias, 0, 0);

	return o;
}

// fragment Shader Function  
half4 frag_DownSample(v2f i) : SV_Target
{
	half4 color = half4(0,0,0,0);

	color += tex2Dproj(_GrabTexture, i.uv20);
	color += tex2Dproj(_GrabTexture, i.uv21);
	color += tex2Dproj(_GrabTexture, i.uv22);
	color += tex2Dproj(_GrabTexture, i.uv23);

	return color / 4;
}

struct v2f_Blur
{
	float4 pos : SV_POSITION;
	half4 uv : TEXCOORD0;
	half2 offset : TEXCOORD1;
};

// vertex Shader Function  
v2f_Blur vert_BlurHorizontal(vertexInput v)
{
	v2f_Blur o;

	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = ComputeGrabScreenPos(o.pos);
	o.offset = o.uv.xy * half2(1.0, 0.0) * 0.004;

	return o;
}

// vertex Shader Function  
v2f_Blur vert_BlurVertical(vertexInput v)
{
	v2f_Blur o;

	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = ComputeGrabScreenPos(o.pos);
	o.offset = o.uv.xy * half2(0.0, 1.0) * 0.004;


	return o;
}

half4 blurColor(v2f_Blur i, sampler2D tex)
{
	half4 uv = i.uv;

	half2 offsetWidth = i.offset;

	// start from offset left or up 3 pixel
	half2 uv_withOffset = uv.xy - offsetWidth * 3.0;
	half4 _uv = half4(uv_withOffset, uv.z, uv.w);

	half4 color = 0;
	for (int j = 0; j < 7; j++)
	{
		half4 texCol = tex2Dproj(tex, _uv);

		color += texCol * gaussWeight[j];

		_uv.xy += offsetWidth;
	}

	return color;
}

sampler2D _BlurVertical;
half4 frag_BlurVertical(v2f_Blur i) : SV_Target
{
	return blurColor(i, _BlurVertical);
}

sampler2D _BlurHorizontal;
half4 frag_BlurHorizontal(v2f_Blur i) : SV_Target
{
	return blurColor(i, _BlurHorizontal);
}