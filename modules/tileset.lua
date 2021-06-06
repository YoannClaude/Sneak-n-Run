local tileset = {}

local tilesBatch
local tilesOnTopBatch


function tileset.load()

    local tilesheet = love.graphics.newImage("assets/tileset/tilesheet.png")
    local texture = {}

    for i=1, #MINE.layers do
        tileset[i] = MINE.layers[i].data
    end


    tilesBatch = love.graphics.newSpriteBatch(tilesheet, 13200, "static")
    tilesOnTopBatch = love.graphics.newSpriteBatch(tilesheet, 13200, "static")

    local nbColumns = tilesheet:getWidth() / MINE.tilewidth
    local nbLines = tilesheet:getHeight() / MINE.tilewidth
    local id = 1
    for l=1,nbLines do
        for c=1,nbColumns do
            texture[id] = love.graphics.newQuad((c-1) * MINE.tilewidth, (l-1) *                   MINE.tilewidth, MINE.tilewidth, MINE.tilewidth, tilesheet:getDimensions())
            id = id + 1
        end
    end

    local id, texQuad

    for layer = 1, #tileset - 2 do
        for line=1,MINE.height do
            for column=1,MINE.width do
                id = tileset[layer][(line-1)*MINE.width + column]
                texQuad = texture[id]
                if texQuad ~= nil then
                    tilesBatch:add(texQuad, (column-1) * MINE.tilewidth,
                        (line-1) * MINE.tilewidth)
                end
            end
        end
    end

    for i = 0, 1 do
        for line=1,MINE.height do
            for column=1,MINE.width do
                id = tileset[#tileset - i][(line-1)*MINE.width + column]
                texQuad = texture[id]
                if texQuad ~= nil then
                    tilesOnTopBatch:add(texQuad, (column-1) * MINE.tilewidth,
                        (line-1) * MINE.tilewidth)
                end
            end
        end
    end

end 


function tileset.draw()

    love.graphics.draw(tilesBatch)

end


function tileset.draw_on_top()

    love.graphics.draw(tilesOnTopBatch)

end


return tileset