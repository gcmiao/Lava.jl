export Feature, IFeature
export instanceExtensions
abstract type IFeature end
function layers(feature::IFeature, available::Array{String})::Array{String}
    return layers(feature);
end

function instanceExtensions(feature::IFeature, available::Array{String})::Array{String}
    return instanceExtensions(feature);
end

function deviceExtensions(feature::IFeature, available::Array{String})::Array{String}
    return deviceExtensions(feature);
end

mutable struct Feature <: IFeature
    layers::Array{String}
    instanceExtensions::Array{String}
    deviceExtensions::Array{String}

    Feature() = new()
end
