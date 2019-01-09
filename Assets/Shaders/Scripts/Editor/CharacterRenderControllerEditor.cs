//using UnityEngine;
//using UnityEditor;

//[CustomEditor(typeof(CharacterRenderController))]
//public class CharacterRenderControllerEditor : Editor
//{
//    private bool _enableSSS;
//    private bool _enableIce;
//    private bool _enableFire;
//    private bool _enableSemiTransparency;

//    public override void OnInspectorGUI()
//    {
//        CharacterRenderController crc = (CharacterRenderController)target;

//        if (GUILayout.Button("SSS"))
//        {
//            _enableSSS = !_enableSSS;
//            if (_enableSSS)
//                crc.ActiveVFX(CharacterRenderController.RenderPipeline.SSS_KEYWORD);
//            else
//                crc.ActiveVFX(CharacterRenderController.RenderPipeline.DEFAULT_KEYWORD);
//        }

//        if (GUILayout.Button("ICE"))
//        {
//            _enableIce = !_enableIce;
//            if (_enableIce)
//                crc.ActiveVFX(CharacterRenderController.RenderPipeline.ICE_KEYWORD);
//            else
//                crc.ActiveVFX(CharacterRenderController.RenderPipeline.DEFAULT_KEYWORD);
//        }

//        if (GUILayout.Button("FIRE"))
//        {
//            _enableFire = !_enableFire;
//            if (_enableFire)
//                crc.ActiveVFX(CharacterRenderController.RenderPipeline.FIRE_KEYWORD);
//            else
//                crc.ActiveVFX(CharacterRenderController.RenderPipeline.DEFAULT_KEYWORD);
//        }

//        if (GUILayout.Button("SEMI-TRANSPARENCY"))
//        {
//            _enableSemiTransparency = !_enableSemiTransparency;
//            if (_enableSemiTransparency)
//                crc.ActiveVFX(CharacterRenderController.RenderPipeline.SEMI_TRANSPARENCY_KEYWORD);
//            else
//                crc.ActiveVFX(CharacterRenderController.RenderPipeline.DEFAULT_KEYWORD);
//        }
//    }
//}