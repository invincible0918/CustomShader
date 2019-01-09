using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[System.Serializable]
public class CharacterRenderController : MonoBehaviour
{
    public CharacterFXInfoList CFXInfoList;

    private void InitMaterials()
    {
        foreach (CharacterFXInfo cfxInfo in CFXInfoList.CFXInfoList)
            cfxInfo.Initialize(gameObject);
    }

    private void ResetDefaultMaterials()
    {
        foreach (CharacterFXInfo cfxInfo in CFXInfoList.CFXInfoList)
        {
            if (cfxInfo.CFXName.Equals(CharacterFXInfo.DEFAULT_KEYWORD))
            {
                cfxInfo.Reset();
                break;
            }
        }
    }

    private void OnEnable()
    {
        InitMaterials();
        ActiveVFX(CharacterFXInfo.DEFAULT_KEYWORD);
        ResetDefaultMaterials();
    }

    [ContextMenu("ActiveDEFAULT")]
    public void ActiveDEFAULT()
    {
        ActiveVFX(CharacterFXInfo.DEFAULT_KEYWORD);
        ResetDefaultMaterials();
    }

    [ContextMenu("ActiveSSS")]
    public void ActiveSSS()
    {
        ActiveVFX(CharacterFXInfo.SSS_KEYWORD);
    }

    [ContextMenu("ActiveDissolve")]
    public void ActiveDissolve()
    {
        ActiveVFX(CharacterFXInfo.DISSOLVE_KEYWORD);
    }

    [ContextMenu("ActiveAdvancedDissolve")]
    public void ActiveAdvancedDissolve()
    {
        ActiveVFX(CharacterFXInfo.ADVANCED_DISSOLVE_KEYWORD);
    }

    [ContextMenu("ActiveIce")]
    public void ActiveICE()
    {
        ActiveVFX(CharacterFXInfo.ICE_KEYWORD);
    }

    [ContextMenu("ActiveSemiTransparency")]
    public void ActiveSemiTransparency()
    {
        ActiveVFX(CharacterFXInfo.SEMI_TRANSPARENCY_KEYWORD);
    }

    [ContextMenu("ActiveMosaic")]
    public void ActiveMosaic()
    {
        ActiveVFX(CharacterFXInfo.MOSAIC_KEYWORD);
    }

    [ContextMenu("ActiveMatcap")]
    public void ActiveMatcap()
    {
        ActiveVFX(CharacterFXInfo.MATCAP_KEYWORD);
    }

    public void ActiveVFX(string keyword)
    {
        foreach(CharacterFXInfo cfxInfo in CFXInfoList.CFXInfoList)
            cfxInfo.Active(cfxInfo.CFXName.Equals(keyword));
    }
}
