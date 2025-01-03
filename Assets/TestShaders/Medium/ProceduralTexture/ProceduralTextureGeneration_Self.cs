using UnityEngine;

[ExecuteInEditMode]
public class ProceduralTextureGeneration_Self : MonoBehaviour
{
    public Material material;

    #region Material Properties

    [SerializeField, SetProperty("textureWidth")]
    private int mTextureWidth = 512;

    public int textureWidth
    {
        get { return mTextureWidth; }
        set
        {
            mTextureWidth = value;
            _UpdateMaterial();
        }
    }

    [SerializeField, SetProperty("backgroundColor")]
    private Color mBackgroundColor = Color.white;

    public Color backgroundColor
    {
        get { return mBackgroundColor; }
        set
        {
            mBackgroundColor = value;
            _UpdateMaterial();
        }
    }
    
    [SerializeField, SetProperty("circleColor")]
    private Color mCircleColor = Color.yellow;

    public Color circleColor
    {
        get { return mCircleColor; }
        set
        {
            mCircleColor = value;
            _UpdateMaterial();
        }
    }
    
    [SerializeField, SetProperty("blurFactor")]
    private float mBlurFactor = 2.0f;

    public float blurFactor
    {
        get { return mBlurFactor; }
        set
        {
            mBlurFactor = value;
            _UpdateMaterial();
        }
    }

    private Texture2D mGeneratedTexture = null;

    void Start()
    {
        if (material == null)
        {
            Renderer renderer = gameObject.GetComponent<Renderer>();
            if (renderer == null)
            {
                Debug.LogWarning("Cannot find a renderer");
                return;
            }
            
            material =  renderer.sharedMaterial;
        }
        
        _UpdateMaterial();
    }

    private void _UpdateMaterial()
    {
        if (material != null)
        {
            mGeneratedTexture = _GenerateProceduralTexture();
            material.SetTexture("_MainTex", mGeneratedTexture);
        }
    }

    private Texture2D _GenerateProceduralTexture()
    {
        Texture2D proceduralTexture = new Texture2D(textureWidth, textureWidth);
        float circleInterval = textureWidth / 4.0f;

        float radius = textureWidth / 10.0f;
        
        float edgeBlur = 1.0f / blurFactor;

        for (int w = 0; w < textureWidth; w++)
        {
            for (int h = 0; h < textureWidth; h++)
            {
                Color pixel = backgroundColor;

                for (int i = 0; i < 3; i++)
                {
                    for (int j = 0; j < 3; j++)
                    {
                        Vector2 circleCenter = new Vector2(circleInterval * (i + 1), circleInterval * (j + 1));
                        float dist = Vector2.Distance(new Vector2(w, h), circleCenter) - radius;
                        
                        Color color = _MixColor(circleColor, new Color(pixel.r, pixel.g, pixel.b, 1.0f), Mathf.SmoothStep(0f, 1.0f, dist * edgeBlur));
                        pixel = _MixColor(pixel, color, color.a);
                    }
                }
                
                proceduralTexture.SetPixel(w, h, pixel);
            }   
        }
        proceduralTexture.Apply();
        return proceduralTexture;
    }

    private Color _MixColor(Color color0, Color color1, float mixFactor) {
        Color mixColor = Color.white;
        mixColor.r = Mathf.Lerp(color0.r, color1.r, mixFactor);
        mixColor.g = Mathf.Lerp(color0.g, color1.g, mixFactor);
        mixColor.b = Mathf.Lerp(color0.b, color1.b, mixFactor);
        mixColor.a = Mathf.Lerp(color0.a, color1.a, mixFactor);
        return mixColor;
    }

    #endregion
}
