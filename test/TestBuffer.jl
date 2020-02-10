function testCreateBufferCreateInfo()
    lava.stagingBuffer()
    lava.storageBuffer()
    lava.indexArrayBuffer(Csize_t(2))
    lava.downloadBuffer()
    lava.uniformBuffer()
    lava.raytracingBuffer()
    return true
end

function testBufferFunction(device)
    @scope begin
        eab = lava.createBuffer(device, lava.indexBuffer())
        eab.setDataVRAM([1, 2], UInt32)
        data = [UInt32(3), UInt32(4)]
        eab.pushData(data, Csize_t(sizeof(data)))
        # println(lava.graphicsQueue(device).activeBuffers())
        lava.graphicsQueue(device).catchUp(Int32(0))
        # println(lava.graphicsQueue(device).activeBuffers())
        outData = Vector{UInt32}(undef, 2)
        eab.getData(outData)
        @test outData[1] == 3
        @test outData[2] == 4
    end
    return true
end
