Shader "Unlit/Chapter7-NormalMapWorldSpace"
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
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
                
                float3 worldLoc = mul(unity_ObjectToWorld, v.vertex).xyz;
                
                float3 worldNormal = mul(v.normal, unity_WorldToObject);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;
                
                o.TtoW0 = float4(worldTangent.x, worldTangent.y, worldTangent.z, worldLoc.x);
                o.TtoW1 = float4(worldBinormal.x, worldBinormal.y, worldBinormal.z, worldLoc.y);
                o.TtoW2 = float4(worldNormal.x, worldNormal.y, worldNormal.z, worldLoc.z);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 tangNormal = UnpackNormal(packedNormal);
                tangNormal.xy *= _BumpScale;
                tangNormal.z = sqrt(1 - saturate(dot(tangNormal.xy, tangNormal.xy)));

                float3x3 world2tangent = float3x3(i.TtoW0.xyz, i.TtoW1.xyz, i.TtoW2.xyz);
                fixed3 normal = normalize(mul(tangNormal, world2tangent));

                fixed3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                float3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                fixed3 albedo = tex2D(_MainTex, i.uv.xy) * _Color.rgb;
                fixed3 ambient = albedo * UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(normal, lightDir));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(normal, normalize(viewDir + lightDir))), _Gloss);
                return fixed4(ambient + diffuse + specular, 1.0);
            }

            
            
            ENDCG
        }
    }
}
