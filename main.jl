push!(LOAD_PATH, ".")
using lava
using features
using VulkanCore

struct CameraData
    view::mat4
    proj::mat4
end


function main()
    # Create a Vulkan instance, tell it we need glfw and the validation as
    # extension features
    fs = Array{features.IFeatureT, 1}()
    push!(fs, features.create(features.Validation))
    push!(fs, features.create(features.GlfwOutputT))
    instance = lava.create(lava.InstanceT, fs)
    queues = [lava.createGraphics(lava.QueueRequest, "graphics")]#::Array{QueueRequest, 1}

    # Create a logical device with a single graphics queue named "graphics" on
    # a discrete (non-integrated) GPU. For more complex apps you can request
    # additional queues (e.g. a separate transfer queue)
    device = lava.createDevice(instance, queues,
                                lava.NthOfTypeStrategy(vk.VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU))
    # Create a pipeline layout that transfers the CameraData as push constants
    # and has no descriptors (textures or uniform buffers)
    plLayout = lava.createPipelineLayout(device, CameraData);
    
end

main()