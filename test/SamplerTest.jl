function testSampler(vkDevice::vk.VkDevice)
    info1 = lava.SamplerCreateInfo(unnormalizedCoordinates = VkExt.VK_TRUE)
    info2 = lava.depth(lava.SamplerCreateInfo)
    info3 = lava.shadow(lava.SamplerCreateInfo)
    lava.@scope begin
        lava.@autodestroy s1 = lava.Sampler(vkDevice, info1)
        lava.@autodestroy s2 = lava.Sampler(vkDevice, info2)
        lava.@autodestroy s3 = lava.Sampler(vkDevice, info3)
    end
    return true
end
