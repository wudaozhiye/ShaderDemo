Shader "My2D/Blur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_blurX ("_blurX", Range(0,1)) = 0
		_blurY ("_blurY", Range(0,1)) = 0
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
			//告诉Unity编译不同版本的Shader,这里和后面vert中的PIXELSNAP_ON对应
			#pragma multi_compile _ PIXELSNAP_ON
			#include "UnityCG.cginc"

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

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				fixed4  rect_Sprite : COLOR1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _blurX; 
			float _blurY; 

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//单张图片  多张图片 rect.x/texture.width  rect.y/texture.height
				//         rect.width/texture.width  rect.height/texture.height
				o.rect_Sprite = fixed4(0,0,1,1);
				#ifdef PIXELSNAP_ON
				OUT.pos = UnityPixelSnap (OUT.pos);
				#endif

				return o;
			}
			
			float4 frag (v2f i) : SV_Target
			{
				float4 result = fixed4(1,1,1,1);
				float4 rect_ROOT =  i.rect_Sprite;
				result = Blur(_MainTex,i.uv,float2( 1*_blurX*0.1 ,1*_blurY*0.1)*rect_ROOT.zw,i.rect_Sprite,true);
				return result;
			}
			ENDCG
		}
	}
}
