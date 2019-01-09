Shader "Custom/Shadow" 
{
	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		Pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata 
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				half4 pos:		POSITION;
				half4 sproj:	TEXCOORD0;
				half4 uv:	TEXCOORD1;
				half4 screenPos:	TEXCOORD2;
				//UNITY_FOG_COORDS(1)
			};

			half4x4 _VPMatrix;
			sampler2D _ShadowTex;
			uniform sampler2D _MainTex;
			sampler2D _CameraDepthTexture;

			v2f vert(appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.sproj = mul(mul(_VPMatrix, unity_ObjectToWorld), v.vertex);
				o.uv = v.texcoord;
				o.screenPos = ComputeScreenPos(o.pos);
				COMPUTE_EYEDEPTH(o.screenPos.z);//计算顶点摄像机空间的深度：距离裁剪平面的距离
				return o;
			}

			float4 frag(v2f i) : COLOR 
			{
				//half4 depth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
				//UNITY_APPLY_FOG_COLOR(i.fogCoord, c, fixed4(1,1,1,1));

				half4 f = tex2D(_MainTex, i.uv);

				//fragment
				float  depth = tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)).r;//UNITY_PROJ_COORD:深度值 [0,1]
				depth = LinearEyeDepth(depth);//深度根据相机的裁剪范围的值[0.3,1000],是将经过透视投影变换的深度值还原了
				depth -= i.screenPos.z;

				return depth;
			}
			ENDCG
		}
	}
}