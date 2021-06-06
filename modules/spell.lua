local spell = {}


local spellSize = 64
local sfx = "event:/SFX/Ennemies/Priest/Spell"
local monoChannel = love.thread.getChannel("monoSfx")
local updateChannel = love.thread.getChannel("posUpdate")

local list = {}


function spell.load()

    list = {}
    
end


function spell.new(vec)

    local newSpell = {}
    newSpell.sType = sType.SPELL
    newSpell.pos = Vector2(vec.x, vec.y - 40)
    newSpell.dir = Vector2()
    newSpell.collide = false
    newSpell.speed = 1000
    newSpell.colBox = Vector2()
    newSpell.colBoxWidth = Vector2(32, 0)
    newSpell.colBoxSize = 32
    newSpell.remove = false
    newSpell.hasPlayedSound = false

    table.insert(list, newSpell)
    local dist = math.floor(distance(newSpell.pos, PLAYER_POS))
    monoChannel:push({obj = sType.SPELL, event = sfx, param = dist})

end


local function update_colBox(pSpell)

    pSpell.colBox = pSpell.pos - pSpell.colBoxWidth/2

end


function spell.update(dt)

    if #list < 1 then
        return
    end

    local spell, currentPos
    for i=#list, 1, -1 do
        spell = list[i]
        currentPos = spell.pos
        if not spell.collide then
            spell.dir = PLAYER_POS - spell.pos
            spell.dir = normalize(spell.dir)
            spell.pos = spell.pos + spell.dir * spell.speed * dt
            spell.speed = spell.speed + 60 * dt
            update_colBox(spell)
        else
            spell.pos = currentPos
            spell.remove = true
            table.remove(list, i)
        end
        local dist = math.floor(distance(spell.pos, PLAYER_POS))
        updateChannel:push({obj = sType.SPELL, param = dist})
    end

end


function spell.get_list()

  return list

end


function spell.check_list()

  return #list

end



return spell
