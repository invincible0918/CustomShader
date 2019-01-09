// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

using System;
using UnityEngine;
using UnityEditor;

public class PopcapCharacterStandardGUI : PopcapPBRGUI
{
    private static class _Styles
    {
        public static GUIContent characterVFXText = new GUIContent("Character VFX", "Character VFX");
        public static GUIContent enableSSSText = new GUIContent("\tEnable SSS", "Enable SSS");
        public static GUIContent thicknessMapText = new GUIContent("\tThickness Map", "Thickness Map");
        public static GUIContent enableIceText = new GUIContent("\tEnable Ice", "Enable Ice");
        public static GUIContent enableFireText = new GUIContent("\tEnable Fire", "Enable Fire");

        public static GUIContent shaderTierText = new GUIContent("Shader Tier", "Shader Tier");

        public static GUIContent fakeMainLightText = new GUIContent("\tFake Main Light", "Fake Main Light");
        public static GUIContent fakeMainLightDirectionText = new GUIContent("\tFake Main Light Direction", "Fake Main Light Direction");
        public static GUIContent fakeMainLightColorText = new GUIContent("\tFake Main Light Color", "Fake Main Light Color");
        public static GUIContent fakeShininessText = new GUIContent("\tFake Shininess", "Fake Shininess");
        public static GUIContent fakeSpecualrScaleText = new GUIContent("\tFake Specualr Scale", "Fake Specualr Scale");
    }

    // Lots of character vfx lives here
    MaterialProperty enableSSS = null;
    MaterialProperty enableIce = null;
    MaterialProperty enableFire = null;

    MaterialProperty shaderTier = null;

    MaterialProperty thicknessMap = null;

    MaterialProperty fakeMainLightDirection = null;
    MaterialProperty fakeMainLightColor = null;
    MaterialProperty fakeShininess = null;
    MaterialProperty fakeSpecualrScale = null;

    private string _enableSSSKeyword = "_ENABLE_SSS";
    private string _enableIceKeyword = "_ENABLE_ICE";
    private string _enableFireKeyword = "_ENABLE_FIRE";

    private string _shaderTier0Keyword = "_SHADER_TIER_0";
    private string _shaderTier1Keyword = "_SHADER_TIER_1";
    private string _shaderTier2Keyword = "_SHADER_TIER_2";

    protected override void FindCustomProperties(MaterialProperty[] props)
    {
        shaderTier = FindProperty("_ShaderTier", props);

        enableSSS = FindProperty("_EnableSSS", props, false);
        thicknessMap = FindProperty("_ThicknessMap", props);

        enableIce = FindProperty("_EnableIce", props, false);
        enableFire = FindProperty("_EnableFire", props, false);

        fakeMainLightDirection = FindProperty("_FakeMainLightDirection", props);
        fakeMainLightColor = FindProperty("_FakeMainLightColor", props);
        fakeShininess = FindProperty("_FakeShininess", props);
        fakeSpecualrScale = FindProperty("_FakeSpecualrScale", props);
    }

    protected override void DoCustomPropertiesArea()
    {
        #region Character VFX
        GUILayout.Label(_Styles.characterVFXText, EditorStyles.boldLabel);
        m_MaterialEditor.ShaderProperty(enableSSS, _Styles.enableSSSText);
        if (enableSSS.floatValue == 1.0)
            m_MaterialEditor.TexturePropertySingleLine(_Styles.thicknessMapText, thicknessMap);

        m_MaterialEditor.ShaderProperty(enableIce, _Styles.enableIceText);
        m_MaterialEditor.ShaderProperty(enableFire, _Styles.enableFireText);
        EditorGUILayout.Space();
        #endregion

        #region Shader Tier
        m_MaterialEditor.ShaderProperty(shaderTier, _Styles.shaderTierText);
        if (shaderTier.floatValue == 2.0)
        {
            GUILayout.Label(_Styles.fakeMainLightText, EditorStyles.boldLabel);
            m_MaterialEditor.ShaderProperty(fakeMainLightDirection, _Styles.fakeMainLightDirectionText);
            m_MaterialEditor.ShaderProperty(fakeMainLightColor, _Styles.fakeMainLightColorText);
            m_MaterialEditor.ShaderProperty(fakeShininess, _Styles.fakeShininessText);
            m_MaterialEditor.ShaderProperty(fakeSpecualrScale, _Styles.fakeSpecualrScaleText);
            EditorGUILayout.Space();
        }
        #endregion
    }

    protected override void DoCustomBoolPropertiesChanged()
    {
        BoolPropertyChanged(enableSSS, _enableSSSKeyword);
        BoolPropertyChanged(enableIce, _enableIceKeyword);
        BoolPropertyChanged(enableFire, _enableFireKeyword);

        bool shaderTier0 = false;
        bool shaderTier1 = false;
        bool shaderTier2 = false;

        if (shaderTier.floatValue >= 1.0 && shaderTier.floatValue < 2.0)
            shaderTier0 = true;
        else if (shaderTier.floatValue >= 2.0 && shaderTier.floatValue < 3.0)
            shaderTier1 = true;

        BoolPropertyChanged(shaderTier, _shaderTier0Keyword, shaderTier0);
        BoolPropertyChanged(shaderTier, _shaderTier1Keyword, shaderTier1);
        BoolPropertyChanged(shaderTier, _shaderTier2Keyword, shaderTier2);
    }
}
