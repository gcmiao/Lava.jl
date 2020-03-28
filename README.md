# Lava
Lava is a library that wraps Vulkan API for easy using. It is my student work in **Visual Computing Institute(VCI) of RWTH Aachen** ([https://www.graphics.rwth-aachen.de](https://www.graphics.rwth-aachen.de)).
[![Logo](https://www.graphics.rwth-aachen.de/static/headerbar.png "VCI of RWTH Aachen")](https://www.graphics.rwth-aachen.de)

This Julia version is based on the C++ version of Lava: [https://graphics.rwth-aachen.de:9000/lava](https://graphics.rwth-aachen.de:9000/lava)

If you want to look at the high-level Vulkan API in Julia, you might wish to take a look at [VulkanCore.jl](https://github.com/JuliaGPU/VulkanCore.jl)

# Install
Since Lava.jl is still in development, it has not been a registered package. You can add it by URL:
```
(v1.3) pkg> add https://github.com/gcmiao/Lava.jl.git
```
Or use the local path if you have cloned this repository:
```
(v1.3) pkg> add C:\YOUR_PATH\Lava.jl
```
Use `rm` to remove the package by name:
```
(v1.3) pkg> rm Lava
```
Use `update` to update the package:
```
(v1.3) pkg> update Lava
```

# Usage
You can find an example of Cube in the folder [examples](https://github.com/gcmiao/Lava.jl/tree/master/examples)