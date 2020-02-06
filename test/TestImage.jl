function testImageCreateInfo(vkPhyDevice)
    info = lava.texture2D(vkPhyDevice, UInt32(127), UInt32(120), vk.VK_FORMAT_R8G8B8A8_UNORM)
    @test info.mViewType == vk.VK_IMAGE_VIEW_TYPE_2D
    @test info.handleRef()[].imageType == vk.VK_IMAGE_TYPE_2D
    @test info.handleRef()[].format == vk.VK_FORMAT_R8G8B8A8_UNORM
    @test info.handleRef()[].extent.width == 127
    @test info.handleRef()[].extent.height == 120
    @test info.handleRef()[].extent.depth == 1
    @test info.handleRef()[].mipLevels == 7
    @test info.handleRef()[].usage | vk.VK_IMAGE_USAGE_SAMPLED_BIT > 0

    info = lava.texture2DArray(vkPhyDevice, UInt32(128), UInt32(128), UInt32(3), vk.VK_FORMAT_R8G8B8A8_UNORM)
    @test info.handleRef()[].mipLevels == 8
    @test info.handleRef()[].arrayLayers == 3

    info = lava.storageImage2D(vkPhyDevice, UInt32(127), UInt32(127), vk.VK_FORMAT_R8G8B8A8_UNORM)
    @test info.handleRef()[].usage | vk.VK_IMAGE_USAGE_STORAGE_BIT > 0

    info = lava.storageImage2DArray(vkPhyDevice, UInt32(127), UInt32(127), UInt32(3), vk.VK_FORMAT_R8G8B8A8_UNORM)
    @test info.mViewType == vk.VK_IMAGE_VIEW_TYPE_2D_ARRAY

    info = lava.attachment2DArray(vkPhyDevice, UInt32(127), UInt32(127), UInt32(3), vk.VK_FORMAT_R8G8B8A8_UNORM)
    @test info.mViewType == vk.VK_IMAGE_VIEW_TYPE_2D_ARRAY

    return true
end
