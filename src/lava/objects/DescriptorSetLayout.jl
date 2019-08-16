mutable struct DescriptorSetLayout
    mDevice::Device,
    mCreateInfo::DescriptorSetLayoutCreateInfo

    mHandleRef::Ref{vk.VkDescriptorSetLayout}

    function DescriptorSetLayout(device::Device,
                                   info::DescriptorSetLayoutCreateInfo,
                               poolSize::UInt32)
        this = new()
        this.mDevice = device
        this.mCreateInfo = info
        
        this.mHandleRef = Ref{vk.VkDescriptorSetLayout}()
        vk.vkCreateDescriptorSetLayout(this.mDevice, handleRef(mCreateInfo), C_NULL, mHandleRef)
        
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

            # mPool = mDevice->createDescriptorPool(pinfo);
        end
    end

end

# TODO: Deconstruction
# DescriptorSetLayout::~DescriptorSetLayout()
# {
#     mDevice->handle().destroyDescriptorSetLayout(mHandle);
# }

function handleRef(this::DescriptorSetLayout)::vk.VkDescriptorSetLayout
end