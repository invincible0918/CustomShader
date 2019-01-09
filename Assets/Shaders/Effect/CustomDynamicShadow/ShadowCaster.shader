Shader "Popcap/Effect/ShadowCaster"   
{
	Properties
	{
		_ShadowColor("Shadow Color", COLOR) = (1, 1, 1, 1)
	}
	
	SubShader
	{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry" }

		Pass
		{
			ZWrite Off
			Cull Back
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			
			struct v2f
			{
				half4 pos : POSITION;
			};

			v2f vert(half4 vertex:POSITION)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(vertex);
				return o;
			}

			half4 frag(v2f i) :SV_TARGET
			{
				return 1;
			}
			
			ENDCG
		}
	}
}