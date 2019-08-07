push!(LOAD_PATH, ".")
using lava
using features
using VulkanCore

function main()
    fs = Array{features.IFeatureT, 1}()
    push!(fs, features.create(features.Validation))
    push!(fs, features.create(features.GlfwOutputT))
    instance = lava.create(lava.InstanceT, fs)
    queues = [lava.createGraphics(lava.QueueRequest, "graphics")]#::Array{QueueRequest, 1}
    device = lava.createDevice(instance, queues,
                                lava.NthOfTypeStrategy(vk.VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU))
    
end

main()