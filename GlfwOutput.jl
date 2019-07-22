
export GlfwOutput, create
export instanceExtensions
using features: IFeature

mutable struct GlfwOutput <: IFeature
    layers::Array{String}
    instanceExtensions::Array{String}
    deviceExtensions::Array{String}

    GlfwOutput() = new()
end

function layers(feature::GlfwOutput)::Array{String}
    
end

function instanceExtensions(feature::GlfwOutput)::Array{String}
    return [""]
end

function deviceExtensions(feature::GlfwOutput)::Array{String}
    
end

function create(::Type{GlfwOutput})
    return GlfwOutput()
end
