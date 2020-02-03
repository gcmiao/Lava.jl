function testCreateBufferCreateInfo()
    lava.stagingBuffer()
    lava.storageBuffer()
    lava.indexArrayBuffer(Csize_t(2))
    lava.downloadBuffer()
    lava.uniformBuffer()
    lava.raytracingBuffer()
    return true
end
