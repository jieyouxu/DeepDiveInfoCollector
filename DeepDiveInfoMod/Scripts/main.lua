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
local SubsysBlueprintLib = StaticFindObject("/Script/Engine.SubsystemBlueprintLibrary") ---@cast SubsysBlueprintLib USubsystemBlueprintLibrary

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
    if SubsysBlueprintLib == nil or not SubsysBlueprintLib:IsValid() then error("SubsystemBlueprintLibrary not valid\n") end
    print("[INFO] " .. string.format("SubsystemBlueprintLibrary: %s", SubsysBlueprintLib) .. "\n")
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
        print(string.format('=== STAGE %i: ===', Level))
        print(string.format('Duration: %s', ToString(Mission:get().DurationLimit)))
        print(string.format('Complexity: %s', ToString(Mission:get().ComplexityLimit)))
        print(string.format('Primary objectives: %s', ToString(Mission:get().PrimaryObjective)))
        print(string.format('Secondary objectives: %s', table.concat(
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

    local DeepDiveManager = FindFirstOf("DeepDiveManager") ---@cast DeepDiveManager UDeepDiveManager
    if DeepDiveManager == nil or not DeepDiveManager:IsValid() then
        error("DeepDiveManager is invalid")
        return
    end

    ---@type UDeepDive
    local NormalDeepDive = DeepDiveManager:GetActiveNormalDeepDive()
    if NormalDeepDive == nil or not NormalDeepDive:IsValid() then
        error("NormalDeepDive is invalid")
    end
    print("<<<<<< NORMAL DEEP DIVE >>>>>>\n")
    -- FIXME: the following crashes
    -- print("Codename:", KTextLib:Conv_TextToString(NormalDeepDive.DeepDiveName))
    print("Biome:", NormalDeepDive.Biome:GetFullName())
    ---@type TArray<UGeneratedMission>
    local Missions = NormalDeepDive.missions

    PrintDiveMissions(Missions)

    DeepDiveManager:SetDeepDive(NormalDeepDive)
    print(string.format("[INFO] DeepDiveManager CurrentMission: %s", DeepDiveManager.CurrentMission))

    local MissionModeManager = FindFirstOf("DeepDiveManager") ---@cast MissionModeManager IMissionModeManager
    if MissionModeManager == nil or not MissionModeManager:IsValid() then
        error("MissionModeManager is invalid")
        return
    end

    MissionModeManager:StartDive()

    -- GameInstance:SetSelectedMission(DeepDiveManager.CurrentMission, true)

    -- local PlayerController = GameInstance:GetLocalFSDPlayerController()
    -- local GameMode = GameFnLib:GetFSDGameMode(PlayerController)
    -- if GameMode:IsA('/Game/Game/SpaceRig/BP_SpaceRig_GamemOde.BP_SpaceRig_Gamemode_C') then
    --     print("[INFO] detected user is loaded into space rig\n")
    --     GameMode --[[@as ABP_SpaceRig_Gamemode_C]]:InstantlyStartMission()
    --     print("[INFO] attempted to instantly start mission\n")
    -- end
end

local function SelectEliteDeepDive()
    if not IsInitialized then
        error("DeepDiveInfo mod failed to initialize")
        return
    end

    ---@type UDeepDiveManager
    local DeepDiveManager = GameInstance.DeepDiveManager
    ---@type UDeepDive
    local EliteDeepDive = DeepDiveManager:GetActiveHardDeepDive()
    if EliteDeepDive == nil or not EliteDeepDive:IsValid() then
        error("EliteDeepDive is invalid")
    end
    print("<<<<<< ELITE DEEP DIVE >>>>>>\n")
    -- FIXME: the following crashes
    -- print("Codename:", KTextLib:Conv_TextToString(EliteDeepDive.DeepDiveName))
    print("Biome:", EliteDeepDive.Biome:GetFullName())
    ---@type TArray<UGeneratedMission>
    local Missions = EliteDeepDive.missions

    PrintDiveMissions(Missions)

    local WorldCtxt = GameInstance:GetLocalFSDPlayerController()
    local MissionGenerationManager = SubsysBlueprintLib:GetGameInstanceSubsystem(WorldCtxt, UMissionGenerationManager) ---@cast MissionGenerationManager UMissionGenerationManager

    local AvailableMissions = MissionGenerationManager:GetAvailableMissions()
    local GeneratedMission = AvailableMissions:__index(0)
    GameInstance:SetSelectedMission(GeneratedMission, true)

    DeepDiveManager:SetDeepDive(EliteDeepDive)

    local WorldCtxt = GameInstance:GetLocalFSDPlayerController()
    DeepDiveManager --[[@as IMissionModeManager]]:StartDive()
end

RegisterKeyBind(Key.Z, Init)
RegisterKeyBind(Key.C, SelectDeepDive)
RegisterKeyBind(Key.V, SelectEliteDeepDive)
