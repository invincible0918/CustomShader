Shader "Popcap/PBR/Character/SSS" 
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

		// Character VFX
		[ToggleOff] _EnableSSS("_EnableSSS", Float) = 0.0

		[ToggleOff] _EnableIce("_EnableIce", Float) = 0.0
		_IceNormalMap("Ice Normal Map", 2D) = "bump" {}

		[ToggleOff] _EnableFire("_EnableFire", Float) = 0.0

		_NoiseMap("Noise Map", 2D) = "white" {}

		_ThicknessMap("Thickness Map", 2D) = "white" {}
		_Distortion("Distortion", Range(0.0, 1.0)) = 0.2

		// Shader Tier parameters
		_ShaderTier("Shader Tier", Range(1, 3)) = 1

		// Only works on low-end
		_FakeMainLightDirection("Fake Main Light Direction", Vector) = (1, 1, -1, 0)
		_FakeMainLightColor("Fake Main Light Color", Color) = (1, 1, 1)
		_FakeShininess("Fake Shininess", Range(0.0, 128.0)) = 24.0
		_FakeSpecualrScale("Fake Specualr Scale", Range(0.0, 10.0)) = 0.5
	}

	CGINCLUDE
		#define _ENABLE_SSS
	ENDCG

	SubShader
	{
		LOD 600
		Tags { "RenderType" = "Opaque" "PerformanceChecks" = "False" }

		CGINCLUDE
			#define _ENABLE_SSS
		ENDCG
		//  Base forward pass (directional light, emission, lightmaps, ...)
		UsePass "Popcap/PBR/Character/__Passes/SSS"
		UsePass "Popcap/PBR/Character/__Passes/FORWARD"
		//  Additive forward pass (one light per pass)
		UsePass "Popcap/PBR/Character/__Passes/FORWARD_DELTA"
		//  Shadow rendering pass
		//UsePass "Popcap/PBR/Character/__Passes/SHADOW_CASTER"
	}

	FallBack "VertexLit"
    CustomEditor "PopcapCharacterStandardGUI"
}	
