#include "__PopcapVFXVSPS.cginc"

#ifdef POPCAP_FIRE
#define PROCESS_CLIP_POS _DilateVertex
#define PROCESS_TEXCOORD _TexcoordByPosition
#define PROCESS_FINAL_COLOR _FireColor

half4 _UV;

half4 _DilateVertex(_VertexInput v)
{
	half4 wPos = mul(UNITY_MATRIX_M, v.vertex);
	half4 wNormal = mul(UNITY_MATRIX_M, v.normal);

	half theta = saturate(dot(wNormal.xyz, half3(0, 1, 0)));
	theta = max(0, theta);

	half random = frac(wPos.x * wPos.y * wPos.z);
	half speed = 100;// *random;
	half v01 = (sin(_Time * speed + _Time * frac(wPos.y * 100) * 0.1) + 1.0f) * 0.5f;

	half height = 1.2 * v01;
	wPos.y += height * theta;
	//wPos.xz += 0.1 * sin(_Time * theta);

	_UV.xy = half2(frac(wPos.x * 0.55), frac(wPos.y * 0.2));
	_UV.z = pow(saturate(1.0 - wPos.y * 0.3), 4);

	return mul(UNITY_MATRIX_VP, wPos);
}

void _TexcoordByPosition(inout half4 texcoord)
{
	texcoord = _UV;
}

sampler2D _NoiseTex;
void _FireColor(_VertexOutputVFX i, FragmentCommonData s, inout half4 color)
{
	half2 uv = i.tex.xy;

	half v01 = (sin(_Time * 10 ) + 1.0f) * 0.5f;
	half noise0 = tex2D(_NoiseTex, uv - _Time * 0.75);
	half noise1 = tex2D(_NoiseTex, uv + _Time * 0.52);

	half noise = pow(noise0 * noise1 * 6, lerp(8, 10, v01));

	color.rgb = i.tex.z * noise * half3(0.975, 0.15, 0);

	//clip(noise - 0.5);
}

#endif

#include "__PopcapVFX.cginc"
	