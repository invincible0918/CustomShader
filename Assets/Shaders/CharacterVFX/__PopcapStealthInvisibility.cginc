#ifndef USING_RENTER_TARGET_TEXTURE
#define USING_RENTER_TARGET_TEXTURE
#endif
#include "__PopcapVFXVSPS.cginc"

#define RENDER_TARGET_TEXTURE _GrabScreenPos
#define PROCESS_FINAL_COLOR _StealthInvisibilityColor

sampler2D _GrabScreenRenderTexture;

half4 _GrabScreenPos(half4 pos)
{
	return ComputeGrabScreenPos(pos);
}

void _StealthInvisibilityColor(_VertexOutputVFX i, FragmentCommonData s, inout half4 color)
{
	half ndotv = dot(s.normalWorld, -s.eyeVec);

	half4 uv = i.customRT;
	uv.w *= saturate(pow(ndotv, 5) + 0.75);
	half4 distortColor = tex2Dproj(_GrabScreenRenderTexture, uv);

	color = half4(distortColor.rgb, 1.0);
}

#include "__PopcapVFX.cginc"
	