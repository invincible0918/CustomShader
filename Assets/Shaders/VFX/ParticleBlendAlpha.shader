Shader "Popcap/VFX/Particle/Blend Alpha"  
{
	Properties 
	{
		_MainTex ("Particle Texture", 2D) = "white" {}
	}
	
	Category 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGB
		Cull Off 
		Lighting Off 
		ZWrite Off
	
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
				half4 frag(_VertexOutput i) : SV_Target { return _fragBlended(i); }

				ENDCG 
			}
		}
	}
}