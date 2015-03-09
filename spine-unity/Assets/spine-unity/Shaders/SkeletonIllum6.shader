Shader "Spine/Skeleton Illum6"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white" {}
		_IllumTex ("Texture to Illum", 2D) = "black" {}
		_AlphaColor ("Alpha Color", Color) = (1,1,1,1)
		_IllumStrength ("Illum Strength", Range(0,1)) = 1
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
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		#pragma surface surf Lambert  vertex:vert noforwardadd approxview halfasview alpha 

		fixed4 _Color;
		sampler2D _MainTex;
		sampler2D _IllumTex;
		uniform fixed4 _AlphaColor;
		float _IllumStrength;


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

		void surf (Input IN, inout SurfaceOutput o) 
		{
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex)*IN.color;
			fixed3 illumC = tex2D(_IllumTex, IN.uv_MainTex)* IN.color;
			fixed3 calC=c.rgb;
			//混合亮度底色
			calC = _AlphaColor.rgb*_AlphaColor.a+calC.rgb*(1-_AlphaColor.a);
			//相乘获得纹理色
			calC = calC.rgb*c.rgb*1.7;
			//盖上颜色
			calC =  _Color.rgb*_Color.a+calC.rgb*(1-_Color.a);
			//相加获得亮度
			calC = calC+illumC*_IllumStrength*1.5f;
			//素材漫反射颜色
			o.Albedo = calC.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}

//Fallback "Transparent/VertexLit"
}
