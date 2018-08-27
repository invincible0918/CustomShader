#if UNITY_EDITOR
using System.Linq;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;

[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]
[ExecuteInEditMode]
public class CausticMesh : MonoBehaviour
{
    private class _Mesh
    {
        private List<Vector3> _vertices = new List<Vector3>();
        private List<Vector3> _normals = new List<Vector3>();
        private List<Vector2> _texCoords = new List<Vector2>();
        private List<int> _indices = new List<int>();

        public void AddPolygon(Vector3[] poly, Vector3 normal)
        {
            int ind1 = AddVertex(poly[0], normal);

            for (int i = 1; i < poly.Length - 1; i++)
            {
                int ind2 = AddVertex(poly[i], normal);
                int ind3 = AddVertex(poly[i + 1], normal);

                _indices.Add(ind1);
                _indices.Add(ind2);
                _indices.Add(ind3);
            }
        }

        public void Push(float distance)
        {
            for (int i = 0; i < _vertices.Count; i++)
            {
                _vertices[i] += _normals[i] * distance;
            }
        }

        public void ToMesh(Mesh mesh)
        {
            mesh.Clear(true);
            if (_indices.Count == 0)
                return;


            mesh.vertices = _vertices.ToArray();
            mesh.normals = _normals.ToArray();
            mesh.uv = _texCoords.ToArray();
            mesh.triangles = _indices.ToArray();


            _vertices.Clear();
            _normals.Clear();
            _texCoords.Clear();
            _indices.Clear();
        }

        private int AddVertex(Vector3 vertex, Vector3 normal)
        {
            int index = FindVertex(vertex);
            if (index == -1)
            {
                _vertices.Add(vertex);
                _normals.Add(normal);
                AddTexCoord(vertex);
                return _vertices.Count - 1;
            }
            else
            {
                _normals[index] = (_normals[index] + normal).normalized;
                return index;
            }
        }

        private int FindVertex(Vector3 vertex)
        {
            for (int i = 0; i < _vertices.Count; i++)
            {
                if (Vector3.Distance(_vertices[i], vertex) < 0.01f)
                    return i;
            }
            return -1;
        }

        private void AddTexCoord(Vector3 ver)
        {
            float u = Mathf.Lerp(0.0f, 1.0f, ver.x + 0.5f);
            float v = Mathf.Lerp(0.0f, 1.0f, ver.y + 0.5f);
            _texCoords.Add(new Vector2(u, v));
        }
    }

    public Transform TargetTrans;
    public float MaxAngle = 90.0f;
    public float PushDistance = 0.009f;

    public Material Material;

    public float OffsetPositionY;

    private Plane _right = new Plane(Vector3.right, 0.5f);
    private Plane _left = new Plane(Vector3.left, 0.5f);

    private Plane _top = new Plane(Vector3.up, 0.5f);
    private Plane _bottom = new Plane(Vector3.down, 0.5f);

    private Plane _front = new Plane(Vector3.forward, 0.5f);
    private Plane _back = new Plane(Vector3.back, 0.5f);

    private Plane _waterPlane;

    private MeshFilter _filter;
    private MeshRenderer _renderer;

    void OnEnable()
    {
        if (Application.isPlaying)
            enabled = false;
    }

    void Start()
    {
        transform.hasChanged = false;

        _filter = GetComponent<MeshFilter>() ?? gameObject.AddComponent<MeshFilter>();
        _renderer = GetComponent<MeshRenderer>() ?? gameObject.AddComponent<MeshRenderer>();
    }

    void Update()
    {
        // Only gameObject's transform changed, it will invoke here
        Build();

        if (gameObject.scene.IsValid())
        {
            if (!EditorApplication.isPlaying)
                EditorSceneManager.MarkSceneDirty(gameObject.scene);
        }
        else
        {
            EditorUtility.SetDirty(gameObject);
        }
    }

    [ContextMenu("SaveMesh")]
    void SaveMesh()
    {
        // root in hierarchy
        GameObject prefabRoot = PrefabUtility.FindPrefabRoot(gameObject);

        // parent in assets folder
        Object o = PrefabUtility.GetPrefabParent(prefabRoot);

        // get path in assets folder
        string prefabPath = AssetDatabase.GetAssetPath(o).Replace("_prefab.prefab", "_mesh_prefab.prefab");

        AssetDatabase.CreateAsset(_filter.sharedMesh, prefabPath);
        AssetDatabase.SaveAssets();
    }

