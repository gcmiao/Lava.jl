using Revise
using Lava
using VulkanCore
using LinearAlgebra
using GeometryTypes
using Lava: @class, @scope, @autodestroy

shaderFolder = String(@__DIR__) * "/../shaders/"

mutable struct CameraData
    view::Mat4f0
    proj::Mat4f0

    CameraData() = new(Mat4f0(1I), Mat4f0(1I))
    CameraData(view::Mat4f0, proj::Mat4f0) = new(view, proj)
end

@class CameraData

function getTransposeData(data::CameraData)
    return [transpose(data.view) transpose(data.proj)]
end

const u8vec4 = Vec{4, UInt8}
struct Vertex
    position::Vec3f0
    color::u8vec4
end

cubeVertices = [
    Vertex(Vec3f0(-1.0, -1.0, -1.0), u8vec4(0, 0, 0, 255)),
    Vertex(Vec3f0(-1.0, -1.0, 1.0), u8vec4(0, 0, 255, 255)),
    Vertex(Vec3f0(-1.0, 1.0, -1.0), u8vec4(0, 255, 0, 255)),
    Vertex(Vec3f0(-1.0, 1.0, 1.0), u8vec4(0, 255, 255, 255)),
    Vertex(Vec3f0(1.0, -1.0, -1.0), u8vec4(255, 0, 0, 255)),
    Vertex(Vec3f0(1.0, -1.0, 1.0), u8vec4(255, 0, 255, 255)),
    Vertex(Vec3f0(1.0, 1.0, -1.0), u8vec4(255, 255, 0, 255)),
    Vertex(Vec3f0(1.0, 1.0, 1.0), u8vec4(255, 255, 255, 255))
]

cubeIndices = Vector{UInt32}(  [0, 2, 3,
                                0, 3, 1,
                                0, 1, 5,
                                0, 5, 4,
                                2, 7, 3,
                                2, 6, 7,
                                1, 7, 5,
                                1, 3, 7,
                                0, 4, 6,
                                0, 6, 2,
                                4, 5, 7,
                                4, 7, 6])

