using System;
using UnityEngine;
using UnityEditor;

class PopcapMultiLayeredRoughnessGUI : ShaderGUI
{
    public enum BlendMode
    {
        Opaque,
        Cutout,
        Fade,   // Old school alpha-blending mode, fresnel does not affect amount of transparency
        Transparent // Physically plausible transparency mode, implemented as alpha pre-multiply
    }

    private static class Styles
    {
        public static GUIContent uvSetLabel = new GUIContent("UV Set");

        public static GUIContent albedo1Text = new GUIContent("Albedo 1", "Albedo 1 (RGB) and Transparency (A)");
        public static GUIContent albedoScale1Text = new GUIContent("Albedo 1 Scale", "Albedo 1 Scale");

        public static GUIContent albedo2Text = new GUIContent("Albedo 2", "Albedo 2 (RGB) and Transparency (A)");
        public static GUIContent albedoScale2Text = new GUIContent("Albedo 2 Scale", "Albedo 2 Scale");

        public static GUIContent albedo3Text = new GUIContent("Albedo 3", "Albedo 3 (RGB) and Transparency (A)");
        public static GUIContent albedoScale3Text = new GUIContent("Albedo 3 Scale", "Albedo 3 Scale");

        public static GUIContent albedo4Text = new GUIContent("Albedo 4", "Albedo 4 (RGB) and Transparency (A)");
        public static GUIContent albedoScale4Text = new GUIContent("Albedo 4 Scale", "Albedo 4 Scale");

        public static GUIContent maskText = new GUIContent("Mask", "Mask");

        public static GUIContent alphaCutoffText = new GUIContent("Alpha Cutoff", "Threshold for alpha cutoff");

        public static GUIContent metallicMap1Text = new GUIContent("Metallic 1", "Metallic (R) and Smoothness (A)");
        public static GUIContent metallicMap2Text = new GUIContent("Metallic 2", "Metallic (R) and Smoothness (A)");
        public static GUIContent metallicMap3Text = new GUIContent("Metallic 3", "Metallic (R) and Smoothness (A)");
        public static GUIContent metallicMap4Text = new GUIContent("Metallic 4", "Metallic (R) and Smoothness (A)");

        public static GUIContent roughnessMap1Text = new GUIContent("Roughness 1", "Roughness value");
        public static GUIContent roughnessMap2Text = new GUIContent("Roughness 2", "Roughness value");
        public static GUIContent roughnessMap3Text = new GUIContent("Roughness 3", "Roughness value");
        public static GUIContent roughnessMap4Text = new GUIContent("Roughness 4", "Roughness value");

        public static GUIContent highlightsText = new GUIContent("Specular Highlights", "Specular Highlights");
        public static GUIContent reflectionsText = new GUIContent("Reflections", "Glossy Reflections");

        public static GUIContent meshNormalMapText = new GUIContent("Mesh Normal Map", "Mesh Normal Map");
        public static GUIContent normalMap1Text = new GUIContent("Normal Map 1", "Normal Map 1");
        public static GUIContent normalMap2Text = new GUIContent("Normal Map 2", "Normal Map 2");
        public static GUIContent normalMap3Text = new GUIContent("Normal Map 3", "Normal Map 3");
        public static GUIContent normalMap4Text = new GUIContent("Normal Map 4", "Normal Map 4");

        public static GUIContent heightMapText = new GUIContent("Height Map", "Height Map (G)");
        public static GUIContent occlusionText = new GUIContent("Occlusion", "Occlusion (G)");
        public static GUIContent emissionText = new GUIContent("Color", "Emission (RGB)");
        public static GUIContent detailMaskText = new GUIContent("Detail Mask", "Mask for Secondary Maps (A)");
        public static GUIContent detailAlbedoText = new GUIContent("Detail Albedo x2", "Albedo (RGB) multiplied by 2");
        public static GUIContent detailNormalMapText = new GUIContent("Normal Map", "Normal Map");

        public static string firstMapsText = "First Layer Maps";
        public static string secondMapsText = "Second Layer Maps";
        public static string thirdMapsText = "Third Layer Maps";
        public static string fourthMapsText = "Fourth Layer Maps";

