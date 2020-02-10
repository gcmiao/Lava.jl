function testCreateComputePipeline(device, outPipelineRef::Ref)
    @scope begin
        shaderFolder = String(@__DIR__) * "/shaders/"
        shader = @autodestroy device.createShaderFromFile(shaderFolder * "test_comp.spv")
        stage = lava.createComputeStage(shader)
        plLayout = @autodestroy lava.createPipelineLayout(device)
        createInfo = lava.ComputePipelineCreateInfo(stage, plLayout)
        pi = lava.ComputePipeline(createInfo)
        @test pi.getLayout() == plLayout
        outPipelineRef[] = pi
    end
    return true
end

function testComputePipeline(device)
    # TODO Add support of compute pipeline to Queue
    # queue = device.namedQueue("compute")
    # cmd = queue.beginCommandBuffer()
    pipRef = Ref{lava.ComputePipeline}()
    @test testCreateComputePipeline(device, pipRef)
    # cmd.bindPipeline(pipRef[])
    # cmd.endCommandBuffer()

    return true
end
