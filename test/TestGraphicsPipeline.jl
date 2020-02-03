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

function testGraphicsPipelineFlag()
    createFlagRef = Ref{vk.VkPipelineCreateFlags}()
    lava.deriveFrom(createFlagRef)
    @test createFlagRef[] & vk.VK_PIPELINE_CREATE_DERIVATIVE_BIT != 0
    lava.allowDerivatives(createFlagRef, true)
    @test createFlagRef[] & vk.VK_PIPELINE_CREATE_ALLOW_DERIVATIVES_BIT != 0
    lava.allowDerivatives(createFlagRef, false)
    @test createFlagRef[] & vk.VK_PIPELINE_CREATE_ALLOW_DERIVATIVES_BIT == 0
    lava.disableOptimization(createFlagRef, true)
    @test createFlagRef[] & vk.VK_PIPELINE_CREATE_DISABLE_OPTIMIZATION_BIT != 0
    lava.disableOptimization(createFlagRef, false)
    @test createFlagRef[] & vk.VK_PIPELINE_CREATE_DISABLE_OPTIMIZATION_BIT == 0

    @test testColorBlendStateFlag()

    return true
end

function testColorBlendStateFlag()
    states = Vector{vk.VkPipelineColorBlendAttachmentState}()
    lava.addNoBlend(states)
    lava.addTransparencyBlend(states)
    @test length(states) == 2
    return true
end
