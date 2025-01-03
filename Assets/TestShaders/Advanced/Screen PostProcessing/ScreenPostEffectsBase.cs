using UnityEngine;

namespace TestShaders.Advanced.Screen_PostProcessing
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(Camera))]
    public class ScreenPostEffectsBase : MonoBehaviour
    {
        protected void CheckResources()
        {
            bool isSupported = CheckSupport();
    
            if (isSupported == false)
            {
                NotSuppported();
            }
        }
    
        private void NotSuppported()
        {
            enabled = false;
        }
    
        private bool CheckSupport()
        {
            /*if (SystemInfo.supportsRenderTextures == false || SystemInfo.supportsImageEffects == false)
            {
                return false;
            }*/
    
            return true;
        }
    
        void Start()
        {
            CheckResources(); 
        }
    
    
        protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
        {
            if (shader == null) return null;
            if (shader.isSupported && material && material.shader == shader)
                return material;
            if (!shader.isSupported)
            {
                return null;
            }
            else
            {
                material = new Material(shader);
                material.hideFlags = HideFlags.DontSave;
                if (material)
                    return material;
                else
                    return null;
            }
        }
    }
}

