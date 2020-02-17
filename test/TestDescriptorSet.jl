function testDescriptorSet(device)
    # Test descriptor set layout
    descCreateInfo = lava.DescriptorSetLayoutCreateInfo()
    lava.addUniformBuffer(descCreateInfo, vk.VK_SHADER_STAGE_VERTEX_BIT);
    lava.addCombinedImageSampler(descCreateInfo, vk.VK_SHADER_STAGE_FRAGMENT_BIT);
    descLayout = lava.createDescriptorSetLayout(device, descCreateInfo)
    descSet = descLayout.createDescriptorSet()

    buf = lava.createBuffer(device, lava.uniformBuffer(Csize_t(4)))

    @test descSet.writeUniformBuffer(buf, UInt32(0))
end
