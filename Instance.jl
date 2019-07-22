import features
export Instance, create
IFeature = features.IFeature
instanceExtensions = features.instanceExtensions

mutable struct Instance
    features::Array{IFeature, 1}

    function Instance(features::Array{IFeature, 1})
        ret = new(features)
        instanceExtensions(features[1], ["aa"])
        return ret
    end
end

function create(::Type{Instance}, features::Array{IFeature, 1})::Instance
    return Instance(features)
end
