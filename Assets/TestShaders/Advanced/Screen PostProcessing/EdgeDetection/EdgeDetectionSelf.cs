
using UnityEngine;

namespace TestShaders.Advanced.Screen_PostProcessing
{
    public class EdgeDetectionSelf : ScreenPostEffectsBase
    {
        public Shader edgeDetectShader;
        private Material edgeDetectMaterial = null;

        public Material material
        {
            get
            {
                edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMaterial);
                return edgeDetectMaterial;
            }
        }

        [Range(0f, 1f)] public float edgesOnly = 0.0f;

        public Color edgeColor = Color.black;
        public Color backgroundColor = Color.white;

        void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            if (material != null)
            {
                material.SetFloat("_EdgeOnly", edgesOnly);
                material.SetColor("_EdgeColor", edgeColor);
                material.SetColor("_BackgroundColor", backgroundColor);
                
                Graphics.Blit(source, destination, material);
            }
            else Graphics.Blit(source, destination);
        }
    }
}
