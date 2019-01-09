#include "UnityCG.cginc"
#include "AutoLight.cginc"

sampler2D _MainTex;
sampler2D _NormalTex;
sampler2D _NoiseTex;

struct Input 
{
	float2 uv_MainTex;
	float3 worldRefl;
	fixed3 viewDir;
	fixed alpha;
};

half _Glossiness;
half _Metallic;
fixed4 _Color;

half _MaxLength;
half _FadeOut;
half _Thickness;

// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
// #pragma instancing_options assumeuniformscaling
UNITY_INSTANCING_BUFFER_START(Props)
	// put more per-instance properties here
UNITY_INSTANCING_BUFFER_END(Props)

void surf (Input IN, inout SurfaceOutputStandard o) 
{
	// Albedo comes from a texture tinted by color
	fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
	o.Albedo = c.rgb;
	
	fixed4 noise = tex2D (_NoiseTex, IN.uv_MainTex * _Thickness);
	half t = saturate(noise.r / NOISEFACTOR);

	// Metallic and smoothness come from slider variables
	o.Metallic = _Metallic;
	o.Smoothness = _Glossiness * t;

	
	o.Alpha = c.a * IN.alpha * t;

	// Normal comes form a texture
	o.Normal = UnpackNormal(tex2D(_NormalTex, IN.uv_MainTex));
}

void vert (inout appdata_full v, out Input o) 
{
	UNITY_INITIALIZE_OUTPUT(Input,o);
		
	float length = _MaxLength * CURRENTLAYER;
	v.vertex.xyz += v.normal * length;
				
	o.alpha = 1 - (CURRENTLAYER * CURRENTLAYER);	
	float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
	o.alpha += dot(viewDir, v.normal) - _FadeOut;

	o.alpha = clamp(o.alpha, 0, 1);
}			