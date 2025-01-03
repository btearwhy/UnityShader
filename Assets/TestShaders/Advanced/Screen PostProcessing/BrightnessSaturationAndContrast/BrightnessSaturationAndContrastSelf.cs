using UnityEngine;

namespace TestShaders.Advanced.Screen_PostProcessing
{
    public class BrightnessSaturationAndContrastSelf : ScreenPostEffectsBase
    {
        public Shader briSatConShader;
        private Material briSatConMat;

        public Material material
        {
            get
            {
                briSatConMat = CheckShaderAndCreateMaterial(briSatConShader, briSatConMat);
                return briSatConMat;
            }
        }

        [Range(0f, 3.0f)] public float brightness = 1.0f;
        [Range(0f, 3.0f)] public float contrast = 1.0f;
        [Range(0f, 3.0f)] public float saturation = 1.0f;
        
        void OnRenderImage(RenderTexture src, RenderTexture dest){
            if (material != null)
            {
                material.SetFloat("_Brightness", brightness);
                material.SetFloat("_Contrast", contrast);
                material.SetFloat("_Saturation", saturation);
                
                Graphics.Blit(src, dest, material);
            }
            else
            {
                Graphics.Blit(src, dest);
            }
        }
    }
}

