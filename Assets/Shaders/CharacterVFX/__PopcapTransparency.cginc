#include "__PopcapVFXVSPS.cginc"

#define PROCESS_FINAL_COLOR _SemiTranparencyColor
void _SemiTranparencyColor(_VertexOutputVFX i, FragmentCommonData s, inout half4 color)
{
	color.a = 0.5f;
}

#include "__PopcapVFX.cginc"
