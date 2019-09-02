mutable struct PipelineShaderStageCreateInfo
std::string mName;
vk::PipelineShaderStageCreateInfo mInfo;
vk::SpecializationInfo mSpecInfo;
std::vector<vk::SpecializationMapEntry> mSpecMap;
std::vector<char> mSpecData;
SharedShaderModule mModule;
end