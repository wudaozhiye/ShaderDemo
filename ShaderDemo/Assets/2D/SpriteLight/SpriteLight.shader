Shader "My2D/SpriteLight"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags {  "Queue"="Transparent"   
				"RenderType"="Transparent" 	
				"IgnoreProjector"="True" 
				"PreviewType"="Plane"
				"CanUseSpriteAtlas"="True"
				"LightMode"="ForwardBase" }
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
			#include "Lighting.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				fixed3 color : COLOR;
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
				// //获得世界空间的单位法线向量
				// fixed3 normalDir = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				//   //世界空间下的光照位置   //对于每一个点来说每一个光的位置就是光的方向（针对平行光）
            	// fixed3  lightDir = _WorldSpaceLightPos0.xyz; 
				// //取得漫反射的颜色
				// fixed3 diffuse = _LightColor0.rgb * max(0,dot(normalDir,lightDir));
				// o.color = diffuse;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 result = fixed4(0,0,0,0);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 diffuse = _LightColor0.rgb * saturate(dot(worldNormal, worldLightDir));  


				 fixed4 col = tex2D(_MainTex, i.uv);
				// col.rgb *= col.a;
				//result = col;

				result = fixed4(diffuse + col.rgb,col.a);
				return result;
			}
			ENDCG
		}
	}
}