    void Build()
    {
        if (TargetTrans == null)
            return;


        _Mesh _m = new _Mesh();

        Bounds bounds = GetBounds(transform);

        _waterPlane = transform.worldToLocalMatrix.TransformPlane(new Plane(-Vector3.up, OffsetPositionY));

        foreach (Transform trans in TargetTrans.GetComponentsInChildren<Transform>(includeInactive:false))
        {
            Bounds _bounds = GetBounds(trans);
            if (bounds.Intersects(_bounds))
            {
                MeshFilter mf = trans.GetComponent<MeshFilter>();
                if (mf != null)
                {
                    Matrix4x4 objToDecalMatrix = transform.worldToLocalMatrix * mf.transform.localToWorldMatrix;

                    Mesh mesh = mf.sharedMesh;
                    Vector3[] vertices = mesh.vertices;
                    int[] triangles = mesh.triangles;

                    for (int i = 0; i < triangles.Length; i += 3)
                    {
                        int i1 = triangles[i];
                        int i2 = triangles[i + 1];
                        int i3 = triangles[i + 2];

                        Vector3 v1 = objToDecalMatrix.MultiplyPoint(vertices[i1]);
                        Vector3 v2 = objToDecalMatrix.MultiplyPoint(vertices[i2]);
                        Vector3 v3 = objToDecalMatrix.MultiplyPoint(vertices[i3]);

                        Vector3 normal = Vector3.Cross(v2 - v1, v3 - v1).normalized;

                        if (Vector3.Angle(Vector3.forward, -normal) <= MaxAngle)
                        {
                            var poly = Clip(v1, v2, v3);
                            if (poly.Length > 0)
                                _m.AddPolygon(poly, normal);
                        }
                    }
                }
            }
        }

        _m.Push(PushDistance);

        if (_filter.sharedMesh == null)
        {
            _filter.sharedMesh = new Mesh
            {
                name = "Decal"
            };
        }

        _m.ToMesh(_filter.sharedMesh);
        _renderer.sharedMaterial = Material;
    }

    private Bounds GetBounds(Transform transform)
    {
        Vector3 size = transform.lossyScale;
        Vector3 min = -size / 2f;
        Vector3 max = size / 2f;

        Vector3[] vts = new Vector3[] 
        {
            new Vector3(min.x, min.y, min.z),
            new Vector3(max.x, min.y, min.z),
            new Vector3(min.x, max.y, min.z),
            new Vector3(max.x, max.y, min.z),

            new Vector3(min.x, min.y, max.z),
            new Vector3(max.x, min.y, max.z),
            new Vector3(min.x, max.y, max.z),
            new Vector3(max.x, max.y, max.z),
        };

        vts = vts.Select(transform.TransformDirection).ToArray();
        min = vts.Aggregate(Vector3.Min);
        max = vts.Aggregate(Vector3.Max);

        return new Bounds(transform.position, max - min);
    }

    private Vector3[] Clip(params Vector3[] poly)
    {
        poly = Clip(poly, _right).ToArray();
        poly = Clip(poly, _left).ToArray();
        poly = Clip(poly, _top).ToArray();
        poly = Clip(poly, _bottom).ToArray();
        poly = Clip(poly, _front).ToArray();
        poly = Clip(poly, _back).ToArray();

        poly = Clip(poly, _waterPlane).ToArray();

        return poly;
    }

    private IEnumerable<Vector3> Clip(Vector3[] poly, Plane plane)
    {
        for (int i = 0; i < poly.Length; i++)
        {
            int next = (i + 1) % poly.Length;
            Vector3 v1 = poly[i];
            Vector3 v2 = poly[next];

            if (plane.GetSide(v1))
            {
                yield return v1;
            }

            if (plane.GetSide(v1) != plane.GetSide(v2))
            {
                yield return PlaneLineCast(plane, v1, v2);
            }
        }
    }

    private Vector3 PlaneLineCast(Plane plane, Vector3 a, Vector3 b)
    {
        float dis;
        Ray ray = new Ray(a, b - a);
        plane.Raycast(ray, out dis);
        return ray.GetPoint(dis);
    }

    void OnDrawGizmosSelected()
    {
        Gizmos.matrix = transform.localToWorldMatrix;
        Gizmos.DrawWireCube(Vector3.zero, Vector3.one);
    }
}
#endif