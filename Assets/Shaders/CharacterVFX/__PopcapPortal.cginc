#include "__PopcapVFXVSPS.cginc"

#define PROCESS_CLIP_POS _PortalVertex
#define PROCESS_TEXCOORD _PortalTexcoord
#define PROCESS_FINAL_COLOR _PortalColor

half4 _TargetPosition;
half __PortalLerpValue;

half4 _PortalVertex(_VertexInput v)
{
	half4 worldPosition = mul(unity_ObjectToWorld, v.vertex);

	__PortalLerpValue = saturate(1.0f- pow(distance(worldPosition.xyz, _TargetPosition.xyz) / 10, 10.1));
	
	half3 c = _TargetPosition.xyz - worldPosition.xyz;
	half3 offset = lerp(0, c, __PortalLerpValue);
	worldPosition.xyz += offset;

	return mul(UNITY_MATRIX_VP, worldPosition);
}

void _PortalTexcoord(inout half4 texcoord)
{
	texcoord.z = __PortalLerpValue;
}

void _PortalColor(_VertexOutputVFX i, FragmentCommonData s, inout half4 color)
{
	color.rgb = lerp(color.rgb, half3(0, 0, 200), i.tex.z);
}

#include "__PopcapVFX.cginc"
