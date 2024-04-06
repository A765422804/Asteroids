---@diagnostic disable: lowercase-global
love = require("love")
Player = require("objects.Player")
Game = require("states.Game")
require("globals")
Menu = require("states.Menu")
SFX = require("components.SFX")

local resetComplete = false
reset = function ()
    sfx = SFX()
    local save_data = readJSON("save") -- 获取保存的数据，是一个table
    player = Player(3)
    game = Game(save_data)
    menu = Menu(game,player)
    judge = Judge()
end

function love.load()
    math.randomseed(os.time())
    love.mouse.setVisible(false) -- 设置鼠标不可见
    mouse_x, mouse_y = 0, 0

    reset()
    resetComplete = true

    sfx:playBGM()

    -- -- 载入player
    -- player = Player()

    -- -- 载入游戏状态
    -- game = Game(save_data)

    -- -- 进行一些条件判断
    -- judge = Judge()

    -- -- 载入行星列表
    -- asteroids = {}

    -- menu = Menu(game, player)
end

-- 控制键盘是否按下按键
function love.keypressed(key)
    if game.state.running then
        if key == "w" or key == "up" then
            player.thrusting = true
        end

        -- 控制暂停
        if key == "escape" then
            game:changeGameState("paused")
        end

        -- 射击
        if key == "space" then
            player:shootLaser()
        end
    elseif game.state.paused then
        if key == "escape" then
            game:changeGameState("running")
        end        
    end
end

-- 控制键盘是否松开按键
function love.keyreleased(key)
    if key == "w" or key == "up" then
        player.thrusting = false
    end 
end

-- 控制鼠标是否按下
function love.mousepressed(x, y, button, isTouch )
    if button == 1 then
        if game.state.running then
            player:shootLaser()
        else
            clickMouse = true
        end
    end
end

function love.update(dt)
    mouse_x, mouse_y = love.mouse.getPosition()
    
    if game.state.running then
        player:movePlayer(dt)      
        
        for ast_index, asteroid in pairs(asteroids) do
            if not player.exploading and not player.invincible then
                if calculateDistance(player.x,player.y, asteroid.x, asteroid.y) < asteroid.radius then
                    player:expload()
                    DESTROY_AST = true
                end       
            else
                player.expload_time = player.expload_time - 1         

                if player.expload_time == 0 then
                    if player.lives - 1 <= 0 then
                        game:changeGameState("ended")
                        return
                    end
                    player = Player(player.lives - 1)
                end
            end


            for _,  laser in pairs(player.lasers) do
                if calculateDistance(laser.x,laser.y, asteroid.x, asteroid.y) < asteroid.radius then
                    laser:expload()
                    DESTROY_AST = true
                end
            end

            if DESTROY_AST then
                if player.lives - 1 <= 0 then
                    if player.expload_time ~= 0 then
                        DESTROY_AST = false
                        asteroid:destroy(asteroids, ast_index,game)
                    end
                else
                    DESTROY_AST = false
                    asteroid:destroy(asteroids, ast_index,game)
                end
            end
            asteroid:move(dt)
        end

        --没有行星了，提高游戏level
        if #asteroids == 0 then
            game.level = game.level + 1
            game:startNewGame(player)
        end
    elseif game.state.menu then
        menu:run(clickMouse)
        clickMouse = false
        if not resetComplete then
            reset()
            resetComplete = true
        end
    elseif game.state.ended then
        resetComplete = false
    end
end

function love.draw()
    if game.state.running or game.state.paused then
        player:drawLives(game.state.paused)
        player:draw(game.state.paused)  

        for i = 1, #asteroids do
            asteroids[i]:draw(game.state.paused)
        end
        
        game:draw(game.state.paused)
    elseif game.state.menu then
        menu:draw()
    elseif game.state.ended then
        game:draw()
    end

    if not game.state.running then
        love.graphics.circle("fill",mouse_x, mouse_y, MOUSE_RADIUS)
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10 )
end