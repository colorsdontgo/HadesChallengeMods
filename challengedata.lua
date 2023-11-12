ChallengeMod.ChallengeData =
{
    --Template
    Challenge1 =
    {
        Name = "Tartarus skip",
        Description = "Zagreus jumped a bit further from the window and landed in Asphodel. Can you survive the heat of Asphodel with only your starting boon?",
        Author = "PonyWarrior",
        SetupFunction = "Challenge1",
        RestoreRoomData = true,
        HellMode = false,
        HardMode =
        {
            Description = "You thought that was too easy? Try again but with a pitiful health pool and in hell mode. Good luck!",
            SetupFunction = "Challenge1",
            HellMode = true,
            RestoreRoomData = true,
            Trait =
            {
                Icon = "Shop_BedroomDecor",
                Name = "ChallengeMode",
		        MaxHealthMultiplier = 0.2,
                PropertyChanges =
                {
                    {
                        LuaProperty = "MaxHealth",
                        ChangeValue = 0.2,
                        ChangeType = "Multiply",
                    },
                },
            }
        },
    },

    BoonsOnly = 
    {
        Name = "Only Boons",
        Description = "How fast can you clear, at what heat can you clear, if every room gives you a boon?",
        Author = "cgull",
        SetupFunction = "OnlyBoonsSetup",
        HellMode=false,
        RestoreRoomData=true,
    },

    PomOneBoon = 
    {
        Name = "Pom One Boon",
        Description = "Pick a boon in chamber one, then level it up every chamber after that.",
        Author = "cgull",
        SetupFunction = "PomOneBoonSetup",
        HellMode=False,
        RestoreRoomData=true,
    },

    RampUpTheSpeed = 
    {
        Name = "Ramp Up the Speed",
        Description = "Every room, enemy speed increases by 1%",
        Author = "colorsdontgo",
        SetupFunction = "SpeedyBoisSetup",
        HellMode = false,
        RestoreRoomData = true,
    }

    -- BossRush =
    -- {
    --     Name = "Boss Rush",
    --     Description = "Fight the Fury, Bone Hydra, Heroes of Elysium and Hades one after the other as fast as you can with one of the build provided.",
    --     Author = "PonyWarrior",
    --     HellMode = false,
    --     SetupFunction = "ChallengeMod.BossRushRoomset",
    --     RestoreRoomData = true,
    --     HardMode =
    --     {
    --         Description = "Fight the Furies, Bone Hydra, Heroes of Elysium and Hades one after the other as fast as you can with one of the build provided, with Extreme Measures, Hell Mode and no midbiome rooms.",
    --         HellMode = true,
    --         SetupFunction = "ChallengeMod.BossRushRoomsetHard",
    --         RestoreRoomData = true,
    --         ForcedPactOptions =
    --         {
    --             {
    --                 Name = "BossDifficultyShrineUpgrade",
    --                 Level = 4
    --             },
    --         },
    --     },
    -- },
}