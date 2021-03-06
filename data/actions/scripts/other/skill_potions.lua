local berserk = Condition(CONDITION_ATTRIBUTES)
berserk:setParameter(CONDITION_PARAM_SUBID, 7)
berserk:setParameter(CONDITION_PARAM_TICKS, 10 * 60 * 1000)
berserk:setParameter(CONDITION_PARAM_SKILL_MELEE, 35)
berserk:setParameter(CONDITION_PARAM_SKILL_SHIELD, -40)
berserk:setParameter(CONDITION_PARAM_BUFF_SPELL, true)

local mastermind = Condition(CONDITION_ATTRIBUTES)
mastermind:setParameter(CONDITION_PARAM_SUBID, 8)
mastermind:setParameter(CONDITION_PARAM_TICKS, 10 * 60 * 1000)
mastermind:setParameter(CONDITION_PARAM_STAT_MAGICPOINTS, 35)
mastermind:setParameter(CONDITION_PARAM_BUFF_SPELL, true)

local bullseye = Condition(CONDITION_ATTRIBUTES)
bullseye:setParameter(CONDITION_PARAM_SUBID, 9)
bullseye:setParameter(CONDITION_PARAM_TICKS, 10 * 60 * 1000)
bullseye:setParameter(CONDITION_PARAM_SKILL_DISTANCE, 35)
bullseye:setParameter(CONDITION_PARAM_SKILL_SHIELD, -40)
bullseye:setParameter(CONDITION_PARAM_BUFF_SPELL, true)

local antidote = Combat()
antidote:setParameter(COMBAT_PARAM_TYPE, COMBAT_HEALING)
antidote:setParameter(COMBAT_PARAM_EFFECT, CONST_ME_MAGIC_BLUE)
antidote:setParameter(COMBAT_PARAM_DISPEL, CONDITION_POISON)
antidote:setParameter(COMBAT_PARAM_AGGRESSIVE, false)
antidote:setParameter(COMBAT_PARAM_TARGETCASTERORTOPMOST, true)

local potions = {
    [6558] = {transform = {id = {7588, 7589}}, effect = CONST_ME_DRAWBLOOD},
    [7439] = {condition = berserk, vocations = {4, 8}, effect = CONST_ME_MAGIC_RED,
            description = "Only knights may drink this potion.", text = "You feel stronger."},

    [7440] = {condition = mastermind, vocations = {1, 2, 5, 6}, effect = CONST_ME_MAGIC_BLUE,
            description = "Only sorcerers and druids may drink this potion.", text = "You feel smarter."},

    [7443] = {condition = bullseye, vocations = {3, 7}, effect = CONST_ME_MAGIC_GREEN,
            description = "Only paladins may drink this potion.", text = "You feel more accurate."},

}

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if type(target) == "userdata" and not target:isPlayer() then
        return false
    end

    local potion = potions[item:getId()]
    if potion.level and player:getLevel() < potion.level or potion.vocations and not table.contains(potion.vocations, player:getVocation():getId()) then
        player:say(potion.description, TALKTYPE_MONSTER_SAY)
        return true
    end

    if potion.health or potion.mana or potion.combat then
        if potion.health then
            doTargetCombatHealth(0, target, COMBAT_HEALING, potion.health[1], potion.health[2], CONST_ME_MAGIC_BLUE)
        end

        if potion.mana then
            doTargetCombatMana(0, target, potion.mana[1], potion.mana[2], CONST_ME_MAGIC_BLUE)
        end

        if potion.combat then
            potion.combat:execute(target, Variant(target:getId()))
        end

        target:say("Aaaah...", TALKTYPE_MONSTER_SAY)
        player:addItem(potion.flask, 1)
    end

    if potion.condition then
        player:addCondition(potion.condition)
        player:say(potion.text, TALKTYPE_MONSTER_SAY)
        player:getPosition():sendMagicEffect(potion.effect)
    end

    if potion.transform then
        item:transform(potion.transform.id[math.random(#potion.transform.id)])
        item:getPosition():sendMagicEffect(potion.effect)
        return true
    end

    item:remove(1)
    return true
end
