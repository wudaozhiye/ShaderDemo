Shader "My2D/ZheShe"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_water ("_water", 2D) = "white" { }
		_refract ("_refract", Range(0,1)) = 0
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
			sampler2D _water;   
			float _refract; 
			uniform sampler2D _GrabTexture;
			
			float4 Blur(sampler2D sam,float2 _uv,float2 offset,float4 rect,bool isSpriteTex)
			{
			    int num =12;
				float2 divi[12] = {float2(-0.326212f, -0.40581f),

				float2(-0.840144f, -0.07358f),

				float2(-0.695914f, 0.457137f),

				float2(-0.203345f, 0.620716f),

				float2(0.96234f, -0.194983f),

				float2(0.473434f, -0.480026f),

				float2(0.519456f, 0.767022f),

				float2(0.185461f, -0.893124f),

				float2(0.507431f, 0.064425f),

				float2(0.89642f, 0.412458f),

				float2(-0.32194f, -0.932615f),

				float2(-0.791559f, -0.59771f)};
				float4 col = float4(0,0,0,0);



				for(int i=0;i<num;i++)
				{
					float2 uv = _uv+ offset*divi[i];
					uv = float2(clamp(uv.x,rect.x,rect.x+rect.z),clamp(uv.y,rect.y,rect.y+rect.w));
					float4 c = tex2D(sam,uv);
					if(isSpriteTex)
						c.rgb*=c.a;
					col += c;
				}
				col /= num;
				return col;
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
				o.vertex = UnityPixelSnap (OUT.pos);
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
				uv_uv2 = uv_uv2+fixed2(0,0.7890625)*(_Time.y);  
				uv_uv2 = uv_uv2/fixed2(3,3);    
				uv_uv2 = uv_uv2+center_uv2; 
				float4 color_uv2 = tex2D(_water,uv_uv2); 
				uv_uv2 = -(color_uv2.r*fixed2(0,0.08789063) + color_uv2.g*fixed2(0.06640625,0) + color_uv2.b*fixed2(0,0) +  color_uv2.a*fixed2(0,0));    

				//====================================
				//============ refract1 ============   
				float2  uv_refract1 = i._uv_Screen;
				uv_refract1 = uv_refract1 + uv_uv2 * _refract;
				float4 color_refract1 = float4(1,1,1,1);
				//color_refract1 = Blur(_GrabTexture,uv_refract1,float2(0 ,0),float4(0,0,1,1),false);
				color_refract1 = tex2D(_GrabTexture,uv_refract1);   

				result = color_refract1;
				return result;
			}
			ENDCG
		}
	}
}
