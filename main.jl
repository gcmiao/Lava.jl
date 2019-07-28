push!(LOAD_PATH, ".")
using lava
using features
using VulkanCore


function main()
    glfw = features.create(features.GlfwOutputT)
    fs = Array{features.IFeatureT, 1}()
    push!(fs, glfw)
    instance = lava.create(lava.InstanceT, fs)
end

main()