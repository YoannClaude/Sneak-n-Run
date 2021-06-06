local aStar = {}



local Grid = require "modules.jumper.grid"
local Pathfinder = require "modules.jumper.pathfinder"

local walkable = 0
local grid
local myFinder
local map = {}


function aStar.get_path(from, to)

    return myFinder:getPath(from.x, from.y, to.x, to.y)

end


function aStar.load()


    for line=1,MINE.height do
        map[line] = {}
        for column=1,MINE.width do
            local id = MINE.layers[layer.GROUND].data[(line-1)*MINE.width + column]
            if id == 0 then
                map[line][column] = 1
            else
                map[line][column] = 0
            end
        end
    end
    grid = Grid(map)
    myFinder = Pathfinder(grid, 'ASTAR', walkable)
    
end



return aStar