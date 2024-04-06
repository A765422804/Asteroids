love = require("love")

-- 音乐组件
function SFX()
    -- 背景音乐
    local bgm = love.audio.newSource("src/sounds/上木彩矢 (Aya Kamiki) - 世界はそれでも変わりはしない.ogg", "stream")
    bgm:setVolume(0.1)
    bgm:setLooping(true)

    -- 效果音乐集合
    local effects = {
        ship_explosion = love.audio.newSource("src/sounds/周杰伦 - 枫_EG.flac", "stream")
    }

    return {
        -- 是否在播放
        fx_played = false,
        
        -- 控制是否在播放
        setFXPlayed = function (self,has_play)
            self.fx_played = has_play
        end,

        -- 控制播放背景音乐
        playBGM = function (self)
            if not bgm:isPlaying() then
                bgm:play()
            end
        end,

        -- 停止播放当前音乐
        stopFX = function (self, effect)
            if effects[effect]:isPlaying() then
                effects[effect]:stop()
            end
        end,

        -- 播放音乐
        playFX = function (self, effect ,mode)
            -- 只播放单一效果
            if mode == "single" then
                if not self.fx_played then
                    self:setFXPlayed(true)

                    if not effects[effect]:isPlaying() then
                        effects[effect]:play()
                    end
                end
            elseif mode == "slow" then
                -- 普通播放
                if not effects[effect]:isPlaying() then
                    effects[effect]:play()
                end
            else
                -- 停止重新播放
                self:stopFX(effect)     
                effects[effect]:play()
            end
        end
    }
end

return SFX