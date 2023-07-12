---@param obj UObject
function ToString(obj)
    if obj == nil or not obj:IsValid() then
        return nil
    end

    local fname = obj:GetFName()
    if fname == nil then
        return obj:GetFullName()
    else
        return fname:ToString()
    end
end

---@generic K, V, N
---@param tbl fun(table: {[K]: V}, index?: K):K, V
---@param f fun(v: V): N
---@return {[K]: N}
function Map(tbl, f)
    local t = {}
    tbl:ForEach(function(Idx, Elem)
        t[Idx] = f(Elem:get())
    end)
    return t
end
