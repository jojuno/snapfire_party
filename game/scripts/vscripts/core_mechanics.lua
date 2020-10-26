-- This function runs to save the location and particle spawn upon hero killed
function GameMode:HeroKilled(hero, attacker, ability)
    if GameMode.pregameActive then
        if GameMode.pregameBuffer == false then
            Timers:CreateTimer({
                endTime = 1, -- respawn in 1 second
                callback = function()
                    GameMode:Restore(hero)
                end
            })
        end

    else
        Timers:CreateTimer({
            endTime = 1, -- respawn in 1 second
            callback = function()
                hero:RespawnHero(false, false)
            end
        })
    end
end