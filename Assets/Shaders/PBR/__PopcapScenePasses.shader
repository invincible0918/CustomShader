Shader "Popcap/PBR/Scene/__Passes" 
{
	SubShader
	{
		CGINCLUDE
			#define UNITY_SETUP_BRDF_INPUT MetallicSetup
		ENDCG

		// ------------------------------------------------------------------
		//  Base forward pass (directional light, emission, lightmaps, ...)
		Pass
		{
			Name "FORWARD"
			Tags { "LightMode" = "ForwardBase" }
			Blend[_SrcBlend][_DstBlend]
			ZWrite[_ZWrite]

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

			// shader tier
			#pragma shader_feature _SHADER_TIER_0
			#pragma shader_feature _SHADER_TIER_1
			#pragma shader_feature _SHADER_TIER_2

			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#pragma multi_compile_instancing
			// Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
			//#pragma multi_compile _ LOD_FADE_CROSSFADE

			#pragma vertex vert
			#pragma fragment frag

			#include "__PopcapScene.cginc"
			
			_VertexOutputForward vert(_VertexInput v) { return _vertForward(v); }
			half4 frag(_VertexOutputForward i) : SV_Target { return _fragForward(i); }

			ENDCG
		}

		// ------------------------------------------------------------------
		//  Additive forward pass (one light per pass)
		Pass
		{
			Name "FORWARD_DELTA"
			Tags { "LightMode" = "ForwardAdd" }
			Blend[_SrcBlend] One
			Fog { Color(0,0,0,0) } // in additive pass fog should be black
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

			// shader tier
			#pragma shader_feature _SHADER_TIER_0
			#pragma shader_feature _SHADER_TIER_1
			#pragma shader_feature _SHADER_TIER_2

			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile_fog
			// Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
			//#pragma multi_compile _ LOD_FADE_CROSSFADE

			#pragma vertex vertAdd
			#pragma fragment fragAdd

			#include "__PopcapScene.cginc"

			_VertexOutputForwardAdd vertAdd(_VertexInput v) { return _vertForwardAdd(v); }
			half4 fragAdd(_VertexOutputForwardAdd i) : SV_Target { return _fragForwardAdd(i); }

			ENDCG
		}
		/*
		// ------------------------------------------------------------------
		//  Shadow rendering pass
		Pass
		{
			Name "SHADOW_CASTER"
			Tags { "LightMode" = "ShadowCaster" }

			ZWrite On ZTest LEqual

			CGPROGRAM
			#pragma target 3.0

			// shader tier
			#pragma shader_feature _SHADER_TIER_0
			#pragma shader_feature _SHADER_TIER_1
			#pragma shader_feature _SHADER_TIER_2

			// character vfx
			//#pragma shader_feature _ENABLE_DISSOLVE

			// -------------------------------------
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _METALLICGLOSSMAP
			#pragma shader_feature _PARALLAXMAP
			#pragma multi_compile_shadowcaster
			#pragma multi_compile_instancing
			// Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
			//#pragma multi_compile _ LOD_FADE_CROSSFADE

			#include "__PopcapSceneShadow.cginc"

			#pragma vertex vertShadow
			#pragma fragment fragShadow

			ENDCG
		}
		*/
	}
}
