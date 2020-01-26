include("TestInstance.jl")
include("TestQueueRequest.jl")
include("TestDevice.jl")
include("TestSampler.jl")
include("TestFramebuffer.jl")
include("TestGraphicsPipeline.jl")

instanceRef = Ref{lava.Instance}()
glfwRef = Ref{features.GlfwOutput}()
@test testInstance(instanceRef, glfwRef)

@test testQueueRequest()
queues = [lava.createGraphics(lava.QueueRequest, "graphics")]

deviceRef = Ref{lava.Device}()
@test testDevice(instanceRef[], queues, deviceRef)
@test testDevice(instanceRef[], queues, lava.NthGroupStrategy(0))

pipelineRef = Ref{lava.GraphicsPipeline}()
passRef = Ref{lava.RenderPass}()
@test testCreateGraphicsPipeline(deviceRef[], glfwRef[], pipelineRef, passRef)

@test testSampler(deviceRef[].getLogicalDevice())

@test testFramebuffer(deviceRef[], passRef[])
