const u8vec4 = Vec{4, UInt8}
struct Vertex
    position::Vec3f0
    color::u8vec4
end

function testVertexInputState(inputStateRef::Ref)
    attributes = Vector{vk.VkVertexInputAttributeDescription}()
    bindings = Vector{vk.VkVertexInputBindingDescription}()
    lava.binding(attributes, bindings, UInt32(0), Vertex, :position)
    lava.binding(attributes, bindings, UInt32(0), Vertex, :color)
    vertexInputState = lava.PipelineVertexInputStateCreateInfo(attributes = attributes, bindings = bindings)
    inputStateRef[] = vertexInputState
    return true
end