        public static string meshNormalMapsText = "Mesh Normal Map";
        public static string maskMapsText = "Mask Map";

        public static string otherSettingText = "Other Settings";

        public static string secondaryMapsText = "Secondary Maps";
        public static string forwardText = "Forward Rendering Options";
        public static string renderingMode = "Rendering Mode";
        public static string advancedText = "Advanced Options";
        public static GUIContent emissiveWarning = new GUIContent("Emissive value is animated but the material has not been configured to support emissive. Please make sure the material itself has some amount of emissive.");
        public static readonly string[] blendNames = Enum.GetNames(typeof(BlendMode));
    }

    MaterialProperty blendMode = null;

    MaterialProperty albedoMap1 = null;
    MaterialProperty albedoMapScale1 = null;

    MaterialProperty albedoMap2 = null;
    MaterialProperty albedoMapScale2 = null;

    MaterialProperty albedoMap3 = null;
    MaterialProperty albedoMapScale3 = null;

    MaterialProperty albedoMap4 = null;
    MaterialProperty albedoMapScale4 = null;

    MaterialProperty maskMap = null;

    MaterialProperty alphaCutoff = null;

    MaterialProperty metallic = null;
    MaterialProperty metallicMap1 = null;
    MaterialProperty metallicMap2 = null;
    MaterialProperty metallicMap3 = null;
    MaterialProperty metallicMap4 = null;

    MaterialProperty roughness = null;
    MaterialProperty roughnessMap1 = null;
    MaterialProperty roughnessMap2 = null;
    MaterialProperty roughnessMap3 = null;
    MaterialProperty roughnessMap4 = null;

    MaterialProperty highlights = null;
    MaterialProperty reflections = null;

    MaterialProperty meshBumpMap = null;

    MaterialProperty bumpMap1 = null;
    MaterialProperty bumpMap2 = null;
    MaterialProperty bumpMap3 = null;
    MaterialProperty bumpMap4 = null;

    MaterialProperty occlusionStrength = null;
    MaterialProperty occlusionMap = null;
    MaterialProperty heigtMapScale = null;
    MaterialProperty heightMap = null;
    MaterialProperty emissionColorForRendering = null;
    MaterialProperty emissionMap = null;
    MaterialProperty detailMask = null;
    MaterialProperty detailAlbedoMap = null;
    MaterialProperty detailNormalMapScale = null;
    MaterialProperty detailNormalMap = null;
    MaterialProperty uvSetSecondary = null;

    MaterialEditor m_MaterialEditor;
    ColorPickerHDRConfig m_ColorPickerHDRConfig = new ColorPickerHDRConfig(0f, 99f, 1 / 99f, 3f);

    bool m_FirstTimeApply = true;

