#version 460
#extension GL_NV_ray_tracing : require

layout(binding = 0) uniform accelerationStructureNV topLevelAS;


rayPayloadInNV vec3 hitValue;
layout(location = 1) rayPayloadNV vec3 nextHit;

hitAttributeNV vec2 attribs;

struct Tri {
    uint a, b, c;
};

struct Vertex {
    float x, y, z;
    float nx, ny, nz;
};

layout(set = 0, binding = 3) buffer indexBuffer {
    Tri inds[];
};
layout(set = 0, binding = 4)  buffer vertexBuffer {
    Vertex verts[];
};

vec3 pos(Vertex v) {
    return vec3(v.x, v.y, v.z);
}

vec3 normal(Vertex v) {
    return vec3(v.nx, v.ny, v.nz);
}

void main()
{
    vec3 bary = vec3(1.0 - attribs.x - attribs.y, attribs.x, attribs.y);

    Tri tri = inds[gl_PrimitiveID];

    mat3 positions = mat3(pos(verts[tri.a]), pos(verts[tri.b]), pos(verts[tri.c]));
    mat3 normals = mat3(normal(verts[tri.a]), normal(verts[tri.b]), normal(verts[tri.c]));

    vec3 p = positions * bary;
    vec3 n = normalize(normals * bary);
    vec3 v = - gl_WorldRayDirectionNV;
    if (dot(n,v) < 0) n *= -1.0;

    vec3 diffuse = 0.6 * clamp(abs(dot(n, v)).xxx, 0, 1);

    uint rayFlags = gl_RayFlagsOpaqueNV | gl_RayFlagsTerminateOnFirstHitNV;
    uint cullMask = 0xff;
    float tmin = 0.001;
    float tmax = 1000.0;

    vec3 r = reflect(-v,n);

    if (hitValue.g < 0.15) {
        hitValue = vec3(0.0);
    } else {
        nextHit = hitValue * 0.9;

        traceNV(topLevelAS, rayFlags, cullMask,
            0 /*sbtRecordOffset*/,
            0 /*sbtRecordStride*/,
            0 /*missIndex*/, p, tmin,
            r, tmax, 1 /*payload*/);

        hitValue *= 0.9 * nextHit;
    }
}
