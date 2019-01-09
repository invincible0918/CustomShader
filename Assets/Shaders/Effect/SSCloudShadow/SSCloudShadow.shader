Shader "Popcap/Effect/SSCloudShadow"   
{
	Properties
	{
		_MainTex ("Cloud Shadow", 2D) = "black" {}
		_ShadowColor ("Shadow Color", Vector) = (1,1,1,1)
		_CloudFactor ("Cloud Factor", Vector) = (0.05,0.05,2,2)
	}

	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"ForceNoShadowCasting"="True"
		}
		Pass
		{
			Fog { Mode Off }
			ZWrite Off 
			ZTest Always
			Blend Zero OneMinusSrcColor

			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct v2f
			{
				half4 pos : SV_POSITION;
				half2 uv  : TEXCOORD0;
				half3 viewDir : TEXCOORD1;
			};

			sampler2D _MainTex;
			sampler2D _CameraDepthTexture;

			uniform half4 _ShadowColor;
			uniform half4 _CloudFactor;

			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos (v.vertex);
				o.uv = v.texcoord.xy;

				half3 pos_world = mul (unity_ObjectToWorld, v.vertex);

				// Don't normalize it
				o.viewDir = pos_world - _WorldSpaceCameraPos;

				return o;
			}

			half4 frag(v2f i) : SV_Target
			{

				// Z buffer to linear 0..1 depth
				half2 uv = half2(1 - i.uv.x, i.uv.y);
				float  depth = Linear01Depth( SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, uv ) );

				half3 world = i.viewDir * depth + _WorldSpaceCameraPos;

				half2 cloud_wind = _CloudFactor.xy;
				half cloud_tiling = _CloudFactor.z;

				half2 cloud_uv = (world.xz + cloud_wind * _Time.x) * cloud_tiling;

				half  cloud = tex2D(_MainTex, cloud_uv).r;
				half  cloud_faded = cloud * (1.0 - depth);

				return half4(_ShadowColor.xyz * cloud_faded, 1.0);
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