    public void FindProperties(MaterialProperty[] props)
    {
        blendMode = FindProperty("_Mode", props);

        albedoMap1 = FindProperty("_MainTex1", props);
        albedoMap2 = FindProperty("_MainTex2", props);
        albedoMap3 = FindProperty("_MainTex3", props);
        albedoMap4 = FindProperty("_MainTex4", props);

        maskMap = FindProperty("_Mask", props);

        alphaCutoff = FindProperty("_Cutoff", props);

        metallic = FindProperty("_Metallic", props, false);
        metallicMap1 = FindProperty("_MetallicGlossMap1", props, false);
        metallicMap2 = FindProperty("_MetallicGlossMap2", props, false);
        metallicMap3 = FindProperty("_MetallicGlossMap3", props, false);
        metallicMap4 = FindProperty("_MetallicGlossMap4", props, false);

        roughness = FindProperty("_Glossiness", props);
        roughnessMap1 = FindProperty("_SpecGlossMap1", props);
        roughnessMap2 = FindProperty("_SpecGlossMap2", props);
        roughnessMap3 = FindProperty("_SpecGlossMap3", props);
        roughnessMap4 = FindProperty("_SpecGlossMap4", props);

        highlights = FindProperty("_SpecularHighlights", props, false);
        reflections = FindProperty("_GlossyReflections", props, false);

        meshBumpMap = FindProperty("_MeshNormal", props);

        bumpMap1 = FindProperty("_BumpMap1", props);
        bumpMap2 = FindProperty("_BumpMap2", props);
        bumpMap3 = FindProperty("_BumpMap3", props);
        bumpMap4 = FindProperty("_BumpMap4", props);

        heigtMapScale = FindProperty("_Parallax", props);
        heightMap = FindProperty("_ParallaxMap", props);
        occlusionStrength = FindProperty("_OcclusionStrength", props);
        occlusionMap = FindProperty("_OcclusionMap", props);
        emissionColorForRendering = FindProperty("_EmissionColor", props);
        emissionMap = FindProperty("_EmissionMap", props);
        detailMask = FindProperty("_DetailMask", props);
        detailAlbedoMap = FindProperty("_DetailAlbedoMap", props);
        detailNormalMapScale = FindProperty("_DetailNormalMapScale", props);
        detailNormalMap = FindProperty("_DetailNormalMap", props);
        uvSetSecondary = FindProperty("_UVSec", props);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        FindProperties(props); // MaterialProperties can be animated so we do not cache them but fetch them every event to ensure animated values are updated correctly
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;

        // Make sure that needed setup (ie keywords/renderqueue) are set up if we're switching some existing
        // material to a standard shader.
        // Do this before any GUI code has been issued to prevent layout issues in subsequent GUILayout statements (case 780071)
        if (m_FirstTimeApply)
        {
            MaterialChanged(material);
            m_FirstTimeApply = false;
        }

        ShaderPropertiesGUI(material);
    }

    public void ShaderPropertiesGUI(Material material)
    {
        // Use default labelWidth
        EditorGUIUtility.labelWidth = 0f;

        // Detect any changes to the material
        EditorGUI.BeginChangeCheck();
        {
            BlendModePopup();

            // 4 Layers properties
            // layer 1
            GUILayout.Label(Styles.firstMapsText, EditorStyles.boldLabel);
            DoAlbedoArea(material, Styles.albedo1Text, albedoMap1);
            DoMetallicRoughnessArea(Styles.metallicMap1Text, metallicMap1, Styles.roughnessMap1Text, roughnessMap1);
            DoNormalArea(Styles.normalMap1Text, bumpMap1);

            // layer 2
            GUILayout.Label(Styles.secondMapsText, EditorStyles.boldLabel);
            DoAlbedoArea(material, Styles.albedo2Text, albedoMap2);
            DoMetallicRoughnessArea(Styles.metallicMap2Text, metallicMap2, Styles.roughnessMap2Text, roughnessMap2);
            DoNormalArea(Styles.normalMap2Text, bumpMap2);

            // layer 3
            GUILayout.Label(Styles.thirdMapsText, EditorStyles.boldLabel);
            DoAlbedoArea(material, Styles.albedo3Text, albedoMap3);
            DoMetallicRoughnessArea(Styles.metallicMap3Text, metallicMap3, Styles.roughnessMap3Text, roughnessMap3);
            DoNormalArea(Styles.normalMap3Text, bumpMap3);

            // layer 4
            GUILayout.Label(Styles.fourthMapsText, EditorStyles.boldLabel);
            DoAlbedoArea(material, Styles.albedo4Text, albedoMap4);
            DoMetallicRoughnessArea(Styles.metallicMap4Text, metallicMap4, Styles.roughnessMap4Text, roughnessMap4);
            DoNormalArea(Styles.normalMap4Text, bumpMap4);

            // mask layer
            GUILayout.Label(Styles.maskMapsText, EditorStyles.boldLabel);
            m_MaterialEditor.TexturePropertySingleLine(Styles.maskText, maskMap);

            // mesh normal
            GUILayout.Label(Styles.meshNormalMapsText, EditorStyles.boldLabel);
            m_MaterialEditor.TexturePropertySingleLine(Styles.meshNormalMapText, meshBumpMap);

            // other settings
            GUILayout.Label(Styles.otherSettingText, EditorStyles.boldLabel);

            m_MaterialEditor.TexturePropertySingleLine(Styles.heightMapText, heightMap, heightMap.textureValue != null ? heigtMapScale : null);
            m_MaterialEditor.TexturePropertySingleLine(Styles.occlusionText, occlusionMap, occlusionMap.textureValue != null ? occlusionStrength : null);
            m_MaterialEditor.TexturePropertySingleLine(Styles.detailMaskText, detailMask);
            DoEmissionArea(material);
            EditorGUI.BeginChangeCheck();
            m_MaterialEditor.TextureScaleOffsetProperty(albedoMap1);
            if (EditorGUI.EndChangeCheck())
                emissionMap.textureScaleAndOffset = albedoMap1.textureScaleAndOffset; // Apply the main texture scale and offset to the emission texture as well, for Enlighten's sake

            EditorGUILayout.Space();

            // Secondary properties
            GUILayout.Label(Styles.secondaryMapsText, EditorStyles.boldLabel);
            m_MaterialEditor.TexturePropertySingleLine(Styles.detailAlbedoText, detailAlbedoMap);
            m_MaterialEditor.TexturePropertySingleLine(Styles.detailNormalMapText, detailNormalMap, detailNormalMapScale);
            m_MaterialEditor.TextureScaleOffsetProperty(detailAlbedoMap);
            m_MaterialEditor.ShaderProperty(uvSetSecondary, Styles.uvSetLabel.text);

            // Third properties
            GUILayout.Label(Styles.forwardText, EditorStyles.boldLabel);
            if (highlights != null)
                m_MaterialEditor.ShaderProperty(highlights, Styles.highlightsText);
            if (reflections != null)
                m_MaterialEditor.ShaderProperty(reflections, Styles.reflectionsText);
        }
        if (EditorGUI.EndChangeCheck())
        {
            foreach (var obj in blendMode.targets)
                MaterialChanged((Material)obj);
        }

        EditorGUILayout.Space();

        // NB renderqueue editor is not shown on purpose: we want to override it based on blend mode
        GUILayout.Label(Styles.advancedText, EditorStyles.boldLabel);
        m_MaterialEditor.EnableInstancingField();
    }

