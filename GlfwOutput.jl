#module GlfwOutput
export GlfwOutputT, create

using features: IFeatureT
using GLFW
using VulkanCore

mutable struct GlfwOutputT <: IFeatureT
    layers::Array{String}
    instanceExtensions::Array{String}
    deviceExtensions::Array{String}
    mInstance::Any

    GlfwOutputT() = new()
end

function create(::Type{GlfwOutputT})
    return GlfwOutputT()
end

function layers(this::GlfwOutputT, available::Array{String})::Array{String}
    return []
end

function instanceExtensions(this::GlfwOutputT, available::Array{String})::Array{String}
    ret = Array{String, 1}()
    glfwReqExts = GLFW.GetRequiredInstanceExtensions()
    extCount = length(glfwReqExts)
    
    # TODO: check availability
    
    append!(ret, glfwReqExts)
    return ret
end

function onInstanceCreated(this::GlfwOutputT, instance)
    mInstance = instance
end

#end