Shader "My2D/ZheZhao"
{
	Properties
	{
		//整体颜色
		_Color ("Color", Color) = (1,1,1,1)
		//卡牌颜色(不包括特效小部分)
		_Color_ROOT ("Color ROOT", Color) = (1,1,1,1)
		//背景颜色
		_Color_image9 ("Color image9", Color) = (0.9117647,0.9117647,0.9117647,1)

		_MainTex ("Texture", 2D) = "white" {}
		//遮罩
		_arrow_mask0 ("_arrow_mask0", 2D) = "white" { }
		//背景
		_sky ("_sky", 2D) = "white" { }
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType"="Transparent" }
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
				float4 color : COLOR;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			float4 _Color_ROOT;
			float4 _Color_image9;

			sampler2D _arrow_mask0;
			sampler2D _sky;  

			float2 UV_RotateAround(float2 center,float2 uv,float rad)
			{
				float2 fuv = uv - center;
				float2x2 ma = float2x2(cos(rad),sin(rad),
										-sin(rad),cos(rad));
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
				float4 color_arrow_mask0 = tex2D(_arrow_mask0,i.uv);
				float4 result = float4(0,0,0,0);

				//====================================
				//============ image9 ============   
				float2  uv_image9 = i.uv;
				float2 center_image9 = float2(0.5,0.5); 
				uv_image9 = uv_image9-center_image9;
				//调整背景位置
				uv_image9 = uv_image9+fixed2(0.02929688,-0.2050781); 
				uv_image9 = uv_image9+fixed2(0,0)*(_Time.y);    
				//设置背景重复铺设大小   
				uv_image9 = uv_image9/fixed2(0.7,0.4);
				uv_image9 = uv_image9+center_image9;  
				float4 color_image9 = tex2D(_sky,uv_image9);    
				color_image9 = color_image9*_Color_image9;
 
 
				float4 color_ROOT = tex2D(_MainTex,i.uv);  
				color_ROOT = color_ROOT*_Color_ROOT;
				result = color_ROOT;

				//lerp(a,b,f)  在a 和 b 之间进行权值f计算     clamp（x,a,b）   x小于a 返回a   x大于b 返回b
				result = lerp(result,float4(color_image9.rgb,1),clamp(color_image9.a*color_arrow_mask0.r,0,1));    
				result = result * i.color;
				return result;
			}
			ENDCG
		}
	}
}
