Shader "Popcap/Effect/ShadowReceiver"  
{
	Properties 
	{
		_ShadowTex ("Shadow Texture", 2D) = "gray" {}
		_Intensity ("_Intensity", Range(0, 1)) = 1
	}

	SubShader 
	{
		Tags { "Queue"="AlphaTest+1" }

		Pass 
		{
			ZWrite Off
			ColorMask RGB
			Blend DstColor Zero
			Offset -1, -1

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "UnityCG.cginc"

			struct v2f 
			{
				half4 pos:		POSITION;
				half4 sproj:	TEXCOORD0;
				//UNITY_FOG_COORDS(1)
			};

			half4x4 _VPMatrix;
			sampler2D _ShadowTex;
			half _Intensity;

			v2f vert(half4 vertex:POSITION)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(vertex);
				o.sproj = mul(mul(_VPMatrix, unity_ObjectToWorld),  vertex);
				return o;
			}

			half4 frag(v2f i):SV_TARGET
			{
				half4 shadowCol = tex2D(_ShadowTex, i.sproj.xy / i.sproj.w * 0.5 + 0.5);
				half4 c = saturate(1.0 - shadowCol.r * _Intensity);
				//UNITY_APPLY_FOG_COLOR(i.fogCoord, c, fixed4(1,1,1,1));
				return c;
			}

			ENDCG
		}
	}
	
	FallBack Off
}