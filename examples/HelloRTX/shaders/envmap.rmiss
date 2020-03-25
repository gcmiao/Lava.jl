#version 460
#extension GL_NV_ray_tracing : require

layout(location = 0) rayPayloadInNV vec3 hitValue;

layout(set=0, binding=1) uniform sampler2D envmap;

#define M_PI 3.1415926

void main()
{
    float elev = acos(gl_WorldRayDirectionNV.y);
    float azim = atan(gl_WorldRayDirectionNV.z, gl_WorldRayDirectionNV.x);

    hitValue = texture(envmap, vec2(azim / (2.0 * M_PI), elev / M_PI)).rgb;
}
