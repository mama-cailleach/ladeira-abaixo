import "utilities/GameConstants"
import "systems/MovementManager"

SpawnManager = {}

-- Move spawnTypes table here
SpawnManager.spawnTypes = {
    pipoqueiro = {
        class = Pipoqueiro,
        yRange = {100, 200},
        typeName = "pipoqueiro",
        canMirror = true
    },
    uninho = {
        class = Uninho,
        yRange = {30, 30},
        typeName = "uninho",
        canMirror = true,
        mirroredY = 210
    },
    motoboy = {
        class = Motoboy,
        yRange = {185, 185},
        typeName = "motoboy",
        canMirror = true,
        mirroredY = 55
    },
    oil = {
        class = Oil,
        yRange = {100, 200},
        typeName = "oil",
        canMirror = true
    },
    bueiro = {
        class = Bueiro,
        yRange = {100, 200},
        typeName = "bueiro",
        canMirror = false
    },
    pastel = {
        class = Pastel,
        yRange = {100, 200},
        typeName = "pastel",
        canMirror = true
    },
    bola = {
        class = Bola,
        yRange = {100, 200},
        typeName = "bola",
        canMirror = false
    },
    poste = {
        class = Poste,
        yRange = {185, 185},
        typeName = "poste",
        canMirror = true,
        mirroredY = 55
    },
    placa = {
        class = Placa,
        yRange = {175, 175},
        typeName = "placa",
        canMirror = false
    },
    bandeirinhas = {
        class = Bandeirinhas,
        yRange = {120, 120},
        typeName = "bandeirinhas",
        canMirror = true
    },
    bandeirinhas02 = {
        class = Bandeirinhas02,
        yRange = {120, 120},
        typeName = "bandeirinhas02",
        canMirror = true
    },
    brflag = {
        class = BRFlag,
        yRange = {120, 120},
        typeName = "brflag",
        canMirror = false
    },
    caflag = {
        class = CAFlag,
        yRange = {120, 120},
        typeName = "caflag",
        canMirror = false
    },
    fios = {
        class = Fios,
        yRange = {120, 120},
        typeName = "fios",
        canMirror = true
    },
    fitinhas = {
        class = Fitinhas,
        yRange = {120, 120},
        typeName = "fitinhas",
        canMirror = true
    },
    hexa = {
        class = Hexa,
        yRange = {120, 120},
        typeName = "hexa",
        canMirror = false
    },
    placa02 = {
        class = Placa02,
        yRange = {175, 175},
        typeName = "placa02",
        canMirror = false
    },
    postequebrado = {
        class = PosteQuebrado,
        yRange = {185, 185},
        typeName = "postequebrado",
        canMirror = true,
        mirroredY = 55
    },
    powercable = {
        class = Powercable,
        yRange = {120, 120},
        typeName = "powercable",
        canMirror = true
    },
    scflag = {
        class = SCFlag,
        yRange = {120, 120},
        typeName = "scflag",
        canMirror = false
    },
    worldcup = {
        class = Worldcup,
        yRange = {120, 120},
        typeName = "worldcup",
        canMirror = true
    }
}

-- (street) decoration types for avoiding overlays
SpawnManager.decorationTypes = {
    "brflag", "caflag", "hexa", "scflag", 
    "worldcup"
}


-- Initialize SpawnManager
function SpawnManager.init(gameScene)
    SpawnManager.gameScene = gameScene
    SpawnManager.spawnTimer = nil
    SpawnManager.spawnTime = math.random(GameConstants.SPAWN.SPAWN_TIME_MIN, GameConstants.SPAWN.SPAWN_TIME_MAX)

    
    -- Object max counts
    SpawnManager.maxCounts = {
        pipoqueiro = 3,
        uninho = 1,
        motoboy = 2,
        oil = 3,
        bueiro = 2,
        pastel = 1,
        bola = 1,
        bandeirinhas = 2,
        poste = 2,
        placa = 2,
        bandeirinhas02 = 2,
        brflag = 1,
        caflag = 1,
        fios = 2,
        fitinhas = 2,
        hexa = 1,
        placa02 = 2,
        postequebrado = 2,
        powercable = 2,
        scflag = 1,
        worldcup = 1
    }

    -- Object current counts
    SpawnManager.currentCounts = {
        pipoqueiro = 0,
        uninho = 0,
        motoboy = 0,
        oil = 0,
        bueiro = 0,
        pastel = 0,
        bola = 0,
        bandeirinhas = 0,
        poste = 0,
        placa = 0,
        bandeirinhas02 = 0,
        brflag = 0,
        caflag = 0,
        fios = 0,
        fitinhas = 0,
        hexa = 0,
        placa02 = 0,
        postequebrado = 0,
        powercable = 0,
        scflag = 0,
        worldcup = 0
    }
