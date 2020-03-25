#version 450
#extension GL_ARB_separate_shader_objects : enable
#extension GL_ARB_shading_language_420pack : enable

layout(location=0) in vec3 aPosition;
layout(location=1) in vec3 aColor;

layout(push_constant) uniform PushConsts {
    mat4 view;
    mat4 proj;
} pu;

layout (location = 0) out vec3 vColor;

out gl_PerVertex
{
    vec4 gl_Position;
};

void main() {
    gl_Position = pu.proj * pu.view * vec4(aPosition, 1.0);
    vColor = aColor;
}
