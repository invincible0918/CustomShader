Shader "Popcap/VFX/Particle/Add Anim"  
{
	Properties 
	{
		_MainTex ("Particle Texture", 2D) = "white" {}
		_SpeedX ("Speed X", float) = 0.0
		_SpeedY ("Speed Y", float) = 0.0
	}
		
	Category
	{
		Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend SrcAlpha One
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
				half4 frag(_VertexOutput i) : SV_Target { return _fragAdditiveWithAnim(i); }

				ENDCG
			}
		}
	}
}
