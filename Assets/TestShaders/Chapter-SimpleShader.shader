

Shader "Unity Shaders Book/Chapter 5/Simple Shader"{

    Properties{
        _Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
    }

    SubShader{
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma enable_d3d11_debug_symbols

            fixed4 _Color;

            struct a2v{
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 textcoord : TEXCOORD0;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 color : COLOR0;
            };

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.color = mul(UNITY_MATRIX_IT_MV, v.normal); 
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            { 
                fixed3 c = i.color;
                c *= _Color.rgb;
                return fixed4(c, 1.0);
            }
            ENDCG
        }
    }
}