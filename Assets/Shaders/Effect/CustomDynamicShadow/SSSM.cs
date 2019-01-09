using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class SSSM : MonoBehaviour
{
    public int TextureSize = 512;

    public Shader ShadowCaster;

    public Transform CharacterTarget;

    public RenderTexture DepthTexture = null;

    private Camera _cam = null;
    private CommandBuffer _commandBuffer;

    private Material _shadowCasterMat;

    private Renderer[] _renderers;

    public Shader Shader;
    private Material _material;

    // Creates a private material used to the effect
    void OnEnable ()
    {
        _material = new Material(Shader);
        _cam = GetComponent<Camera>();
        //if (ShadowRT)
        //    DestroyImmediate(ShadowRT);

        //ShadowRT = new RenderTexture(TextureSize, TextureSize, 0, RenderTextureFormat.R8, RenderTextureReadWrite.Linear)
        //{
        //    name = "ShadowRT_" + GetInstanceID(),
        //    isPowerOfTwo = true,
        //    hideFlags = HideFlags.DontSave,
        //    antiAliasing = 1,   // no antiAliasing
        //    filterMode = FilterMode.Bilinear,
        //    wrapMode = TextureWrapMode.Clamp
        //};

        //// Create render camera
        _cam = gameObject.GetComponent<Camera>();
        //if (_cam == null)
        //    _cam = gameObject.AddComponent<Camera>();

        //_cam.RemoveAllCommandBuffers();
        //if (_commandBuffer != null)
        //{
        //    _commandBuffer.Dispose();
        //    _commandBuffer = null;
        //}

        //_commandBuffer = new CommandBuffer();
        //_cam.AddCommandBuffer(CameraEvent.BeforeImageEffectsOpaque, _commandBuffer);

        //if (_shadowCasterMat == null && ShadowCaster != null)
        //{
        //    _shadowCasterMat = new Material(ShadowCaster)
        //    {
        //        hideFlags = HideFlags.HideAndDontSave
        //    };
    

        //// Create render target
        //if (CharacterTarget != null)
        //    _renderers = CharacterTarget.GetComponentsInChildren<Renderer>(includeInactive: false);


        _cam.depthTextureMode = DepthTextureMode.Depth;
    }

    //void OnPreRender()
    //{
    //    if (DepthTexture)
    //    {
    //        RenderTexture.ReleaseTemporary(DepthTexture);
    //        DepthTexture = null;
    //    }
    //    Camera depthCam;
    //    if (depthCamObj == null)
    //    {
    //        depthCamObj = new GameObject("DepthCamera");
    //        depthCamObj.AddComponent<Camera>();
    //        depthCam = depthCamObj.GetComponent<Camera>();
    //        depthCam.enabled = false;
    //        // depthCamObj.hideFlags = HideFlags.HideAndDontSave;
    //    }
    //    else
    //    {
    //        depthCam = depthCamObj.GetComponent<Camera>();
    //    }

    //    depthCam.CopyFrom(mCam);
    //    DepthTexture = RenderTexture.GetTemporary(mCam.pixelWidth, mCam.pixelHeight, 16, RenderTextureFormat.ARGB32);
    //    depthCam.backgroundColor = new Color(0, 0, 0, 0);
    //    depthCam.clearFlags = CameraClearFlags.SolidColor;

    //    depthCam.targetTexture = DepthTexture;
    //    depthCam.RenderWithShader(mCopyShader, "RenderType");
    //    mMat.SetTexture("_DepthTexture", DepthTexture);
    //}

    void Update()
    {
        if (!_shadowCasterMat)
            return;

        if (_renderers == null)
            return;

        ////_cam.depthTextureMode = DepthTextureMode.Depth;
        //_cam.clearFlags = CameraClearFlags.Color;
        //_cam.backgroundColor = Color.black;
        //_cam.orthographic = true;
        //_cam.orthographicSize = projector.orthographicSize;
        //_cam.depth = -100.0f;
        //_cam.nearClipPlane = projector.nearClipPlane;
        //_cam.farClipPlane = projector.farClipPlane;
        //_cam.targetTexture = _shadowRT;
        //_cam.cullingMask = CharacterLayer.value;

        //// Create command buffer
        //_cam.cullingMask = 0;




    }

    // Postprocess the image
    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //_commandBuffer.Clear();

        //foreach (Renderer render in _renderers)
        //{
        //    if (render == null)
        //        continue;

        //    _commandBuffer.DrawRenderer(render, _shadowCasterMat);
        //}

        //Matrix4x4 VP = GL.GetGPUProjectionMatrix(_cam.projectionMatrix, false) * _cam.worldToCameraMatrix;
        //_material.SetMatrix("_VPMatrix", VP);
        //_material.SetTexture("_ShadowTex", ShadowRT);

        //_commandBuffer.Clear();


        //foreach (Renderer render in _renderers)
        //{
        //    if (render == null)
        //        continue;

        //    _commandBuffer.DrawRenderer(render, _shadowCasterMat);
        //}

        //Matrix4x4 VP = GL.GetGPUProjectionMatrix(_cam.projectionMatrix, false) * _cam.worldToCameraMatrix;
        //_material.SetMatrix("_VPMatrix", VP);
        //_material.SetTexture("_ShadowTex", ShadowRT);




        Graphics.Blit(source, destination, _material);
    }

    void OnDisable()
    {
        //if (ShadowRT != null)
        //{
        //    _cam.targetTexture = null;
        //    DestroyImmediate(ShadowRT);
        //    ShadowRT = null;
        //}

        if (_shadowCasterMat != null)
            DestroyImmediate(_shadowCasterMat);
    }
}