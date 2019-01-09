using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "New Character FX Info", menuName = "Character FX Info")]
public class CharacterFXInfo : ScriptableObject
{
    [System.Serializable]
    public class MaterialInfo
    {
        public string MaterialName;

        private Material _mat;
        private BlendMode _blendMode;

        public Material Mat
        {
            get
            {
                return _mat;
            }

            set
            {
                _mat = value;
            }
        }

        public BlendMode OrigBlendMode
        {
            get
            {
                return _blendMode;
            }

            set
            {
                _blendMode = value;
            }
        }

        public MaterialInfo(Material mat)
        {
            _mat = mat;
            MaterialName = mat.name;
            _blendMode = (BlendMode)_mat.GetFloat("_Mode");
        }

        public void SetupMaterialWithBlendMode(BlendMode blendMode)
        {
            switch (blendMode)
            {
                case BlendMode.Opaque:
                    _mat.SetOverrideTag("RenderType", "");
                    _mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    _mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    _mat.SetInt("_ZWrite", 1);
                    _mat.DisableKeyword("_ALPHATEST_ON");
                    _mat.DisableKeyword("_ALPHABLEND_ON");
                    _mat.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                    _mat.renderQueue = -1;
                    break;
                case BlendMode.Cutout:
                    _mat.SetOverrideTag("RenderType", "TransparentCutout");
                    _mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    _mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    _mat.SetInt("_ZWrite", 1);
                    _mat.EnableKeyword("_ALPHATEST_ON");
                    _mat.DisableKeyword("_ALPHABLEND_ON");
                    _mat.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                    _mat.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                    break;
                case BlendMode.Fade:
                    _mat.SetOverrideTag("RenderType", "Transparent");
                    _mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    _mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    _mat.SetInt("_ZWrite", 0);
                    _mat.DisableKeyword("_ALPHATEST_ON");
                    _mat.EnableKeyword("_ALPHABLEND_ON");
                    _mat.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                    _mat.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    break;
                case BlendMode.Transparent:
                    _mat.SetOverrideTag("RenderType", "Transparent");
                    _mat.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    _mat.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    _mat.SetInt("_ZWrite", 0);
                    _mat.DisableKeyword("_ALPHATEST_ON");
                    _mat.DisableKeyword("_ALPHABLEND_ON");
                    _mat.EnableKeyword("_ALPHAPREMULTIPLY_ON");
                    _mat.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                    break;
            }
        }

        public enum BlendMode
        {
            Opaque,
            Cutout,
            Fade,   // Old school alpha-blending mode, fresnel does not affect amount of transparency
            Transparent, // Physically plausible transparency mode, implemented as alpha pre-multiply
            None
        }
    }

    [System.Serializable]
    public struct FeatureTexture
    {
        public string Keyword;
        public Texture2D Tex;
    }

    public FeatureTexture[] FeatureTextures;

    public string CFXName;
    public int ShaderLOD;
    public string[] Keywords;
    public MaterialInfo.BlendMode OverrideBlendMode = MaterialInfo.BlendMode.None;

    private MaterialInfo[] _materialInfos;

    public static string SSS_KEYWORD = "_ENABLE_SSS";
    public static string ICE_KEYWORD = "_ENABLE_ICE";
    public static string DISSOLVE_KEYWORD = "_ENABLE_DISSOLVE";
    public static string ADVANCED_DISSOLVE_KEYWORD = "_ENABLE_ADVANCED_DISSOLVE";
    public static string MATCAP_KEYWORD = "_ENABLE_MATCAP";
    public static string FIRE_KEYWORD = "_ENABLE_FIRE";
    public static string STEALTH_KEYWORD = "_ENABLE_STEALTH";
    public static string SEMI_TRANSPARENCY_KEYWORD = "_ENABLE_SEMI_TRANSPARENCY";
    public static string MOSAIC_KEYWORD = "_ENABLE_MOSAIC";
    public static string DEFAULT_KEYWORD = "_ENABLE_DEFAULT";

    public MaterialInfo[] MaterialInfos
    {
        get { return _materialInfos; }
    }

    public void Initialize(GameObject go)
    {
        List<Material> matList = new List<Material>();
        foreach (Renderer r in go.GetComponentsInChildren<Renderer>(includeInactive: false))
        {
            foreach (Material mat in r.sharedMaterials)
            {
                if (!matList.Contains(mat))
                    matList.Add(mat);
            }
        }

        _materialInfos = new MaterialInfo[matList.Count];
        for (int i = 0; i < matList.Count; ++i)
            _materialInfos[i] = new MaterialInfo(matList[i]);
    }

    public void Active(bool active)
    {
        // open needed passes
        ActiveKeywords(Keywords, active);

        // set feature textures
        ActiveFeatureTextures(active);

        if (active)
        {
            // open shader lod
            ActiveShaderLod();

            // override blend mode
            ActiveBlendMode();
        }
    }

    public void Reset()
    {
        foreach (MaterialInfo mi in _materialInfos)
            mi.SetupMaterialWithBlendMode(mi.OrigBlendMode);
        Active(true);
    }

    private void ActiveBlendMode()
    {
        if (OverrideBlendMode != MaterialInfo.BlendMode.None)
        {
            foreach (MaterialInfo mi in _materialInfos)
                mi.SetupMaterialWithBlendMode(OverrideBlendMode);
        }
    }

    private void ActiveShaderLod()
    {
        foreach (MaterialInfo mi in _materialInfos)
            mi.Mat.shader.maximumLOD = ShaderLOD;
    }

    private void ActiveKeywords(string[] keywords, bool active)
    {
        foreach (MaterialInfo mi in _materialInfos)
        {
            foreach (string keyword in keywords)
            {
                if (active)
                    mi.Mat.EnableKeyword(keyword);
                else
                    mi.Mat.DisableKeyword(keyword);
            }
        }
    }

    private void ActiveFeatureTextures(bool active)
    {
        if (active)
        {
            foreach (FeatureTexture ft in FeatureTextures)
            {
                foreach (MaterialInfo mi in _materialInfos)
                    mi.Mat.SetTexture(ft.Keyword, ft.Tex);
            }
        }
    }
}
