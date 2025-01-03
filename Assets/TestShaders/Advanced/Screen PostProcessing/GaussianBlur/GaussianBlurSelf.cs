
using UnityEngine;
using UnityEngine.Serialization;
using UnityEngine.UI;

namespace TestShaders.Advanced.Screen_PostProcessing
{
    public class GaussianBlurSelf : ScreenPostEffectsBase
    {
        public Shader gaussianBlurShader;
        private Material gaussianBlurMaterial = null;

        public Material material
        {
            get
            {
                gaussianBlurMaterial = CheckShaderAndCreateMaterial(gaussianBlurShader, gaussianBlurMaterial);
                return gaussianBlurMaterial;
            }
        }

        [Range(0f, 4f)] public int iteration = 3;

        [Range(0.2f, 3f)] public float blurSpread = 0.6f;

        [Range(1, 8)] public int downsample = 2;

        void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            OnRenderImage_Original(source, destination);
            //OnRenderImage_DownSample(source, destination);
            //OnRenderImage_Iteration(source, destination);
        }
        
        void OnRenderImage_Original(RenderTexture source, RenderTexture destination)
        {
            if (material != null)
            {
                int rtW = source.width;
                int rtH = source.height;
                
                RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
                Graphics.Blit(source, buffer, material, 0);
                Graphics.Blit(buffer, destination, material, 1);
                RenderTexture.ReleaseTemporary(buffer);
            }
            else Graphics.Blit(source, destination);
        }
        
        void OnRenderImage_DownSample(RenderTexture source, RenderTexture destination)
        {
            if (material != null)
            {
                int rtW = source.width / downsample;
                int rtH = source.height / downsample;
                
                RenderTexture buffer = RenderTexture.GetTemporary(rtW, rtH, 0);
                buffer.filterMode = FilterMode.Bilinear;
                
                Graphics.Blit(source, buffer, material, 0);
                Graphics.Blit(buffer, destination, material, 1);
                RenderTexture.ReleaseTemporary(buffer);
            }
            else Graphics.Blit(source, destination);
        }
        
        void OnRenderImage_Iteration(RenderTexture source, RenderTexture destination)
        {
            if (material != null)
            {
                int rtW = source.width / downsample;
                int rtH = source.height / downsample;
                
                RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
                buffer0.filterMode = FilterMode.Bilinear;
                
                Graphics.Blit(source, buffer0);

                for (int i = 0; i < iteration; i++)
                {
                    material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
                    
                    RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                    Graphics.Blit(buffer0, buffer1, material, 0);
                    RenderTexture.ReleaseTemporary(buffer0);
                    buffer0 = buffer1;
                    
                    buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
                    Graphics.Blit(buffer0, buffer1, material, 1);
                    RenderTexture.ReleaseTemporary(buffer0);
                    buffer0 = buffer1;
                }
                
                Graphics.Blit(buffer0, destination);
                RenderTexture.ReleaseTemporary(buffer0);
            }
            else Graphics.Blit(source, destination);
        }
    }
}
