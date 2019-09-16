function sizeof_obj(x)
    total = 0;
    fieldNames = fieldnames(typeof(x));
    if length(fieldNames) == 0
        return sizeof(x);
    else
        for fieldName in fieldNames
            total += sizeof_obj(getfield(x, fieldName));
        end
        return total;
    end
end

function indexOfField(type, field)
    names = fieldnames(type)
    count = length(names)
    for i = 1 : count
        if names[i] == field
            return i
        end
    end
    return 0
end