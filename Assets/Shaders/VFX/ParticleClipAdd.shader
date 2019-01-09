Shader "Popcap/VFX/Particle/__Obsolete"  
{
	Properties 
	{
		_MainTex ("Particle Texture", 2D) = "white" {}
		_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)

		//-------------------add----------------------
		_MinX("Min x", Float) = 0
		_MaxX("Max x", Float) = 0
		_MinY("Min Y", Float) = 0
		_MaxY("Max Y", Float) = 0
		//-------------------add----------------------
	}

	Category 
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Blend SrcAlpha One
		Cull Off Lighting Off ZWrite Off Fog { Color (0,0,0,0) }
	
		SubShader 
		{
			Pass 
			{
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag

				#include "UnityCG.cginc"

				sampler2D _MainTex;

				//-------------------add----------------------
				float _MinX;
				float _MaxX;
				float _MinY;
				float _MaxY;
				//-------------------add----------------------
			
				struct appdata_t 
				{
					float4 vertex : POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
				};

				struct v2f 
				{
					float4 vertex : SV_POSITION;
					fixed4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					float3 worldPos : TEXCOORD2;
				};
			
				float4 _MainTex_ST;
				fixed4 _TintColor;

				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.color = v.color;
					o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
					o.worldPos.xy = v.vertex.xy;
					return o;
				}

				sampler2D_float _CameraDepthTexture;
				float _InvFade;
			
				fixed4 frag (v2f i) : SV_Target
				{
					//-------------------add----------------------
					fixed4 c = i.color * _TintColor * tex2D(_MainTex, i.texcoord);
					c.a *= (i.worldPos.x > _MinX);
					c.a *= (i.worldPos.x < _MaxX);
					c.a *= (i.worldPos.y > _MinY);
					c.a *= (i.worldPos.y < _MaxY);
					return c;
					//-------------------add----------------------
				}
				ENDCG 
			}
		}	
	}
}
