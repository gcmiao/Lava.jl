using Lava: @class
using VulkanCore
include("TestInstance.jl")
include("TestQueueRequest.jl")
include("TestDevice.jl")

instanceRef = Ref{lava.Instance}()
@test testInstance(instanceRef)

@test testQueueRequest()
queues = [lava.createGraphics(lava.QueueRequest, "graphics")]

deviceRef = Ref{lava.Device}()
@test testDevice(instanceRef[], queues, deviceRef)
