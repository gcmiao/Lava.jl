push!(LOAD_PATH, "lava")
push!(LOAD_PATH, "lava/common")
push!(LOAD_PATH, "lava/features")
using lava
using features
using VulkanCore
using LinearAlgebra

shaderFolder = "../shaders/"

struct CameraData
    view::Matrix{Float32}
    proj::Matrix{Float32}

    CameraData() = new(Matrix{Float32}(I, 4, 4), Matrix{Float32}(I, 4, 4))
end

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

    stageVert = lava.defaults(lava.PipelineShaderStageCreateInfo,
                        _module = lava.createShaderFromFile(device, shaderFolder * "cube_vert.spv"))
    stageFrag = lava.defaults(lava.PipelineShaderStageCreateInfo, 
                        _module = lava.createShaderFromFile(device, shaderFolder * "cube_frag.spv"))
    stages = [lava.handleRef(stageVert)[], lava.handleRef(stageFrag)[]]

    ci = lava.defaults(lava.GraphicsPipelineCreateInfo,
        stages = stages,
        layout = lava.handleRef(plLayout)[],
        renderPass = lava.handleRef(pass)[],
        subpass = UInt32(0),
        depthTestEnable = vk.VkBool32(vk.VK_TRUE),
        depthWriteEnable = vk.VkBool32(vk.VK_TRUE),
        # Due to the flipped y axis in NDC, the triangle winding order is inverted, too
        frontFace = vk.VK_FRONT_FACE_CLOCKWISE,
    )

    #ci.vertexInputState.binding(0, &Vertex::position, &Vertex::color);
end

main()