mutable struct ExtensionStructure
  mNext
  function ExtensionStructure()
    this = new()
  end
end

function setNext(this::T, next::U) where {T<:ExtensionStructure, U<:ExtensionStructure}
    this.mNext = next;
end

function next(this::T) where T<:ExtensionStructure
    return this.mNext
end