mutable struct VkPhysicalDeviceFeatures
    robustBufferAccess::vk.VkBool32
    fullDrawIndexUint32::vk.VkBool32
    imageCubeArray::vk.VkBool32
    independentBlend::vk.VkBool32
    geometryShader::vk.VkBool32
    tessellationShader::vk.VkBool32
    sampleRateShading::vk.VkBool32
    dualSrcBlend::vk.VkBool32
    logicOp::vk.VkBool32
    multiDrawIndirect::vk.VkBool32
    drawIndirectFirstInstance::vk.VkBool32
    depthClamp::vk.VkBool32
    depthBiasClamp::vk.VkBool32
    fillModeNonSolid::vk.VkBool32
    depthBounds::vk.VkBool32
    wideLines::vk.VkBool32
    largePoints::vk.VkBool32
    alphaToOne::vk.VkBool32
    multiViewport::vk.VkBool32
    samplerAnisotropy::vk.VkBool32
    textureCompressionETC2::vk.VkBool32
    textureCompressionASTC_LDR::vk.VkBool32
    textureCompressionBC::vk.VkBool32
    occlusionQueryPrecise::vk.VkBool32
    pipelineStatisticsQuery::vk.VkBool32
    vertexPipelineStoresAndAtomics::vk.VkBool32
    fragmentStoresAndAtomics::vk.VkBool32
    shaderTessellationAndGeometryPointSize::vk.VkBool32
    shaderImageGatherExtended::vk.VkBool32
    shaderStorageImageExtendedFormats::vk.VkBool32
    shaderStorageImageMultisample::vk.VkBool32
    shaderStorageImageReadWithoutFormat::vk.VkBool32
    shaderStorageImageWriteWithoutFormat::vk.VkBool32
    shaderUniformBufferArrayDynamicIndexing::vk.VkBool32
    shaderSampledImageArrayDynamicIndexing::vk.VkBool32
    shaderStorageBufferArrayDynamicIndexing::vk.VkBool32
    shaderStorageImageArrayDynamicIndexing::vk.VkBool32
    shaderClipDistance::vk.VkBool32
    shaderCullDistance::vk.VkBool32
    shaderFloat64::vk.VkBool32
    shaderInt64::vk.VkBool32
    shaderInt16::vk.VkBool32
    shaderResourceResidency::vk.VkBool32
    shaderResourceMinLod::vk.VkBool32
    sparseBinding::vk.VkBool32
    sparseResidencyBuffer::vk.VkBool32
    sparseResidencyImage2D::vk.VkBool32
    sparseResidencyImage3D::vk.VkBool32
    sparseResidency2Samples::vk.VkBool32
    sparseResidency4Samples::vk.VkBool32
    sparseResidency8Samples::vk.VkBool32
    sparseResidency16Samples::vk.VkBool32
    sparseResidencyAliased::vk.VkBool32
    variableMultisampleRate::vk.VkBool32
    inheritedQueries::vk.VkBool32

    VkPhysicalDeviceFeatures() =  new(false, false, false, false, false, false, false, false, false, false,
                                    false, false, false, false, false, false, false, false, false, false,
                                    false, false, false, false, false, false, false, false, false, false,
                                    false, false, false, false, false, false, false, false, false, false,
                                    false, false, false, false, false, false, false, false, false, false,
                                    false, false, false, false, false
                                    )
end
@class VkPhysicalDeviceFeatures

function build(this::VkPhysicalDeviceFeatures)::vk.VkPhysicalDeviceFeatures
    return vk.VkPhysicalDeviceFeatures(
        this.robustBufferAccess,
        this.fullDrawIndexUint32,
        this.imageCubeArray,
        this.independentBlend,
        this.geometryShader,
        this.tessellationShader,
        this.sampleRateShading,
        this.dualSrcBlend,
        this.logicOp,
        this.multiDrawIndirect,
        this.drawIndirectFirstInstance,
        this.depthClamp,
        this.depthBiasClamp,
        this.fillModeNonSolid,
        this.depthBounds,
        this.wideLines,
        this.largePoints,
        this.alphaToOne,
        this.multiViewport,
        this.samplerAnisotropy,
        this.textureCompressionETC2,
        this.textureCompressionASTC_LDR,
        this.textureCompressionBC,
        this.occlusionQueryPrecise,
        this.pipelineStatisticsQuery,
        this.vertexPipelineStoresAndAtomics,
        this.fragmentStoresAndAtomics,
        this.shaderTessellationAndGeometryPointSize,
        this.shaderImageGatherExtended,
        this.shaderStorageImageExtendedFormats,
        this.shaderStorageImageMultisample,
        this.shaderStorageImageReadWithoutFormat,
        this.shaderStorageImageWriteWithoutFormat,
        this.shaderUniformBufferArrayDynamicIndexing,
        this.shaderSampledImageArrayDynamicIndexing,
        this.shaderStorageBufferArrayDynamicIndexing,
        this.shaderStorageImageArrayDynamicIndexing,
        this.shaderClipDistance,
        this.shaderCullDistance,
        this.shaderFloat64,
        this.shaderInt64,
        this.shaderInt16,
        this.shaderResourceResidency,
        this.shaderResourceMinLod,
        this.sparseBinding,
        this.sparseResidencyBuffer,
        this.sparseResidencyImage2D,
        this.sparseResidencyImage3D,
        this.sparseResidency2Samples,
        this.sparseResidency4Samples,
        this.sparseResidency8Samples,
        this.sparseResidency16Samples,
        this.sparseResidencyAliased,
        this.variableMultisampleRate,
        this.inheritedQueries
    )
