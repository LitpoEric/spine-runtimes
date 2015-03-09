Shader "Spine/Skeleton Illum2Glow"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Main Texture", 2D) = "white" {}
		_GlowTex ("Glow Texture", 2D) = "black" {}
		_AlphaColor ("Alpha Color", Color) = (1,1,1,1)
		_IllumStrength ("Illum Strength", Range(0,1)) = 1
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Glow" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Fog { Mode Off }
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
		//选项见http://docs.unity3d.com/Manual/SL-SurfaceShaders.html
		#pragma surface surf Lambert  vertex:vert noforwardadd approxview halfasview alpha
		fixed4 _Color;
		sampler2D _MainTex;
		sampler2D _GlowTex;
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
			fixed4 c=  tex2D(_MainTex, IN.uv_MainTex);
			//混合顶点颜色
			
			fixed3 illumC = tex2D(_GlowTex, IN.uv_MainTex)* IN.color;
			fixed3 calC=c.rgb;
			//混合亮度底色
			calC = _AlphaColor.rgb*_AlphaColor.a+calC.rgb*(1-_AlphaColor.a);
			//相乘获得纹理色
			calC = calC.rgb*c.rgb*1.5;
			//盖上颜色
			calC =  _Color.rgb*_Color.a+calC.rgb*(1-_Color.a);
			//调整发光亮度
			illumC=illumC*0.75f;//_IllumStrength

			//混合顶点颜色
			illumC.rgb=illumC.rgb*(1-IN.color.a)+IN.color.rgb*IN.color.a;
			
			////混合顶点颜色
			//calC.rgb=calC.rgb*(1-IN.color.a)+IN.color.rgb*IN.color.a;
			illumC =illumC.rgb*(1-IN.color.a)+IN.color.rgb*IN.color.a;
			
			//相加获得亮度
			o.Emission = illumC*0.75f;
			//素材漫反射颜色
			o.Albedo = calC.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}

	CustomEditor "GlowMaterialInspector"
//Fallback "Transparent/VertexLit"
}
