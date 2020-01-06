function testQueueRequest()
    lava.createGraphics(lava.QueueRequest, "graphics")
    lava.createTransfer(lava.QueueRequest, "transfer")
    lava.createCompute(lava.QueueRequest, "compute")
    lava.createByFlags(lava.QueueRequest, "by_flags", vk.VkQueueFlags(vk.VK_QUEUE_SPARSE_BINDING_BIT), 1.0f0)
    lava.createByFamily(lava.QueueRequest, "by_family", 1, 1.0f0)
    return true
end