end
    # robustBufferAccess::vk.VkBool32
    # fullDrawIndexUint32::vk.VkBool32
    # imageCubeArray::vk.VkBool32
    # independentBlend::vk.VkBool32

function setGeometryShader(this::VkPhysicalDeviceFeatures, value::vk.VkBool32)::VkPhysicalDeviceFeatures
    this.geometryShader = value
    return this
end

function setTessellationShader(this::VkPhysicalDeviceFeatures, value::vk.VkBool32)::VkPhysicalDeviceFeatures
    this.tessellationShader = value
    return this
end

    # sampleRateShading::vk.VkBool32
    # dualSrcBlend::vk.VkBool32
    # logicOp::vk.VkBool32
    # multiDrawIndirect::vk.VkBool32
    # drawIndirectFirstInstance::vk.VkBool32
    # depthClamp::vk.VkBool32
    # depthBiasClamp::vk.VkBool32
    # fillModeNonSolid::vk.VkBool32
    # depthBounds::vk.VkBool32
    # wideLines::vk.VkBool32
    # largePoints::vk.VkBool32
    # alphaToOne::vk.VkBool32
    # multiViewport::vk.VkBool32
function setSamplerAnisotropy(this::VkPhysicalDeviceFeatures, value::vk.VkBool32)::VkPhysicalDeviceFeatures
    this.samplerAnisotropy = value
    return this
end
    # textureCompressionETC2::vk.VkBool32
    # textureCompressionASTC_LDR::vk.VkBool32
    # textureCompressionBC::vk.VkBool32
    # occlusionQueryPrecise::vk.VkBool32
    # pipelineStatisticsQuery::vk.VkBool32

function setVertexPipelineStoresAndAtomics(this::VkPhysicalDeviceFeatures, value::vk.VkBool32)::VkPhysicalDeviceFeatures
    this.vertexPipelineStoresAndAtomics = value
    return this
end

function setFragmentStoresAndAtomics(this::VkPhysicalDeviceFeatures, value::vk.VkBool32)::VkPhysicalDeviceFeatures
    this.fragmentStoresAndAtomics = value
    return this
end
    # shaderTessellationAndGeometryPointSize::vk.VkBool32
    # shaderImageGatherExtended::vk.VkBool32
    # shaderStorageImageExtendedFormats::vk.VkBool32
    # shaderStorageImageMultisample::vk.VkBool32
    # shaderStorageImageReadWithoutFormat::vk.VkBool32
    # shaderStorageImageWriteWithoutFormat::vk.VkBool32
    # shaderUniformBufferArrayDynamicIndexing::vk.VkBool32
    # shaderSampledImageArrayDynamicIndexing::vk.VkBool32
    # shaderStorageBufferArrayDynamicIndexing::vk.VkBool32
    # shaderStorageImageArrayDynamicIndexing::vk.VkBool32
    # shaderClipDistance::vk.VkBool32
    # shaderCullDistance::vk.VkBool32
    # shaderFloat64::vk.VkBool32
    # shaderInt64::vk.VkBool32
    # shaderInt16::vk.VkBool32
    # shaderResourceResidency::vk.VkBool32
    # shaderResourceMinLod::vk.VkBool32
    # sparseBinding::vk.VkBool32
    # sparseResidencyBuffer::vk.VkBool32
    # sparseResidencyImage2D::vk.VkBool32
    # sparseResidencyImage3D::vk.VkBool32
    # sparseResidency2Samples::vk.VkBool32
    # sparseResidency4Samples::vk.VkBool32
    # sparseResidency8Samples::vk.VkBool32
    # sparseResidency16Samples::vk.VkBool32
    # sparseResidencyAliased::vk.VkBool32
    # variableMultisampleRate::vk.VkBool32
    # inheritedQueries::vk.VkBool32
