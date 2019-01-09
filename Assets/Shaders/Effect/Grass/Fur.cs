using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Fur : MonoBehaviour
{
    public GameObject Template;

    public int InstanceCount;
    public Vector3 Scale = Vector3.one;

	// Use this for initialization
	void Start ()
    {
        DoIt();
    }

    // Update is called once per frame
    void Update()
    {
        Graphics.DrawMeshInstanced(_templateMesh, 0, _templateMaterial, _matrices);
    }

    private List<Vector3> _positions = new List<Vector3>();
    private List<Matrix4x4> _matrices = new List<Matrix4x4>();
    private Mesh _templateMesh;
    private Material _templateMaterial;

    [ContextMenu("DoIt")]
    void DoIt()
    {
        _matrices.Clear();
        _positions.Clear();

        Mesh mesh = GetComponent<MeshFilter>().sharedMesh;
        Matrix4x4 mat = transform.localToWorldMatrix;
        Vector3[] vertices = mesh.vertices;
        int[] triangles = mesh.triangles;

        float sumArea = 0.0f;
        List<float> areaList = new List<float>();
        for (int i = 0; i < triangles.Length; i += 3)
        {
            float area = 0.5f * (Vector3.Cross(vertices[triangles[i + 1]] - vertices[triangles[i]], vertices[triangles[i + 2]] - vertices[triangles[i]])).magnitude;
            sumArea += area;
            areaList.Add(area);
        }

        int index = 0;
        int xxx = 0;
        for (int i = 0; i < triangles.Length; i += 3)
        {
            int count = (int)(areaList[index] / sumArea * InstanceCount);
            xxx += count;
            index += 1;

            Vector3 v0 = mat.MultiplyPoint3x4(vertices[triangles[i]]);
            Vector3 v1 = mat.MultiplyPoint3x4(vertices[triangles[i + 1]]);
            Vector3 v2 = mat.MultiplyPoint3x4(vertices[triangles[i + 2]]);

            Vector3 normal = Vector3.Cross(v1 - v0, v2 - v0);

            Vector3 dir0 = v1 - v0;
            Vector3 dir1 = v2 - v0;

            for (int j = 0; j < count; ++j)
            {
                Vector3 v = v0 + dir0 * Random.value + dir1 * Random.value;

                Vector3 vv0 = v - v0;
                Vector3 vv1 = v - v1;
                Vector3 vv2 = v - v2;

                Vector3 t0 = Vector3.Cross(vv0, vv1);
                Vector3 t1 = Vector3.Cross(vv1, vv2);
                Vector3 t2 = Vector3.Cross(vv2, vv0);

                Vector3 position = Vector3.zero;
                if (Vector3.Dot(t0, t1) > 0 && Vector3.Dot(t1, t2) > 0)
                    position = v;
                else
                    position = v1 + v2 - v;

                Quaternion rotation = Quaternion.FromToRotation(Vector3.up, normal);
                Matrix4x4 matrix = Matrix4x4.TRS(position, rotation, Scale);
                _matrices.Add(matrix);
                _positions.Add(position);
            }

        }
        Debug.Log(xxx);

        MeshRenderer meshRenderer = Template.GetComponent<MeshRenderer>();
        MeshFilter meshFilter = Template.GetComponent<MeshFilter>();
        _templateMesh = meshFilter.sharedMesh;
        _templateMaterial = meshRenderer.sharedMaterial;
    }

    private void OnDrawGizmos()
    {
        for (int i = 0; i < _positions.Count; ++i)
        {
            Gizmos.DrawSphere(_positions[i], 0.1f);
        }
    }
}
