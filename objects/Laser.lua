---@diagnostic disable: lowercase-global
love = require("love")

function Laser(x, y, angle)
    local LASER_SPEED = 500
    local LASER_SIZE = 5
    local EXPLOAD_DUR = 0.5 -- 爆炸持续时间

    return {
        x = x,
        y = y,
        x_vel = LASER_SPEED * math.cos(angle) / love.timer.getFPS(), -- 在x轴上的位移
        y_vel = -LASER_SPEED * math.sin(angle) / love.timer.getFPS(), -- 在y轴上的位移
        -- 设置运行的距离，然后定义移动一定距离以后消除laser 
        distance = 0,
        exploading = EXPLOADING.not_exploading,
        exploading_time = 0, -- 爆炸多久

        draw = function (self, faded)
            local opacity = 1

            if faded then
                opacity = 0.2
            end
            if self.exploading == EXPLOADING.not_exploading then
                love.graphics.setColor(0,1,0, opacity)
                love.graphics.setPointSize(LASER_SIZE)
                love.graphics.points(self.x, self.y)
            else
                love.graphics.setColor(1,104/255,0,opacity)
                love.graphics.circle("fill", self.x,self.y , 7 * 1.5)     
                love.graphics.setColor(1,234/255,0,opacity)
                love.graphics.circle("fill", self.x,self.y , 7 * 1)
            end
        end,

        move = function (self)
            self.x = self.x + self.x_vel
            self.y = self.y + self.y_vel

            if self.exploading_time > 0 then -- 说明在爆炸
                self.exploading = EXPLOADING.exploading
            end

            self.x,self.y = judge.judgeEdge(self.x,self.y, 0)

            self.distance = self.distance + math.sqrt((self.x_vel ^ 2) + (self.y_vel ^ 2))
        end,

        expload = function (self)
            self.exploading_time = math.ceil(EXPLOAD_DUR * (love.timer.getFPS() / 100))

            if self.exploading_time > EXPLOAD_DUR then
                self.exploading = EXPLOADING.done_exploading
            end
        end
    }
end

return Laser