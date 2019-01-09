Shader "Popcap/VFX/Particle/__Obsolete"   
{	
	Properties 
	{
		_MainTex ("Particle Texture", 2D) = "white" {}
	}
		
	Category 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend DstColor One
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
