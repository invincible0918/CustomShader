<td><strong>Optimize Unity's default PBR shader for our mobile game</strong></td>

We use shader lod to switch between high/low end devices.</p>

1. Remove additive forward pass (one light per pass) and deferred renderring pass to reduce shader variants.</p>
2. Unity default PBR shaders are very important aspects in 3D space. It enhances spatial awareness of objects
in 3D space and give better user experience for players. However, it rendering is GPU
intensive process. For low-end mobile devices, it will slow down our games.</p>
So we use custom shading model (standard blinn/phong shading model) instead of PRB in mobile device.</p>
3. Use custom shadow method.</p>
3.1 We choose a useful mesh search tree called “Mesh Tree” which is used to search for polygons which are receiving shadows.
![picture](/ReadMe/p1.png)</p>

3.2 Use a R8 texture format to render shadow map from main light view. Then blur it with 3 draw calls.</p>
![picture](/ReadMe/p2.png)</p>

3.3 Final image.</p>
![picture](/ReadMe/p0.png)</p>