    public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
    {
        // _Emission property is lost after assigning Standard shader to the material
        // thus transfer it before assigning the new shader
        if (material.HasProperty("_Emission"))
        {
            material.SetColor("_EmissionColor", material.GetColor("_Emission"));
        }

        base.AssignNewShaderToMaterial(material, oldShader, newShader);

        if (oldShader == null || !oldShader.name.Contains("Legacy Shaders/"))
        {
            SetupMaterialWithBlendMode(material, (BlendMode)material.GetFloat("_Mode"));
            return;
        }

        BlendMode blendMode = BlendMode.Opaque;
        if (oldShader.name.Contains("/Transparent/Cutout/"))
        {
            blendMode = BlendMode.Cutout;
        }
        else if (oldShader.name.Contains("/Transparent/"))
        {
            // NOTE: legacy shaders did not provide physically based transparency
            // therefore Fade mode
            blendMode = BlendMode.Fade;
        }
        material.SetFloat("_Mode", (float)blendMode);

        MaterialChanged(material);
    }

    void BlendModePopup()
    {
        EditorGUI.showMixedValue = blendMode.hasMixedValue;
        var mode = (BlendMode)blendMode.floatValue;

        EditorGUI.BeginChangeCheck();
        mode = (BlendMode)EditorGUILayout.Popup(Styles.renderingMode, (int)mode, Styles.blendNames);
        if (EditorGUI.EndChangeCheck())
        {
            m_MaterialEditor.RegisterPropertyChangeUndo("Rendering Mode");
            blendMode.floatValue = (float)mode;
        }

        EditorGUI.showMixedValue = false;
    }

    void DoAlbedoArea(Material material, GUIContent label, MaterialProperty prop)
    {
        m_MaterialEditor.TexturePropertySingleLine(label, prop);
        if (((BlendMode)material.GetFloat("_Mode") == BlendMode.Cutout))
        {
            m_MaterialEditor.ShaderProperty(alphaCutoff, Styles.alphaCutoffText.text, MaterialEditor.kMiniTextureFieldLabelIndentLevel + 1);
        }
    }

