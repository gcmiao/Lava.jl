push!(LOAD_PATH, ".")
import lava
import features


function main()
    glfw = features.create(features.GlfwOutput)
    fs = Array{features.IFeature, 1}()
    push!(fs, glfw)
    instance = lava.create(lava.Instance, fs)
    print(instance)
end

main()