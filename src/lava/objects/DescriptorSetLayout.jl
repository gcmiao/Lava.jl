mutable struct DescriptorSetLayout
    mVkDevice::vk.VkDevice
    mCreateInfo::DescriptorSetLayoutCreateInfo

    mHandleRef::Ref{vk.VkDescriptorSetLayout}

    function DescriptorSetLayout(device::vk.VkDevice,
                                   info::DescriptorSetLayoutCreateInfo,
                               poolSize::UInt32)
        this = new()
        this.mVkDevice = device
        this.mCreateInfo = info
        
        this.mHandleRef = Ref{vk.VkDescriptorSetLayout}()
        if poolSize != 0 #TODO
            # std::unordered_map<vk::DescriptorType, uint32_t> sizes;
            # for (auto b : info.mBindings) {
            #     sizes[b.descriptorType] += b.descriptorCount;
            # }

            # DescriptorPoolCreateInfo pinfo;
            # pinfo.allowFreeing();
            # for (auto s : sizes) {
            #     pinfo.addSize(s.first, s.second * poolSize);
            # }
            # pinfo.setMaxSets(poolSize);
        if vk.vkCreateDescriptorSetLayout(this.mVkDevice, handleRef(this.mCreateInfo), C_NULL, this.mHandleRef) != vk.VK_SUCCESS
            error("Failed to create descriptor set layout!")
        end
        println("descriptor set layout:", this.mHandleRef)

            # mPool = mDevice->createDescriptorPool(pinfo);
        end
        return this
    end

end

# TODO: Deconstruction
# DescriptorSetLayout::~DescriptorSetLayout()
# {
#     mDevice->handle().destroyDescriptorSetLayout(mHandle);
# }

function handleRef(this::DescriptorSetLayout)::Ref{vk.VkDescriptorSetLayout}
    return this.mHandleRef
end
end