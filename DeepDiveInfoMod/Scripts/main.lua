-- DeepDiveInfo

local UEHelpers = require('UEHelpers')

local Utils = require('utils')

local GetKismetSystemLibrary = UEHelpers.GetKismetSystemLibrary
local GetKismetMathLibrary = UEHelpers.GetKismetMathLibrary
local GetPlayerController = UEHelpers.GetPlayerController

local KSysLib = GetKismetSystemLibrary() ---@cast KSysLib UKismetSystemLibrary
local KMathLib = GetKismetMathLibrary() ---@cast KMathLib UKismetMathLibrary

---@type boolean
IsInitialized = false

function Init()
    if KSysLib == nil then error("KismetSystemLibrary not valid\n") end
    print("[INFO] " .. string.format("KismetSystemLibrary: %s", GetKismetSystemLibrary():GetFullName()))
    if KMathLib == nil then error("KismetMathLibrary not valid\n") end
    print("[INFO] " .. string.format("KismetMathLibrary: %s", GetKismetMathLibrary():GetFullName()))

    IsInitialized = true
end

local function DeepDiveInfoMain()
    Init()
    if not IsInitialized then
        error("DeepDiveInfo mod failed to initialize")
        return
    end

    ---@type UFSDGameInstance
    local GameInstance = FindFirstOf("FSDGameInstance")
    if GameInstance == nil or not GameInstance:IsValid() then
        error("could not find FSDGameInstance")
    end
    print("[INFO] retrieved game instance\n")

    ---@type UDeepDiveManager
    local DeepDiveManager = GameInstance.DeepDiveManager
    print("[INFO] retrieved DeepDiveManager: " .. DeepDiveManager:GetFullName() .. "\n")

    local GameFnLib = StaticFindObject('/Script/FSD.Default__GameFunctionLibrary') ---@cast GameFnLib UGameFunctionLibrary
    local GameplayStatics = UEHelpers.GetGameplayStatics() ---@cast GameplayStatics UGameplayStatics
    local PlayerController = GameInstance:GetLocalFSDPlayerController()
    local GameMode = GameFnLib:GetFSDGameMode(PlayerController)

    if GameMode:IsA('/Game/Game/SpaceRig/BP_SpaceRig_GamemOde.BP_SpaceRig_Gamemode_C') then
        print("[INFO] detected user is loaded into space rig\n")
        GameMode --[[@as ABP_SpaceRig_Gamemode_C]]:InstantlyStartMission()
        print("[INFO] attempted to instantly start mission\n")
    end
end

RegisterKeyBind(Key.X, DeepDiveInfoMain)
