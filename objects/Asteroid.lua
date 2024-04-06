---@diagnostic disable: lowercase-global
love = require("love")
Judge = require("components.Judge")
require("globals")

function Asteroid(x, y, ast_size, level)
    local ASTEROID_VERT = 10 -- 顶点数量
    local ASTEROID_JAG = 0.4 -- 多边形的规范程度
    local MIN_ASTEROID_SIZE = math.ceil(ASTEROID_SIZE / 8)
    local ASTEROID_SPEED = math.random(50) + level*2 + 25

    local vert = math.floor(math.random(ASTEROID_VERT) + ASTEROID_VERT / 2)

    local offset = {}
    for i = 1, vert do
        table.insert(offset, math.random() * ASTEROID_JAG * 2 + 1 - ASTEROID_JAG)
    end

    local vel = -1 -- 决定方向
    if math.random() < 0.5 then
        vel = 1
    end
        
    return {
        x = x,
        y = y,
        x_vel = math.random() * ASTEROID_SPEED * vel,
        y_vel = math.random() * ASTEROID_SPEED * vel,
        radius = math.ceil(ast_size / 2),
        angle = math.rad(math.random(math.pi)),
        vert = vert,
        offset = offset,

        draw = function (self, faded) -- faded 控制是否虚化
            local opacity = 1

            if faded then 
                opacity = 0.2
            end

           love.graphics.setColor(186 / 255, 189 / 255, 182 / 255, opacity) 

           local points = {}
           for i = 1, self.vert do
                table.insert(points, self.x + self.radius * self.offset[i] * math.cos(self.angle + i * math.pi * 2 / self.vert))
                table.insert(points, self.y + self.radius * self.offset[i] * math.sin(self.angle + i * math.pi * 2 / self.vert))
           end

           love.graphics.polygon("line", points)

           if SHOW_DEBUGGING then
            love.graphics.setColor(1 ,0, 0)
            love.graphics.circle("line", self.x ,self.y,self.radius)
           end
        end,

        move = function (self, dt)
            self.x = self.x + self.x_vel * dt
            self.y = self.y + self.y_vel * dt

            self.x,self.y = judge.judgeEdge(self.x,self.y, self.radius)
        end,

        destroy = function (self, asteroid_tbl, index,game)
            -- 创造两个新的小行星
            if self.radius > MIN_ASTEROID_SIZE then
                table.insert(asteroid_tbl, Asteroid(self.x,self.y, self.radius, game.level))
                table.insert(asteroid_tbl, Asteroid(self.x,self.y, self.radius, game.level))
            end

            if self.radius >= ASTEROID_SIZE / 2 then --击败大型行星，加20
                game.score = game.score + 20
            elseif self.radius <= MIN_ASTEROID_SIZE then --击败小的加100
                game.score = game.score + 100
            else
                game.score = game.score + 50
            end

            -- 更新最高分
            if game.score > game.high_score then
                game.high_score = game.score
            end

            -- 摧毁当前小行星
            table.remove(asteroid_tbl, index)
        end
    }
end

return Asteroid