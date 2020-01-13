function testDescriptorSetLayout(device)
    descCreateInfo = lava.DescriptorSetLayoutCreateInfo()
    lava.addUniformBuffer(descCreateInfo, vk.VK_SHADER_STAGE_VERTEX_BIT);
    lava.addCombinedImageSampler(descCreateInfo, vk.VK_SHADER_STAGE_FRAGMENT_BIT);
    descLayout = lava.createDescriptorSetLayout(device, descCreateInfo)
    return true
end
