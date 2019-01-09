#include "__PopcapVFXInput.cginc"

////////////////////////////////////////////////////////////////////////////////////
// Shader Lod 0 Start
////////////////////////////////////////////////////////////////////////////////////

sampler2D _MainTex;
half4 _MainTex_ST;

_VertexOutput _vert (_VertexInput v)
{
    _VertexOutput o;

	UNITY_SETUP_INSTANCE_ID(v);

    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	o.color = v.color;

    //UNITY_TRANSFER_FOG(o,o.pos);

    return o;
}

half4 _vertexColor(half4 color)
{
	half4 vertexColor = color;
#ifdef UNITY_COLORSPACE_GAMMA
	//Do nothing
#else
	vertexColor.rgb = GammaToLinearSpace(vertexColor.rgb);
#endif
	return vertexColor;
}

half4 _baseColor(_VertexOutput i)
{
	half4 col = _vertexColor(i.color) * tex2D(_MainTex, i.uv);
	//UNITY_APPLY_FOG(i.fogCoord, col);
	return col;
}

half4 _fragBlended(_VertexOutput i) : SV_Target
{
	half4 col = _baseColor(i);
    return col;
}

half4 _fragAdditive(_VertexOutput i) : SV_Target
{
	half4 col = 2.0 * _baseColor(i);
	col.a = saturate(col.a);

	return col;
}

half _SpeedX;
half _SpeedY;

half4 _baseColorWithAnim(_VertexOutput i)
{
	half x = frac(_SpeedX * _Time);
	half y = frac(_SpeedY * _Time);

	half2 uv = i.uv;
	uv.x += x;
	uv.y += y;

	half4 col = _vertexColor(i.color) * tex2D(_MainTex, uv);
	//UNITY_APPLY_FOG(i.fogCoord, col);
	return col;
}

half4 _fragBlendedWithAnim(_VertexOutput i) : SV_Target
{
	half4 col = _baseColorWithAnim(i);
	return col;
}

half4 _fragAdditiveWithAnim(_VertexOutput i) : SV_Target
{
	half4 col = 2.0 * _baseColorWithAnim(i);
	col.a = saturate(col.a);

	return col;
}

sampler2D _NoiseTex;
half4 _EdgeColor;
half _Value;

half4 _fragDissolve(_VertexOutput i) : SV_Target
{
	half4 col = _baseColor(i);

	half melt = saturate(tex2D(_NoiseTex, i.uv).r * 8.0 - 8.0 + _Value * 9.0);
	melt = melt * melt;

	col.a = saturate(melt * 2.0 - 1.0);

	half4 edge = _EdgeColor;
	edge.a = 1.0 - abs(melt * 2.0 - 1.0);

	col.rgb = col.rgb * col.a + edge.rgb * edge.a * 2.0;
	col.a = saturate(edge.a + col.a);

	return col;
}

_VertexOutput _vertDistortion(_VertexInput v)
{
	_VertexOutput o;

	UNITY_SETUP_INSTANCE_ID(v);

	o.pos = UnityObjectToClipPos(v.vertex);
	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	o.color = v.color;

#ifdef USING_RENTER_TARGET_TEXTURE
	o.customRT = ComputeGrabScreenPos(o.pos);
#endif
	//UNITY_TRANSFER_FOG(o,o.pos);

	return o;
}

sampler2D _GrabScreenRenderTexture;
half4 _fragDistortion(_VertexOutput i) : SV_Target
{
#ifdef USING_RENTER_TARGET_TEXTURE
	half4 uv = i.customRT;

	half2 _uv = i.uv * 2.0f - 1.0f;
	_uv = _uv * _uv;
	
	half mask = saturate(pow(_uv.x + _uv.y, 0.5f));

	half noise = 1.0f - tex2D(_NoiseTex, i.uv).r * (1.0f - mask);

	uv.w *= lerp(1.0 - _Value, 1.0, noise);
	
	half4 distortColor = tex2Dproj(_GrabScreenRenderTexture, uv);
	half4 color = half4(distortColor.rgb, 1.0);
	return color;
#else
	return 0;
#endif
}


