using System;
using TestShaders.Advanced.Screen_PostProcessing;
using UnityEngine;

public class MotionBlurWithDepthTextureSelf : ScreenPostEffectsBase
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
    
    [Range(0.0f, 1.0f)]
    public float blurSize = 0.5f;
    
    private Camera myCamera;

    public Camera camera
    {
        get
        {
            if (myCamera == null)
            {
                myCamera = GetComponent<Camera>();
            }
            return myCamera;
        }
    }
    
    private Matrix4x4 previousViewProjectionMatrix;

    private void OnEnable()
    {
        camera.depthTextureMode |= DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material != null)
        {
            material.SetFloat("_BlurSize", blurSize);
            
            material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
            
            Matrix4x4 currentViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
            Matrix4x4 currentViewProjectionMatrixInverse = currentViewProjectionMatrix.inverse;
            material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionMatrixInverse);
            previousViewProjectionMatrix = currentViewProjectionMatrix;
            
            Graphics.Blit(source, destination, material);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
}
