Shader "Spine/Skeleton Illum4"
{
	Properties
	{
		_MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		_IllumTex ("Texture to Illum", 2D) = "black" {}
		_NoiseTex ("Texture to Noise", 2D) = "black" {}
//		_AlphaColor ("Alpha Color", Color) = (1,1,1,1)
		_IllumStrength ("Illum Strength", Range(0,1)) = 1
		_LightStrngth ("Light Strength", Range(0,1)) = 1
		_DensityX ("_DensityX Slider",Range(100,1000))=1
		_DensityY ("_DensityY Slider",Range(100,1000))=1
		_GlitchX ("_GlitchX Slider",Range(0,0.02))=1
		_GlitchY ("_GlitchY Slider",Range(0,0.02))=1
		_ChromaX ("_ChromaX Slider",Range(-0.02,0.02))=1
		_ChromaY ("_ChromaY Slider",Range(0,0.02))=1
		_uTime ("_uTime Slider",Range(0,1000))=0
		uIntensity ("uIntensity Slider",Range(0,10))=0
		uInvert ("uInvert Slider",Range(0,1))=0
		uBrightness ("uBrightness Slider",Range(0,1))=0
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Fog { Mode Off }
		Blend One OneMinusSrcAlpha

		CGPROGRAM
		#pragma surface surf SimpleLambert  vertex:vert noforwardadd approxview halfasview alpha 
		#pragma target 3.0
		fixed4 _Color;
		sampler2D _IllumTex;
 	 	half4 LightingSimpleLambert (SurfaceOutput s, half3 lightDir, half atten) {
          	half NdotL = dot (s.Normal, lightDir);
          	//灯光色
          	half4 c;
          	c.rgb = s.Albedo * _LightColor0.rgb * (NdotL * atten * 2);
          	c.a = s.Alpha;
          	return c;
      	}

		sampler2D _MainTex;
		fixed4 _AlphaColor;
		float _IllumStrength;

		//特效数据
		sampler2D _NoiseTex;
		float _DensityX;
		float _DensityY;
		float _ChromaX;
		float _ChromaY;
		float _GlitchX;
		float _GlitchY;
		float _uTime;
		float uInvert;
		float uIntensity;
		float uBrightness;
		float uSqueeze;

		struct Input
		{
			float2 uv_MainTex;
			fixed4 color;
		};
		
		void vert (inout appdata_full v, out Input o)
		{
			v.normal = float3(0,0,-1);
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.color.rgb = v.color.rgb ;
			o.color.a=v.color.a;
		}

		//# luminance
		float luminance(fixed3 c) {
		    return c.r * 0.299 + c.g * 0.587 + c.b * 0.114;
		}

		//# brightness
		float brightness(fixed3 c) {
		    return c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722;
		}

		//# whiteNoise
		float whiteNoise(float2 uv, float scale) {
			// from Three.js / film shader
			float x = (uv.x + 0.2) * (uv.y + 0.2) * (10000.0 + _uTime);
			x = mod( x, 13.0 ) * mod( x, 123.0 );
			float dx = mod( x, 0.005 );
			return clamp( 0.1 + dx * 100.0, 0.0, 1.0 ) * scale;
		}

		//# pixelate
		float2 pixelate(float2 coord, float2 density) 
		{
			coord.x = floor(coord.x * density.x) / density.x;
			coord.y = floor(coord.y * density.y) / density.y;
			return coord;
		}

		void surf (Input IN, inout SurfaceOutput o) 
		{
			//from http://district13.co.in/glsl/basic.glsl district13 shader
			//准备数据
			float2 texCoord=IN.uv_MainTex;

			float2 uDensity=float2(_DensityX,_DensityY);

			float2 uGlitch=float2(_GlitchX,_GlitchY);

			float2 uChroma=float2(_ChromaX,_ChromaY);

			sampler2D uCanvas=_MainTex;
			//数据准备完毕

			//解析度
			float2 pixTexCoord = pixelate(texCoord,uDensity);
			float3 color = tex2D(_MainTex, pixTexCoord).rgb * 0.66;

			float offset = luminance(color);

   			texCoord = texCoord + float2(offset * uGlitch.x , offset * uGlitch.y);  //无dist,dist调用了鼠标位置

			float noise = whiteNoise(texCoord,1.0);
			//偏色
			fixed4 cr = tex2D(uCanvas, texCoord + float2(offset *  uChroma.x, offset * -uChroma.y)); 
			fixed4 cg = tex2D(uCanvas, texCoord); 
			fixed4 cb = tex2D(uCanvas, texCoord + float2(offset * -uChroma.x, offset *  uChroma.y)); 

			float cl = (abs(uChroma.x) + abs(uChroma.y)) * 10.0;
			cl = step(0.0, cl) * 0.4;

			fixed3 canvas_rgb = fixed3(cr.r * cr.a, cg.g * cg.a, cb.b * cb.a);
			fixed3 canvas_grey = fixed3(luminance(canvas_rgb));

			canvas_rgb = lerp(canvas_rgb, canvas_grey, cl);

			fixed3 invert_rgb = fixed3(1.0) - canvas_rgb;
			invert_rgb = fixed3(luminance(invert_rgb));
			invert_rgb *= noise;

			canvas_rgb = mix(canvas_rgb, invert_rgb, uInvert);

			fixed3 gather = (color * noise * uIntensity + canvas_rgb) * uBrightness;

 	 		//发光色
			//half4 illum = tex2D(_IllumTex, IN.uv_MainTex)* IN.color;
			//o.Emission=illum.rgb*_IllumStrength;
			//素材漫反射颜色
			fixed4 c = IN.color;
			c.a=tex2D(uCanvas, pixTexCoord).a;
			c.rgb=gather;
			c.rgb=c.rgb*(1-_AlphaColor.a)+_AlphaColor.rgb*_AlphaColor.a;
			o.Albedo = c.rgb * c.a;
			o.Alpha = c.a; 
		}
		ENDCG
	}

	

//Fallback "Transparent/VertexLit"
}
