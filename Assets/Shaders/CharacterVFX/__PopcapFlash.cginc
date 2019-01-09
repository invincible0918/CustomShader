#include "__PopcapVFXVSPS.cginc"

#define PROCESS_FINAL_COLOR _AddFlashColor

half _RotateValue;
half _FlashWidth;
half3 _FlashColor;

void _AddFlashColor(_VertexOutputVFX i, FragmentCommonData s, inout half4 color)
{
	half v0 = frac(-s.posWorld.y + s.posWorld.x * _RotateValue - _Time * 50);
	half v1 = frac(s.posWorld.y + _FlashWidth - 0.01f - s.posWorld.x * _RotateValue + _Time * 50);
	
	half width = step(v0, _FlashWidth);

	half v = pow(v0, 10) + pow(v1, 10);

	half3 flashColor = (width + v) * _FlashColor;

	color.rgb += flashColor;
}

#include "__PopcapVFX.cginc"
