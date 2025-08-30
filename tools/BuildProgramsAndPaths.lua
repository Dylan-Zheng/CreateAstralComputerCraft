local ProgramsAndPaths = {
    {
        program = "programs.PositiveCrafter",
        paths = {
           {
                path = "C:/Program Files (x86)/MultiMC/instances/Creat Astral - 2.1.31/.minecraft/saves/New World/computercraft/computer/10/",
                rename = "startup.lua",
           }
        }
    },
    {
        program = "programs.PositiveCrafterTurtle",
        paths = {
              {
                 path = "C:/Program Files (x86)/MultiMC/instances/Creat Astral - 2.1.31/.minecraft/saves/New World/computercraft/computer/11/",
                 rename = "startup.lua",
              },
              {
                 path = "C:/Program Files (x86)/MultiMC/instances/Creat Astral - 2.1.31/.minecraft/saves/New World/computercraft/computer/16/",
                 rename = "startup.lua",
              }
        }
    }
}

local BuildPrograms = {
    "programs.PositiveCrafter",
    "programs.PositiveCrafterTurtle",
    "programs.RecipeManager",
    "programs.CommandLineTransfer",
    "programs.CaBelt",
    "programs.CaBasin",
    "programs.CaDepot",
    "programs.SimpleTurtleControl",
    "programs.Transfer"
}

local BuildProgramsAndPaths = {}

BuildProgramsAndPaths.programsAndPaths = ProgramsAndPaths
BuildProgramsAndPaths.buildPrograms = BuildPrograms


return BuildProgramsAndPaths
