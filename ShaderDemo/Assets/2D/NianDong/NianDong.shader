Shader "My2D/NianDong"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_code1_value ("code1_value", Range(0,360)) = 90
		_code1_posx ("code1_posx", Range(0,1)) = 0.5
		_code1_posy ("code1_posy", Range(0,1)) = 0.5
		_code1_radius ("code1_radius", Range(0,1)) = 0.5
	}
	SubShader
	{
		Tags { 	"Queue"="Transparent"
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
			#pragma multi_compile _ PIXELSNAP_ON
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _code1_value;
			float _code1_posx;
			float _code1_posy;
			float _code1_radius;

			float2 UV_RotateAround(float2 center,float2 uv,float rad)
			{
				float2 fuv = uv - center;
				float2x2 ma = float2x2(cos(rad),sin(rad),-sin(rad),cos(rad));
				fuv = mul(ma,fuv)+center;
				return fuv;
			}
			
			float2 Twirl( float2 uv , float value , float posx , float posy , float radius )
			{
				value = value / (180/3.141592653);
				uv -= float2(posx,posy);
				//以中心点float2(0,0)  旋转
				float2 distortedOffset = UV_RotateAround(float2(0,0),uv,value);

				float2 tmp = uv / radius;
				float t = min (1, length(tmp));
				uv = lerp (distortedOffset, uv, t);

				uv += float2(posx,posy);
				return uv;
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float2 v_code1 = float2(0,0);
				v_code1 = Twirl(i.uv,_code1_value,_code1_posx,_code1_posy,_code1_radius);
				// sample the texture
				fixed4 col = tex2D(_MainTex, v_code1);
				
				return col;
			}
			ENDCG
		}
	}
}
