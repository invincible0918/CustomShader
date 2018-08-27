using System;
using UnityEngine;
using UnityEditor;

class CustomMultiLayeredGUI : ShaderGUI
{
    private enum WorkflowMode
    {
        Specular,
        Metallic,
        Dielectric
    }

    public enum BlendMode
    {
        Opaque,
        Cutout,
        Fade,   // Old school alpha-blending mode, fresnel does not affect amount of transparency
        Transparent // Physically plausible transparency mode, implemented as alpha pre-multiply
    }

    public enum SmoothnessMapChannel
    {
        SpecularMetallicAlpha,
        AlbedoAlpha,
    }

    private static class Styles
    {
        public static GUIContent uvSetLabel = new GUIContent("UV Set");

        public static GUIContent albedo1Text = new GUIContent("Albedo 1", "Albedo 1 (RGB) and Transparency (A)");
        public static GUIContent albedo2Text = new GUIContent("Albedo 2", "Albedo 2 (RGB) and Transparency (A)");
        public static GUIContent albedo3Text = new GUIContent("Albedo 3", "Albedo 3 (RGB) and Transparency (A)");
        public static GUIContent albedo4Text = new GUIContent("Albedo 4", "Albedo 4 (RGB) and Transparency (A)");

        public static GUIContent materialScale1Text = new GUIContent("Material Scale 1", "Material Scale 1");
        public static GUIContent materialScale2Text = new GUIContent("Material Scale 2", "Material Scale 2");
        public static GUIContent materialScale3Text = new GUIContent("Material Scale 3", "Material Scale 3");
        public static GUIContent materialScale4Text = new GUIContent("Material Scale 4", "Material Scale 4");

        public static GUIContent maskText = new GUIContent("Mask", "Mask");

        public static GUIContent alphaCutoffText = new GUIContent("Alpha Cutoff", "Threshold for alpha cutoff");

        public static GUIContent specularMap1Text = new GUIContent("Specular 1", "Specular 1 (RGB) and Smoothness (A)");
        public static GUIContent specularMap2Text = new GUIContent("Specular 2", "Specular 2 (RGB) and Smoothness (A)");
        public static GUIContent specularMap3Text = new GUIContent("Specular 3", "Specular 3 (RGB) and Smoothness (A)");
        public static GUIContent specularMap4Text = new GUIContent("Specular 4", "Specular 4 (RGB) and Smoothness (A)");

        public static GUIContent metallicMap1Text = new GUIContent("Metallic 1", "Metallic (R) and Smoothness (A)");
        public static GUIContent metallicMap2Text = new GUIContent("Metallic 2", "Metallic (R) and Smoothness (A)");
        public static GUIContent metallicMap3Text = new GUIContent("Metallic 3", "Metallic (R) and Smoothness (A)");
        public static GUIContent metallicMap4Text = new GUIContent("Metallic 4", "Metallic (R) and Smoothness (A)");

        public static GUIContent smoothnessText = new GUIContent("Smoothness", "Smoothness value");
        public static GUIContent smoothnessScaleText = new GUIContent("Smoothness", "Smoothness scale factor");

        public static GUIContent smoothnessMapChannelText = new GUIContent("Source", "Smoothness texture and channel");
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

        public static GUIContent enableThirdLayerMapsText = new GUIContent("Active Third Layer Maps", "Active Third Layer Maps");
        public static GUIContent enableFourthLayerMapsText = new GUIContent("Active Fourth Layer Maps", "Active Fourth Layer Maps");

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

        public static readonly string[] blendNames = Enum.GetNames(typeof(BlendMode));
    }

    MaterialProperty blendMode = null;

    MaterialProperty albedoMap1 = null;
    MaterialProperty albedoMap2 = null;
    MaterialProperty albedoMap3 = null;
    MaterialProperty albedoMap4 = null;

    MaterialProperty materialScale1 = null;
    MaterialProperty materialScale2 = null;
    MaterialProperty materialScale3 = null;
    MaterialProperty materialScale4 = null;

    MaterialProperty maskMap = null;

    MaterialProperty alphaCutoff = null;

    MaterialProperty specularMap1 = null;
    MaterialProperty specularMap2 = null;
    MaterialProperty specularMap3 = null;
    MaterialProperty specularMap4 = null;
    MaterialProperty specularColor = null;

