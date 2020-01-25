include("TestInstance.jl")
include("TestQueueRequest.jl")
include("TestDevice.jl")
include("TestShader.jl")
include("TestSampler.jl")
include("TestFramebuffer.jl")
include("TestRenderpass.jl")

# mutable struct CameraData
#     view::Mat4f0
#     proj::Mat4f0
#
#     CameraData() = new(Mat4f0(1I), Mat4f0(1I))
#     CameraData(view::Mat4f0, proj::Mat4f0) = new(view, proj)
# end
# @class CameraData

instanceRef = Ref{lava.Instance}()
glfwRef = Ref{features.GlfwOutput}()
@test testInstance(instanceRef, glfwRef)

@test testQueueRequest()
queues = [lava.createGraphics(lava.QueueRequest, "graphics")]

deviceRef = Ref{lava.Device}()
@test testDevice(instanceRef[], queues, deviceRef)
@test testDevice(instanceRef[], queues, lava.NthGroupStrategy(0))

# plLayout = deviceRef[].createPipelineLayout(CameraData)
@test testDescriptorSetLayout(deviceRef[])

passRef = Ref{lava.RenderPass}()
@test testRenderPass(deviceRef[], glfwRef[], passRef)

@test testSampler(deviceRef[].getLogicalDevice())

@test testFramebuffer(deviceRef[], passRef[])
