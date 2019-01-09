// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Popcap/Effect/WaterCaustic" 
{
	Properties 
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_NoiseTex ("Noise Texture", 2D) = "white" {}
		_Scale("Scale", Range (0.00, 10.00)) = 1.0
		_Speed("Speed", Range (0.00, 5.00)) = 0.0
		_Distortion("Distortion", Range (0.00, 0.10)) = 0.05
	}	

	Category 
	{
		Tags 
		//{ "RenderType"="Opaque" }
		{ "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
		Blend SrcAlpha One
		//Blend One One
		SubShader 
		{
			Pass 
			{

				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0

				#include "UnityCG.cginc"

				sampler2D _MainTex;
				sampler2D _NoiseTex;

				half _Scale;
				half _Speed;
				half _Distortion;

				struct appdata_t 
				{
					half4 vertex : POSITION;
					half4 texcoord : TEXCOORD0;
				};

				struct v2f 
				{
					half4 vertex : SV_POSITION;
					half4 texcoord : TEXCOORD0;
				};

				half4 _MainTex_ST;

				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					o.texcoord = v.texcoord;
					return o;
				}
				half4 frag (v2f i) : SV_Target
				{
					half3 noise = tex2D(_NoiseTex, (i.texcoord.xy - _Time.x) * 5.0f).rgb;

					half t01 = (sin(_Time.y) + 1.0f) * 0.5f;
					half t02 = (cos(-_Time.x) + 1.0f) * 0.5f;

					half scale01 = lerp(1.0f - t01 * _Distortion, 1.0f + t01 * _Distortion, saturate(noise.r));
					half scale02 = lerp(1.0f - t02 * _Distortion, 1.0f + t02 * _Distortion, saturate(noise.g));

					half scaleU = lerp(1.0f - t01 * _Distortion, 1.0f + t01 * _Distortion, t01) * scale01;
					half scaleV = lerp(1.0f - t02 * _Distortion, 1.0f + t02 * _Distortion, t02) * scale02;
					half2 uv = i.texcoord.xy * half2(scaleU, scaleV) * _Scale + _Time.x * _Speed;
					half4 col = tex2D(_MainTex, uv);

					return col;
				}
				ENDCG
			}
		}
	}
}
