mutable struct RayTracingPipeline
    mHandle::vk.VkPipeline
    mRaytracingProperties::vk.VkPhysicalDeviceRayTracingPropertiesNV
    mDevice::Device
    mShaderBindingTable::Buffer
    mCreateInfo::RayTracingPipelineCreateInfo

    function RayTracingPipeline(device::Device, info::RayTracingPipelineCreateInfo)
        this = new()
        this.mDevice = device
        vkDevice = device.getLogicalDevice()
        phyDevice = device.getPhysicalDevice()
        pipelineRef = Ref{vk.VkPipeline}()
        vk.vkCreateRayTracingPipelinesNV(vkDevice, C_NULL, 1, this.mCreateInfo.handleRef(), C_NULL, pipelineRef)
        this.mHandle = pipelineRef[]

        this.mShaderBindingTable = this.mDevice.createBuffer(raytracingBuffer())
        this.mRaytracingProperties = VkExt.getRayTracingProperties(phyDevice)

        groupData = Vector{UInt8}(undef, this.mRaytracingProperties.shaderGroupHandleSize *
                                         length(this.mCreateInfo.getGroups()))
        vk.vkGetRayTracingShaderGroupHandlesNV(vkDevice, this.mHandle,
                0, length(this.mCreateInfo.getGroups()), length(groupData), pointer(groupData))

        this.mShaderBindingTable.setDataVRAM(groupData)
        return this
    end
end
@class RayTracingPipeline

struct OffsetStride
    offset::Integer
    stride::Integer
    OffsetStride(offset::Integer = 0, stride::Integer = 1) = new(offset, stride)
end

function destroy(this::RayTracingPipeline)
    vk.vkDestroyPipeline(mDevice.getLogicalDevice(), this.mHandle, C_NULL)
end

function handle(this::RayTracingPipeline)::vk.VkPipeline
    return this.mHandle
end

function bindPipeline(this::RayTracingPipeline, cmd::RecordingCommandBuffer)
    vk.vkCmdBindPipeline(cmd.handle(), vk.VK_PIPELINE_BIND_POINT_RAY_TRACING_NV, this.handle())
end

function shaderBindingTable(this::RayTracingPipeline)::Buffer
    return this.mShaderBindingTable
end

function getLayout(this::RayTracingPipeline)::PipelineLayout
    return this.mCreateInfo.getLayout()
end

function trace(cmd::RecordingCommandBuffer,
             width::UInt32, height::UInt32,
             depth::UInt32 = UInt32(1), raygen::Integer = Integer(0),
              miss::OffsetStride = OffsetStride(), hit::OffsetStride = OffsetStride())::RayTracingPipeline
    sbt = this.mShaderBindingTable.handle()
    handlesize = this.mRaytracingProperties.shaderGroupHandleSize

    genoffset = raygen + this.mCreateInfo.firstRaygenIndex();
    hitoffset = hit.offset + this.mCreateInfo.firstHitIndex();
    missoffset = miss.offset + this.mCreateInfo.firstMissIndex();

    vk.vkCmdTraceRaysNV(cmd.handle(), sbt, genoffset * handlesize,
                        sbt, missoffset * handlesize, miss.stride * handlesize,
                        sbt, hitoffset * handlesize, hit.stride * handlesize,
                        C_NULL, 0, 0,
                        width, height, depth)
end
