function testCreateComputePipeline(device)
    @scope begin
        shaderFolder = String(@__DIR__) * "/shaders/"
        shader = @autodestroy device.createShaderFromFile(shaderFolder * "test_comp.spv")
        stage = lava.createComputeStage(shader)
        plLayout = @autodestroy lava.createPipelineLayout(device)
        createInfo = lava.ComputePipelineCreateInfo(stage, plLayout)
        pi = @autodestroy lava.ComputePipeline(createInfo)
        @test pi.getLayout() == plLayout
    end
    return true
end
