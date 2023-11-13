
function Challenge1()
    RoomSetData.Tartarus.RoomOpening.NextRoomSet = {"Asphodel"}
end

function OnlyBoonsSetup()
    for _, roomData in pairs(RoomData) do
        roomData.SecretSpawnChance = 0.0
        roomData.EligibleRewards = {"Boon", "HermesUpgrade"}
        roomData.ForcedRewardStore = "RunProgress"
    end
end

ModUtil.Path.Wrap("ReachedMaxGods", function(baseFunc, excludedGods)
    if ChallengeMod.ActiveChallenge == ChallengeMod.ChallengeData.BoonsOnly.Name then
        return false
    else
        return baseFunc(excludedGods)
    end    
end, ChallengeMod)

function PomOneBoonSetup()
    for _, roomData in pairs(RoomData) do
        if roomData.Name == "RoomOpening" then
            roomData.SecretSpawnChance = 0.0
            roomData.EligibleRewards = {"Boon"}
        else
            roomData.SecretSpawnChance = 0.0
            roomData.EligibleRewards = {"StackUpgrade"}
            roomData.ForcedRewardStore = "RunProgress"
        end
    end
end

function SpeedyBoisSetup()
    -- For now, let's just mess with the normal base enemies
    EnemyData.BaseVulnerableEnemy.AdditionalEnemySetupFunctionName = "RampSpeed"
end

function RampSpeed(enemy, currentRun)
    -- Get the room number
    local roomNumber = GetRunDepth(currentRun)

    -- Calculate speed multiplier. Increase speed by 2% every room. In modded runs, that means ~51 rooms (for two tunnels) so 102% faster enemies at the end.
    -- Would be cool if we could allow user to specify
    local speedMultiplier = enemy.SpeedMultiplier or 1
    speedMultiplier = speedMultiplier + (roomNumber * .02)

    -- Set enemy's speed multiplier. These are copied from RoomManager.lua lines 4115-4116
    DebugPrint({ Text = "ChallengeMod: Room "..roomNumber..". Setting speed multiplier for "..enemy.Name.." to "..speedMultiplier })
    enemy.SpeedMultiplier = speedMultiplier
    SetThingProperty({ Property = "ElapsedTimeMultiplier", Value = enemy.SpeedMultiplier, ValueChangeType = "Multiply", DataValue = false, DestinationId = enemy.ObjectId })
end

-- Furies and Theseus already have their AdditionalEnemySetupFunctionName set, so we need to override those functions
ModUtil.Path.Wrap("SelectHarpySupportAIs", function( baseFunc, enemy, currentRun)
    if ChallengeMod.ActiveChallenge == ChallengeMod.ChallengeData.RampUpTheSpeed.Name then
        DebugPrint({Text = "ChallengeMod: Speeding up Furies"})
        RampSpeed(enemy, currentRun)
    end
    
    return baseFunc(enemy, currentRun)
end, ChallengeMod)

ModUtil.Path.Wrap("SelectTheseusGod", function(baseFunc, enemy, run, args)
    if ChallengeMod.ActiveChallenge == ChallengeMod.ChallengeData.RampUpTheSpeed.Name then
        DebugPrint({ Text = "ChallengeMod: Speeding up Theseus" })
        RampSpeed(enemy, run)
    end
    return baseFunc(enemy, run, args)
end, ChallengeMod)

ModUtil.Path.Wrap("IsRoomRewardEligible", function( baseFunc, run, room, reward, previouslyChosenRewards, args)
    if ChallengeMod.ActiveChallenge == ChallengeMod.ChallengeData.PomOneBoon.Name then
        local reward2 = DeepCopyTable(reward)
        reward2.AllowDuplicates = true
        return baseFunc(run, room, reward2, previouslyChosenRewards, args)
    else
        return baseFunc(run, room, reward, previouslyChosenRewards, args)
    end
end, ChallengeMod)

function ChallengeMod.BossRushRoomset()
    for _, roomData in pairs(RoomData) do
        roomData.SecretSpawnChance = 0.0
        roomData.ShrinePointDoorSpawnChance = 0.0
        roomData.ChallengeSpawnChance = 0.0
        roomData.WellShopSpawnChance = 0.0
        roomData.SellTraitShopChance = 0.0
        roomData.FishingPointChance = 0.0
        roomData.FlipHorizontalChance = 0.0
    end

    RoomData.RoomOpening.ForcedRewardStore = "MetaProgress"
    RoomData.RoomOpening.LinkedRooms = {"A_Boss01", "A_Boss02", "A_Boss03"}

    RoomData.A_Boss01.EligibleRewards = {}
    RoomData.A_Boss02.EligibleRewards = {}
    RoomData.A_Boss03.EligibleRewards = {}

    RoomData.A_PostBoss01.LinkedRoom = "B_Boss01"

    RoomData.B_Boss01.RemoveTimerBlock = "InterBiome"
    RoomData.B_Boss01.EligibleRewards = {}
    RoomData.B_Boss01.RemoveTimerBlock = "InterBiome"
    RoomData.B_PostBoss01.LinkedRoom = "C_Boss01"

    RoomData.C_Boss01.RemoveTimerBlock = "InterBiome"
    RoomData.C_PostBoss01.LinkedRoom = "D_Boss01"
    RoomData.C_Boss01.EligibleRewards = {}
    RoomData.C_Boss01.RemoveTimerBlock = "InterBiome"

    RoomData.D_Boss01.RemoveTimerBlock = "InterBiome"
    RoomData.D_Boss01.EligibleRewards = {}
end

function ChallengeMod.BossRushRoomsetHard()
    for _, roomData in pairs(RoomData) do
        roomData.SecretSpawnChance = 0.0
        roomData.ShrinePointDoorSpawnChance = 0.0
        roomData.ChallengeSpawnChance = 0.0
        roomData.WellShopSpawnChance = 0.0
        roomData.SellTraitShopChance = 0.0
        roomData.FishingPointChance = 0.0
        roomData.FlipHorizontalChance = 0.0
    end

    RoomData.RoomOpening.UnthreadedEvents = nil
    RoomData.RoomOpening.LinkedRooms = {"A_Boss01", "A_Boss02", "A_Boss03"}

    RoomData.A_Boss01.NextRoomSet = { "Asphodel"}
    RoomData.A_Boss01.LinkedRoom = "B_Boss02"
    RoomData.A_Boss01.EligibleRewards = {}

    RoomData.A_Boss02.NextRoomSet = { "Asphodel"}
    RoomData.A_Boss02.LinkedRoom = "B_Boss02"
    RoomData.A_Boss02.EligibleRewards = {}

    RoomData.A_Boss03.NextRoomSet = { "Asphodel"}
    RoomData.A_Boss03.LinkedRoom = "B_Boss02"
    RoomData.A_Boss03.EligibleRewards = {}

    RoomData.B_Boss02.NextRoomSet = {"Elysium"}
    RoomData.B_Boss02.LinkedRoom = "C_Boss01"
    RoomData.B_Boss02.RemoveTimerBlock = "InterBiome"
    RoomData.B_Boss02.EligibleRewards = {}

    RoomData.C_Boss01.NextRoomSet = {"Styx"}
    RoomData.C_Boss01.LinkedRoom = "D_Boss01"
    RoomData.C_Boss01.EligibleRewards = {}
    RoomData.C_Boss01.RemoveTimerBlock = "InterBiome"

    RoomData.D_Boss01.RemoveTimerBlock = "InterBiome"
    RoomData.D_Boss01.EligibleRewards = {}
end