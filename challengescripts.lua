
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

-- Force all rooms to be either health or wealth, and all chaos boons to be health or increased money
function HealthAndWealthSetup()
    for _, roomData in pairs(RoomData) do
        if roomData.Name == "RoomOpening" then
            roomData.SecretSpawnChance = 1.0
            roomData.EligibleRewards = {"Boon"} -- you can have a boon, i guess.
        elseif not string.find(roomData.Name, "Secret") then
            roomData.EligibleRewards = {"RoomRewardMaxHealthDrop", "RoomRewardMoneyDrop"}
            roomData.ForcedRewardStore = "RunProgress"
        end
    end

    for _, lootData in pairs(LootData) do 
        if lootData.Name == "TrialUpgrade" then
            lootData.PermanentTraits = {"ChaosBlessingMaxHealthTrait", "ChaosBlessingMoneyTrait","ChaosBlessingMaxHealthTrait","ChaosBlessingMoneyTrait"} -- we need at least 3 options or the game crashes. let's try 2 of each.
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

function EatTheRichSetup()
    for _, roomData in pairs(RoomData) do
        if string.find(roomData.Name, "PostBoss") then
            table.insert(roomData.ThreadedEvents, { FunctionName = "RemoveHealth", Args = { HealthPercentage = 0.05, StartDelay = 1} })
        end
    end
end

function RemoveHealth( args )
    -- We basically use the amount of money to determine what percentage of our health we are taking away. 
    -- More money, bigger percentage removed. Starting with calculating 5% of money to determine the percent removed.
    -- We also want to remove the same % from the amount of health we have, to make it spicy
    local healthPercentage = args.HealthPercentage or 0.05
    DebugPrint({ Text="ChallengeMod: Using "..healthPercentage.." percentage of money. Have "..CurrentRun.Money })
    local healthChange = 1.0 - (CurrentRun.Money * healthPercentage)/100

    local waitDelay = args.StartDelay or 0 
    wait( waitDelay )

    DebugPrint({Text="ChallengeMod: Reducing to "..healthChange.." percentage of health."})

    local newCurrentHealth = round(CurrentRun.Hero.Health * healthChange)
    DebugPrint({Text="ChallengeMod: Setting current health to "..newCurrentHealth})
    CurrentRun.Hero.Health = newCurrentHealth

    local newTotalHealth = round(CurrentRun.Hero.MaxHealth * healthChange)
    DebugPrint({Text="ChallengeMod: Setting max health to "..newTotalHealth})
    CurrentRun.Hero.MaxHealth = newTotalHealth

    thread( UpdateHealthUI )
end

ModUtil.Path.Wrap("CalculateDamageAdditions", function(baseFunc, attacker, victim, triggerArgs)
    if ChallengeMod.ActiveChallenge == ChallengeMod.ChallengeData.EatTheRich.Name then
        local damageReduction = -0.05 * CurrentRun.Money
        DebugPrint({Text="ChallengeMod: Reducing damage by "..damageReduction})
        return baseFunc(attacker, victim, triggerArgs) + damageReduction
    else
        return baseFunc(attacker, victim, triggerArgs)
    end
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