mutable struct DescriptorSetWriter
    mSet
    mCurrentBinding::UInt32 # start from 0
    mWrites::Vector{vk.VkWriteDescriptorSet}

    function DescriptorSetWriter(_set, binding::UInt32 = UInt32(0))
        this = new(_set, binding, Vector{vk.VkWriteDescriptorSet}())
        return this
    end
end
@class DescriptorSetWriter

function write(this::DescriptorSetWriter)
    vk.vkUpdateDescriptorSets(this.mSet.mVkDevice, length(this.mWrites), pointer(this.mWrites), 0, C_NULL)
end

# Use this if you want to skip a binding, e.g. if you don't want to start
# with binding 0
function skipToBinding(this::DescriptorSetWriter, binding::UInt32)::DescriptorSetWriter
    this.mCurrentBinding = binding
    return this
end

function pushWrite(this::DescriptorSetWriter, type::vk.VkDescriptorType;
                    bufferInfos::Vector{vk.VkDescriptorBufferInfo} = Vector{vk.VkDescriptorBufferInfo}(),
                    imageInfos::Vector{vk.VkDescriptorImageInfo} = Vector{vk.VkDescriptorImageInfo}(),
                    descCount::Integer = 0,
                    pNext::Ptr{Cvoid} = C_NULL)
    push!(this.mWrites, vk.VkWriteDescriptorSet(
        vk.VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET, # sType::VkStructureType
        pNext, # pNext::Ptr{Cvoid}
        this.mSet.handleRef()[], # dstSet::VkDescriptorSet
        this.mCurrentBinding, # dstBinding::UInt32
        UInt32(0), # dstArrayElement::UInt32
        UInt32(descCount), # descriptorCount::UInt32
        type, # descriptorType::VkDescriptorType
        pointer(imageInfos), # pImageInfo::Ptr{VkDescriptorImageInfo}
        pointer(bufferInfos), # pBufferInfo::Ptr{VkDescriptorBufferInfo}
        C_NULL # pTexelBufferView::Ptr{VkBufferView}
    ))
end

function getBindingResource(this::DescriptorSetWriter, binding::UInt32)::Vector
    res = this.mSet.mBindingResources
    if haskey(res, binding)
        return get(res, binding)
    else
        return get!(res, binding, Vector{Any}())
    end
end

function bufferWithType(this::DescriptorSetWriter, buffer::Buffer, type::vk.VkDescriptorType)::DescriptorSetWriter
    res = this.getBindingResource(this.mCurrentBinding)
    empty!(res)
    push!(res, buffer)

    info = [vk.VkDescriptorBufferInfo(
                buffer.handle(), # buffer::VkBuffer
                vk.VkDeviceSize(0), # offset::VkDeviceSize
                vk.VkDeviceSize(vk.VK_WHOLE_SIZE)) #range::VkDeviceSize
    ]
    pushWrite(this, type, bufferInfos = info, descCount = 1)

    this.mCurrentBinding += 1
    return this
end

function buffersWithType(this::DescriptorSetWriter, buffers::Vector{Buffer}, type::vk.VkDescriptorType)::DescriptorSetWriter
    res = this.getBindingResource(this.mCurrentBinding)
    empty!(res)
    append!(res, buffers)

    bufferLen = length(buffers)
    if bufferLen > 0
        info = Vector{vk.VkDescriptorBufferInfo}(undef, bufferLen)
        for i = 1 : bufferLen
            info[i] = vk.VkDescriptorBufferInfo(
                        buffers[i].handle(), # buffer::VkBuffer
                        vk.VkDeviceSize(0), # offset::VkDeviceSize
                        vk.VkDeviceSize(vk.VK_WHOLE_SIZE)) #range::VkDeviceSize
        end

        pushWrite(this, type, bufferInfos = info, descCount = UInt32(bufferLen))
    end

    this.mCurrentBinding += 1
    return this
end

function imageWithType(this::DescriptorSetWriter, view::ImageView, type::vk.VkDescriptorType;
                        samplerRef::Ref{Sampler} = Ref{Sampler}(),
                        imageLayout::vk.VkImageLayout = vk.VkImageLayout(vk.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL))::DescriptorSetWriter
    res = this.getBindingResource(this.mCurrentBinding)
    empty!(res)
    push!(res, view)

    sampler = C_NULL
    if isdefined(samplerRef, :x)
        sampler = samplerRef[].handle()
        push!(res, samplerRef[])
    end

    info = [vk.VkDescriptorImageInfo(
        sampler, # sampler::VkSampler
        view.handle(), # imageView::VkImageView
        imageLayout) # imageLayout::VkImageLayout
    ]

    pushWrite(this, type, imageInfos = info, descCount = 1)

    this.mCurrentBinding += 1
    return this
end

