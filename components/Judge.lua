---@diagnostic disable: lowercase-global
love = require("love")

function Judge()
    return {
        -- 判断是否到达边界，并穿过边界到达另一边
        judgeEdge = function (x, y, radius)
            if x + radius < 0 then
                x = love.graphics.getWidth() + radius
            elseif x - radius > love.graphics.getWidth() then
                x = 0 - radius
            end
            if y + radius < 0 then
                y = love.graphics.getHeight() + radius
            elseif y - radius > love.graphics.getHeight() then
                y = 0 - radius
            end
            return x, y
        end
    }
end

return Judge