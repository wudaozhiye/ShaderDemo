Shader "My2D/DotFadeOut"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_dots ("_dots", 2D) = "white" { }
		_Noise ("_Noise", 2D) = "white" { }
		finalAlphaBlend ("finalAlphaBlend", Range(0,1)) = 0
	}
	SubShader
	{
		Tags {
			"Queue"="Transparent"
			"RenderType"="Transparent"
			"IgnoreProjector"="True" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"}

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
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _dots;   
			sampler2D _Noise;   
			float finalAlphaBlend; 
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{

				//====================================
				//============ uv8 ============   
				float2  uv_uv8 = i.uv;
				float2 center_uv8 = float2(0.5,0.5);    
				uv_uv8 = uv_uv8-center_uv8;    
				uv_uv8 = uv_uv8+fixed2(0,-4.172325E-07);    
				uv_uv8 = uv_uv8+fixed2(0,-0.08859903)*(_Time.y);    
   
				uv_uv8 = uv_uv8/fixed2(0.5175781,0.68827);    
  
				uv_uv8 = uv_uv8+center_uv8;    
				float2 uv_uv8orgin = uv_uv8;
				uv_uv8 = float2(uv_uv8.x >0 ?(uv_uv8.x%(1+0)) : (1+0) - abs(uv_uv8.x)%(1+0), uv_uv8.y >0 ?(uv_uv8.y%(1+0)) : (1+0) - abs(uv_uv8.y)%(1+0));
				bool discard_uv8 = false;
				if(uv_uv8.x>1 || uv_uv8.y>1)
					discard_uv8 = true;
				float4 rect_uv8 =  float4(1,1,1,1);
				float4 color_uv8 = tex2D(_Noise,uv_uv8);    
				if(discard_uv8 == true) color_uv8 = float4(0,0,0,0);
				uv_uv8 = -(color_uv8.r*fixed2(-0.07226563,0.1367182) + color_uv8.g*fixed2(0.03125,0.1152338) + color_uv8.b*fixed2(0,0) +  color_uv8.a*fixed2(0,0.001952708));    


				//====================================
				//============ alpha7 ============   
				float2  uv_alpha7 = i.uv;
				float2 center_alpha7 = float2(0.5,0.5);    
				uv_alpha7 = uv_alpha7-center_alpha7;    
  
				uv_alpha7 = uv_alpha7/fixed2(0.1,0.1);    
 
				uv_alpha7 = uv_alpha7+center_alpha7;    
				uv_alpha7 = uv_alpha7 + uv_uv8*1*((1));
				float2 uv_alpha7orgin = uv_alpha7;
				uv_alpha7 = float2(uv_alpha7.x >0 ?(uv_alpha7.x%(1+0)) : (1+0) - abs(uv_alpha7.x)%(1+0), uv_alpha7.y >0 ?(uv_alpha7.y%(1+0)) : (1+0) - abs(uv_alpha7.y)%(1+0));
				bool discard_alpha7 = false;
				if(uv_alpha7.x>1 || uv_alpha7.y>1)
					discard_alpha7 = true;
				float4 rect_alpha7 =  float4(1,1,1,1);
				float4 color_alpha7 = tex2D(_dots,uv_alpha7);    
				if(discard_alpha7 == true) color_alpha7 = float4(0,0,0,0);
				float aplha_alpha7 = 1 +-2*(finalAlphaBlend) + color_alpha7.a;

			
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb *= col.a;
				float4 result = float4(col.rgb,col.a);
				result = float4(result.rgb,result.a* lerp(1,clamp(aplha_alpha7,0,1),1));    
				return result;
			}
			ENDCG
		}
	}
}