function imagesWithType(this::DescriptorSetWriter, views::Vector{ImageView}, type::vk.VkDescriptorType;
                        samplerRef::Ref{Sampler} = Ref{Sampler}(),
                        imageLayout::vk.VkImageLayout = vk.VkImageLayout(vk.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL))::DescriptorSetWriter
    res = this.getBindingResource(this.mCurrentBinding)
    empty!(res)
    append!(res, views)

    sampler = C_NULL
    if isdefined(samplerRef, :x)
        sampler = samplerRef[].handle()
        push!(res, samplerRef[])
    end

    viewLen = length(views)
    if viewLen > 0
        info = Vector{vk.VkDescriptorImageInfo}(undef, viewLen)
        for i = 1 : viewLen
            info[i] = vk.VkDescriptorImageInfo(
                        sampler, # sampler::VkSampler
                        views[i].handle(), # imageView::VkImageView
                        imageLayout) # imageLayout::VkImageLayout
        end

        pushWrite(this, type, imageInfos = info, descCount = UInt32(viewLen))
    end

    this.mCurrentBinding += 1
    return this
end

function uniformBuffer(this::DescriptorSetWriter, buffer::Buffer)::DescriptorSetWriter
    return this.bufferWithType(buffer, vk.VkDescriptorType(vk.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER))
end

function uniformBuffers(this::DescriptorSetWriter, buffers::Vector{Buffer})::DescriptorSetWriter
    return this.buffersWithType(buffers, vk.VkDescriptorType(vk.VK_DESCRIPTOR_TYPE_UNIFORM_BUFFER))
end

function storageBuffer(this::DescriptorSetWriter, buffer::Buffer)::DescriptorSetWriter
    return this.bufferWithType(buffer, vk.VkDescriptorType(vk.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER))
end

function storageBuffers(this::DescriptorSetWriter, buffers::Vector{Buffer})::DescriptorSetWriter
    return this.buffersWithType(buffers, vk.VkDescriptorType(vk.VK_DESCRIPTOR_TYPE_STORAGE_BUFFER))
end

function sampledImage(this::DescriptorSetWriter, view::ImageView)::DescriptorSetWriter
    return this.imageWithType(view, vk.VkDescriptorType(vk.VK_DESCRIPTOR_TYPE_SAMPLED_IMAGE))
end

function combinedImageSampler(this::DescriptorSetWriter, sampler::Sampler, view::ImageView)::DescriptorSetWriter
    return this.imageWithType(view, vk.VkDescriptorType(vk.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                samplerRef = Ref(sampler))
end

function combinedImageSamplers(this::DescriptorSetWriter, sampler::Sampler, views::Vector{ImageView})::DescriptorSetWriter
    return this.imagesWithType(views, vk.VkDescriptorType(vk.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER),
                                samplerRef = Ref(sampler))
end

function storageImage(this::DescriptorSetWriter, view::ImageView)::DescriptorSetWriter
    return this.imageWithType(view, vk.VkDescriptorType(vk.VK_DESCRIPTOR_TYPE_STORAGE_IMAGE),
                                imageLayout = vk.VkImageLayout(vk.VK_IMAGE_LAYOUT_GENERAL))
end

function inputAttachment(this::DescriptorSetWriter, view::ImageView, layout::vk.VkImageLayout)::DescriptorSetWriter
     return this.imageWithType(view, vk.VkDescriptorType(vk.VK_DESCRIPTOR_TYPE_INPUT_ATTACHMENT),
                                imageLayout = layout)
end

function inputAttachmentColor(this::DescriptorSetWriter, view::ImageView)::DescriptorSetWriter
    return this.inputAttachment(view, vk.VkImageLayout(vk.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL))
end

function inputAttachmentDepth(this::DescriptorSetWriter, view::ImageView)::DescriptorSetWriter
    return this.inputAttachment(view, vk.VkImageLayout(vk.VK_IMAGE_LAYOUT_DEPTH_STENCIL_READ_ONLY_OPTIMAL))
end

# TODO need TopLevelAccelerationStructure
# function accelerationStructure(this::DescriptorSetWriter, tlas::TopLevelAccelerationStructure)::DescriptorSetWriter
#     res = this.getBindingResource(this.mCurrentBinding)
#     empty!(res)
#     append!(res, tlas)
#
#     handles::Vector{vk.VkAccelerationStructureNV} = [tlas.handle()]
#     infoRef = Ref(vk.VkWriteDescriptorSetAccelerationStructureNV(
#         vk.VK_STRUCTURE_TYPE_WRITE_DESCRIPTOR_SET_ACCELERATION_STRUCTURE_NV, # sType::VkStructureType
#         C_NULL, # pNext::Ptr{Cvoid}
#         UInt32(1), # accelerationStructureCount::UInt32
#         pointers(handles) # pAccelerationStructures::Ptr{VkAccelerationStructureNV}
#     ))
#
#     pushWrite(this, vk.VK_DESCRIPTOR_TYPE_ACCELERATION_STRUCTURE_NV, pNext = ref_to_pointer(infoRef), descCount = UInt32(1))
#
#     this.mCurrentBinding += 1
#     return this
# end
