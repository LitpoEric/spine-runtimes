Shader "Spine/Skeleton Illum" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_Emission ("Emissive Color", Color) = (0,0,0,0)
		_Cutoff ("Shadow alpha cutoff", Range(0,1)) = 0.1
		_MainTex ("Texture to blend", 2D) = "black" {}
		_IllumTex ("Texture to Illum", 2D) = "black" {}
		_AlphaColor ("Main Color", Color) = (1,1,1,1)
	}
	// 2 texture stage GPUs
	SubShader {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		LOD 100

		Cull Off
		ZWrite Off
		Blend One OneMinusSrcAlpha

		Pass {
			Tags { "LightMode"="Vertex" }
			Material {
				Diffuse [_Color]
				Ambient [_Color]
				Emission [_Emission]	
			}
			Lighting On
			SetTexture [_MainTex] {
				constantColor [_AlphaColor]
				combine constant lerp (constant) previous ,texture*primary
			}
			SetTexture [_MainTex] {
				Combine texture  * previous  double,previous
			}
			SetTexture [_IllumTex] {
				Combine previous + texture  ,previous
			}
		}
	}
	// 1 texture stage GPUs
	SubShader {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
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
}