function testFramebuffer(device, pass)
    lava.@scope begin
        info = lava.attachment2D(device.getPhysicalDevice(), 10, 10, vk.VK_FORMAT_D32_SFLOAT)
        lava.@autodestroy image1 = lava.Image(device, info.handleRef()[], vk.VK_IMAGE_VIEW_TYPE_2D)
        info = lava.attachment2D(device.getPhysicalDevice(), 10, 10, vk.VK_FORMAT_B8G8R8A8_SRGB)
        lava.@autodestroy image2 = lava.Image(device, info.handleRef()[], vk.VK_IMAGE_VIEW_TYPE_2D)
        image1.realizeAttachment()
        image2.realizeAttachment()
        lava.@autodestroy fb = lava.Framebuffer(pass, [image1, image2])
        @test length(fb.mViews) == 2
        @test fb.mViews[1].getImage() === image1 && fb.mViews[2].getImage() === image2
    end
    return true
end
