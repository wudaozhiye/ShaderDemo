Shader "My2D/OutLine"
{
	Properties
	{
		[HDR]_Color_color4 ("Color color4", Color) = (1.2,1.1064,0.492,1)
		_MainTex ("Texture", 2D) = "white" {}		
		blur ("blur", Range(0,1)) = 0.1
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
	}
	SubShader
	{
		Tags { "Queue"="Transparent" 
		"RenderType"="Transparent" 
		"IgnoreProjector"="True"
		"PreviewType" = "Plane"
		"CanUseSpriteAtlas" = "True"
		}
		LOD 100

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
				float4 rect_Sprite : COLOR1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float blur; 
			float4 _Color_color4;
			float GradientEvaluate(float _listTime[3],float _listValue[3],float count,float pcg)
			{
				if(count==0)
					return 0;
				if(pcg<_listTime[0])
					return 0;
				if(pcg>_listTime[count-1])
					return 0;

				for(int i= 1;i<count;i++)
				{
					if(pcg <= _listTime[i])
					{
						float v1= _listValue[i-1];
						float v2= _listValue[i];
						float t1= _listTime[i-1];
						float t2= _listTime[i];
						return lerp(v1,v2, (pcg - t1) / (t2-t1));
					}
				}
				return 0;
			}
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
				o.rect_Sprite = float4(0,0,1,1);
				#ifdef PIXELSNAP_ON
				o.pos = UnityPixelSnap (o.pos);
				#endif
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 result = float4(0,0,0,0);

				float2 uv_temp = i.uv;
				fixed4 remp_col = Blur(_MainTex,uv_temp,float2( blur*0.1 ,blur*0.1)*i.rect_Sprite.zw,i.rect_Sprite,false);

				//====================================
				//============ mixer3 ============   
				float mixer_mixer3;
				mixer_mixer3 = (remp_col).a;
				mixer_mixer3 = clamp(mixer_mixer3,0,1);
				float gra_mixer3_0ListTime[3] = {0,0.3,1};
				float gra_mixer3_0ListValue[3] = {0,1,1};
				//在0-1 , 1-1  权值 pcg-0/0.3-0   pcg-0.3/1-0.3
				float gra_mixer3_0 = GradientEvaluate(gra_mixer3_0ListTime,gra_mixer3_0ListValue,3,mixer_mixer3);

				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				col.rgb *= col.a;
				
				result = float4(_Color_color4.rgb,_Color_color4.a*gra_mixer3_0);
				result = lerp(result,float4(col.rgb,1),clamp(col.a,0,1));    
				return result;
			}
			ENDCG
		}
	}
}
