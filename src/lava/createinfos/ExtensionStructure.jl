mutable struct ExtensionStructure
  mNext
end

function setNext(this::T, next::U) where {T<:ExtensionStructure, U<:ExtensionStructure}
    this.mNext = next;
end

function next(this::T) where T<:ExtensionStructure
    return this.mNext
end