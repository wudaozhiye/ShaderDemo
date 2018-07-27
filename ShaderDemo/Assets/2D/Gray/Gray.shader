Shader "My2D/Gray"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_code1_rate ("code1_rate", Range(0,1)) = 1
	}
	SubShader
	{
		Tags { "Queue"="Transparent"
			"RenderType"="Transparent"
			"IgnoreProjector"="True" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True" }

		Pass
		{
			Cull Off
			Lighting Off
			ZWrite Off
			Blend SrcAlpha  OneMinusSrcAlpha 
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _code1_rate;

			float4 Grayscale( float4 color , float rate )
			{
				//Luminance Unity内置函数
				fixed gray = Luminance(color.rgb);
				return lerp(color, float4(gray,gray,gray,color.a),rate);
			}
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				
				//====================================
				//============ code1 ============   
				float4 v_code1 = float4(0,0,0,0);
				v_code1 = Grayscale(col,_code1_rate);

				return v_code1;
			}
			ENDCG
		}
	}
}
