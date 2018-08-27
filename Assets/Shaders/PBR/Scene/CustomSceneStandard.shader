Shader "Custom/PBR/Scene/Standard" 
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo", 2D) = "white" {}

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
        _GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
        [Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel ("Smoothness texture channel", Float) = 0

        [Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _MetallicGlossMap("Metallic", 2D) = "white" {}

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

		// Changed color parameters
		[ToggleOff] _EnableChangedColor("Enable Changed Color", Float) = 0.0
		_ChangedColor("Changed Color", Color) = (1,1,1,1)
		_ChangedColorMask("Changed Color Mask", 2D) = "white" {}

		// Wet parameters
		_WetMask("Wet Mask", 2D) = "white" {}
		_WetlAreaIntensity("Wet Area lIntensity", Range (0.00, 2.00)) = 1.0

		_NormalWave ("Normal Wave", 2D) = "bump" {}
		_NormalWavelIntensity("Normal Wave lIntensity", Range (0.00, 1.00)) = 1.0

		_WaterDrop("Water Drop", 2D) = "white" {}

		_RainDensity("Rain Density", Range (0.00, 5.00)) = 1.0
		_RainIntensity("Rain Intensity", Range (0.00, 1.00)) = 1.0
		_RainSpeed("Rain Speed", Range (0.00, 5.00)) = 1.0

		// Reflection parameters
		[ToggleOff] _EnableRealTimeReflection("Enable RealTime Reflection", Float) = 0.0
		_ReflectionScale("Reflection Scale", Float) = 2.0
		_ReflectionNormalScale("Reflection Normal Scale", Float) = 0.2
		_ReflectionTex ("Reflection Texture", 2D) = "black" {}	
			
		// Water parameters
		[ToggleOff] _EnableWater("Enable Water", Float) = 0.0
		_WaterNormalScaleU("Water Normal Scale U", Range (0.00, 2.00)) = 0.5
		_WaterNormalScaleV("Water Normal Scale V", Range (0.00, 2.00)) = 0.5
		_WaterNormalIntensity("Water Normal Texture Intensity", Range (0.00, 10.00)) = 1.0
		_CausticTex ("Caustic Texture", 2D) = "black" {}
		_CausticScale("Caustic Scale", Range (0.00, 10.00)) = 2.0
		_RefractionTex ("Refraction Texture", 2D) = "black" {}	
		[ToggleOff] _EnableWaterReflectionAndRefraction("Enable Water Reflection/Refraction", Float) = 0.0
		_NoiseTex ("Noise Texture", 2D) = "black" {}
		_FoamTex ("Foam Texture", 2D) = "black" {}
    }

    CGINCLUDE
        #define UNITY_SETUP_BRDF_INPUT MetallicSetup
    ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" "PerformanceChecks"="False" }
        LOD 300

        // ------------------------------------------------------------------
        //  Base forward pass (directional light, emission, lightmaps, ...)
        Pass
        {
            Name "FORWARD"
            Tags { "LightMode" = "ForwardBase" }

            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]

            CGPROGRAM
			
            #pragma target 3.0

            // -------------------------------------

            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature _METALLICGLOSSMAP
            //#pragma multi_compile _METALLICGLOSSMAP
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
            #pragma shader_feature _PARALLAXMAP

			// scene macro
			#pragma shader_feature _ENABLE_CHANGED_COLOR
			#pragma shader_feature _ENABLE_REALTIME_REFLECTION
			#pragma shader_feature _ENABLE_WATER
			#pragma shader_feature _ENABLE_WATER_REFLECTION_AND_REFRACTION
				
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            // Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
            //#pragma multi_compile _ LOD_FADE_CROSSFADE

			#pragma vertex vert
            #pragma fragment frag

			#include "UnityStandardCore.cginc"
			#include "../../Includes/CustomScene.cginc"

			_VertexOutputForward vert (_VertexInput v) { return _vertForward(v); }
			half4 frag (_VertexOutputForward i) : SV_Target { return _fragForward(i); }
            ENDCG
        }
		
        // ------------------------------------------------------------------
        //  Additive forward pass (one light per pass)
        Pass
        {
            Name "FORWARD_DELTA"
            Tags { "LightMode" = "ForwardAdd" }
            Blend [_SrcBlend] One
            Fog { Color (0,0,0,0) } // in additive pass fog should be black
            ZWrite Off
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0

            // -------------------------------------

            #pragma shader_feature _NORMALMAP
            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature _PARALLAXMAP

			// scene macro
			#pragma shader_feature _ENABLE_CHANGED_COLOR
			#pragma shader_feature _ENABLE_REALTIME_REFLECTION
			#pragma shader_feature _ENABLE_WATER
			#pragma shader_feature _ENABLE_WATER_REFLECTION_AND_REFRACTION

            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            // Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
            //#pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma vertex vertAdd
            #pragma fragment fragAdd

            #include "UnityStandardCoreForward.cginc"
			#include "../../Includes/CustomScene.cginc"

			_VertexOutputForwardAdd vertAdd (_VertexInput v) { return _vertForwardAdd(v); }
			half4 fragAdd (_VertexOutputForwardAdd i) : SV_Target { return _fragForwardAdd(i); }

            ENDCG	
        }
				
		// ------------------------------------------------------------------
        //  Shadow rendering pass
        Pass {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On ZTest LEqual

            CGPROGRAM
            #pragma target 3.0


			// scene macro
			#pragma shader_feature _ENABLE_CHANGED_COLOR
			#pragma shader_feature _ENABLE_REALTIME_REFLECTION
			#pragma shader_feature _ENABLE_WATER
			#pragma shader_feature _ENABLE_WATER_REFLECTION_AND_REFRACTION

            // -------------------------------------

            #pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _METALLICGLOSSMAP
            #pragma shader_feature _PARALLAXMAP
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing
            // Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
            //#pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma vertex vertShadowCaster
            #pragma fragment fragShadowCaster

			#include "UnityStandardShadow.cginc"
            //#include "../../Includes/CustomSceneShadow.cginc"

            ENDCG	
        }
    }
    FallBack "VertexLit"
    CustomEditor "CustomSceneStandardGUI"
}	
