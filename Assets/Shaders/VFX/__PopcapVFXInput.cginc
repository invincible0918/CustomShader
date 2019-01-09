struct _VertexInput
{
    half4 vertex	: POSITION;
	half4 color		: COLOR;
	half2 uv		: TEXCOORD0;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct _VertexOutput
{
	half4 pos		: SV_POSITION;
	half2 uv		: TEXCOORD0;
	half4 color     : COLOR;

#if USING_RENTER_TARGET_TEXTURE
	half4 customRT	: TEXCOORD1;
#endif

	UNITY_VERTEX_INPUT_INSTANCE_ID
};
