Shader "Unlit/BuildingName"
{
    Properties
    {
		_Color("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
		_TexSize("Texture Size", float) = 1.0
		_OutlineSpread("Outline Spread", float) = 0.7
    }
		SubShader{
			  Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

			  ZWrite Off
			  Blend SrcAlpha OneMinusSrcAlpha
			Cull off

			  Pass {
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog
				#pragma shader_feature AUTO_OUTLINE_COLOR
				#include "UnityCG.cginc"

				struct appdata_t {
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			  };

			  struct v2f {
				float4 vertex : SV_POSITION;
				half4 color : COLOR;
				half2 texcoord : TEXCOORD0;
				UNITY_FOG_COORDS(1)
			  };

			  sampler2D _MainTex;
			  float4 _MainTex_ST;
			  float4 _MainTex_TexelSize;
			  fixed4 _Color;
			  float _TexSize;
			  half _OutlineSpread;

			  v2f vert(appdata_t v)
			  {
				  float4 pos = float4(_WorldSpaceCameraPos, 0) - mul(unity_ObjectToWorld, float4(0, 0, 0, 1));
				  float fai = atan2(pos.x,pos.z);
				  float theta = (UNITY_PI / 2 - acos(pos.y / sqrt(pow(pos.x, 2) + pow(pos.y, 2) + pow(pos.z, 2)))) * 0.5;

				  float4x4 Yr = { {cos(fai),0,sin(fai),0}, {0,1,0,0}, {-sin(fai),0,cos(fai),0}, {0,0,0,1} };
				  //float4x4 Zr = { {cos(theta),sin(theta),0,0}, {-sin(theta),cos(theta),0,0}, {0,0,1,0}, {0,0,0,1} };
				  float4x4 Xr = { {1,0,0,0}, {0,cos(theta),sin(theta),0}, {0,-sin(theta),cos(theta),0}, {0,0,0,1} };
				  //float4x4 Y90r = { {cos(UNITY_PI/2),0,-sin(UNITY_PI/2),0}, {0,1,0,0}, {sin(UNITY_PI/2),0,cos(UNITY_PI/2),0}, {0,0,0,1} };

				v2f o;
				//o.vertex = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_MV, float4(0, 0, 0, 1)) + float4(v.vertex.x * _TexSize, v.vertex.y * _TexSize, v.vertex.z * _TexSize, 0));
				o.vertex = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, mul(mul(mul(unity_ObjectToWorld, Yr), Xr), v.vertex)));
				//o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			  }

			  fixed4 frag(v2f i) : SV_Target
			  {
				fixed4 col = i.color;
				UNITY_APPLY_FOG(i.fogCoord, col);
#ifdef AUTO_OUTLINE_COLOR
				half4 outc = abs(col - half4(1, 1, 1, 0));
#else
				half4 outc = _Color;
#endif
				half a0 = tex2D(_MainTex, i.texcoord).a;

				col.a *= a0;

				return col;
			  }
			  ENDCG
			}
	}
	
}
