Shader "My2D/DaBaoJian"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Mask ("Mask", 2D) = "white" { }
		_Fire ("Fire", 2D) = "white" { }
		_Wave ("Wave", 2D) = "white" { }
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _Mask;
			sampler2D _Fire;  
			sampler2D _Wave;

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
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{				
				float4 result = float4(0,0,0,0);

				//====================================
				//============ mask ============   
				float2  maskUV = i.uv;
				float4 color_mask = tex2D(_Mask,maskUV);    

				//====================================
				//============ wave ============   
				float2  uv_uv4 = i.uv;
				float2 center_uv4 = float2(0.5,0.5);    
				uv_uv4 = uv_uv4-center_uv4;    
				uv_uv4 = uv_uv4+fixed2(-0.1855469,0)*(_Time.y);       
				uv_uv4 = uv_uv4/fixed2(0.6,0.6);       
				uv_uv4 = uv_uv4+center_uv4;    
				float4 color_uv4 = tex2D(_Wave,uv_uv4);
				//红色通道和绿色通道混合
				uv_uv4 = -(color_uv4.r*fixed2(0,0.140625) + color_uv4.g*fixed2(0.2324219,0) + color_uv4.b*fixed2(0,0) +  color_uv4.a*fixed2(0,0));    

				//====================================
				//============ fire ============   
				float2  uv_fire = i.uv;
				//!!  把遮罩的红色通道和绿色通道作为uv 
				uv_fire = color_mask.rg;
				//进行适配  偏移 缩放
				float2 center_fire = float2(0.5,0.5); 
				uv_fire = uv_fire-center_fire;	

				//小马驹		
				//uv_fire = uv_fire+fixed2(-0.1757813,0)*(_Time.y);    				   
				//uv_fire = uv_fire/fixed2(0.125,1);  
				//大宝剑    uv速度不一样
				uv_fire = uv_fire+fixed2(-0.06640625,0)*(_Time.y);        
				uv_fire = uv_fire/fixed2(0.5,1);  

				uv_fire = uv_fire+center_fire; 
				//添加扰动
				uv_fire = uv_fire + uv_uv4;

				//重复堆叠
				uv_fire = float2(uv_fire.x >0 ?(uv_fire.x%1) : 1 - abs(uv_fire.x)%1, uv_fire.y >0 ?(uv_fire.y%1) : 1 - abs(uv_fire.y)%1);
				
				float4 color_fire = tex2D(_Fire,uv_fire); 

				//只显示遮罩部分	
				color_fire = float4(color_fire.rgb,color_fire.a*color_mask.a);

				float4 color_ROOT = tex2D(_MainTex,i.uv);  
				result = color_ROOT;

				//lerp(a,b,f)  在a 和 b 之间进行权值f计算     clamp（x,a,b）   x小于a 返回a   x大于b 返回b
				result = lerp(result,float4(color_fire.rgb,1),clamp(color_fire.a,0,1));    

				return result;
			}
			ENDCG
		}
	}
}
