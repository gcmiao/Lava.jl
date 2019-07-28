#module Feature
export FeatureT, IFeatureT

using VulkanCore

abstract type IFeatureT end

function layers(this::IFeatureT, available::Array{String})::Array{String}
    println("empty implementation in IFeatureT.layers")
    return []
end

function instanceExtensions(this::IFeatureT, available::Array{String})::Array{String}
    println("empty implementation in IFeatureT.instanceExtensions")
    return []
end

function deviceExtensions(this::IFeatureT, available::Array{String})::Array{String}
    println("empty implementation in IFeatureT.deviceExtensions")
    return []
end

function onInstanceCreated(this::IFeatureT, instance)
    println("empty implementation in IFeatureT.onInstanceCreated")
end


#end