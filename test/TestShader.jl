function testDescriptorSetLayout(device)
    descCreateInfo = lava.DescriptorSetLayoutCreateInfo()
    lava.addUniformBuffer(descCreateInfo, vk.VK_SHADER_STAGE_VERTEX_BIT);
    lava.addCombinedImageSampler(descCreateInfo, vk.VK_SHADER_STAGE_FRAGMENT_BIT);
    descLayout = lava.createDescriptorSetLayout(device, descCreateInfo)
    return true
end

function testLoadShader(device, path, shaderRef::Ref)
    shaderRef[] = device.createShaderFromFile(path)
    return true
end

function testShaderStages(device, stagesRef::Ref)
    shaderFolder = String(@__DIR__) * "/../../HelloCube/shaders/"
    vertShaderRef = Ref{lava.ShaderModule}()
    @test testLoadShader(device, shaderFolder * "cube_vert.spv", vertShaderRef)
    fragShaderRef = Ref{lava.ShaderModule}()
    @test testLoadShader(device, shaderFolder * "cube_frag.spv", fragShaderRef)

    stageVert = lava.defaults(lava.PipelineShaderStageCreateInfo, _module = vertShaderRef[])
    stageFrag = lava.defaults(lava.PipelineShaderStageCreateInfo, _module = fragShaderRef[])
    stages = [stageVert.handleRef()[], stageFrag.handleRef()[]]
    stagesRef[] = stages
    return true
end
