Shader "My2D/Alpha"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Wave("_Wave",2D) = "white" {}
		_p("_p",Range(0,1)) = 0
	}
	SubShader
	{
		Tags { "Queue"="Transparent"   "RenderType"="Transparent" }
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
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _Wave;
			float _p;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 result = fixed4(0,0,0,0);
				
				float2 uv_alpha1 = i.uv;
				float4 color_alpha1 = tex2D(_Wave,uv_alpha1);
				float aplha_alpha1 = -1+2*(_p) + color_alpha1.r;

				fixed4 col = tex2D(_MainTex, i.uv);
				result = fixed4(col.rgb,col.a * lerp(1,clamp(aplha_alpha1,0,1),1));

				return result;
			}
			ENDCG
		}
	}
}
