function testDescriptorSet(device)
    # Test descriptor set layout
    descCreateInfo = lava.DescriptorSetLayoutCreateInfo()
    lava.addUniformBuffer(descCreateInfo, vk.VK_SHADER_STAGE_VERTEX_BIT)
    lava.addUniformBuffer(descCreateInfo, vk.VK_SHADER_STAGE_VERTEX_BIT, UInt32(2))
    lava.addCombinedImageSampler(descCreateInfo, vk.VK_SHADER_STAGE_FRAGMENT_BIT)
    lava.addCombinedImageSampler(descCreateInfo, vk.VK_SHADER_STAGE_FRAGMENT_BIT, UInt32(2))
    descLayout = lava.createDescriptorSetLayout(device, descCreateInfo)
    descSet = descLayout.createDescriptorSet()

    data1 = [UInt32(1), UInt32(2)]
    data2 = [UInt32(3), UInt32(4)]
    buf1 = lava.createBuffer(device, lava.uniformBuffer(Csize_t(sizeof(data1))))
    buf1.setDataVRAM(data1, UInt32)
    buf2 = lava.createBuffer(device, lava.uniformBuffer(Csize_t(sizeof(data2))))
    buf2.setDataVRAM(data2, UInt32)

    descSet.writeUniformBuffer(buf1, UInt32(0))
    descSet.writeUniformBuffers([buf1, buf2], UInt32(1))

    vkDevice = device.getLogicalDevice()
    s1 = lava.Sampler(vkDevice, lava.depth(lava.SamplerCreateInfo))
    info = lava.attachment2D(device.getPhysicalDevice(), 10, 10, vk.VK_FORMAT_B8G8R8A8_SRGB)
    image1 = lava.Image(device, info.handleRef()[], vk.VK_IMAGE_VIEW_TYPE_2D)
    image1.realizeAttachment()
    view1 = image1.createView()
    image2 = lava.Image(device, info.handleRef()[], vk.VK_IMAGE_VIEW_TYPE_2D)
    image2.realizeAttachment()
    view2 = image2.createView()
    descSet.writeCombinedImageSampler(s1, view1, UInt32(2))
    descSet.writeCombinedImageSamplers(s1, [view1, view2], UInt32(3))

    writer = lava.DescriptorSetWriter(descSet, UInt32(4))
    writer.storageBuffer(buf1)
    writer.storageBuffers([buf1, buf2])
    writer.sampledImage(view1)
    writer.storageImage(view1)
    writer.imagesWithType([view1, view2], vk.VkDescriptorType(vk.VK_DESCRIPTOR_TYPE_COMBINED_IMAGE_SAMPLER))
    writer.inputAttachmentColor(view1)
    writer.inputAttachmentDepth(view1)

    return true
end
