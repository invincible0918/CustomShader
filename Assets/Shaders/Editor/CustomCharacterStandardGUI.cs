// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

using System;
using UnityEngine;
using UnityEditor;

public class CustomCharacterStandardGUI : CustomPBRGUI
{
    private static class _Styles
    {
        public static GUIContent enableSSSText = new GUIContent("Enable SSS", "Enable SSS");

        public static GUIContent thicknessMapText = new GUIContent("Thickness Map", "Thickness Map");
        public static GUIContent thicknessScaleText = new GUIContent("Thickness Scale", "Thickness Scale");

        public static GUIContent distortionText = new GUIContent("Distortion", "Distortion");

        public static GUIContent backgroundLightDirectionText = new GUIContent("Background Light Direction", "Background Light Direction");
        public static GUIContent backgroundLightColorText = new GUIContent("Background Light Color", "Background Light Color");
        public static GUIContent backgroundLightScaleText = new GUIContent("Background Light Scale", "Background Light Scale");

        public static GUIContent ltPowerText = new GUIContent("LT Power", "LT Power");
        public static GUIContent ltScaleText = new GUIContent("LT Scale", "LT Scale");
    }

    MaterialProperty enableSSS = null;

    MaterialProperty thicknessMap = null;
    MaterialProperty thicknessScale = null;

    MaterialProperty distortion = null;

    MaterialProperty backgroundLightDirection = null;
    MaterialProperty backgroundLightColor = null;
    MaterialProperty backgroundLightScale = null;

    MaterialProperty ltPower = null;
    MaterialProperty ltScale = null;

    private string _enableSSSKeyword = "_ENABLE_SSS";

    protected override void FindCustomProperties(MaterialProperty[] props)
    {
        enableSSS = FindProperty("_EnableSSS", props, false);

        thicknessMap = FindProperty("_ThicknessMap", props);
        thicknessScale = FindProperty("_ThicknessScale", props);

        distortion = FindProperty("_Distortion", props);

        backgroundLightDirection = FindProperty("_BackgroundLightDirection", props);
        backgroundLightColor = FindProperty("_BackgroundLightColor", props);
        backgroundLightScale = FindProperty("_BackgroundLightScale", props);

        ltPower = FindProperty("_LTPower", props);
        ltScale = FindProperty("_LTScale", props);
    }

    protected override void DoCustomPropertiesArea()
    {
        #region SSS
        m_MaterialEditor.ShaderProperty(enableSSS, _Styles.enableSSSText);
        if (enableSSS.floatValue == 1.0)
        {
            m_MaterialEditor.TexturePropertySingleLine(_Styles.thicknessMapText, thicknessMap);
            m_MaterialEditor.ShaderProperty(thicknessScale, _Styles.thicknessScaleText);

            m_MaterialEditor.ShaderProperty(distortion, _Styles.distortionText.text);

            m_MaterialEditor.ShaderProperty(backgroundLightDirection, _Styles.backgroundLightDirectionText.text);
            m_MaterialEditor.ShaderProperty(backgroundLightColor, _Styles.backgroundLightColorText.text);
            m_MaterialEditor.ShaderProperty(backgroundLightScale, _Styles.backgroundLightScaleText.text);

            m_MaterialEditor.ShaderProperty(ltPower, _Styles.ltPowerText.text);
            m_MaterialEditor.ShaderProperty(ltScale, _Styles.ltScaleText.text);
        }
        #endregion
    }

    protected override void DoCustomBoolPropertiesChanged()
    {
        BoolPropertyChanged(enableSSS, _enableSSSKeyword);
    }
}