end

-- Linear interpolation helper
local function lerp(a, b, t)
    return a + (b - a) * t
end

-- Difficulty t in [0,1] based on player score and configured SCORE_TO_MAX_DIFFICULTY
function SpawnManager.getDifficultyT()
    local score = 0
    if SpawnManager.gameScene and SpawnManager.gameScene.playerScore then
        score = SpawnManager.gameScene.playerScore
    end
    local maxScore = GameConstants.SPAWN.SCORE_TO_MAX_DIFFICULTY
    local t = score / math.max(1, maxScore)
    if t < 0 then t = 0 end
    if t > 1 then t = 1 end
    return t
end


-- Build active pool of spawn types according to unlock score and current counts
function SpawnManager.buildActivePool()
    local pool = {}
    local score = 0
    if SpawnManager.gameScene and SpawnManager.gameScene.playerScore then
        score = SpawnManager.gameScene.playerScore
    end

    -- Read tiers from GameConstants
    local tiers = GameConstants.SPAWN.WEIGHT_TIERS or {}
    local currentWeights = {}
    if #tiers > 0 then
        currentWeights = tiers[1].weights or {}
    end
    for i = #tiers, 1, -1 do
        local tier = tiers[i]
        if score >= (tier.scoreThreshold or 0) then
            currentWeights = tier.weights or currentWeights
            break
        end
    end

    for typeKey, meta in pairs(SpawnManager.spawnTypes) do
        local unlock = 0
        if GameConstants.SPAWN.UNLOCK_SCORE and GameConstants.SPAWN.UNLOCK_SCORE[typeKey] then
            unlock = GameConstants.SPAWN.UNLOCK_SCORE[typeKey]
        end
        local maxCount = SpawnManager.maxCounts[typeKey] or 999
        local current = SpawnManager.currentCounts[typeKey] or 0
        if score >= unlock and current < maxCount then
            local weight = (currentWeights and currentWeights[typeKey]) or 1
            table.insert(pool, {typeKey = typeKey, weight = weight})
        end
    end
    return pool
end