    void DoMetallicRoughnessArea(GUIContent metallicLabel, MaterialProperty metallicProp, GUIContent roughnessLabel, MaterialProperty roughnessProp)
    {
        m_MaterialEditor.TexturePropertySingleLine(metallicLabel, metallicProp, metallicProp.textureValue != null ? null : metallic);
        m_MaterialEditor.TexturePropertySingleLine(roughnessLabel, roughnessProp, roughnessProp.textureValue != null ? null : roughness);
    }

    void DoNormalArea(GUIContent label, MaterialProperty prop)
    {
        m_MaterialEditor.TexturePropertySingleLine(label, prop);
    }

    void DoEmissionArea(Material material)
    {
        // Emission for GI?
        if (m_MaterialEditor.EmissionEnabledProperty())
        {
            bool hadEmissionTexture = emissionMap.textureValue != null;

            // Texture and HDR color controls
            m_MaterialEditor.TexturePropertyWithHDRColor(Styles.emissionText, emissionMap, emissionColorForRendering, m_ColorPickerHDRConfig, false);

            // If texture was assigned and color was black set color to white
            float brightness = emissionColorForRendering.colorValue.maxColorComponent;
            if (emissionMap.textureValue != null && !hadEmissionTexture && brightness <= 0f)
                emissionColorForRendering.colorValue = Color.white;

            // change the GI flag and fix it up with emissive as black if necessary
            m_MaterialEditor.LightmapEmissionFlagsProperty(MaterialEditor.kMiniTextureFieldLabelIndentLevel, true);
        }
    }

    public static void SetupMaterialWithBlendMode(Material material, BlendMode blendMode)
    {
        switch (blendMode)
        {
            case BlendMode.Opaque:
                material.SetOverrideTag("RenderType", "");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                material.DisableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = -1;
                break;
            case BlendMode.Cutout:
                material.SetOverrideTag("RenderType", "TransparentCutout");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                material.EnableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest;
                break;
            case BlendMode.Fade:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                material.DisableKeyword("_ALPHATEST_ON");
                material.EnableKeyword("_ALPHABLEND_ON");
                material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
            case BlendMode.Transparent:
                material.SetOverrideTag("RenderType", "Transparent");
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                material.DisableKeyword("_ALPHATEST_ON");
                material.DisableKeyword("_ALPHABLEND_ON");
                material.EnableKeyword("_ALPHAPREMULTIPLY_ON");
                material.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                break;
        }
    }

    static void SetMaterialKeywords(Material material)
    {
        // Note: keywords must be based on Material value not on MaterialProperty due to multi-edit & material animation
        // (MaterialProperty value might come from renderer material property block)
        SetKeyword(material, "_NORMALMAP", material.GetTexture("_BumpMap") || material.GetTexture("_DetailNormalMap"));
        SetKeyword(material, "_SPECGLOSSMAP", material.GetTexture("_SpecGlossMap"));
        SetKeyword(material, "_METALLICGLOSSMAP", material.GetTexture("_MetallicGlossMap"));
        SetKeyword(material, "_PARALLAXMAP", material.GetTexture("_ParallaxMap"));
        SetKeyword(material, "_DETAIL_MULX2", material.GetTexture("_DetailAlbedoMap") || material.GetTexture("_DetailNormalMap"));

        // A material's GI flag internally keeps track of whether emission is enabled at all, it's enabled but has no effect
        // or is enabled and may be modified at runtime. This state depends on the values of the current flag and emissive color.
        // The fixup routine makes sure that the material is in the correct state if/when changes are made to the mode or color.
        MaterialEditor.FixupEmissiveFlag(material);
        bool shouldEmissionBeEnabled = (material.globalIlluminationFlags & MaterialGlobalIlluminationFlags.EmissiveIsBlack) == 0;
        SetKeyword(material, "_EMISSION", shouldEmissionBeEnabled);
    }

    static void MaterialChanged(Material material)
    {
        SetupMaterialWithBlendMode(material, (BlendMode)material.GetFloat("_Mode"));

        SetMaterialKeywords(material);
    }

    static void SetKeyword(Material m, string keyword, bool state)
    {
        if (state)
            m.EnableKeyword(keyword);
        else
            m.DisableKeyword(keyword);
    }
}
