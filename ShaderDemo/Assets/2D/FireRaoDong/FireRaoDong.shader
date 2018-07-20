Shader "My2D/FireRaoDong"
{
	Properties
	{
		_Amount ("_Amount", Range(0,1)) = 0
		_MainTex ("Texture", 2D) = "white" {}
		_WaveTex ("WaveTexture", 2D) = "white" {}

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
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
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _WaveTex;
			float _Amount; 
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 result = fixed4(1,1,1,1);

				float2 waveUV = i.uv;
				float2 waveUV_center = float2(0.5,0.5);
				waveUV = waveUV - waveUV_center;
				waveUV = waveUV+fixed2(0,-0.2636719)*(_Time.y);    
				waveUV = waveUV + waveUV_center;
				float4 color_uv1 = tex2D(_WaveTex,waveUV); 
				//重点
				waveUV = -(color_uv1.r*fixed2(0,0.2636719) + color_uv1.g*fixed2(0.15625,0.1074219) + color_uv1.b*fixed2(-0.1894531,0.1191406) +  color_uv1.a*fixed2(0,0));    
				  
				float4 color_ROOT = tex2D(_MainTex,i.uv);  
				fixed4 col = tex2D(_MainTex, i.uv + waveUV);
				result = lerp(color_ROOT,col,clamp(1*(_Amount),0,1)); 

				return result;
			}
			ENDCG
		}
	}
}