    MaterialProperty metallic = null;
    MaterialProperty metallicMap1 = null;
    MaterialProperty metallicMap2 = null;
    MaterialProperty metallicMap3 = null;
    MaterialProperty metallicMap4 = null;

    MaterialProperty smoothness = null;
    MaterialProperty smoothnessScale = null;
    MaterialProperty smoothnessMapChannel = null;
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

    MaterialProperty enableThirdLayerMaps = null;
    MaterialProperty enableFourthLayerMaps = null;

    MaterialEditor m_MaterialEditor;
    WorkflowMode m_WorkflowMode = WorkflowMode.Specular;
    private const float kMaxfp16 = 65536f; // Clamp to a value that fits into fp16.
    ColorPickerHDRConfig m_ColorPickerHDRConfig = new ColorPickerHDRConfig(0f, kMaxfp16, 1 / kMaxfp16, 3f);

    bool m_FirstTimeApply = true;

    private string _enableThirdLayerMapsKeyword = "_ENABLE_THIRD_LAYER_MAPS";
    private string _enableFourthLayerMapsKeyword = "_ENABLE_FOURTH_LAYER_MAPS";

    public void FindProperties(MaterialProperty[] props)
    {
        blendMode = FindProperty("_Mode", props);

        albedoMap1 = FindProperty("_MainTex1", props);
        albedoMap2 = FindProperty("_MainTex2", props);
        albedoMap3 = FindProperty("_MainTex3", props);
        albedoMap4 = FindProperty("_MainTex4", props);

        materialScale1 = FindProperty("_MaterialScale1", props);
        materialScale2 = FindProperty("_MaterialScale2", props);
        materialScale3 = FindProperty("_MaterialScale3", props);
        materialScale4 = FindProperty("_MaterialScale4", props);

        maskMap = FindProperty("_Mask", props);

        alphaCutoff = FindProperty("_Cutoff", props);

        specularMap1 = FindProperty("_SpecGlossMap1", props, false);
        specularMap2 = FindProperty("_SpecGlossMap2", props, false);
        specularMap3 = FindProperty("_SpecGlossMap3", props, false);
        specularMap4 = FindProperty("_SpecGlossMap4", props, false);
        specularColor = FindProperty("_SpecColor", props, false);

        metallicMap1 = FindProperty("_MetallicGlossMap1", props, false);
        metallicMap2 = FindProperty("_MetallicGlossMap2", props, false);
        metallicMap3 = FindProperty("_MetallicGlossMap3", props, false);
        metallicMap4 = FindProperty("_MetallicGlossMap4", props, false);
        metallic = FindProperty("_Metallic", props, false);

        if (specularMap1 != null && specularColor != null)
            m_WorkflowMode = WorkflowMode.Specular;
        else if (metallicMap1 != null && metallic != null)
            m_WorkflowMode = WorkflowMode.Metallic;
        else
            m_WorkflowMode = WorkflowMode.Dielectric;
        smoothness = FindProperty("_Glossiness", props);
        smoothnessScale = FindProperty("_GlossMapScale", props, false);
        smoothnessMapChannel = FindProperty("_SmoothnessTextureChannel", props, false);
        highlights = FindProperty("_SpecularHighlights", props, false);
        reflections = FindProperty("_GlossyReflections", props, false);

        meshBumpMap = FindProperty("_MeshNormal", props);

        bumpMap1 = FindProperty("_BumpMap1", props);
        bumpMap2 = FindProperty("_BumpMap2", props);
        bumpMap3 = FindProperty("_BumpMap3", props);
        bumpMap4 = FindProperty("_BumpMap4", props);

        enableThirdLayerMaps = FindProperty("_EnableThirdLayerMaps", props, false);
        enableFourthLayerMaps = FindProperty("_EnableFourthLayerMaps", props, false);

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
            MaterialChanged(material, m_WorkflowMode);
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
            DoAlbedoArea(material, Styles.albedo1Text, albedoMap1, Styles.materialScale1Text, materialScale1);
            DoSpecularMetallicArea(Styles.specularMap1Text, specularMap1, Styles.metallicMap1Text, metallicMap1);
            DoNormalArea(Styles.normalMap1Text, bumpMap1);

            // layer 2
            GUILayout.Label(Styles.secondMapsText, EditorStyles.boldLabel);
            DoAlbedoArea(material, Styles.albedo2Text, albedoMap2, Styles.materialScale2Text, materialScale2);
            DoSpecularMetallicArea(Styles.specularMap2Text, specularMap2, Styles.metallicMap2Text, metallicMap2);
            DoNormalArea(Styles.normalMap2Text, bumpMap2);

            m_MaterialEditor.ShaderProperty(enableThirdLayerMaps, Styles.enableThirdLayerMapsText);
            if (enableThirdLayerMaps.floatValue == 1.0)
            {
                // layer 3
                GUILayout.Label(Styles.thirdMapsText, EditorStyles.boldLabel);
                DoAlbedoArea(material, Styles.albedo3Text, albedoMap3, Styles.materialScale3Text, materialScale3);
                DoSpecularMetallicArea(Styles.specularMap3Text, specularMap3, Styles.metallicMap3Text, metallicMap3);
                DoNormalArea(Styles.normalMap3Text, bumpMap3);
            }

            m_MaterialEditor.ShaderProperty(enableFourthLayerMaps, Styles.enableFourthLayerMapsText);
            if (enableFourthLayerMaps.floatValue == 1.0)
            {
                // layer 4
                GUILayout.Label(Styles.fourthMapsText, EditorStyles.boldLabel);
                DoAlbedoArea(material, Styles.albedo4Text, albedoMap4, Styles.materialScale4Text, materialScale4);
                DoSpecularMetallicArea(Styles.specularMap4Text, specularMap4, Styles.metallicMap4Text, metallicMap4);
                DoNormalArea(Styles.normalMap4Text, bumpMap4);
            }

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
                MaterialChanged((Material)obj, m_WorkflowMode);

            BoolPropertyChanged(enableThirdLayerMaps, _enableThirdLayerMapsKeyword);
            BoolPropertyChanged(enableFourthLayerMaps, _enableFourthLayerMapsKeyword);
        }

