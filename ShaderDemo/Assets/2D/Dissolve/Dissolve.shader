Shader "My2D/Dissolve"
{
	Properties
	{
		[HDR]_Color_color3 ("Color color3", Color) = (3,2.769,1.569,1)
		[HDR]_Color_color4 ("Color color4", Color) = (3,0,0,1)
		_MainTex ("Texture", 2D) = "white" {}
		_Noise ("_Noise", 2D) = "white" { }
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

		GrabPass{ }
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
				float2  _uv_Screen : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color_color3;
			float4 _Color_color4;
			sampler2D _Noise;   
			sampler2D _wave;   
			float _pcg; 
			uniform sampler2D _GrabTexture;
			
			float GradientEvaluate(float _listTime[2],float _listValue[2],float count,float pcg)
			{
				if(count==0)
					return 0;
				if(pcg<_listTime[0])
					return 0;
				if(pcg>_listTime[count-1])
					return 0;

				for(int i= 0;i<=count;i++)
				{
					if(pcg <= _listTime[i+1])
					{
						float v1= _listValue[i];
						float v2= _listValue[i+1];
						float t1= _listTime[i];
						float t2= _listTime[i+1];
						return lerp(v1,v2, (pcg - t1) / (t2-t1));
					}
				}
				return 0;
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//#if UNITY_UV_STARTS_AT_TOP 可以用来判断我们是否是在 Direct3D 平台下。
				// 1 就是Direct3D  0 是 OpenGL
				
				//float4 _ProjectionParams;
				// x = 1 or -1 (-1 if projection is flipped)
				// y = near plane
				// z = far plane
				// w = 1/far plane

				#if UNITY_UV_STARTS_AT_TOP
					float grabSign = -_ProjectionParams.x;
				#else
					float grabSign = _ProjectionParams.x;
				#endif

				float4 wpos = o.vertex;
				//控制远近
				o._uv_Screen = wpos.xy / wpos.w;
				o._uv_Screen.y *= _ProjectionParams.x;
				o._uv_Screen = float2(1,grabSign)*o._uv_Screen*0.5+0.5;
				o.rect_Sprite = fixed4(0,0,1,1);
				#ifdef PIXELSNAP_ON
				o.vertex = UnityPixelSnap (o.pos);
				#endif
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 result = float4(0,0,0,0);

				//====================================
				//============ uv2 ============  
				float2 uv_uv2 = i.uv; 
				float2 center_uv2 = float2(0.5,0.5);    
				uv_uv2 = uv_uv2-center_uv2;   
				uv_uv2 = uv_uv2+fixed2(0,0.1171875)*(_Time.y);
				//uv_uv2 = uv_uv2/fixed2(0.1,0.1);        				  
				uv_uv2 = uv_uv2+center_uv2; 

				uv_uv2 = float2(uv_uv2.x >0 ?(uv_uv2.x%1) : 1 - abs(uv_uv2.x)%1, uv_uv2.y >0 ?(uv_uv2.y%1) : 1 - abs(uv_uv2.y)%1);
				bool discard_uv2 = false;
				if(uv_uv2.x>1 || uv_uv2.y>1)
					discard_uv2 = true;				

				float4 color_uv2 = tex2D(_Noise,uv_uv2); 
				if(discard_uv2 == true) color_uv2 = float4(0,0,0,0);
				uv_uv2 = -(color_uv2.r*fixed2(0,0.01) + color_uv2.g*fixed2(0.01,0) + color_uv2.b*fixed2(0,0) +  color_uv2.a*fixed2(0,0));

				//====================================
				//============ refract1 ============   
				float2  uv_refract1 = i._uv_Screen;
				uv_refract1 = uv_refract1 + uv_uv2 * (_pcg);

				uv_refract1 = float2(uv_refract1.x >0 ?(uv_refract1.x%1) : 1 - abs(uv_refract1.x)%1, uv_refract1.y >0 ?(uv_refract1.y%1) : 1 - abs(uv_refract1.y)%1);
				bool discard_refract1 = false;
				if(uv_refract1.x>1 || uv_refract1.y>1)
					discard_refract1 = true;
				float4 color_refract1 = tex2D(_GrabTexture,uv_refract1); 
				if(discard_refract1 == true) color_refract1 = float4(0,0,0,0);

				//====================================
				//============ color3 ============   
				float4 color_color3 = _Color_color3;

				//====================================
				//============ color4 ============   
				float4 color_color4 = _Color_color4;

				float2  uv_alpha5 = i.uv;
				uv_alpha5 = float2(uv_alpha5.x >0 ?uv_alpha5.x%1 : 1 - abs(uv_alpha5.x)%1, uv_alpha5.y >0 ?uv_alpha5.y%1 : 1 - abs(uv_alpha5.y)%1);
				bool discard_alpha5 = false;

				//uv_alpha5 = uv_alpha5/fixed2(6,6);

				if(uv_alpha5.x>1 || uv_alpha5.y>1)
					discard_alpha5 = true;
				float4 color_alpha5 = tex2D(_wave,uv_alpha5);    
				if(discard_alpha5 == true) color_alpha5 = float4(0,0,0,0);
				float aplha_alpha5 = 1 +-2*(_pcg) + color_alpha5.r;

				//====================================
				//============ mixer5 ============   
				float mixer_mixer5;
				mixer_mixer5 = clamp(aplha_alpha5,0,1);
				float gra_mixer5_0ListTime[2] = {0,0.2};
				//在1 - 1 之间插值  权值 pcg - 0.2 / 0.25 - 0.2
				float gra_mixer5_0ListValue[2] = {1,1};
				float gra_mixer5_0 = GradientEvaluate(gra_mixer5_0ListTime,gra_mixer5_0ListValue,2,mixer_mixer5);
				float gra_mixer5_1ListTime[2] = {0.2,0.25};
				//在1 - 0 之间插值  权值 pcg - 0.2 / 0.3 - 0.2
				float gra_mixer5_1ListValue[2] = {1,0};
				float gra_mixer5_1 = GradientEvaluate(gra_mixer5_1ListTime,gra_mixer5_1ListValue,2,mixer_mixer5);
				float gra_mixer5_2ListTime[2] = {0.2,0.3};
				//在0 - 1 之间插值 权值 pcg - 0.2 / 0.3 - 0.2
				float gra_mixer5_2ListValue[2] = {0,1};
				float gra_mixer5_2 = GradientEvaluate(gra_mixer5_2ListTime,gra_mixer5_2ListValue,2,mixer_mixer5);


				float2  uv_ROOT = i.uv;
				uv_ROOT = uv_ROOT + uv_uv2*(_pcg);
				float4 color_ROOT = tex2D(_MainTex,uv_ROOT);    
				color_ROOT.rgb*=color_ROOT.a;

				float4 rootTexColor = color_ROOT;
				result = float4(color_ROOT.rgb,color_ROOT.a);
				result = lerp(result,float4(color_color4.rgb,rootTexColor.a),clamp(color_color4.a*gra_mixer5_2,0,1));    
				result = lerp(result,float4(color_color3.rgb,rootTexColor.a),clamp(color_color3.a*gra_mixer5_1,0,1));    
				result = lerp(result,float4(color_refract1.rgb,rootTexColor.a),clamp(color_refract1.a*(_pcg*0.8)*gra_mixer5_0,0,1));    
				//result = float4(color_ROOT.rgb,aplha_alpha5) ;
				return result;
			}
			ENDCG
		}
	}
}
