include("TestShader.jl")
include("TestVertexInputState.jl")
include("TestRenderpass.jl")

mutable struct CameraData
    view::Mat4f0
    proj::Mat4f0

    CameraData() = new(Mat4f0(1I), Mat4f0(1I))
    CameraData(view::Mat4f0, proj::Mat4f0) = new(view, proj)
end
@class CameraData

function testCreateGraphicsPipeline(device, glfw, pipelineRef::Ref, passRef::Ref)
    plLayout = device.createPipelineLayout(CameraData)
    @test testDescriptorSetLayout(device)

    @test testRenderPass(device, glfw, passRef)

    stagesRef = Ref{Vector}()
    @test testShaderStages(device, stagesRef)

    inputStateRef = Ref{lava.PipelineVertexInputStateCreateInfo}()
    @test testVertexInputState(inputStateRef)

    ci = lava.defaults(lava.GraphicsPipelineCreateInfo,
        stages = stagesRef[],
        layout = plLayout,
        renderPass = lava.handleRef(passRef[])[],
        subpass = UInt32(0),
        depthTestEnable = VkExt.VK_TRUE,
        depthWriteEnable = VkExt.VK_TRUE,
        # Due to the flipped y axis in NDC, the triangle winding order is inverted, too
        frontFace = vk.VK_FRONT_FACE_CLOCKWISE,
        inputState = inputStateRef[]
    )
    pipeline = lava.GraphicsPipeline(ci)
    pipelineRef[] = pipeline
    return true
end
