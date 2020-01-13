function testSampler(vkDevice)
    sampler = lava.Sampler(vkDevice, lava.SamplerCreateInfo())
    sampler.destroy()
    return true
end
