Shader "My2D/XuanWo"
{
	Properties
	{
		_code3_value ("code3_value", Range(0,3600)) = 0
		_code3_posx ("code3_posx", Range(0,1)) = 0.5
		_code3_posy ("code3_posy", Range(0,1)) = 0.5
		_code3_radius ("code3_radius", Range(0,1)) = 0.5
		_MainTex ("Texture", 2D) = "white" {}
		_wave ("_wave", 2D) = "white" { }
		_pcg ("_pcg", Range(0,1)) = 0
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
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
				float4  rect_Sprite : COLOR1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _code3_value;
			float _code3_posx;
			float _code3_posy;
			float _code3_radius;
			sampler2D _wave;   
			float _pcg; 

			float2 Vortex( float2 uv , float value , float posx , float posy , float radius )
			{
				// 0 - 3600
				value = value / (180/3.141592653);
				//以哪里为中心
				uv -= float2(posx,posy);
				//圆心角度数 = 弧长 /半径(得到弧度) * (180 /PI);
				//弧度 = 圆心角度数 / (180 /PI);
				
				//进行多次旋转控制
				float angle = 1.0 - length(uv / radius);
				angle = max (0, angle);
				angle = angle * angle * value;
				//float angle = value;
				float cosLength, sinLength;
				sincos (angle, sinLength, cosLength);
				
				float2 _uv;
				_uv.x = cosLength * uv[0] - sinLength * uv[1];
				_uv.y = sinLength * uv[0] + cosLength * uv[1];
				_uv += float2(posx,posy);
				return _uv;
			}
			float OneMinus( float a )
			{
				return 1-a;
			}
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.rect_Sprite = float4(0,0,1,1);
				#ifdef PIXELSNAP_ON
				o.pos = UnityPixelSnap (o.pos);
				#endif
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//====================================
				//============ uv6 ============   
				float2  uv_uv6 = i.uv;
				float2 center_uv6 = float2(0.5,0.5);    
				uv_uv6 = uv_uv6-center_uv6;        
				uv_uv6 = uv_uv6+fixed2(0,-0.06933594)*(_Time.y);      
				uv_uv6 = uv_uv6/fixed2(0.3,0.3);     
				uv_uv6 = uv_uv6+center_uv6;   
				 
				float2 uv_uv6orgin = uv_uv6;
				uv_uv6 = float2(uv_uv6.x >0 ?(uv_uv6.x%(1+0)) : (1+0) - abs(uv_uv6.x)%(1+0), uv_uv6.y >0 ?(uv_uv6.y%(1+0)) : (1+0) - abs(uv_uv6.y)%(1+0));
				bool discard_uv6 = false;
				if(uv_uv6.x>1 || uv_uv6.y>1)
					discard_uv6 = true;
				float4 rect_uv6 =  float4(1,1,1,1);
				float4 color_uv6 = tex2D(_wave,uv_uv6);    
				if(discard_uv6 == true) color_uv6 = float4(0,0,0,0);
				uv_uv6 = -(color_uv6.r*fixed2(-0.03417969,0.03417969) + color_uv6.g*fixed2(0.02441406,0.03808594) + color_uv6.b*fixed2(0,0) +  color_uv6.a*fixed2(0,0));    

				//====================================
				//============ code3 ============   
				float2 v_code3 = float2(0,0);
				v_code3 = Vortex(i.uv,_code3_value,_code3_posx,_code3_posy,_code3_radius);

				//====================================
				//============ code5 ============   
				float v_code5 = 0;
				v_code5 = OneMinus(_pcg);

				float2  uv_ROOT = i.uv;
				uv_ROOT = lerp(uv_ROOT,v_code3,1);
				uv_ROOT = uv_ROOT + uv_uv6*((clamp(_pcg*5,0,1)));
				fixed4 col = tex2D(_MainTex, uv_ROOT);
				col.rgb *= col.a;
				col = float4(col.rgb,col.a* lerp(1,clamp(v_code5,0,1),1));    
				//col = float4(col.rgb,col.a* lerp(1,clamp(v_code5*1*((1)),0,1),1*((1))));    
				return col;
			}
			ENDCG
		}
	}
}
