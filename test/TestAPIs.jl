using Lava: @class
using VulkanCore
include("TestInstance.jl")
include("TestQueueRequest.jl")
include("TestDevice.jl")
include("ShaderTest.jl")

instanceRef = Ref{lava.Instance}()
@test testInstance(instanceRef)

@test testQueueRequest()
queues = [lava.createGraphics(lava.QueueRequest, "graphics")]

deviceRef = Ref{lava.Device}()
@test testDevice(instanceRef[], queues, deviceRef)
@test testDevice(instanceRef[], queues, lava.NthGroupStrategy(0))

@test testDescriptorSetLayout(deviceRef[])
