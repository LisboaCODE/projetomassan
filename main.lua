-- este main lua foi retirado e copiado de alguns mods, entao creditos ao criador(a) do mod da personagem hatsune miku e catinsurance pelo seu tutotial
-- tentarei escrever o que eu fiz em portugues, mas caso de duvida entre em contato comigo, tentarei responder se possivel
local mod = RegisterMod("ProjetoMassan", 1)
local ActiveItemSing = Isaac.GetItemIdByName("Sings of Massan")
local MassanType = Isaac.GetPlayerTypeByName ("Massan", false)
local hairCostume = Isaac.GetCostumeIdByPath("gfx/characters/hair_massan.anm2")
local Massan = Isaac.GetPlayerTypeByName ("Massan")
local sfx = SFXManager()
local SOUND_MASSAN = Isaac.GetSoundIdByName("Massan_Sings") -- Som do item do mod, caso queira adicionar um som especifico para o personagem
local DAMAGE_RADIUS = 136
local PROJECTILE_RADIUS = 150 -- Raio de remoção de projéteis
--irei adicionar um parametro para meu personagem comeca com item personalizado DO MEU MOD especificamente
---@param player EntityPlayer
function mod:MassanInit(player)
    if player:GetPlayerType() ~= MassanType then
        return
    end

    if player:GetName() == "Massan" then --estou pedindo pra quando o jogo ler o nome do jogador e se for igual o nome do seu personagem, ele adicionara o item
    player:SetPocketActiveItem(ActiveItemSing, ActiveSlot.SLOT_POCKET, true) --nesse caso um item ativavel de bolso
    player:AddNullCostume(hairCostume)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.MassanInit)
local Massan = { -- shown below are default values, as shown on Isaac, for you to change around
    SPEED = 1.10,
    FIREDELAY = 11, -- your tears stat is "30/(FIREDELAY+1)"
    DAMAGE = 3.74, -- is only the damage stat, not damage multiplier
    RANGE = 250, -- your range stat is "40*RANGE"
    SHOTSPEED = 0.90,
    LUCK = 1.00,
    TEARHEIGHT = 0.00, -- these are non default values, instead being additive to the default value because I do not know what the default is
    TEARFALLINGSPEED = 0.00, -- these are non default values, instead being additive to the default value because I do not know what the default is
    TEARFLAG = 0, -- Determines some behaviors of your tears, https://wofsauge.github.io/IsaacDocs/rep/enums/TearFlags.html
    TEARCOLOR = Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0), -- r1.0 g1.0 b1.0 a1.0 0r 0g 0b (the last three are offsets)
    FLYING = false
}

function Massan:onCache(player, cacheFlag)
    if player:GetName() == "Massan" then
        if cacheFlag == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed - 1 + Massan.SPEED
        end
        if cacheFlag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay - 10 + Massan.FIREDELAY
        end
        if cacheFlag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage - 3.5 + Massan.DAMAGE
        end
        if cacheFlag == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange - 260 + Massan.RANGE
            player.TearHeight = player.TearHeight + Massan.TEARHEIGHT
            player.TearFallingSpeed = player.TearFallingSpeed + Massan.TEARFALLINGSPEED
        end
        if cacheFlag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed - 1 + Massan.SHOTSPEED
        end
        if cacheFlag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + Massan.LUCK
        end
        if cacheFlag == CacheFlag.CACHE_TEARFLAG then
            player.TearFlags = player.TearFlags | Massan.TEARFLAG -- The OR here makes sure that if you have an item that changes tear flags, the values you set takes priority
        end
        if cacheFlag == CacheFlag.CACHE_TEARCOLOR then
            player.TearColor = Massan.TEARCOLOR
        end
        if cacheFlag == CacheFlag.CACHE_FLYING and Massan.FLYING then
            player.CanFly = true
        end
    end
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Massan.onCache)


function mod:UseSing(item, rng, player, flags, slot, varData)
    local playerDamage = player.Damage * 1.75
    sfx:Play(SOUND_MASSAN)
    Isaac.Spawn(1000, 164, 0, player.Position, Vector.Zero, player)
    local confusionDuration = 150  -- 2.5 segundos (150 frames)
    local roomEntities = Isaac.GetRoomEntities()

    for _, entity in ipairs(roomEntities) do
        if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
            local distance = player.Position:Distance(entity.Position)
            if distance <= DAMAGE_RADIUS then
                entity:TakeDamage(playerDamage, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(player), 0)
                entity:AddConfusion(EntityRef(player), confusionDuration, false)
            end
        end
    end

    for _, entity in ipairs(roomEntities) do
        if entity.Type == EntityType.ENTITY_PROJECTILE then
            local distanceToProjectile = player.Position:Distance(entity.Position)
            if distanceToProjectile <= PROJECTILE_RADIUS then
                entity:Remove()
            end
        end
    end

    return { 
        Discharge = true,
        Remove = false,
        ShowAnim = true
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseSing, ActiveItemSing)