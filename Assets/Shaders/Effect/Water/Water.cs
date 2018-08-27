using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Water : MonoBehaviour
{
    public int TextureSize = 512;
    public float ReflectionClipPlaneOffset = 0.07f;
    public float RefractionClipPlaneOffset = -0.01f;
    public float RefractionAngle = 0;

    public bool RealtimeWater = false;

    public LayerMask ReflectLayers = -1;

    public Material WaterMaterial = null;

    public Material CausticMaterial = null;

    public Texture2D CausticTexture;
    public Texture2D FoamTexture;

    public Texture2D NoiseTexture;

    private RenderTexture _reflectionRT;
    private RenderTexture _refractionRT;

    private Camera _reflectionCamera;
    private Camera _refractionCamera;

    private int _oldRTSize = 0;
    private static bool insideRendering = false;

    void OnEnable()
    {
        if (WaterMaterial == null)
        {
            Renderer renderer = GetComponentInChildren<Renderer>();
            WaterMaterial = renderer.sharedMaterial;
        }
        WaterMaterial.SetTexture("_FoamTex", FoamTexture);
        WaterMaterial.SetTexture("_NoiseTex", NoiseTexture);

        if (CausticTexture != null && CausticMaterial != null)
            CausticMaterial.SetTexture("_MainTex", CausticTexture);
    }

    // Cleanup all the objects we possibly have created
    void OnDisable()
    {
        ReleaseRT();
    }

    // This is called when it's known that the object will be rendered by some
    // camera. We render reflections and do other updates here.
    // Because the script executes in edit mode, reflections for the scene view
    // camera will just work!
    void OnWillRenderObject()
    {
        Camera cam = Camera.current;
        if (!cam)
            return;

        // Safeguard from recursive reflections.        
        if (insideRendering)
            return;
        insideRendering = true;

        // Render water now
        if (RealtimeWater)
        {
            WaterMaterial.EnableKeyword("_ENABLE_WATER_REFLECTION_AND_REFRACTION");
            WaterMaterial.SetFloat("_EnableWaterReflectionAndRefraction", 1.0f);
            RenderReflectionRT(cam);
            RenderRefractionRT(cam);
        }
        else
        {
            WaterMaterial.DisableKeyword("_ENABLE_WATER_REFLECTION_AND_REFRACTION");
            WaterMaterial.SetFloat("_EnableWaterReflectionAndRefraction", 0.0f);
            ReleaseRT();
        }

        insideRendering = false;
    }

    private void ReleaseRT()
    {
        if (_reflectionRT)
        {
            DestroyImmediate(_reflectionRT);
            _reflectionRT = null;
        }
        if (_reflectionCamera)
        {
            DestroyImmediate(_reflectionCamera.gameObject);
            _reflectionCamera = null;
        }

        if (_refractionRT)
        {
            DestroyImmediate(_refractionRT);
            _refractionRT = null;
        }
        if (_refractionCamera)
        {
            DestroyImmediate(_refractionCamera.gameObject);
            _refractionCamera = null;
        }
    }

    private void UpdateCameraModes(Camera src, Camera dest)
    {
        if (dest == null)
            return;
        // set camera to clear the same way as current camera
        dest.clearFlags = src.clearFlags;
        dest.backgroundColor = src.backgroundColor;
        if (src.clearFlags == CameraClearFlags.Skybox)
        {
            Skybox sky = src.GetComponent(typeof(Skybox)) as Skybox;
            Skybox mysky = dest.GetComponent(typeof(Skybox)) as Skybox;
            if (!sky || !sky.material)
            {
                mysky.enabled = false;
            }
            else
            {
                mysky.enabled = true;
                mysky.material = sky.material;
            }
        }
        // update other values to match current camera.
        // even if we are supplying custom camera&projection matrices,
        // some of values are used elsewhere (e.g. skybox uses far plane)
        dest.farClipPlane = src.farClipPlane;
        dest.nearClipPlane = src.nearClipPlane;
        dest.orthographic = src.orthographic;
        dest.fieldOfView = src.fieldOfView;
        dest.aspect = src.aspect;
        dest.orthographicSize = src.orthographicSize;
    }

    // On-demand create any objects we need
    private void CreateMirrorObjects(Camera currentCamera, ref Camera renderCamera, ref RenderTexture rt)
    {
        if (!rt || _oldRTSize != TextureSize)
        {
            if (rt)
                DestroyImmediate(rt);

            rt = new RenderTexture(TextureSize, TextureSize, 0)
            {
                name = "__RenderTexture" + GetInstanceID(),
                isPowerOfTwo = true,
                hideFlags = HideFlags.DontSave
            };
            _oldRTSize = TextureSize;
        }

        if (!renderCamera) 
        {
            GameObject go = new GameObject("Mirror Refl Camera id" + GetInstanceID() + " for " + currentCamera.GetInstanceID(), typeof(Camera), typeof(Skybox));
            renderCamera = go.GetComponent<Camera>();
            renderCamera.enabled = false;
            renderCamera.transform.position = transform.position;
            renderCamera.transform.rotation = transform.rotation;
            renderCamera.gameObject.AddComponent<FlareLayer>();
            go.hideFlags = HideFlags.HideAndDontSave;
        }
    }

    // Given position/normal of the plane, calculates plane in camera space.
    private Vector4 CameraSpacePlane(Camera cam, Vector3 pos, Vector3 normal, float sideSign, float clipPlaneOffset)
    {
        Vector3 offsetPos = pos + normal * clipPlaneOffset;
        Matrix4x4 m = cam.worldToCameraMatrix;
        Vector3 cpos = m.MultiplyPoint(offsetPos);
        Vector3 cnormal = m.MultiplyVector(normal).normalized * sideSign;
        return new Vector4(cnormal.x, cnormal.y, cnormal.z, -Vector3.Dot(cpos, cnormal));
    }

    // Calculates reflection matrix around the given plane
    private void CalculateReflectionMatrix(ref Matrix4x4 reflectionMat, Vector4 plane)
    {
        reflectionMat.m00 = (1F - 2F * plane[0] * plane[0]);
        reflectionMat.m01 = (-2F * plane[0] * plane[1]);
        reflectionMat.m02 = (-2F * plane[0] * plane[2]);
        reflectionMat.m03 = (-2F * plane[3] * plane[0]);

        reflectionMat.m10 = (-2F * plane[1] * plane[0]);
        reflectionMat.m11 = (1F - 2F * plane[1] * plane[1]);
        reflectionMat.m12 = (-2F * plane[1] * plane[2]);
        reflectionMat.m13 = (-2F * plane[3] * plane[1]);

        reflectionMat.m20 = (-2F * plane[2] * plane[0]);
        reflectionMat.m21 = (-2F * plane[2] * plane[1]);
        reflectionMat.m22 = (1F - 2F * plane[2] * plane[2]);
        reflectionMat.m23 = (-2F * plane[3] * plane[2]);

        reflectionMat.m30 = 0F;
        reflectionMat.m31 = 0F;
        reflectionMat.m32 = 0F;
        reflectionMat.m33 = 1F;
    }

    private void RenderReflectionRT(Camera cam)
    {
        Vector3 pos = transform.position;
        Vector3 normal = transform.up;

        CreateMirrorObjects(cam, ref _reflectionCamera, ref _reflectionRT);

        UpdateCameraModes(cam, _reflectionCamera);

        float d = -Vector3.Dot(normal, pos) - ReflectionClipPlaneOffset;
        Vector4 reflectionPlane = new Vector4(normal.x, normal.y, normal.z, d);

        Matrix4x4 reflection = Matrix4x4.zero;
        CalculateReflectionMatrix(ref reflection, reflectionPlane);
        Vector3 oldpos = cam.transform.position;
        Vector3 newpos = reflection.MultiplyPoint(oldpos);
        _reflectionCamera.worldToCameraMatrix = cam.worldToCameraMatrix * reflection;

        // Setup oblique projection matrix so that near plane is our reflection
        // plane. This way we clip everything below/above it for free.
        Vector4 clipPlane = CameraSpacePlane(_reflectionCamera, pos, normal, 1.0f, ReflectionClipPlaneOffset);
        //Matrix4x4 projection = cam.projectionMatrix;
        Matrix4x4 projection = cam.CalculateObliqueMatrix(clipPlane);
        _reflectionCamera.projectionMatrix = projection;

        _reflectionCamera.cullingMask = ~(1 << 4) & ReflectLayers.value; // never render water layer
        _reflectionCamera.targetTexture = _reflectionRT;
        GL.invertCulling = true;
        _reflectionCamera.transform.position = newpos;
        Vector3 euler = cam.transform.eulerAngles;
        _reflectionCamera.transform.eulerAngles = new Vector3(0, euler.y, euler.z);
        _reflectionCamera.Render();
        _reflectionCamera.transform.position = oldpos;
        GL.invertCulling = false;

        WaterMaterial.SetTexture("_ReflectionTex", _reflectionRT);
    }

    // Calculates reflection matrix around the given plane
    private void CalculateRefractionMatrix(ref Matrix4x4 refractionMat)
    {
        refractionMat *= Matrix4x4.Scale(new Vector3(1, Mathf.Clamp(1 - RefractionAngle, 0.001f, 1), 1));
    }

    private Matrix4x4 Tex2DProj2Tex2D(Transform transform, Camera cam)
    {
        Matrix4x4 scaleOffset = Matrix4x4.TRS(
            new Vector3(0.5f, 0.5f, 0.5f), Quaternion.identity, new Vector3(0.5f, 0.5f, 0.5f));
        Vector3 scale = transform.lossyScale;
        Matrix4x4 _ProjMatrix = transform.localToWorldMatrix * Matrix4x4.Scale(new Vector3(1.0f / scale.x, 1.0f / scale.y, 1.0f / scale.z));
        _ProjMatrix = scaleOffset * cam.projectionMatrix * cam.worldToCameraMatrix * _ProjMatrix;
        return _ProjMatrix;
    }

    private void RenderRefractionRT(Camera cam)
    {
        // Don't render self
        gameObject.layer = 4;

        Vector3 pos = transform.position;
        Vector3 normal = transform.up;

        CreateMirrorObjects(cam, ref _refractionCamera, ref _refractionRT);

        UpdateCameraModes(cam, _refractionCamera);

        Matrix4x4 refraction = cam.worldToCameraMatrix;
        CalculateRefractionMatrix(ref refraction);
        _refractionCamera.worldToCameraMatrix = refraction;

        Vector4 clipPlane = CameraSpacePlane(_refractionCamera, pos, normal, 1.0f, RefractionClipPlaneOffset);
        Matrix4x4 projection = cam.projectionMatrix;
        projection[2] = clipPlane.x + projection[3];//x
        projection[6] = clipPlane.y + projection[7];//y
        projection[10] = clipPlane.z + projection[11];//z
        projection[14] = clipPlane.w + projection[15];//w
        _refractionCamera.projectionMatrix = projection;

        _refractionCamera.cullingMask = ~(1 << 4) & ReflectLayers.value; // never render water layer
        _refractionCamera.targetTexture = _refractionRT;
        _refractionCamera.transform.position = cam.transform.position;
        _refractionCamera.transform.eulerAngles = cam.transform.eulerAngles;
        _refractionCamera.Render();

        WaterMaterial.SetTexture("_RefractionTex", _refractionRT);
    }
}