function main()
    # Create a Vulkan instance, tell it we need glfw and the validation as
    # extension features
    @scope begin
    fs = Vector{features.IFeature}()
    glfw = features.create(features.GlfwOutput)
    push!(fs, features.create(features.Validation))
    push!(fs, glfw)
    instance = @autodestroy lava.create(lava.Instance, fs)
    queues = [lava.createGraphics(lava.QueueRequest, "graphics")]#::Vector{QueueRequest}

    # Create a logical device with a single graphics queue named "graphics" on
    # a discrete (non-integrated) GPU. For more complex apps you can request
    # additional queues (e.g. a separate transfer queue)
    device = @autodestroy instance.createDevice(queues,
                                    lava.NthOfTypeStrategy(vk.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU))
                                   # lava.NthOfTypeStrategy(vk.VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU
                                   
    # Create a pipeline layout that transfers the CameraData as push constants
    # and has no descriptors (textures or uniform buffers)
    plLayout = @autodestroy device.createPipelineLayout(CameraData)

    # Test descriptor set layout
    # descCreateInfo = lava.DescriptorSetLayoutCreateInfo()
    # lava.addUniformBuffer(descCreateInfo, vk.VK_SHADER_STAGE_VERTEX_BIT);
    # lava.addCombinedImageSampler(descCreateInfo, vk.VK_SHADER_STAGE_FRAGMENT_BIT);
    # descLayout = lava.createDescriptorSetLayout(device, descCreateInfo)
    # plLayout = lava.createPipelineLayout(device, CameraData, [descLayout])

    pass = @autodestroy device.createRenderPass(lava.createSimpleForward(lava.RenderPassCreateInfo, glfw.format()))

    vertShader = @autodestroy device.createShaderFromFile(shaderFolder * "cube_vert.spv")
    fragShader = @autodestroy device.createShaderFromFile(shaderFolder * "cube_frag.spv")
    stageVert = lava.defaults(lava.PipelineShaderStageCreateInfo, _module = vertShader)
    stageFrag = lava.defaults(lava.PipelineShaderStageCreateInfo, _module = fragShader)
    stages = [stageVert.handleRef()[], stageFrag.handleRef()[]]

    attributes = Vector{vk.VkVertexInputAttributeDescription}()
    bindings = Vector{vk.VkVertexInputBindingDescription}()
    lava.binding(attributes, bindings, UInt32(0), Vertex, :position)
    lava.binding(attributes, bindings, UInt32(0), Vertex, :color)
    vertexInputState = lava.PipelineVertexInputStateCreateInfo(attributes = attributes, bindings = bindings)

    ci = lava.defaults(lava.GraphicsPipelineCreateInfo,
        stages = stages,
        layout = plLayout,
        renderPass = lava.handleRef(pass)[],
        subpass = UInt32(0),
        depthTestEnable = VkExt.VK_TRUE,
        depthWriteEnable = VkExt.VK_TRUE,
        # Due to the flipped y axis in NDC, the triangle winding order is inverted, too
        frontFace = vk.VK_FRONT_FACE_CLOCKWISE,
        inputState = vertexInputState
    )
    pipeline = @autodestroy lava.GraphicsPipeline(ci)

    camera = Camera.GenericCamera()
    camera.setTarget(Vec3f0(0.0, 0.0, 0.0))
    fbos = @autodestroy Vector{lava.Framebuffer}()
    window = @autodestroy glfw.openWindow(UInt32(800), UInt32(600), true)
    imgList = @autodestroy []
    imgViewList = @autodestroy []
    window.buildSwapchainWith(views::Vector{lava.ImageView}->begin
        depthImageCreateInfo = lava.attachment2D(lava.getPhysicalDevice(device), window.mWidth, window.mHeight, vk.VK_FORMAT_D32_SFLOAT)
        depthImage = lava.createImage(depthImageCreateInfo, device)
        depthImage.realizeAttachment()
        depthView = depthImage.createView()
        lava.destroy!(imgList)
        lava.destroy!(imgViewList)
        push!(imgList, depthImage)
        push!(imgViewList, depthView)

        lava.destroy!(fbos)
        for view in views
            push!(fbos, lava.Framebuffer(pass, [depthView, view]))
        end

        camera.setAspectRatio(Float32(features.getWidth(window)) / Float32(features.getHeight(window)))
    end)

    #Upload of the cube mesh
    vab = @autodestroy lava.createBuffer(device, lava.arrayBuffer())
    vab.setDataVRAM(cubeVertices, Vertex)
    eab = @autodestroy lava.createBuffer(device, lava.indexBuffer())
    eab.setDataVRAM(cubeIndices, UInt32)

    camera.setPosition(Vec3f0(2.0, 2.0, 2.0))
    camera.setTarget(Vec3f0(0.0, 0.0, 0.0))
    camera.rotateAroundTarget_GlobalAxes(Float32(0.0), Float32(0.001), Float32(0.0))

    while true
        features.pollEvent()
        lava.graphicsQueue(device).catchUp(Int32(1))
        camera.rotateAroundTarget_GlobalAxes(Float32(0.0), Float32(0.001), Float32(0.0))
        #println(CameraData(Camera.getViewMatrix(camera), Camera.getProjectionMatrix(camera)))
        frame = window.startFrame()
        cmd = lava.graphicsQueue(device).beginCommandBuffer()

        # Vulkan doesn't take care of synchronization for us.
        # We need to tell it to wait with rendering until the image is ready
        # and to wait with presenting the image until the rendering is done.
        # The frame struct provides the necessary semaphores.
        cmd.wait(frame.imageReady())
        cmd.signal(frame.renderingComplete())

        forward = cmd.beginRenderpass(fbos[features.imageIndex(frame) + 1])

        sub = forward.startInlineSubpass()
        sub.bindPipeline(pipeline)
        sub.setViewports([vk.VkViewport(0, 0, features.getWidth(window), features.getHeight(window), 0.0, 1.0)])
        sub.bindVertexBuffers([vab])
        sub.bindIndexBuffer(eab)
        cameraData = CameraData(camera.getViewMatrix(), camera.getProjectionMatrix())
        sub.pushConstantBlock(cameraData.getTransposeData())

        sub.drawIndexed(UInt32(length(cubeIndices)))

        forward.endRenderPass()
        cmd.endCommandBuffer()
        frame.endFrame()
    end
    end
end
