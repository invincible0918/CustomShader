using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Renderer))]
public class SSCloudShadow : MonoBehaviour
{
    public string SceneCameraName = "SceneCamera";

    public float CloudTiling = 1.0f;
    public Vector2 CloudSpeed = new Vector2(0.05f, 0.05f);

    // Use this value to avoid culling
    public float Threshold = 0.1f;

    private Camera _mainCam;

    void OnEnable()
    {
        _mainCam = GameObject.Find(SceneCameraName).GetComponent<Camera>();

        if (_mainCam)
            _mainCam.depthTextureMode |= DepthTextureMode.Depth;
    }

    void OnDisable()
    {
        if (_mainCam)
            _mainCam.depthTextureMode &= ~ DepthTextureMode.Depth;
    }

    void OnWillRenderObject()
    {
        if (!_mainCam)
            return;

        // Adjust Quad position to Farplane
        Camera cam = _mainCam;
        float dist = cam.farClipPlane - Threshold;
        Vector3 campos = cam.transform.position;
        Vector3 camray = cam.transform.forward * dist;
        Vector3 quadpos = campos + camray;
        transform.position = quadpos;

        // Adjust Quad size to Farplane
        Vector3 scale = transform.parent ? transform.parent.localScale : Vector3.one;
        float h = Mathf.Tan(cam.fieldOfView * Mathf.Deg2Rad * 0.5f) * dist * 2f;
        transform.localScale = new Vector3(h * cam.aspect / scale.x, h / scale.y, -1f);
        transform.LookAt(campos);

        //float t = Time.time;
        //GetComponent<Renderer>().sharedMaterial.SetVector("_CloudFactor", new Vector4(
        //    CloudSpeed.x * t
        //    , CloudSpeed.y * t
        //    , CloudTiling
        //    , CloudTiling));
    }
}
