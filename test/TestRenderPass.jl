function testRenderPass(device, glfw, passRef)
    pass = device.createRenderPass(lava.createSimpleForward(lava.RenderPassCreateInfo, glfw.format()))
    pass.setClearColor(vk.VkClearColorValue((0, 0, 0, 0)))
    pass.setClearColors([vk.VkClearColorValue((0, 0, 0, 0))])
    pass.setClearDepthStencil(vk.VkClearDepthStencilValue(0, 0))
    passRef[] = pass
    return true
end
