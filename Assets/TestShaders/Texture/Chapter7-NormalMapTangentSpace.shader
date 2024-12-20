Shader "Unlit/Chapter7-NormalMapTangentSpace"
{
    Properties
    {
        _Color("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex("Main Tex", 2D) = "white"{}
        _BumpMap("Normal Map", 2D) = "bump"{}
        _BumpScale("Bump Scale", Float) = 1.0
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include"Lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1; /*light dir in tangent space*/
                float3 viewDir : TEXCOORD2; /*view dir in tangent space*/
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                
                float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
                float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 tangLightDir = normalize(i.lightDir);
                fixed3 tangViewDir = normalize(i.viewDir);
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 normal;
                normal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
                normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv.xy) * _Color.rgb;
                fixed3 ambient = albedo * UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(normal,tangLightDir));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(normal, normalize(tangViewDir + tangLightDir))), _Gloss);
                return fixed4( ambient + diffuse + specular, 1.0);
            }

            
            ENDCG
        }
    }
}
