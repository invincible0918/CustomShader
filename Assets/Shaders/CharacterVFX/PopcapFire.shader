Shader "Popcap/CharacterVFX/Fire" 
{
    Properties	
    {
        _Color("Color", Color) = (1,1,1,1)

        _MainTex("Albedo", 2D) = "white" {}

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
        _GlossMapScale("Smoothness Factor", Range(0.0, 1.0)) = 1.0
        [Enum(Specular Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel ("Smoothness texture channel", Float) = 0

        _SpecColor("Specular", Color) = (0.2,0.2,0.2)
        _SpecGlossMap("Specular", 2D) = "white" {}
        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

        _BumpScale("Scale", Float) = 1.0
        _BumpMap("Normal Map", 2D) = "bump" {}

        _Parallax ("Height Scale", Range (0.005, 0.08)) = 0.02
        _ParallaxMap ("Height Map", 2D) = "black" {}

        _OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
        _OcclusionMap("Occlusion", 2D) = "white" {}

        _EmissionColor("Color", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {}

        _DetailMask("Detail Mask", 2D) = "white" {}

        _DetailAlbedoMap("Detail Albedo x2", 2D) = "grey" {}
        _DetailNormalMapScale("Scale", Float) = 1.0
        _DetailNormalMap("Normal Map", 2D) = "bump" {}

        [Enum(UV0,0,UV1,1)] _UVSec ("UV Set for secondary textures", Float) = 0

        // Blending state
        [HideInInspector] _Mode ("__mode", Float) = 0.0
        [HideInInspector] _SrcBlend ("__src", Float) = 1.0
        [HideInInspector] _DstBlend ("__dst", Float) = 0.0
        [HideInInspector] _ZWrite ("__zw", Float) = 1.0

		// SSS
		[ToggleOff] _EnableSSS("_EnableSSS", Float) = 0.0

        _ThicknessMap("Thickness Map", 2D) = "white" {}
        _ThicknessScale("Thickness Scale", Range(0.0, 5.0)) = 1.0

        _Distortion("Distortion", Range(0.0, 1.0)) = 0.2
       
		_BackgroundLightDirection("Background Light Direction", Vector) = (0, 0, 0, 0)
		_BackgroundLightColor("Background Light Color", Color) = (1,1,1)
		_BackgroundLightScale("Background Light Scale", Range(0.0, 5.0)) = 1.0

        _LTPower("LTPower", Range(0.0, 32.0)) = 2.0
        _LTScale("LTScale", Range(0.0, 10.0)) = 5.0

		// Only works on low-end
		_FakeMainLightDirection("Fake Main Light Direction", Vector) = (1, 1, -1, 0)
		_FakeMainLightColor("Fake Main Light Color", Color) = (1, 1, 1)
        _FakeShininess("Fake Shininess", Range(0.0, 128.0)) = 24.0
        _FakeSpecualrScale("Fake Specualr Scale", Range(0.0, 10.0)) = 0.5

		_NoiseTex("Noise Tex", 2D) = "white" {}
	}

    CGINCLUDE
        #define UNITY_SETUP_BRDF_INPUT SpecularSetup
    ENDCG

	SubShader
    {
        // ------------------------------------------------------------------
        //  Base forward pass (directional light, emission, lightmaps, ...)
        Pass
        {
            Name "FORWARD"
            Tags { "RenderType" = "Opaque" "PerformanceChecks" = "False" "LightMode" = "ForwardBase" }

			Blend[_SrcBlend][_DstBlend]
			ZWrite[_ZWrite]

            CGPROGRAM

            #pragma target 3.0

            // -------------------------------------
            //#pragma shader_feature _NORMALMAP
            #pragma multi_compile _NORMALMAP
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            //#pragma shader_feature _SPECGLOSSMAP
            #pragma multi_compile _SPECGLOSSMAP
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
            #pragma shader_feature _PARALLAXMAP

			// SSS
			#pragma shader_feature _ENABLE_SSS

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            // Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
            //#pragma multi_compile _ LOD_FADE_CROSSFADE

			#include "UnityStandardCoreForward.cginc"
			#include "__PopcapFire.cginc"

			#pragma vertex vertVFX
			#pragma fragment fragVFX

            ENDCG
        }
		
		Pass
		{
			ZWrite On
			ColorMask 0

			CGPROGRAM

			#pragma target 3.0

			#define POPCAP_FIRE
			#include "UnityStandardCoreForward.cginc"
			#include "__PopcapFire.cginc"

			#pragma vertex vertVFX
			#pragma fragment _frag
			half4 _frag(_VertexOutputVFX i) : SV_Target { return 0; }

			ENDCG
		}
		
		Pass
		{
			Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }

			ZWrite Off
			//Blend SrcAlpha OneMinusSrcAlpha
			Blend SrcAlpha One
			CGPROGRAM

			#pragma target 3.0

			// -------------------------------------
			//#pragma shader_feature _NORMALMAP
			#pragma multi_compile _NORMALMAP
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _EMISSION
			//#pragma shader_feature _SPECGLOSSMAP
			#pragma multi_compile _SPECGLOSSMAP
			#pragma shader_feature ___ _DETAIL_MULX2
			#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
			#pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
			#pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
			#pragma shader_feature _PARALLAXMAP

			// SSS
			#pragma shader_feature _ENABLE_SSS

			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile_instancing
			// Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
			//#pragma multi_compile _ LOD_FADE_CROSSFADE
			
			#define POPCAP_FIRE
			#include "UnityStandardCoreForward.cginc"
			#include "__PopcapFire.cginc"

			#pragma vertex vertVFX
			#pragma fragment fragVFX

			ENDCG
		}	
		
    }
    FallBack "VertexLit"
    CustomEditor "PopcapCharacterStandardGUI"
}	
