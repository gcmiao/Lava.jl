using Revise
using Lava
using VulkanCore
using Lava: @class, @scope, @autodestroy
using LinearAlgebra
using GeometryTypes
using FileIO

const shaderFolder = String(@__DIR__) * "/../shaders/"
const dataFolder = String(@__DIR__) * "/../data/"

struct Vertex
    position::Vec3f0
    normal::Vec3f0

    Vertex(pos::Vec3f0, normal::Vec3f0) = new(pos, normal)
end

function main()
    @scope begin
        fs = Vector{features.IFeature}()
        glfw = features.create(features.GlfwOutput)
        rtx = features.create(features.RayTracing)
        push!(fs, features.create(features.Validation))
        push!(fs, glfw)
        push!(fs, rtx)

        instance = @autodestroy lava.create(lava.Instance, fs)
        queues = [lava.createGraphics(lava.QueueRequest, "graphics")]
        device = @autodestroy instance.createDevice(queues,
                                       # lava.NthOfTypeStrategy(vk.VK_PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU))
                                       lava.NthOfTypeStrategy(vk.VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU))
        window = glfw.openWindow(UInt32(1920), UInt32(1080), false, "RTX Test")
        window->buildSwapchain()

        # Load a model to render
        vertices = Vector{Vertex}()
        indices = geometry.Importer().load(dataFolder * "/models/cube.off",
            (pos, normal, others...)->begin
                push!(vertices, Vertex(Vec3f0(pos), Vec3f0(normal)))
            end)

        vbuffer = @autodestroy lava.createBuffer(device, lava.arrayIndexStorageBuffer())
        vbuffer->setDataVRAM(vertices)
        ibuffer = @autodestroy lava.createBuffer(device, lava.arrayIndexStorageBuffer())
        ibuffer->setDataVRAM(indices)

        # Load the environment map
        envmap = lava.createFromFile(dataFolder * "spruit_sunrise_4k.hdr").uploadTo(device)
        envmap.changeLayout(vk.VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL, vk.VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL)

        vkDevice = device.getLogicalDevice()
        phyDevice = device.getPhysicalDevice()
        dslayout = lava.DescriptorSetLayout(vkDevice,
                        lava.DescriptorSetLayoutCreateInfo().
                             addAccelerationStructure(). # binding 0
                             addSampledImage(vk.VK_SHADER_STAGE_MISS_BIT_NV). # binding 1
                             addStorageImage(vk.VK_SHADER_STAGE_RAYGEN_BIT_NV). # binding 2
                             addStorageBuffer(vk.VK_SHADER_STAGE_ALL). # binding 3
                             addStorageBuffer(vk.VK_SHADER_STAGE_ALL)) # binding 4

        # Build the pipeline
        plLayout = @autodestroy device.createPipelineLayout(Mat4f0, [dslayout])

        rgen = @autodestroy device.createShaderFromFile(shaderFolder * "pinhole.rgen.spv")
        rchit = @autodestroy device.createShaderFromFile(shaderFolder * "chrome.rchit.spv")
        rmiss = @autodestroy device.createShaderFromFile(shaderFolder * "envmap.rmiss.spv")

        pipeline = @autodestroy lava.RayTracingPipeline(device,
                    lava.RayTracingPipelineCreateInfo(plLayout).
                            addRayGeneration(rgen).
                            addTriangleHitGroup(rchit).
                            addMiss(rmiss))

        # Output image
        output = lava.storageImage2D(phyDevice, window.getWidth(), window.getHeight(),
                                     vk.VK_FORMAT_R32G32B32A32_SFLOAT).
                                     createImage(device)
        output.realizeVRAM()
        output.changeLayout(vk.VK_IMAGE_LAYOUT_GENERAL)
        outputView = output.createView(vk.VkImageSubresourceRange(
                                            vk.VK_IMAGE_ASPECT_COLOR_BIT, # aspectMask::VkImageAspectFlags
                                            0, # baseMipLevel::UInt32
                                            1, # levelCount::UInt32
                                            0, # baseArrayLayer::UInt32
                                            1 # layerCount::UInt32
                                        ))
        # Acceleration structures
        geometries = Vector{vk.VkGeometryNV}()
        buffers = Set{lava.Buffer}()
        lava.addTriangleGeometry(geometries, buffers, vbuffer, UInt32(lava.fieldOffset(Vertex, :position)),
                                 UInt32(lava.sizeOfField(Vertex, :position)), UInt32(sizeof(Vertex)),
                                 vk.VK_FORMAT_R32G32B32_SFLOAT, ibuffer, UInt32(0),
                                 UInt32(length(indices)), vk.VK_INDEX_TYPE_UINT32)
        dragon = lava.BottomLevelAccelerationStructureCreateInfo(geometries, buffers).create(device)
        dragon.build()

        tlas = lava.TopLevelAccelerationStructure(device, UInt32(1))
        tlas.build([lava.RayTracingInstance(dragon)])

        # Update Descriptor

        dset = dslayout.createDescriptorSet()
        dset.write().accelerationStructure(tlas).
                     sampledImage(envmap.createView()).
                     storageImage(outputView).
                     storageBuffer(ibuffer).
                     storageBuffer(vbuffer)
    end
end
main()
