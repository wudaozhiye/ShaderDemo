Shader "My2D/SpriteLightSurface" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("_MainTex", 2D) = "white" {}		
	}
	SubShader {
		Tags { "Queue"="Transparent"
			"RenderType"="Transparent"
			"IgnoreProjector"="True" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True" }

			Cull Off
			Lighting Off
			ZWrite Off
			Blend SrcAlpha  OneMinusSrcAlpha   

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Lambert vertex:vert nofog nolightmap nodynlightmap keepalpha noinstancing		

		float4 _MainTex_ST;
		sampler2D _MainTex;
		fixed4 _Color;

		struct Input {
			fixed4  color;
			float2 _uv_MainTex;
		};

		void vert (inout appdata_full IN, out Input OUT)
			{
				UNITY_INITIALIZE_OUTPUT(Input,OUT);
				OUT._uv_MainTex = TRANSFORM_TEX(IN.texcoord,_MainTex);
				OUT.color = IN.color * _Color;
				
			}
		void surf (Input IN, inout SurfaceOutput o) {
			
			fixed4 result = fixed4(0,0,0,0);

			fixed4 c = tex2D (_MainTex, IN._uv_MainTex);
			c.rgb *= c.a;
			c = c * _Color;
			result = c;
			result = result*IN.color;

			o.Albedo = result.rgb;
			o.Alpha = result.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
