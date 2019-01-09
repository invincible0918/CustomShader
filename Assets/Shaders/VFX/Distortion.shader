Shader "Popcap/VFX/Distortion"  
{
	Properties 
	{
		[HideInInspector] _MainTex ("Texture", 2D) = "white" {}
		_NoiseTex("Noise Tex", 2D) = "white" {}
		_Value("Value", Range(0, 1)) = 1.0
	}
		
	Category 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	
		SubShader 
		{
			GrabPass
			{
				"_GrabScreenRenderTexture"
			}

			Pass 
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#define USING_RENTER_TARGET_TEXTURE 1	
				#include "UnityCG.cginc"
				#include "__PopcapVFX.cginc"

				_VertexOutput vert(_VertexInput v) { return _vertDistortion(v); }
				half4 frag(_VertexOutput i) : SV_Target { return _fragDistortion(i); }

				ENDCG
			}
		}
	}
}