-- Pick a typeKey from pool using weighted random selection
function SpawnManager.pickTypeByWeight(pool)
    if not pool or #pool == 0 then return nil end
    local total = 0
    for _, item in ipairs(pool) do total = total + (item.weight or 1) end
    if total <= 0 then return pool[1].typeKey end
    local r = math.random() * total
    local acc = 0
    for _, item in ipairs(pool) do
        acc = acc + (item.weight or 1)
        if r <= acc then return item.typeKey end
    end
    return pool[#pool].typeKey
end

-- Check if position is free from other objects
function SpawnManager.isPositionFree(x, y, width, height, checkDecorationOnly)
    for _, obj in ipairs(SpawnManager.gameScene.objects) do
        if obj.x and obj.y then
             -- If checking decoration-only, skip non-decoration objects
            if checkDecorationOnly then
                local isDecoration = false
                for _, decType in ipairs(SpawnManager.decorationTypes) do
                    if obj.type == decType then
                        isDecoration = true
                        break
                    end
                end
                if not isDecoration then goto continue end
            end

            if x < obj.x + width and 
               x + width > obj.x and 
               y < obj.y + height and 
               y + height > obj.y then
                return false -- Position is not free
            end
            ::continue::
        end
    end
    return true -- Position is free
end

-- Spawn object of specified type
function SpawnManager.spawnObject(typeKey)
    local t = SpawnManager.spawnTypes[typeKey]
    if not t then return end
    
    if SpawnManager.currentCounts[typeKey] < SpawnManager.maxCounts[typeKey] then
        local obj = t.class()
        local spawnRandomY, spawnRandomX
        local mirrored = false

        local isDecoration = false
        for _, decType in ipairs(SpawnManager.decorationTypes) do
            if typeKey == decType then
                isDecoration = true
                break
            end
        end
        
        -- Try to find a valid spawn position up to 10 times
        local attempts = 0
        local maxAttempts = 10
        local validPosition = false
        
        while attempts < maxAttempts and not validPosition do
            spawnRandomY = math.random(table.unpack(t.yRange))
            
            spawnRandomX = math.random(GameConstants.SPAWN.SPAWN_X_MIN, GameConstants.SPAWN.SPAWN_X_MAX)

            -- Handle mirroring logic
            mirrored = false
            if t.canMirror and obj.setMirrored then
                mirrored = math.random() < 0.5
                if mirrored and t.mirroredY then
                    spawnRandomY = t.mirroredY
                end
            end
            
            -- Different collision logic for decorations
            if isDecoration then
                -- Decorations only check against other decorations
                if SpawnManager.isPositionFree(spawnRandomX, spawnRandomY, math.random(400, 400), math.random(50, 150), true) then
                    validPosition = true
                end
            else
                -- Regular objects use standard collision
                if SpawnManager.isPositionFree(spawnRandomX, spawnRandomY, math.random(100, 350), math.random(50, 150), false) then
                    validPosition = true
                end
            end
            
            attempts = attempts + 1
        end
        
        -- Only spawn if we found a valid position
        if validPosition then
            -- Apply mirroring if needed
            if mirrored and obj.setMirrored then
                obj:setMirrored(mirrored)
            end
            
            obj:add(spawnRandomX, spawnRandomY)
            obj.type = t.typeName
            table.insert(SpawnManager.gameScene.objects, obj)
            SpawnManager.currentCounts[typeKey] = SpawnManager.currentCounts[typeKey] + 1

            -- Apply current speed to new object
            MovementManager.applySpeedToObject(obj)
        end
    end
end

-- Create spawning timer
function SpawnManager.createTimer()
    -- compute dynamic spawnTime based on difficulty
    local t = SpawnManager.getDifficultyT()
    SpawnManager.spawnTime = math.floor(lerp(GameConstants.SPAWN.SPAWN_TIME_MAX, GameConstants.SPAWN.SPAWN_TIME_MIN, t))

    SpawnManager.spawnTimer = playdate.timer.performAfterDelay(SpawnManager.spawnTime, function ()
        -- schedule next tick
        SpawnManager.createTimer()

        -- decide spawnCount (scale modestly with difficulty)
        local base = GameConstants.SPAWN.BASE_SPAWN_TICK  -- base spawn per tick before scaling
        local maxPerTick = GameConstants.SPAWN.MAX_SPAWN_PER_TICK
        local extra = math.floor(t * math.max(0, maxPerTick - base))
        local spawnCount = math.min(maxPerTick, base + extra)
        -- local spawnCount = 1 IF DECIDE ON 1 PER TICK can delete above and leave only this

        -- build active pool and spawn accordingly
        local pool = SpawnManager.buildActivePool()
        if not pool or #pool == 0 then return end


        for i = 1, spawnCount do
            local chosen = SpawnManager.pickTypeByWeight(pool)
            if chosen then
                SpawnManager.spawnObject(chosen)
                -- optionally rebuild pool so counts affect subsequent picks
                pool = SpawnManager.buildActivePool()
                if not pool or #pool == 0 then break end
            end
        end
    end)
end


-- Start the spawner
function SpawnManager.startSpawner()
    math.randomseed(playdate.getSecondsSinceEpoch())
    SpawnManager.createTimer()
    SpawnManager.zeroCurrentCounts()
end

-- Stop the spawner
function SpawnManager.stopSpawner()
    if SpawnManager.spawnTimer then
        SpawnManager.spawnTimer:remove()
        SpawnManager.spawnTimer = nil
        SpawnManager.zeroCurrentCounts()
    end
end

-- Reset all spawn counters
function SpawnManager.zeroCurrentCounts()
    for key, _ in pairs(SpawnManager.currentCounts) do
        SpawnManager.currentCounts[key] = 0
    end
end

-- Update spawning and manage object removal
function SpawnManager.updateSpawning()
    -- Remove off-screen objects and update counters
    for i = #SpawnManager.gameScene.objects, 1, -1 do
        local obj = SpawnManager.gameScene.objects[i]
        local removeForX = obj.x and obj.x < GameConstants.SPAWN.REMOVAL_X_THRESHOLD
        if removeForX then
            -- DON'T remove curbs - they handle their own looping
            if obj.type ~= "curbL" and obj.type ~= "curbR" then
                obj:remove()
                table.remove(SpawnManager.gameScene.objects, i)
            
                if obj.type and SpawnManager.currentCounts[obj.type] then
                    SpawnManager.currentCounts[obj.type] = SpawnManager.currentCounts[obj.type] - 1
                end
            end
        end
    end
end

return SpawnManager
