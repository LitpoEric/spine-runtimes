Shader "Spine/Skeleton IllumGlow" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Texture to blend", 2D) = "black" {}
		_GlowTex ("Glow Texture", 2D) = "white" {}
		_IllumTex ("Texture to Illum", 2D) = "black" {}
		_AlphaColor ("AlphaColor", Color) = (1,1,1,1)
	}
	// 2 texture stage GPUs
	SubShader {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Glow"}
		LOD 100

		Cull Off
		ZWrite Off
		Blend SrcAlpha  OneMinusSrcAlpha

		Pass {
			Tags { "LightMode"="Vertex" }
			ColorMaterial AmbientAndDiffuse
			Material {
			}
			Lighting On
			//混合亮度底色
			SetTexture [_MainTex] {
				constantColor [_AlphaColor]
				combine constant lerp (constant) previous ,texture*primary
			}
			//相乘获得纹理色
			SetTexture [_MainTex] {
				Combine texture  * previous  double,previous
			}
			//盖上颜色
			SetTexture [_MainTex] {
				constantColor [_Color]
				combine constant lerp (constant) previous ,texture*primary
			}
			//相加获得亮度
			SetTexture [_IllumTex] {
				Combine previous + texture ,previous
			}

		}
	}
	// 1 texture stage GPUs
	SubShader {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Glow"  }
		LOD 100

		Cull Off
		ZWrite Off
		Blend One OneMinusSrcAlpha

		Pass {
			Tags { "LightMode"="Vertex" }
			ColorMaterial AmbientAndDiffuse
			Lighting On
			SetTexture [_MainTex] {
				Combine texture * primary DOUBLE, texture * primary
			}
		}
	}

	CustomEditor "GlowMaterialInspector"
}