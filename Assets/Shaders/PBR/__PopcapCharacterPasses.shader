Shader "Popcap/PBR/Character/__Passes" 
{
	SubShader
	{
		Pass
		{
			Name "STENCIL"
			ZWrite On
			ColorMask 0
		}

		Pass
		{
			Name "STENCIL_ENABLE_ICE"
			ZWrite On
			ColorMask 0

			CGPROGRAM
			#define _ENABLE_ICE

			#pragma vertex vert
			#pragma fragment frag

			#include "__PopcapCharacter.cginc"

			_VertexOutputForward vert(_VertexInput v) { return _vertForward(v); }
			half4 frag(_VertexOutputForward i) : SV_Target { return _fragForward(i); }

			ENDCG
		}
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
			#pragma shader_feature _SPECGLOSSMAP
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

			// Character VFX
			#pragma shader_feature _ENABLE_TANGENT_TO_WORLD
			#pragma shader_feature _ENABLE_SSS
			#pragma shader_feature _ENABLE_ICE
			#pragma shader_feature _ENABLE_FIRE
			#pragma shader_feature _ENABLE_SEMI_TRANSPARENCY
			#pragma shader_feature _ENABLE_MOSAIC
			#pragma shader_feature _ENABLE_RENDER_TARGET_TEXTURE
			#pragma shader_feature _ENABLE_SHADOW_WORLD_POSITION
			#pragma shader_feature _ENABLE_DISSOLVE
			#pragma shader_feature _ENABLE_ADVANCED_DISSOLVE
			#pragma shader_feature _ENABLE_MATCAP

			#pragma vertex vert
			#pragma fragment frag

			#include "__PopcapCharacter.cginc"
			
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
			Fog { Color(0,0,0,0) } // in additive pass fog should be black
			
			Blend[_SrcBlend] One
			ZWrite Off

			ZTest LEqual

			CGPROGRAM
			#pragma target 3.0

			// -------------------------------------

			#pragma shader_feature _NORMALMAP
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _SPECGLOSSMAP
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

			// Character VFX
			#pragma shader_feature _ENABLE_TANGENT_TO_WORLD
			#pragma shader_feature _ENABLE_SSS
			#pragma shader_feature _ENABLE_ICE
			#pragma shader_feature _ENABLE_FIRE
			#pragma shader_feature _ENABLE_SEMI_TRANSPARENCY
			#pragma shader_feature _ENABLE_MOSAIC
			#pragma shader_feature _ENABLE_RENDER_TARGET_TEXTURE
			#pragma shader_feature _ENABLE_SHADOW_WORLD_POSITION
			#pragma shader_feature _ENABLE_DISSOLVE
			#pragma shader_feature _ENABLE_ADVANCED_DISSOLVE
			#pragma shader_feature _ENABLE_MATCAP

			#pragma vertex vertAdd
			#pragma fragment fragAdd

			#include "__PopcapCharacter.cginc"

			_VertexOutputForwardAdd vertAdd(_VertexInput v) { return _vertForwardAdd(v); }
			half4 fragAdd(_VertexOutputForwardAdd i) : SV_Target { return _fragForwardAdd(i); }

			ENDCG
		}
		
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
			#pragma shader_feature _ENABLE_MOSAIC
			#pragma shader_feature _ENABLE_DISSOLVE
			#pragma shader_feature _ENABLE_ADVANCED_DISSOLVE
			#pragma shader_feature _ENABLE_RENDER_TARGET_TEXTURE
			#pragma shader_feature _ENABLE_SHADOW_WORLD_POSITION

			// -------------------------------------
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _METALLICGLOSSMAP
			#pragma shader_feature _PARALLAXMAP
			#pragma multi_compile_shadowcaster
			#pragma multi_compile_instancing
			// Uncomment the following line to enable dithering LOD crossfade. Note: there are more in the file to uncomment for other passes.
			//#pragma multi_compile _ LOD_FADE_CROSSFADE

			#include "__PopcapCharacterShadow.cginc"

			#pragma vertex vertShadow
			#pragma fragment fragShadow

			ENDCG
			
		}

		Pass
		{
			// pass 0 for down sample
			Name "DOWN_SAMPLE"

			//ZTest Off Cull Off
			CGPROGRAM
			#include "__PopcapCharacter.cginc"
			#pragma vertex vert_DownSample
			#pragma fragment frag_DownSample
			ENDCG
		}

		Pass
		{
			// pass 1 for vertical blur
			Name "VERTICAL_BLUR"

			CGPROGRAM
			#include "__PopcapCharacter.cginc"
			#pragma vertex vert_BlurVertical
			#pragma fragment frag_BlurVertical

			ENDCG
		}

		Pass
		{
			// pass 2 for horizontal blur
			NAME "HORIZONTAL_BLUR"

			CGPROGRAM
			#include "__PopcapCharacter.cginc"
			#pragma vertex vert_BlurHorizontal
			#pragma fragment frag_BlurHorizontal

			ENDCG
		}

		Pass
		{
			Name "FORWARD_ENABLE_ICE"
			Tags { "LightMode" = "ForwardBase" }

			//Blend[_SrcBlend][_DstBlend]
			//ZWrite[_ZWrite]

			Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }

			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off

			CGPROGRAM

			#pragma target 3.0
			#define _ENABLE_ICE
			#define _ALPHATEST_ON 0
			#define _ALPHABLEND_ON 1
			#define _ALPHAPREMULTIPLY_ON 0

			// -------------------------------------
			#pragma shader_feature _NORMALMAP
			#pragma shader_feature _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
			#pragma shader_feature _EMISSION
			#pragma shader_feature _SPECGLOSSMAP
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

			#include "__PopcapCharacter.cginc"

			_VertexOutputForward vert(_VertexInput v) { return _vertForward(v); }
			half4 frag(_VertexOutputForward i) : SV_Target { return _fragForward(i); }

			ENDCG
		}
	}
}
