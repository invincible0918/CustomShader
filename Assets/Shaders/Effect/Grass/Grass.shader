Shader "Popcap/Effect/Grass"  
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NoiseTex ("Noise", 2D) = "white" {}
		_NormalTex ("Normal (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_MaxLength ("Max Length", Range(0,0.5)) = 0.08
		_FadeOut ("Fade Out", Range(0,1)) = 0.4
		_Thickness ("_Thickness", Range(0,10)) = 1
	}	
		
	SubShader 
	{
		ZWrite On
		Tags { "QUEUE"="Transparent" "RenderType"="Opaque" "IgnoreProjector"="True"}	
		Blend SrcAlpha OneMinusSrcAlpha
		LOD 200		
			
		// base pass
		CGPROGRAM
		#define CURRENTLAYER 0.0
		#define NOISEFACTOR 1.0		
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG
		
		// grass fur pass
		CGPROGRAM
		#define CURRENTLAYER 0.05
		#define NOISEFACTOR 0.05
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG

		CGPROGRAM
		#define CURRENTLAYER 0.1
		#define NOISEFACTOR 0.1
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG

		CGPROGRAM
		#define CURRENTLAYER 0.15
		#define NOISEFACTOR 0.15
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG

		CGPROGRAM
		#define CURRENTLAYER 0.2
		#define NOISEFACTOR 0.2
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG

		CGPROGRAM
		#define CURRENTLAYER 0.25
		#define NOISEFACTOR 0.25
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG

		CGPROGRAM
		#define CURRENTLAYER 0.3
		#define NOISEFACTOR 0.3
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG

		CGPROGRAM
		#define CURRENTLAYER 0.35
		#define NOISEFACTOR 0.35
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG

		CGPROGRAM
		#define CURRENTLAYER 0.4
		#define NOISEFACTOR 0.4
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG

		CGPROGRAM
		#define CURRENTLAYER 0.45
		#define NOISEFACTOR 0.45
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG

		CGPROGRAM
		#define CURRENTLAYER 0.5
		#define NOISEFACTOR 0.5
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG

		CGPROGRAM
		#define CURRENTLAYER 0.55
		#define NOISEFACTOR 0.55
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG

		CGPROGRAM
		#define CURRENTLAYER 0.6
		#define NOISEFACTOR 0.6
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG

		CGPROGRAM
		#define CURRENTLAYER 0.65
		#define NOISEFACTOR 0.65
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG

		CGPROGRAM
		#define CURRENTLAYER 0.7
		#define NOISEFACTOR 0.7
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG

		CGPROGRAM
		#define CURRENTLAYER 0.75
		#define NOISEFACTOR 0.75
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG

		CGPROGRAM
		#define CURRENTLAYER 0.8
		#define NOISEFACTOR 0.8
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG

		CGPROGRAM
		#define CURRENTLAYER 0.85
		#define NOISEFACTOR 0.85
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG

		CGPROGRAM
		#define CURRENTLAYER 0.9
		#define NOISEFACTOR 0.9
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0	
		#include "../../Includes/GrassHelper.cginc"
		ENDCG	
			
		CGPROGRAM
		#define CURRENTLAYER 0.95
		#define NOISEFACTOR 0.95
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG	

		CGPROGRAM
		#define CURRENTLAYER 1.0
		#define NOISEFACTOR 1.0
		#pragma surface surf Standard fullforwardshadows alpha:blend vertex:vert
		#pragma target 3.0
		#include "../../Includes/GrassHelper.cginc"
		ENDCG
		
	}
	FallBack "Diffuse"
}
