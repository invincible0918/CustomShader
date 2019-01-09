// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

using System;
using UnityEngine;
using UnityEditor;

public class PopcapSceneStandardGUI : PopcapPBRGUI
{
    private static class _Styles
    {
        public static GUIContent shaderTierText = new GUIContent("Shader Tier", "Shader Tier");

        public static GUIContent enableRealTimeReflectionText = new GUIContent("Enable Real Time Reflection", "Enable Real Time Reflection");

        public static GUIContent enablePondWaterText = new GUIContent("Enable Pond Water", "Enable Pond Water");

        public static GUIContent fakeMainLightText = new GUIContent("\tFake Main Light", "Fake Main Light");
        public static GUIContent fakeMainLightDirectionText = new GUIContent("\tFake Main Light Direction", "Fake Main Light Direction");
        public static GUIContent fakeMainLightColorText = new GUIContent("\tFake Main Light Color", "Fake Main Light Color");
        public static GUIContent fakeShininessText = new GUIContent("\tFake Shininess", "Fake Shininess");
        public static GUIContent fakeSpecualrScaleText = new GUIContent("\tFake Specualr Scale", "Fake Specualr Scale");
    }

    MaterialProperty shaderTier = null;

    MaterialProperty enableRealTimeReflection = null;

    MaterialProperty enablePondWater = null;

    MaterialProperty fakeMainLightDirection = null;
    MaterialProperty fakeMainLightColor = null;
    MaterialProperty fakeShininess = null;
    MaterialProperty fakeSpecualrScale = null;

    private string _enableRealTimeReflectionKeyword = "_ENABLE_REALTIME_REFLECTION";
    private string _enablePondWaterKeyword = "_ENABLE_POND_WATER";
    private string _shaderTier0Keyword = "_SHADER_TIER_0";
    private string _shaderTier1Keyword = "_SHADER_TIER_1";
    private string _shaderTier2Keyword = "_SHADER_TIER_2";

    protected override void FindCustomProperties(MaterialProperty[] props)
    {
        shaderTier = FindProperty("_ShaderTier", props);

        enableRealTimeReflection = FindProperty("_EnableRealTimeReflection", props, false);

        enablePondWater = FindProperty("_EnablePondWater", props, false);
        fakeMainLightDirection = FindProperty("_FakeMainLightDirection", props);
        fakeMainLightColor = FindProperty("_FakeMainLightColor", props);
        fakeShininess = FindProperty("_FakeShininess", props);
        fakeSpecualrScale = FindProperty("_FakeSpecualrScale", props);
    }

    protected override void DoCustomPropertiesArea()
    {
        #region Realtime Reflection
        m_MaterialEditor.ShaderProperty(enableRealTimeReflection, _Styles.enableRealTimeReflectionText);
        #endregion

        #region Pond Water
        m_MaterialEditor.ShaderProperty(enablePondWater, _Styles.enablePondWaterText);
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
        BoolPropertyChanged(enableRealTimeReflection, _enableRealTimeReflectionKeyword);
        BoolPropertyChanged(enablePondWater, _enablePondWaterKeyword);

        bool shaderTier0 = false;
        bool shaderTier1 = false;
        bool shaderTier2 = false;

        if ( shaderTier.floatValue >= 1.0 && shaderTier.floatValue < 2.0)
            shaderTier0 = true;
        else if (shaderTier.floatValue >= 2.0 && shaderTier.floatValue < 3.0)
            shaderTier1 = true;

        BoolPropertyChanged(shaderTier, _shaderTier0Keyword, shaderTier0);
        BoolPropertyChanged(shaderTier, _shaderTier1Keyword, shaderTier1);
        BoolPropertyChanged(shaderTier, _shaderTier2Keyword, shaderTier2);
    }
}   
