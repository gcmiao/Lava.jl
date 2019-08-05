push!(LOAD_PATH, ".")
using lava
using features
using VulkanCore


function main()
    glfw = features.create(features.GlfwOutputT)
    fs = Array{features.IFeatureT, 1}()
    push!(fs, glfw)
    instance = lava.create(lava.InstanceT, fs)
    queues = [lava.createGraphics(lava.QueueRequest, "graphics")]#::Array{QueueRequest, 1}
    device = lava.createDevice(instance, queues,
                                lava.NthOfTypeStrategy(vk.VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU))
    
end

main()