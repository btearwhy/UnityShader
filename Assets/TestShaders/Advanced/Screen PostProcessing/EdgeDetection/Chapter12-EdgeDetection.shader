Shader "Unlit/Chapter12-EdgeDetection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeOnly ("Edge Only", Float) = 1.0
        _EdgeColor ("Edge Color", Color) = (0.0, 0.0, 0.0, 1.0)
        _BackgroundColor ("Background Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv[9] : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            fixed _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;
            
            half luminance(fixed4 color)
            {
                return 0.2125 * color.x + 0.7154 * color.y + 0.0721 * color.z;
            }
            
            half Sobel(v2f i)
            {
                const half Gx[9] = {-1, -2, -1,
                                    0, 0, 0,
                                    1, 2, 1};
                const half Gy[9] = {-1, 0, 1,
                                    -2, 0, 2,
                                    -1, 0, 1};
                half edgeX = 0;
                half edgeY = 0;
                for (int it = 0; it < 9; it++)
                {
                    half texColor = luminance(tex2D(_MainTex, i.uv[it]));
                    edgeX += texColor * Gx[it];
                    edgeY += texColor * Gy[it];
                }

                half edge = 1 - abs(edgeX) - abs(edgeY);

                return edge;
            }
            
            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv[0] = v.uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[1] = v.uv + _MainTex_TexelSize.xy * half2(0, -1);
                o.uv[2] = v.uv + _MainTex_TexelSize.xy * half2(1, -1);
                o.uv[3] = v.uv + _MainTex_TexelSize.xy * half2(-1, 0);
                o.uv[4] = v.uv + _MainTex_TexelSize.xy * half2(0, 0);
                o.uv[5] = v.uv + _MainTex_TexelSize.xy * half2(1, 0);
                o.uv[6] = v.uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[7] = v.uv + _MainTex_TexelSize.xy * half2(0, 1);
                o.uv[8] = v.uv + _MainTex_TexelSize.xy * half2(1, 1);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                half edge = Sobel(i);

                fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);
                fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
                return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
            }

            
            ENDCG
        }
    }
    Fallback Off
}
