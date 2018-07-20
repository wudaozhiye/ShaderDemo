Shader "My2D/MaskUVMove"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RampTex ("Ramp", 2D) = "white" {}
		_MaskTex ("Mask", 2D) = "white" {}

		_Color("Color",Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				fixed4 color : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _RampTex;
			sampler2D _MaskTex;

			fixed4 _Color;

			float2 UV_RotateAround(float2 center,float2 uv,float rad)
			{
				float2 fuv = uv - center;
				float2x2 ma = float2x2(cos(rad),sin(rad),-sin(rad),cos(rad));
				fuv = mul(ma,fuv)+center;
				return fuv;
			}
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.color = v.color * _Color;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 result = fixed4(0,0,0,0);

				 float2 rampUV  = i.uv;
				 float2 center_ramp = float2(0.5,0.5);    
				 rampUV = rampUV - center_ramp;
				//用shader weaver 计算
				rampUV = rampUV+fixed2(0,1.192093E-07);    
				rampUV = rampUV+fixed2(-0.1503906,2.045943E-08)*(_Time.y);    
				rampUV = UV_RotateAround(fixed2(0,0),rampUV,1.371521);    
				rampUV = rampUV/fixed2(1,0.9726894);  

				 rampUV = rampUV + center_ramp;
				 fixed4 color_image2 = tex2D(_RampTex,rampUV); 

				 fixed4 color_mask = tex2D(_MaskTex,i.uv);

				fixed4 col = tex2D(_MainTex, i.uv);
				result = col * i.color;
				result = lerp(result,float4(color_image2.rgb,1),clamp(color_image2.a*color_mask.r,0,1));    

				return result;
			}
			ENDCG
		}
	}
}
