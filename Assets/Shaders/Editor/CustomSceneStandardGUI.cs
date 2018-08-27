// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

using System;
using UnityEngine;
using UnityEditor;

public class CustomSceneStandardGUI : CustomPBRGUI
{
    private static class _Styles
    {
        public static GUIContent enableChangedColorText = new GUIContent("Enable Changed Color", "Enable Changed Color");
        public static GUIContent changedColorText = new GUIContent("Changed Color", "Changed Color");
        public static GUIContent changedColorMaskText = new GUIContent("Changed Color Mask", "Changed Color Mask");

        public static GUIContent enableRealTimeReflectionText = new GUIContent("Enable Real Time Reflection", "Enable Real Time Reflection");

        public static GUIContent foamTextureText = new GUIContent("Foam Texture", "Foam Texture");
        public static GUIContent noiseTextureText = new GUIContent("Noise Texture", "Noise Texture");
        public static GUIContent enableWaterText = new GUIContent("Enable Water", "Enable Water");
        public static GUIContent causticScaleText = new GUIContent("Caustic Scale", "Caustic Scale");
        public static GUIContent waterNormalScaleUText = new GUIContent("Water Normal Scale U", "Water Normal Scale U");
        public static GUIContent waterNormalScaleVText = new GUIContent("Water Normal Scale V", "Water Normal Scale V");
        public static GUIContent waterNormalIntensityText = new GUIContent("Water Normal Intensity", "Water Normal Intensity");
        public static GUIContent enableWaterReflectionAndRefractionText = new GUIContent("Enable Water Reflection/Refraction", "Enable Water Reflection/Refraction");
    }

    MaterialProperty enableChangedColor = null;
    MaterialProperty changedColor = null;
    MaterialProperty changedColorMask = null;

    MaterialProperty enableRealTimeReflection = null;

    MaterialProperty foamTexture = null;
    MaterialProperty noiseTexture = null;
    MaterialProperty enableWater = null;
    MaterialProperty enableWaterReflectionAndRefraction = null;
    MaterialProperty causticScale = null;
    MaterialProperty waterNormalScaleU = null;
    MaterialProperty waterNormalScaleV = null;
    MaterialProperty waterNormalIntensity = null;

    private string _enableChangedColorKeyword = "_ENABLE_CHANGED_COLOR";
    private string _enableRealTimeReflectionKeyword = "_ENABLE_REALTIME_REFLECTION";
    private string _enableWaterKeyword = "_ENABLE_WATER";
    private string _enableWaterReflectionAndRefractionKeyword = "_ENABLE_WATER_REFLECTION_AND_REFRACTION";

    protected override void FindCustomProperties(MaterialProperty[] props)
    {
        enableChangedColor = FindProperty("_EnableChangedColor", props, false);
        changedColor = FindProperty("_ChangedColor", props);
        changedColorMask = FindProperty("_ChangedColorMask", props);

        enableRealTimeReflection = FindProperty("_EnableRealTimeReflection", props, false);

        enableWater = FindProperty("_EnableWater", props, false);
        foamTexture = FindProperty("_FoamTex", props);
        noiseTexture = FindProperty("_NoiseTex", props);
        causticScale = FindProperty("_CausticScale", props);
        waterNormalScaleU = FindProperty("_WaterNormalScaleU", props);
        waterNormalScaleV = FindProperty("_WaterNormalScaleV", props);
        waterNormalIntensity = FindProperty("_WaterNormalIntensity", props);
        enableWaterReflectionAndRefraction = FindProperty("_EnableWaterReflectionAndRefraction", props);
    }

    protected override void DoCustomPropertiesArea()
    {
        #region Changed Color
        m_MaterialEditor.ShaderProperty(enableChangedColor, _Styles.enableChangedColorText);
        if (enableChangedColor.floatValue == 1.0)
        {
            m_MaterialEditor.ShaderProperty(changedColor, _Styles.changedColorText);
            m_MaterialEditor.TexturePropertySingleLine(_Styles.changedColorMaskText, changedColorMask);
        }
        #endregion

        #region Realtime Reflection
        m_MaterialEditor.ShaderProperty(enableRealTimeReflection, _Styles.enableRealTimeReflectionText);
        #endregion

        #region Water
        m_MaterialEditor.ShaderProperty(enableWater, _Styles.enableWaterText);
        if (enableWater.floatValue == 1.0)
        {
            m_MaterialEditor.TexturePropertySingleLine(_Styles.foamTextureText, foamTexture);
            m_MaterialEditor.TexturePropertySingleLine(_Styles.noiseTextureText, noiseTexture);

            m_MaterialEditor.ShaderProperty(causticScale, _Styles.causticScaleText);
            m_MaterialEditor.ShaderProperty(waterNormalScaleU, _Styles.waterNormalScaleUText);
            m_MaterialEditor.ShaderProperty(waterNormalScaleV, _Styles.waterNormalScaleVText);
            m_MaterialEditor.ShaderProperty(waterNormalIntensity, _Styles.waterNormalIntensityText);

            m_MaterialEditor.ShaderProperty(enableWaterReflectionAndRefraction, _Styles.enableWaterReflectionAndRefractionText);
        }
        #endregion
    }

    protected override void DoCustomBoolPropertiesChanged()
    {
        BoolPropertyChanged(enableChangedColor, _enableChangedColorKeyword);
        BoolPropertyChanged(enableRealTimeReflection, _enableRealTimeReflectionKeyword);
        BoolPropertyChanged(enableWater, _enableWaterKeyword);
        BoolPropertyChanged(enableWaterReflectionAndRefraction, _enableWaterReflectionAndRefractionKeyword);
    }
}
