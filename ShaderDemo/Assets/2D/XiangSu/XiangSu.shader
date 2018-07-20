Shader "My2D/XiangSu"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_rate ("_rate", Range(0,1)) = 0
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
			//fmod v 不可为0 
			float2 Retro(float2 uv,float v)
			{
				uv = float2(uv.x - fmod(uv.x,v) + v*0.5 ,uv.y - fmod(uv.y,v) + v*0.5);
				return uv;
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
			float _rate; 

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
				float retroFactor_ROOT_retro1 = (0.16*(_rate)*0.2)*max(rect_ROOT.z,rect_ROOT.w);
				float2  uv_ROOT = i.uv;
				uv_ROOT = Retro(uv_ROOT,retroFactor_ROOT_retro1);
				
				result =  tex2D(_MainTex,uv_ROOT);   
				result.rgb*=result.a; 
				return result;
			}
			ENDCG
		}
	}
}
