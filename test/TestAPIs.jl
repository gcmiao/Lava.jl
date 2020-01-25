include("TestInstance.jl")
include("TestQueueRequest.jl")
include("TestDevice.jl")
include("TestShader.jl")
include("TestSampler.jl")
include("TestFramebuffer.jl")

instanceRef = Ref{lava.Instance}()
glfwRef = Ref{features.GlfwOutput}()
@test testInstance(instanceRef, glfwRef)

@test testQueueRequest()
queues = [lava.createGraphics(lava.QueueRequest, "graphics")]

deviceRef = Ref{lava.Device}()
@test testDevice(instanceRef[], queues, deviceRef)
@test testDevice(instanceRef[], queues, lava.NthGroupStrategy(0))

@test testDescriptorSetLayout(deviceRef[])

pass = deviceRef[].createRenderPass(lava.createSimpleForward(lava.RenderPassCreateInfo, glfwRef[].format()))

@test testSampler(deviceRef[].getLogicalDevice())

@test testFramebuffer(deviceRef[], pass)
