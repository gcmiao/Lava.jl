include("TestFeature.jl")
function testInstance(outInstance::Ref)
    # Create a Vulkan instance, tell it we need glfw and the validation as
    # extension features
    fs = Vector{features.IFeature}()
    fsValid = features.create(features.Validation)
    glfw = features.create(features.GlfwOutput)
    fsTest = create(TestFeature)
    fs = [fsValid, glfw, fsTest]
    instance = lava.create(lava.Instance, fs)

    @test fsTest.mOnInstanceCreatedCalled
    @test lava.handle(instance) != vk.VK_NULL_HANDLE
    @test glfw.mTempWindow != vk.VK_NULL_HANDLE
    @test glfw.mTempSurface != vk.VK_NULL_HANDLE

    outInstance[] = instance
    return true
end
