local gameController = {}

function gameController.playerOneMovement(bar)

    if love.keyboard.isDown('w') then 
        bar.dy = - bar.vel

    elseif love.keyboard.isDown('s') then 
        bar.dy = bar.vel
    else
        bar.dy = 0
    end

end

function gameController.playerTwoMovement(bar)

    if love.keyboard.isDown('up') then 
        bar.dy = - bar.vel

    elseif love.keyboard.isDown('down') then 
        bar.dy = bar.vel
    else
        bar.dy = 0
    end

end

return gameController