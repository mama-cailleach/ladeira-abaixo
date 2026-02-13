GameConstants = {}


-- Movement and Speed Constants
GameConstants.MOVEMENT = {
    PLAYER_ANGLE_LIMIT = 60,
    PLAYER_Y_MIN = 30,
    PLAYER_Y_MAX = 210,
    
    -- Base Speeds (the single source of truth)
    PLAYER_BASE_SPEED = 9.0, -- has to be float for player movement physics calculations
    NORMAL_SPEED = 9,
    -- new percentage ratio system
    SLOW_SPEED_RATIO = 0.6,
    FAST_SPEED_RATIO = 1.25,
    
    -- Movement Physics
    LATERAL_MOVEMENT_FACTOR = 0.08, -- how fast the player moves left/right
    DOWNWARD_DRIFT_FACTOR = 0.0001, -- how fast the player drifts 

    -- scoring
    PIXELS_PER_METER = 50 -- 1 meter = integer meters (atm this is kinda 5 m/s)
}

GameConstants.SPEED = {
    -- Example: UNLOCK_STEP = 200 and INCREMENT = 1 => +1 speed every 200 meters.
    UNLOCK_STEP = 60, -- 50
    INCREMENT = 1,
    MAX_INCREMENT = 18  -- cap MAX SPEED 
}

-- Spawning Constants
GameConstants.SPAWN = {
    SPAWN_X_MIN = 585, -- tem que ser esse minimo pra taça
    SPAWN_X_MAX = 985, -- uma tela de diferença
    REMOVAL_X_THRESHOLD = -185, -- threshold pra taça
    SPAWN_TIME_MIN = 100,
    SPAWN_TIME_MAX = 500,
    
    SCORE_TO_MAX_DIFFICULTY = 300, -- Score at which spawn timing reaches max difficulty
    MAX_SPAWN_PER_TICK = 1, -- Maximum number of objects to attempt to spawn per timer tick. feels like leaving 1 is awrite?
    BASE_SPAWN_TICK = 1 -- Base spawn before difficulty scaling
}

-- difficulty prog tiers idea
local tier1 = 0
local tier2 = 100
local tier3 = 200
-- Difficulty & progression tuning for spawning. when types become available
GameConstants.SPAWN.UNLOCK_SCORE = {
    --tier1
    bandeirinhas = tier1,
    bandeirinhas02 = tier1,
    brflag = tier1,
    caflag = tier1,
    fios = tier1,
    fitinhas = tier1,
    hexa = tier1,
    placa02 = tier1,
    postequebrado = tier1,
    powercable = tier1,
    scflag = tier1,
    worldcup = tier1,
    placa = tier1,
    poste = tier1,
    oil = tier1,
    pastel = tier1,
    bola = tier1,
    bueiro = tier1,
    --tier2
    pipoqueiro = tier2,
    --tier3
    uninho = tier3,
    motoboy = tier3
}


-- Weight tiers for spawn probabilities based on score thresholds
GameConstants.SPAWN.WEIGHT_TIERS = { 
    {
        scoreThreshold = 0,
        weights = {
            bandeirinhas = 2, placa = 2, poste = 2, bandeirinhas02 = 2,
            brflag = 2, caflag = 2, fios = 2, fitinhas = 2,
            hexa = 2, placa02 = 2, posteQuebrado = 2, powercable = 2,
            scflag = 2, worldcup = 2,
            oil = 6, pastel = 8, bola = 8, bueiro = 8,
            pipoqueiro = 3, uninho = 2, motoboy = 2
        }
    },
    {
        scoreThreshold = 200,
        weights = {
            bandeirinhas = 4, placa = 4, poste = 4, bandeirinhas02 = 4,
            brflag = 4, caflag = 4, fios = 4, fitinhas = 4,
            hexa = 4, placa02 = 4, posteQuebrado = 4, powercable = 4,
            scflag = 4, worldcup = 4,
            oil = 6, pastel = 4, bola = 6, bueiro = 4,
            pipoqueiro = 2, uninho = 2, motoboy = 2
        }
    },
    {
        scoreThreshold = 400,
        weights = {
            bandeirinhas = 4, placa = 4, poste = 4, bandeirinhas02 = 4,
            brflag = 4, caflag = 4, fios = 4, fitinhas = 4,
            hexa = 4, placa02 = 4, posteQuebrado = 4, powercable = 4,
            scflag = 4, worldcup = 4,
            oil = 13, pastel = 13, bola = 14, bueiro = 13,
            pipoqueiro = 2, uninho = 4, motoboy = 4
        }
    },
    {
        scoreThreshold = 800,
        weights = {
            bandeirinhas = 4, placa = 4, poste = 4, bandeirinhas02 = 4,
            brflag = 4, caflag = 4, fios = 4, fitinhas = 4,
            hexa = 4, placa02 = 4, posteQuebrado = 4, powercable = 4,
            scflag = 4, worldcup = 4,
            oil = 6, pastel = 4, bola = 5, bueiro = 6,
            pipoqueiro = 13, uninho = 10, motoboy = 10
        }
    }
}


-- Effect Constants
GameConstants.EFFECTS = {
    OIL_DURATION = 1500,
    BOLA_DURATION = 1500,
    BUEIRO_DURATION = 1500,
    PASTEL_DURATION = 1500,
    BLINK_INTERVAL = 100,
    SHAKE_TIME = 900,
    SHAKE_MAGNITUDE = 5
}

-- Game Flow Constants
GameConstants.GAME = {
    COUNTDOWN_FPS = 30,
    DEATH_FRAME_DURATION = 3000,
}

-- Collision Groups
GameConstants.COLLISION_GROUPS = {
    PLAYER = 1,
    ENEMIES = 2,
    EFFECTS = 3,
    POWERUPS = 4,
    CONSUMABLES = 6,
    CURBS = 8,
    TEMPORARY_INVULNERABLE = 32
}

return GameConstants