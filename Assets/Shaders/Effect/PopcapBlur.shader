// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Popcap/Effect/Blur" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "" {}
	}

	CGINCLUDE
	
	#include "UnityCG.cginc"

	struct vertexInput  
    {   
        float4 vertex : POSITION;  
        half2 texcoord : TEXCOORD0;  
    };  

	struct v2f 
	{
		float4 pos : POSITION;
		
		// right up
		half2 uv20 : TEXCOORD0;
		// left down
		half2 uv21 : TEXCOORD1;
		// right down
		half2 uv22 : TEXCOORD2;
		// left up
		half2 uv23 : TEXCOORD3;
	};

	// gauss Weight  
    static const half4 gaussWeight[7] =  
    {  
        half4(0.0205,0.0205,0.0205,0),  
        half4(0.0855,0.0855,0.0855,0),  
        half4(0.232,0.232,0.232,0),  
        half4(0.324,0.324,0.324,1),  
        half4(0.232,0.232,0.232,0),  
        half4(0.0855,0.0855,0.0855,0),  
        half4(0.0205,0.0205,0.0205,0)  
    }; 
	
	half _DownSampleValue;
	
	sampler2D _MainTex;
	half4 _MainTex_TexelSize;  

	//vertex Shader Function  
    v2f vert_DownSample(vertexInput v)  
    {  
        v2f o;  
  
        o.pos = UnityObjectToClipPos(v.vertex);  

		// down sample, up, down, left, right pixel
        o.uv20 = v.texcoord + _MainTex_TexelSize.xy * half2(0.5h, 0.5h); 
        o.uv21 = v.texcoord + _MainTex_TexelSize.xy * half2(-0.5h, -0.5h);  
        o.uv22 = v.texcoord + _MainTex_TexelSize.xy * half2(0.5h, -0.5h);  
        o.uv23 = v.texcoord + _MainTex_TexelSize.xy * half2(-0.5h, 0.5h);  
   
        return o;  
    }  
  
    // fragment Shader Function  
    fixed4 frag_DownSample(v2f i) : SV_Target  
    {  
        fixed4 color = (0,0,0,0);  
   
        color += tex2D(_MainTex, i.uv20);  
        color += tex2D(_MainTex, i.uv21);  
        color += tex2D(_MainTex, i.uv22);  
        color += tex2D(_MainTex, i.uv23);  
  
        return color / 4;  
    }  

    // vertex Input Struct  
    struct v2f_Blur  
    {  
        float4 pos : SV_POSITION;  
        
		half4 uv : TEXCOORD0;  
        half2 offset : TEXCOORD1;  
    };  
  
    // vertex Shader Function  
    v2f_Blur vert_BlurHorizontal(vertexInput v)  
    {  
        v2f_Blur o;  
  
        o.pos = UnityObjectToClipPos(v.vertex);  

        o.uv = half4(v.texcoord.xy, 1, 1);  
        o.offset = _MainTex_TexelSize.xy * half2(1.0, 0.0) * _DownSampleValue;  
  
		return o;  
    }  
  
    // vertex Shader Function  
    v2f_Blur vert_BlurVertical(vertexInput v)  
    {  
        v2f_Blur o;  
  
        o.pos = UnityObjectToClipPos(v.vertex);  
        
		o.uv = half4(v.texcoord.xy, 1, 1);  
        o.offset = _MainTex_TexelSize.xy * half2(0.0, 1.0) * _DownSampleValue;  
  
        return o;  
    }  
  
    // fragment Shader Function  
    half4 frag_Blur(v2f_Blur i) : SV_Target  
    {  
        half2 uv = i.uv.xy;  
  
        half2 OffsetWidth = i.offset;  

		// start from offset left or up 3 pixel
        half2 uv_withOffset = uv - OffsetWidth * 3.0;  
  
        half4 color = 0;  
        for (int j = 0; j < 7; j++)  
        {  
            //偏移后的像素纹理值  
            half4 texCol = tex2D(_MainTex, uv_withOffset);  

            color += texCol * gaussWeight[j];  

            uv_withOffset += OffsetWidth;  
        }  
		
		return color;  
    }  

	ENDCG
	
	Subshader 
	{
		ZWrite Off
		Blend Off

		Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }	

		// pass 0 for down sample
        Pass
        {		
			ZTest Off Cull Off

			CGPROGRAM
			//#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert_DownSample
			#pragma fragment frag_DownSample
			ENDCG
        }
		
		// pass 1 for vertical blur
		Pass
		{
			ZTest Always Cull Off

			CGPROGRAM
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert_BlurVertical
			#pragma fragment frag_Blur
			ENDCG
		}

		// pass 2 for horizontal blur
		Pass
		{
			ZTest Always Cull Off

			CGPROGRAM
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert_BlurHorizontal
			#pragma fragment frag_Blur
			ENDCG
		}
	}

	Fallback "VertexLit"

} // shader
