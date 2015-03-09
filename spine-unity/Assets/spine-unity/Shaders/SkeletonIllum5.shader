Shader "Spine/Skeleton Illum5"
{
	Properties
	{
		_MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		_IllumTex ("Texture to Illum", 2D) = "black" {}
		_AlphaColor ("Alpha Color", Color) = (1,1,1,1)
		_IllumStrength ("Illum Strength", Range(0,1)) = 1
		_LightStrngth ("Light Strength", Range(0,1)) = 1
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
 	 		//发光色
			half4 illum = tex2D(_IllumTex, IN.uv_MainTex)* IN.color;
			o.Emission=illum.rgb*_IllumStrength;
			//素材漫反射颜色
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex)*IN.color;
			fixed3 c2=lerp(c.rgb,_AlphaColor.rgb*2,_AlphaColor.a);
		    float judge=illum.r+illum.g+illum.b;
			c.rgb=judge>0.5f?illum.rgb:c.rgb;
			c.rgb=c.rgb*c2;
			o.Albedo = c.rgb * c.a ;
			o.Alpha = c.a;
		}
		ENDCG
	}

//Fallback "Transparent/VertexLit"
}
