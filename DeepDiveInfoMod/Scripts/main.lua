-- DeepDiveInfo

local UEHelpers = require('UEHelpers')

local Utils = require('utils')

local GetKismetSystemLibrary = UEHelpers.GetKismetSystemLibrary
local GetKismetMathLibrary = UEHelpers.GetKismetMathLibrary
local GetPlayerController = UEHelpers.GetPlayerController

local KSysLib = GetKismetSystemLibrary() ---@cast KSysLib UKismetSystemLibrary
local KMathLib = GetKismetMathLibrary() ---@cast KMathLib UKismetMathLibrary
local KTextLib = StaticFindObject("/Script/Engine.Default__KismetTextLibrary") ---@cast KTextLib UKismetTextLibrary
local GameFnLib = StaticFindObject("/Script/FSD.Default__GameFunctionLibrary") ---@cast GameFnLib UGameFunctionLibrary

---@type UFSDGameInstance
local GameInstance = nil

---@type boolean
IsInitialized = false

local function Init()
    if KSysLib == nil then error("KismetSystemLibrary not valid\n") end
    print("[INFO] " .. string.format("KismetSystemLibrary: %s", GetKismetSystemLibrary():GetFullName()))
    if KMathLib == nil then error("KismetMathLibrary not valid\n") end
    print("[INFO] " .. string.format("KismetMathLibrary: %s", GetKismetMathLibrary():GetFullName() .. "\n"))
    if KTextLib == nil then error("KismetTexLibrary not valid\n") end
    print("[INFO] " .. string.format("KTextLib: %s", KTextLib) .. "\n")
    if GameFnLib == nil then error("GameFunctionLibrary not valid\n") end
    print("[INFO] " .. string.format("GameFnLib: %s", GameFnLib) .. "\n")
    GameInstance = FindFirstOf("FSDGameInstance")
    if GameInstance == nil or not GameInstance:IsValid() then
        error("could not find FSDGameInstance")
    end
    print("[INFO] retrieved game instance\n")

    IsInitialized = true
end

---@param Missions TArray<UGeneratedMission>
local function PrintDiveMissions(Missions)
    Missions:ForEach(function(Level, Mission)
        print(string.format('===STAGE %i: ===', Level))
        print(string.format('duration: %s', ToString(Mission:get().DurationLimit)))
        print(string.format('complexity: %s', ToString(Mission:get().ComplexityLimit)))
        print(string.format('primary obj: %s', ToString(Mission:get().PrimaryObjective)))
        print(string.format('secondary obj: %s', table.concat(
            Map(
                Mission:get().SecondaryObjectives,
                function(v) return ToString(v) end
            )
        ), ', '))
    end)
end

local function SelectDeepDive()
    if not IsInitialized then
        error("DeepDiveInfo mod failed to initialize")
        return
    end

    ---@type UDeepDiveManager
    local DeepDiveManager = GameInstance.DeepDiveManager
    ---@type UDeepDive
    local NormalDeepDive = DeepDiveManager:GetActiveNormalDeepDive()
    if NormalDeepDive == nil or not NormalDeepDive:IsValid() then
        error("NormalDeepDive is invalid")
    end
    ---@type TArray<UGeneratedMission>
    local Missions = NormalDeepDive.missions

    PrintDiveMissions(Missions)
end

RegisterKeyBind(Key.Z, Init)
RegisterKeyBind(Key.X, SelectDeepDive)
