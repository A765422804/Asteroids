---@diagnostic disable: lowercase-global
love = require("love")
Text = require("components.Text")
Asteroid = require("objects.Asteroid")
require("globals")

-- 创建游戏状态
function Game(save_data)
    return {
        level = 1,
        state = {
            menu = true,
            paused = false,
            running = false,
            ended = false
        },
        score = 0,
        high_score = save_data.high_score or 0,
        screen_text = {},
        game_over_showing = false,

        saveGame = function (self)
            writeJSON("save",{
                high_score = self.high_score
            })
        end,

        -- 修改函数状态
        changeGameState = function (self, state)
            self.state.menu = (state == "menu")
            self.state.paused = (state == "paused")
            self.state.running = (state == "running")
            self.state.ended = (state == "ended")

            if self.state.ended then
                self:gameover()
            end
        end,

        gameover = function (self)
            self.screen_text = {
                Text(
                    "GAME OVER",
                    0,
                    love.graphics.getHeight() * 0.4,
                    "h1",
                    true,
                    true,
                    love.graphics.getWidth(),
                    "center"
                )
            }
            self.game_over_showing = true

            self:saveGame()
        end,

        draw = function (self, faded)
            local opacity = 1

            if faded then
                opacity = 0.5
            end

            for index, text in pairs(self.screen_text) do
                if self.game_over_showing then
                    self.game_over_showing = text:draw(self.screen_text,index)

                    if not self.game_over_showing then
                        self:changeGameState("menu")
                    end
                else
                    text:draw(self.screen_text,index)
                end
            end

            Text(
                "YOUR SCORE: " .. self.score,
                0,
                50,
                "h3",
                false,
                false,
                love.graphics.getWidth(),
                "center",
                faded and opacity or 0.6 
            ):draw()

            Text(
                "HIGHEST SCORE: " .. self.high_score,
                0,
                10,
                "h5",
                false,
                false,
                love.graphics.getWidth(),
                "center",
                faded and opacity or 0.5
            ):draw()

            if faded then
                Text(
                    "PAUSED",
                    0,
                    love.graphics.getHeight() * 0.4,
                    "h1",
                    false,
                    false,
                    love.graphics.getWidth(),
                    "center"
                ):draw()
            end
        end,

        startNewGame = function (self, player)
            if player.lives <= 0 then
                self:changeGameState("ended")
            else
                self:changeGameState("running")
            end

            local num_asteroids = 0
            -- 载入行星列表
            asteroids = {}

            self.screen_text = {
                Text(
                    "level " .. self.level,
                    0,
                    love.graphics.getHeight() * 0.25,
                    "h1",
                    true,
                    true,
                    love.graphics.getWidth(),
                    "center"
                )
            }

            for i = 1, num_asteroids + self.level do
                local as_x,as_y

                repeat
                    as_x = math.floor(math.random(love.graphics.getWidth()))           
                    as_y = math.floor(math.random(love.graphics.getHeight()))
                until calculateDistance(player.x,player.y ,as_x,as_y) > 
                ASTEROID_SIZE * 2 + player.radius -- 保证远离玩家生成

                table.insert(asteroids, 1 ,Asteroid(as_x,as_y,100,self.level))
            end

        end
    }
end

return Game