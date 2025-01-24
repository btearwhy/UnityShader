using System;
using UnityEngine;


public class MotionBlurSelf : PostEffectsBase
{
   public Shader motionBlurShader = null;
   private Material motionBlurMaterial = null;

   public Material material
   {
      get
      {
         motionBlurMaterial = CheckShaderAndCreateMaterial(motionBlurShader, motionBlurMaterial);
         return motionBlurMaterial;
      }
   }

   [Range(0.0f, 0.9f)] public float blurAmount = 0.5f;
   
   private RenderTexture accumulationTexture = null;

   private void OnDisable()
   {
      DestroyImmediate(accumulationTexture);
   }

   private void OnRenderImage(RenderTexture source, RenderTexture destination)
   {
      if (material != null)
      {
         if (accumulationTexture == null || accumulationTexture.width != source.width ||
             accumulationTexture.height != source.height)
         {
            DestroyImmediate(accumulationTexture);
            accumulationTexture = new RenderTexture(source.width, source.height, 0);
            accumulationTexture.hideFlags = HideFlags.HideAndDontSave;
            Graphics.Blit(source, accumulationTexture);
         }
         material.SetFloat("_BlurAmount", 1.0f - blurAmount);
         
         Graphics.Blit(source, accumulationTexture, material);
         Graphics.Blit(accumulationTexture, destination);
         
      }   
      else{
         Graphics.Blit(source, destination);
      }

      
   }

}
