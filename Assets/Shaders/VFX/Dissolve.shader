Shader "Popcap/VFX/Dissolve"  
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" {}
		_EdgeColor("Edge Color", Color) = (1,0,0,0)
		_NoiseTex("Noise Tex", 2D) = "white" {}
		_Value("Value", Range(0, 1)) = 1.0
	}
		
	Category 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }

		Alphatest Greater 0.01
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGB
		Lighting Off
	
		SubShader 
		{
			Pass 
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"
				#include "__PopcapVFX.cginc"

				_VertexOutput vert(_VertexInput v) { return _vert(v); }
				half4 frag(_VertexOutput i) : SV_Target { return _fragDissolve(i); }

				ENDCG
			}
		}
	}
}