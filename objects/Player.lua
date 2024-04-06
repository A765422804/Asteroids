---@diagnostic disable: lowercase-global
love  = require("love")
Laser = require("objects.Laser")
Judge = require("components.Judge")
require("globals")

function Player(num_lives)
    local SHIP_SIZE = 30 -- 常量大写
    local VIEW_ANGLE = math.rad(90)
    local LASER_DISTANCE = 0.6 -- 子弹的最远距离
    local MAX_LASER = 10 -- 最大子弹数量
    local EXPLOAD_DUR = 3
    local USABLE_BLINKS = 5 * 2 --闪烁次数

    return {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() / 2,
        radius = SHIP_SIZE / 2,
        angle = VIEW_ANGLE,
        rotation = 0,
        thrusting = false,
        thrust = { -- 推力
            x = 0,
            y = 0,
            speed = 5,
            big_flame = false,
            flame = 2.0
        },
        lasers = {},
        expload_time = 0,
        exploading = false,
        lives = num_lives or 3,
        invincible = true, -- 是否无敌
        invincible_seen = true, --是否闪烁
        time_blinked = USABLE_BLINKS, --闪烁次数

        shootLaser = function (self)
            if #self.lasers < MAX_LASER then
                table.insert(self.lasers, Laser(self.x, self.y,self.angle))                
            end
        end,

        destoryLaser = function (self,index)
            table.remove(self.lasers,index)
        end,

        -- 绘制火焰
        drawFlameThrust = function (self, fillType, color)
            if self.invincible_seen then
                table.insert(color, 0.5)
            end

            love.graphics.setColor(color)

            love.graphics.polygon(
                fillType,
                self.x - self.radius* ( 2 / 3 * math.cos(self.angle) + 0.5 * math.sin(self.angle)),
                self.y + self.radius* ( 2 / 3 * math.sin(self.angle) - 0.5 * math.cos(self.angle)),
                self.x - self.radius* self.thrust.flame * math.cos(self.angle),
                self.y + self.radius* self.thrust.flame * math.sin(self.angle),
                self.x - self.radius* ( 2 / 3 * math.cos(self.angle) - 0.5 * math.sin(self.angle)),
                self.y + self.radius* ( 2 / 3 * math.sin(self.angle) + 0.5 * math.cos(self.angle))
            )
        end,

        draw = function (self,faded)
            local opacity = 1 -- 可见性

            -- 如果淡出，降低透明度
            if faded then
                opacity = 0.2
            end

            if not self.exploading then
                -- 动态改变火焰的大小
                if self.thrusting then
                    if not self.thrust.big_flame then --小火焰
                        self.thrust.flame = self.thrust.flame - 1 / love.timer.getFPS()

                        if self.thrust.flame < 1.5 then
                            self.thrust.big_flame = true
                        end
                    else
                        self.thrust.flame = self.thrust.flame + 1 / love.timer.getFPS()

                        if self.thrust.flame > 2.5 then
                            self.thrust.big_flame = false
                        end                    
                    end

                    self:drawFlameThrust("fill", {255 / 255, 102 / 255, 25 / 255 })
                    self:drawFlameThrust("line", {1, 0.16, 0 })
                end          

                if self.invincible_seen then
                    love.graphics.setColor(1,1,1,faded and opacity or 0.5)
                else
                    love.graphics.setColor(1,1,1,opacity)
                end                

                love.graphics.polygon(
                    "line",
                    self.x + (4 / 3 * self.radius) * math.cos(self.angle),
                    self.y - (4 / 3 * self.radius) * math.sin(self.angle),
                    self.x - self.radius * (2 / 3 * math.cos(self.angle) + math.sin(self.angle)),
                    self.y + self.radius * (2 / 3 * math.sin(self.angle) - math.cos(self.angle)),
                    self.x - self.radius * (2 / 3 * math.cos(self.angle) - math.sin(self.angle)),
                    self.y + self.radius * (2 / 3 * math.sin(self.angle) + math.cos(self.angle))
                )
            else
                -- 绘制爆炸样式
                love.graphics.setColor(1,0,0,opacity)
                love.graphics.circle("fill", self.x,self.y , self.radius * 1.5)     
                love.graphics.setColor(1,158/255,0,opacity)
                love.graphics.circle("fill", self.x,self.y , self.radius * 1)        
                love.graphics.setColor(1,234/255,0,opacity)
                love.graphics.circle("fill", self.x,self.y , self.radius * 0.5)                    
            end

            if SHOW_DEBUGGING then
                love.graphics.setColor(1, 0, 0)
                love.graphics.rectangle("fill", self.x - 1, self.y - 1, 2, 2) -- 在中间绘制图像
                love.graphics.circle("line", self.x,self.y,self.radius)
            end

            for i =1 ,#self.lasers do
                self.lasers[i]:draw(faded)
            end
        end,

        movePlayer = function (self, dt)
            if self.invincible then
                self.time_blinked = self.time_blinked - dt * 2

                if math.ceil(self.time_blinked) % 2 == 0 then
                    self.invincible_seen = false
                else
                    self.invincible_seen = true
                end

                if self.time_blinked <= 0 then
                    self.invincible = false
                end
            else
                self.time_blinked = USABLE_BLINKS
                self.invincible_seen = false
            end
            self.exploading = (self.expload_time > 0)

            if not self.exploading then
                local FPS = love.timer.getFPS()
                local friction = 1.5 -- 摩擦力
    
                self.rotation = 2 * math.pi / FPS -- 每秒转2pi，求出每帧转多少
                if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
                    self.angle = self.angle + self.rotation
                end
    
                if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
                    self.angle = self.angle - self.rotation
                end
    
                if self.thrusting then
                    self.thrust.x = self.thrust.x + self.thrust.speed * math.cos(self.angle) / FPS -- 做一定削弱
                    self.thrust.y = self.thrust.y - self.thrust.speed * math.sin(self.angle) / FPS 
                else
                    -- 进行减速
                    if self.thrust.x ~= 0 or self.thrust.y ~= 0 then
                        self.thrust.x = self.thrust.x - friction * self.thrust.x / FPS
                        self.thrust.y = self.thrust.y - friction * self.thrust.y / FPS
                    end
                end
    
                self.x = self.x + self.thrust.x
                self.y = self.y + self.thrust.y
    
                -- 边界走出从另一边循环进来
                -- 判断x和y是否分别完全走出去了
                self.x,self.y = judge.judgeEdge(self.x,self.y, self.radius)                
            end

            -- 绘制子弹的运动
            for index, laser in pairs(self.lasers) do
                
                if laser.distance > LASER_DISTANCE * love.graphics.getWidth() and laser.exploading == EXPLOADING.not_exploading then
                    laser:expload()
                end
                
                if laser.exploading == EXPLOADING.not_exploading then
                    laser:move()
                elseif laser.exploading == EXPLOADING.done_exploading then
                    self:destoryLaser(index)
                end
            end
        end,

        drawLives = function (self,faded)
            local opacity = 1

            if faded then
                opacity = 0.2
            end

            if self.lives == 3 then
            love.graphics.setColor(1,1,1,opacity)
            elseif self.lives == 2 then
                love.graphics.setColor(1,1,0.5,opacity)                
            else
                love.graphics.setColor(1,0.2,0.2,opacity)
            end

            local x_pos, y_pos, x_offset = 45, 30,love.graphics.getWidth() - 175

            for i = 1, self.lives do
                if self.exploading then
                    if i == self.lives then
                        love.graphics.setColor(1,0,0,opacity)
                    end
                end

                love.graphics.polygon(
                    "line",
                    x_offset + (i * x_pos) + (4 / 3 * self.radius) * math.cos(VIEW_ANGLE),
                    y_pos - (4 / 3 * self.radius) * math.sin(VIEW_ANGLE),
                    x_offset + (i * x_pos) - self.radius * (2 / 3 * math.cos(VIEW_ANGLE) + math.sin(VIEW_ANGLE)),
                    y_pos + self.radius * (2 / 3 * math.sin(VIEW_ANGLE) - math.cos(VIEW_ANGLE)),
                    x_offset + (i * x_pos) - self.radius * (2 / 3 * math.cos(VIEW_ANGLE) - math.sin(VIEW_ANGLE)),
                    y_pos + self.radius * (2 / 3 * math.sin(VIEW_ANGLE) + math.cos(VIEW_ANGLE))
                )
            end

        end,

        expload = function (self)
            self.expload_time = math.ceil(EXPLOAD_DUR * love.timer.getFPS())
        end
    }
end

return Player