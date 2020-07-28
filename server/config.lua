Globals = {
    Minus_Hydration = 0.2,
    Minus_Fertilizer = 0.1,

    Plus_Hydration = 25.0,
    Plus_Fertilizer = 30.0,

    Main_Scale = 1.0,
    Main_Interval = 60,

    Scoreboard = {
        ["reward"] = {
            [0] = {min = 60, max = 80},
            [1] = {min = 40,  max = 60}           
        },
        ["water"] = {
            ["bad"] = 0.5,
            ["good"] = 1.0,
            ["best"] = 1.5
        },
        ["fertilizer"] = {
            ["bad"] = 0.0,
            ["good"] = 1.5,
            ["best"] = 3.0,
        },
        ["weather"] = {
            ["EXTRASUNNY"] = 1.0,
            ["CLEAR"] = 0.9, 
            ["CLOUDS"] = 0.8,
            ["OVERCAST"] = 0.75,
            ["RAIN"] = 0.6,
            ["CLEARING"] = 0.7,
            ["THUNDER"] = 0.45,
            ["SMOG"] = 0.7,
            ["FOGGY"] = 0.5,
            ["XMAS"] = 0.4,
            ["SNOWLIGHT"] = 0.3,
            ["BLIZZARD"]  = 0.2
        },
        ["time"] = {
            [0] = 0,
            [1] = 0,
            [2] = 0,
            [3] = 0,
            [4] = 0,
            [5] = 0.5,
            [6] = 0.8,
            [7] = 1.0,
            [8] = 1.2,
            [9] = 1.4,
            [10] = 1.6,
            [11] = 1.8,
            [12] = 2.0,
            [13] = 2.0,
            [14] = 2.0,
            [15] = 2.0,
            [16] = 2.0,
            [17] = 1.8,
            [18] = 1.6,
            [19] = 1.4,
            [20] = 1.2,
            [21] = 1.0,
            [22] = 0.5,
            [23] = 0,
            [24] = 0,
        }
    },
    DailyNumber = math.random(100, 999),
}