struct PipelineVertexInputStateCreateInfo
    mHandleRef::Ref{vk.VkPipelineVertexInputStateCreateInfo}
    mPreserve::Vector{Any}

    function PipelineVertexInputStateCreateInfo(;
        pNext::Ptr{Cvoid} = C_NULL,
        flags::vk.VkPipelineVertexInputStateCreateFlags = vk.VkFlags(0),
        attributes::Vector{vk.VkVertexInputAttributeDescription} = Vector{vk.VkVertexInputAttributeDescription}(),
        bindings::Vector{vk.VkVertexInputBindingDescription} = Vector{vk.VkVertexInputBindingDescription}()
    )

        this = new(Ref(vk.VkPipelineVertexInputStateCreateInfo(
            vk.VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO, #sType::VkStructureType
            pNext, #::Ptr{Cvoid}
            flags, #::VkPipelineVertexInputStateCreateFlags
            length(bindings), #vertexBindingDescriptionCount::UInt32
            pointer(bindings), #pVertexBindingDescriptions::Ptr{VkVertexInputBindingDescription}
            length(attributes), #vertexAttributeDescriptionCount::UInt32
            pointer(attributes) #pVertexAttributeDescriptions::Ptr{VkVertexInputAttributeDescription}
        )), [attributes, bindings])
    end
end

@class PipelineVertexInputStateCreateInfo

function handleRef(this::PipelineVertexInputStateCreateInfo)::Ref{vk.VkPipelineVertexInputStateCreateInfo}
    this.mHandleRef
end

function addBinding(bindings::Vector{vk.VkVertexInputBindingDescription},
                     binding::UInt32, stride::UInt32,
                   inputRate::vk.VkVertexInputRate = vk.VK_VERTEX_INPUT_RATE_VERTEX)
    push!(bindings, vk.VkVertexInputBindingDescription(
                            binding, #binding::UInt32
                            stride, #stride::UInt32
                            inputRate #inputRate::VkVertexInputRate
                        ))
end

function addAttribute(attributes::Vector{vk.VkVertexInputAttributeDescription},
                        bindings::Vector{vk.VkVertexInputBindingDescription},
                       attribute::vk.VkVertexInputAttributeDescription,
                       type::Type)
    push!(attributes, attribute)
    if findfirst(b -> (b.binding == attribute.binding), bindings) == nothing
        addBinding(bindings, attribute.binding, UInt32(sizeof(type)))
    end
end

function addAttribute(attributes::Vector{vk.VkVertexInputAttributeDescription},
                        bindings::Vector{vk.VkVertexInputBindingDescription},
                            type::Type, member::Symbol, location::UInt32, binding::UInt32 = 0)
    idx = indexOfField(type, member)
    if idx == 0
        error("Cannot find field '", member, "' in type '", type, "'")
    end
    offset = fieldoffset(type, idx)
    format = vkTypeOfFormat(fieldtype(type, member))
    addAttribute(attributes, bindings, vk.VkVertexInputAttributeDescription(location, binding, format, offset), type)
end

function binding(attributes::Vector{vk.VkVertexInputAttributeDescription},
                   bindings::Vector{vk.VkVertexInputBindingDescription},
                  bindingId::UInt32, type::Type, member::Symbol)
    addAttribute(attributes, bindings, type, member, isempty(attributes) ? UInt32(0) : UInt32(Base.last(attributes).location + 1), bindingId)
end
