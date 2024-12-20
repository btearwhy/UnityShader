// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Chapter6-SpecularVertexLevel"
{
    Properties{
        _Diffuse ("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
        _Specular("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 1024)) = 20
    }

    SubShader{
        Pass{
            ZWrite On
            Tags{"LightMode" = "ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag


            #include "Lighting.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;


            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f{
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            v2f vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                fixed4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldPos = worldPos.xyz;
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target{
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                fixed3 worldNormal = i.worldNormal;
                fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));
                
                fixed3 reflectedDir = normalize(reflect(-worldLightDir, worldNormal));
                fixed3 cameraDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                fixed3 glossy = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(cameraDir, reflectedDir)), _Gloss);
                return fixed4(ambient + diffuse + glossy, 1.0);
            }

            ENDCG
        }
    }

    Fallback "SPECULAR"
}
