Shader "Unlit/Chapter10-Reflection"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _FresnelScale("Fresnel Scale", Range(0, 1)) = 0.5
        _CubeMap("Reflection CubeMap", Cube) = "_Skybox"{}
        
        _RefractColor("Refract Color", Color) = (1, 1, 1, 1)
        _RefractAmount("Refract Amount", Range(0, 1)) = 1
        _RefractRatio("Refraction Ratio", Range(0, 1)) = 0.5
        
        _ReflectColor("Reflection Color", Color) = (1, 1, 1, 1)
        _ReflectAmount("Reflection Amount", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}


        Pass
        {
            Tags { "LightMode"="ForwardBase" }
            
            CGPROGRAM
            #pragma multi_compile_fwdbase
            
            #pragma vertex vert
            #pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

            fixed4 _Color;
            fixed _FresnelScale;
            samplerCUBE _CubeMap;

            fixed4 _RefractColor;
            fixed _RefractAmount;
            fixed _RefractRatio;

            fixed4 _ReflectColor;
            fixed _ReflectAmount;
            
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldViewDir : TEXCOORD2;
                float3 worldReflectDir : TEXCOORD3;
                float3 worldRefractDir : TEXCOORD4;
                SHADOW_COORDS(5)
            };
            

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal).xyz;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos).xyz;
                o.worldReflectDir = reflect(-normalize(o.worldViewDir), normalize(o.worldNormal));
                o.worldRefractDir = refract(-normalize(o.worldViewDir), normalize(o.worldNormal), _RefractRatio);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(i.worldViewDir);

                fixed ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0, dot(worldLightDir, worldNormal));
                fixed3 reflection = texCUBE(_CubeMap, i.worldReflectDir).rgb;
                fixed3 refraction = texCUBE(_CubeMap, i.worldRefractDir).rgb;
                fixed fresnel = _FresnelScale + (1 - _FresnelScale) * pow(1 - dot(worldViewDir, worldNormal), 5);
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                fixed3 color = ambient + lerp(refraction, reflection, fresnel) * atten;
                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
	FallBack "Reflective/VertexLit"
}
