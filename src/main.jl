push!(LOAD_PATH, "lava")
push!(LOAD_PATH, "lava/common")
push!(LOAD_PATH, "lava/features")
push!(LOAD_PATH, "lava/camera")
using lava
using features
using VulkanCore
using VkExt
using LinearAlgebra
using StaticArrays
using Utils: vec3, mat4, u8vec4

shaderFolder = "../shaders/"

struct CameraData
    view::mat4
    proj::mat4

    CameraData() = new(mat4(1I), mat4(1I))
    CameraData(view::mat4, proj::mat4) = new(view, proj)
end

struct Vertex
    # glm::vec3 position
    # glm::u8vec4 color
    position::vec3
    color::u8vec4
end

cubeVertices = [
    Vertex(vec3(-1.0, -1.0, -1.0), u8vec4(0, 0, 0, 255)),
    Vertex(vec3(-1.0, -1.0, 1.0), u8vec4(0, 0, 255, 255)),
    Vertex(vec3(-1.0, 1.0, -1.0), u8vec4(0, 255, 0, 255)),
    Vertex(vec3(-1.0, 1.0, 1.0), u8vec4(0, 255, 255, 255)),
    Vertex(vec3(1.0, -1.0, -1.0), u8vec4(255, 0, 0, 255)),
    Vertex(vec3(1.0, -1.0, 1.0), u8vec4(255, 0, 255, 255)),
    Vertex(vec3(1.0, 1.0, -1.0), u8vec4(255, 255, 0, 255)),
    Vertex(vec3(1.0, 1.0, 1.0), u8vec4(255, 255, 255, 255))
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
    fs = Vector{features.IFeatureT}()
    glfw = features.create(features.GlfwOutputT)
    push!(fs, features.create(features.Validation))
    push!(fs, glfw)
    instance = lava.create(lava.InstanceT, fs)
    queues = [lava.createGraphics(lava.QueueRequest, "graphics")]#::Vector{QueueRequest}

    # Create a logical device with a single graphics queue named "graphics" on
    # a discrete (non-integrated) GPU. For more complex apps you can request
    # additional queues (e.g. a separate transfer queue)
    device = lava.createDevice(instance, queues,
                                lava.NthOfTypeStrategy(vk.VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU))
    # Create a pipeline layout that transfers the CameraData as push constants
    # and has no descriptors (textures or uniform buffers)
    plLayout = lava.createPipelineLayout(device, CameraData, Vector{lava.DescriptorSetLayout}())

    # Test descriptor set layout
    # descCreateInfo = lava.DescriptorSetLayoutCreateInfo()
    # lava.addUniformBuffer(descCreateInfo, vk.VK_SHADER_STAGE_VERTEX_BIT);
    # lava.addCombinedImageSampler(descCreateInfo, vk.VK_SHADER_STAGE_FRAGMENT_BIT);
    # descLayout = lava.createDescriptorSetLayout(device, descCreateInfo)
    # plLayout = lava.createPipelineLayout(device, CameraData, [descLayout])
    
    pass = lava.createRenderPass(device, lava.createSimpleForward(lava.RenderPassCreateInfo, features.format(glfw)))

    vertShader = lava.createShaderFromFile(device, shaderFolder * "cube_vert.spv")
    fragShader = lava.createShaderFromFile(device, shaderFolder * "cube_frag.spv")
    stageVert = lava.defaults(lava.PipelineShaderStageCreateInfo, _module = vertShader)
    stageFrag = lava.defaults(lava.PipelineShaderStageCreateInfo, _module = fragShader)
    stages = [lava.handleRef(stageVert)[], lava.handleRef(stageFrag)[]]

    attributes = Vector{vk.VkVertexInputAttributeDescription}()
    bindings = Vector{vk.VkVertexInputBindingDescription}()
    lava.binding(attributes, bindings, UInt32(0), Vertex, :position)
    lava.binding(attributes, bindings, UInt32(0), Vertex, :color)
    ci = lava.defaults(lava.GraphicsPipelineCreateInfo,
        stages = stages,
        layout = lava.handleRef(plLayout)[],
        renderPass = lava.handleRef(pass)[],
        subpass = UInt32(0),
        depthTestEnable = vk.VkBool32(vk.VK_TRUE),
        depthWriteEnable = vk.VkBool32(vk.VK_TRUE),
        # Due to the flipped y axis in NDC, the triangle winding order is inverted, too
        frontFace = vk.VK_FRONT_FACE_CLOCKWISE,
        inputState = lava.PipelineVertexInputStateCreateInfo(attributes = attributes, bindings = bindings)
    )
    GC.@preserve ci begin
        pipeline = lava.GraphicsPipeline(lava.getLogicalDevice(device), lava.handleRef(ci))
    end

    camera = lava.camera.GenericCamera()
    lava.camera.setTarget(camera, vec3(0.0, 0.0, 0.0))
    fbos = Vector{vk.VkFramebuffer}()
    window = features.openWindow(glfw)
    swapChain = lava.SwapChain(device)
    lava.buildSwapchainWith(swapChain, window, views::Vector{lava.ImageView}->begin
        depthImageCreateInfo = lava.attachment2D(lava.getPhysicalDevice(device), window.mWidth, window.mHeight, vk.VK_FORMAT_D32_SFLOAT)
        depthImage = lava.createImage(depthImageCreateInfo, device)
        lava.realizeAttachment(depthImage)
        depthView = lava.createView(depthImage)
        empty!(fbos)

        for view in views
            push!(fbos, lava.handle(lava.createFramebuffer(pass, [depthView, view])))
        end
            lava.camera.setAspectRatio(camera, Float32(features.getWidth(window)) / Float32(features.getHeight(window)))
    end)

    #Upload of the cube mesh
    vab = lava.createBuffer(device, lava.arrayBuffer())
    lava.setDataVRAM(vab, cubeVertices, Vertex)
    eab = lava.createBuffer(device, lava.indexBuffer())
    lava.setDataVRAM(eab, cubeIndices, UInt32)

    lava.camera.setPosition(camera, vec3(2.0, 2.0, 2.0))
    lava.camera.setTarget(camera, vec3(0.0, 0.0, 0.0))
    lava.camera.rotateAroundTarget_GlobalAxes(camera, Float32(0.0), Float32(0.001), Float32(0.0))
    println(CameraData(lava.camera.getViewMatrix(camera), lava.camera.getProjectionMatrix(camera)))
end

main()