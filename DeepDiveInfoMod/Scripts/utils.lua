---@param obj UObject
function ToString(obj)
    if obj == nil or not obj:IsValid() then
        return nil
    end

    print(obj:IsValid() and 'valid' or 'invalid')
    local fname = obj:GetFName()
    if fname == nil then
        return obj:GetFullName()
    else
        return fname:ToString()
    end
end