        EditorGUILayout.Space();

        // NB renderqueue editor is not shown on purpose: we want to override it based on blend mode
        GUILayout.Label(Styles.advancedText, EditorStyles.boldLabel);
        m_MaterialEditor.EnableInstancingField();
        m_MaterialEditor.DoubleSidedGIField();
    }

    internal void DetermineWorkflow(MaterialProperty[] props)
    {
        if (FindProperty("_SpecGlossMap", props, false) != null && FindProperty("_SpecColor", props, false) != null)
            m_WorkflowMode = WorkflowMode.Specular;
        else if (FindProperty("_MetallicGlossMap", props, false) != null && FindProperty("_Metallic", props, false) != null)
            m_WorkflowMode = WorkflowMode.Metallic;
        else
            m_WorkflowMode = WorkflowMode.Dielectric;
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

        DetermineWorkflow(MaterialEditor.GetMaterialProperties(new Material[] { material }));
        MaterialChanged(material, m_WorkflowMode);
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

    void DoNormalArea(GUIContent label, MaterialProperty prop)
    {
        m_MaterialEditor.TexturePropertySingleLine(label, prop);
    }

    void DoAlbedoArea(Material material, GUIContent albedoLabel, MaterialProperty albedoProp, GUIContent materialLabel, MaterialProperty materialProp)
    {
        m_MaterialEditor.TexturePropertySingleLine(albedoLabel, albedoProp);
        m_MaterialEditor.ShaderProperty(materialProp, materialLabel);

        if (((BlendMode)material.GetFloat("_Mode") == BlendMode.Cutout))
        {
            m_MaterialEditor.ShaderProperty(alphaCutoff, Styles.alphaCutoffText.text, MaterialEditor.kMiniTextureFieldLabelIndentLevel + 1);
        }
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

    void DoSpecularMetallicArea(GUIContent specularLabel, MaterialProperty specularProp, GUIContent metallicLabel, MaterialProperty metallicProp)
    {
        bool hasGlossMap = false;
        if (m_WorkflowMode == WorkflowMode.Specular)
        {
            hasGlossMap = specularProp.textureValue != null;
            m_MaterialEditor.TexturePropertySingleLine(specularLabel, specularProp, hasGlossMap ? null : specularColor);
        }
        else if (m_WorkflowMode == WorkflowMode.Metallic)
        {
            hasGlossMap = metallicProp.textureValue != null;
            m_MaterialEditor.TexturePropertySingleLine(metallicLabel, metallicProp, hasGlossMap ? null : metallic);
        }

        bool showSmoothnessScale = hasGlossMap;
        if (smoothnessMapChannel != null)
        {
            int smoothnessChannel = (int)smoothnessMapChannel.floatValue;
            if (smoothnessChannel == (int)SmoothnessMapChannel.AlbedoAlpha)
                showSmoothnessScale = true;
        }

        int indentation = 2; // align with labels of texture properties
        m_MaterialEditor.ShaderProperty(showSmoothnessScale ? smoothnessScale : smoothness, showSmoothnessScale ? Styles.smoothnessScaleText : Styles.smoothnessText, indentation);

        ++indentation;
        if (smoothnessMapChannel != null)
            m_MaterialEditor.ShaderProperty(smoothnessMapChannel, Styles.smoothnessMapChannelText, indentation);
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

    void BoolPropertyChanged(MaterialProperty boolProperty, string keyword)
    {
        bool enabled = boolProperty.floatValue == 1.0;

        foreach (var obj in boolProperty.targets)
        {
            Material mat = (Material)obj;
            if (enabled)
                mat.EnableKeyword(keyword);
            else
                mat.DisableKeyword(keyword);
        }
    }

    static SmoothnessMapChannel GetSmoothnessMapChannel(Material material)
    {
        int ch = (int)material.GetFloat("_SmoothnessTextureChannel");
        if (ch == (int)SmoothnessMapChannel.AlbedoAlpha)
            return SmoothnessMapChannel.AlbedoAlpha;
        else
            return SmoothnessMapChannel.SpecularMetallicAlpha;
    }

    static void SetMaterialKeywords(Material material, WorkflowMode workflowMode)
    {
        // Note: keywords must be based on Material value not on MaterialProperty due to multi-edit & material animation
        // (MaterialProperty value might come from renderer material property block)
        SetKeyword(material, "_NORMALMAP", material.GetTexture("_BumpMap1") || material.GetTexture("_DetailNormalMap"));
        if (workflowMode == WorkflowMode.Specular)
            SetKeyword(material, "_SPECGLOSSMAP", material.GetTexture("_SpecGlossMap1"));
        else if (workflowMode == WorkflowMode.Metallic)
            SetKeyword(material, "_METALLICGLOSSMAP", material.GetTexture("_MetallicGlossMap1"));
        SetKeyword(material, "_PARALLAXMAP", material.GetTexture("_ParallaxMap"));
        SetKeyword(material, "_DETAIL_MULX2", material.GetTexture("_DetailAlbedoMap") || material.GetTexture("_DetailNormalMap"));

        // A material's GI flag internally keeps track of whether emission is enabled at all, it's enabled but has no effect
        // or is enabled and may be modified at runtime. This state depends on the values of the current flag and emissive color.
        // The fixup routine makes sure that the material is in the correct state if/when changes are made to the mode or color.
        MaterialEditor.FixupEmissiveFlag(material);
        bool shouldEmissionBeEnabled = (material.globalIlluminationFlags & MaterialGlobalIlluminationFlags.EmissiveIsBlack) == 0;
        SetKeyword(material, "_EMISSION", shouldEmissionBeEnabled);

        if (material.HasProperty("_SmoothnessTextureChannel"))
        {
            SetKeyword(material, "_SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A", GetSmoothnessMapChannel(material) == SmoothnessMapChannel.AlbedoAlpha);
        }
    }

    static void MaterialChanged(Material material, WorkflowMode workflowMode)
    {
        SetupMaterialWithBlendMode(material, (BlendMode)material.GetFloat("_Mode"));

        SetMaterialKeywords(material, workflowMode);
    }

    static void SetKeyword(Material m, string keyword, bool state)
    {
        if (state)
            m.EnableKeyword(keyword);
        else
            m.DisableKeyword(keyword);
    }
}
