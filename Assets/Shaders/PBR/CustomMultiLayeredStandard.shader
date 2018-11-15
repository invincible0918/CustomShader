Shader "Custom/PBR/MultiLayered/Standard"
{
    Properties
    {	
        _MainTex1("Albedo 1", 2D) = "transparent" {}
        _MainTex2("Albedo 2", 2D) = "transparent" {}
		_MainTex3("Albedo 3", 2D) = "transparent" {}
		_MainTex4("Albedo 4", 2D) = "transparent" {}

		_MaterialScale1 ("Material Scale 1", Range (0.0,128.0)) = 1.00
		_MaterialScale2 ("Material Scale 2", Range (0.0,128.0)) = 1.00
		_MaterialScale3 ("Material Scale 3", Range (0.0,128.0)) = 1.00
		_MaterialScale4 ("Material Scale 4", Range (0.0,128.0)) = 1.00

		_Mask ("Mask RGB", 2D) = "transparent" {}

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _Glossiness("Smoothness", Range(0.0, 1.0)) = 0.5
        _GlossMapScale("Smoothness Scale", Range(0.0, 1.0)) = 1.0
        [Enum(Metallic Alpha,0,Albedo Alpha,1)] _SmoothnessTextureChannel ("Smoothness texture channel", Float) = 0

        [Gamma] _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
		_MetallicGlossMap1("Metallic Map 1", 2D) = "white" {}
		_MetallicGlossMap2("Metallic Map 2", 2D) = "white" {}
		_MetallicGlossMap3("Metallic Map 3", 2D) = "white" {}
		_MetallicGlossMap4("Metallic Map 4", 2D) = "white" {}

        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _GlossyReflections("Glossy Reflections", Float) = 1.0

        _BumpMap1("Normal Map 1", 2D) = "bump" {}
        _BumpMap2("Normal Map 2", 2D) = "bump" {}
        _BumpMap3("Normal Map 3", 2D) = "bump" {}
        _BumpMap4("Normal Map 4", 2D) = "bump" {}

		_MeshNormal ("Mesh normal", 2D) = "bump" {}

		[ToggleOff] _EnableThirdLayerMaps("_EnableThirdLayerMaps", Float) = 0.0
		[ToggleOff] _EnableFourthLayerMaps("_EnableFourthLayerMaps", Float) = 0.0

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
    }

    CGINCLUDE
        #define Custom_SETUP_BRDF_INPUT MetallicSetupWithMultiLayered
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
            #pragma shader_feature ___ _DETAIL_MULX2
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature _ _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature _ _GLOSSYREFLECTIONS_OFF
            #pragma shader_feature _PARALLAXMAP

			#pragma shader_feature _ENABLE_THIRD_LAYER_MAPS
			#pragma shader_feature _ENABLE_FOURTH_LAYER_MAPS

            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            // Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
            //#pragma multi_compile _ LOD_FADE_CROSSFADE

			#pragma vertex vertBaseWithMultiLayered
            #pragma fragment fragBaseWithMultiLayered

			#include "UnityStandardCore.cginc"
			#include "../Includes/CustomPBRWithMultiLayered.cginc"

			VertexOutputForwardBaseWithMultiLayered vertBaseWithMultiLayered (VertexInput v) { return vertForwardBaseWithMultiLayered(v); }
			half4 fragBaseWithMultiLayered (VertexOutputForwardBaseWithMultiLayered i) : SV_Target { return fragForwardBaseWithMultiLayered(i); }

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

            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            // Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
            //#pragma multi_compile _ LOD_FADE_CROSSFADE

            #pragma vertex vertAdd
            #pragma fragment fragAdd
            #include "UnityStandardCoreForward.cginc"

            ENDCG
        }
    }
    FallBack "VertexLit"
    CustomEditor "CustomMultiLayeredGUI"
}
	