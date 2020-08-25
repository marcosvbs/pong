Class = require 'class'
push = require 'push'
gameController = require 'gameController'

require 'Ball'
require 'Bar'

WINDOW_WIDTH = 1366 --1280
WINDOW_HEIGHT = 768 --720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243  

-- Text in game
welcomeMessage = "Welcome to pong!"
playMessage = "Press enter to play..."
serveMessage = "Press enter to serve..."
restartMessage = "Press enter to restart..."

--[[
    Runs when the game starts up, only once. Initialize the game. 
]]
function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = true,
        vsync = true,
        resizable = true
    })

    -- Creates a random seed based on the time
    math.randomseed(os.time())

    -- Set a title to the game's window
    love.window.setTitle('Pong')

    -- Initialize the game's font
    smallFont = love.graphics.newFont('04B03_font.TTF', 8)
    scoreFont = love.graphics.newFont('04B03_font.TTF', 32)
    victoryFont = love.graphics.newFont('04B03_font.TTF', 24)

    -- Creates an object with the game's sounds
    sounds = {
        ['ball_hit_bar'] = love.audio.newSource('ball_hit_bar.wav', 'static'),
        ['point_scored'] = love.audio.newSource('point_scored.wav', 'static'),
        ['ball_hit_window'] = love.audio.newSource('ball_hit_window.wav', 'static')
    }

    -- Initialize the game score for both players
    playerOneScore = 0
    playerTwoScore = 0

    -- Generates a 0 or 1 indicating who is the turn player
    servingPlayer = math.random(1, 2)

    winningPlayer = 0

    -- Creates and places the bar objects
    barOne = Bar(20, 20, 5, 20)
    barTwo = Bar(VIRTUAL_WIDTH - 25, VIRTUAL_HEIGHT - 40, 5, 20)

    -- Creates and places the ball object
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT/2 - 2, 4, 4)

    --[[ servingPlayer(servingPlayer, ball) ]]
    if servingPlayer == 1 then
        ball.dx = ball.dx
    else
        ball.dx = -ball.dx
    end

    gameState = 'start'

end

function love.resize(width, height)
    push:resize(width, height)
end

function love.update(dt)

    if gameState == 'play' then

        -- Win condition for the player two
        if ball.x <= 0 then
            playerTwoScore = playerTwoScore + 1 
            servingPlayer = 1
            ball:reset()
            sounds['point_scored']:play()
            
            if playerTwoScore >= 3 then 
                gameState = 'victory'
                winningPlayer = 2
            else
                gameState = 'serve'
            end
        end

        -- Win condition for the player one
        if ball.x >= VIRTUAL_WIDTH - 4 then
            playerOneScore = playerOneScore + 1 
            servingPlayer = 2
            ball:reset()
            sounds['point_scored']:play()

            if playerOneScore >= 3 then 
                gameState = 'victory'
                winningPlayer = 1
            else
                gameState = 'serve'
            end
        end

        --[[ 
            handling the ball collisions with the game window's edge
        ]]
        if ball:collides(barOne) then
            -- Deflect the ball to the right
            ball.dx = -ball.dx
            sounds['ball_hit_bar']:play()
        end

        if ball:collides(barTwo) then
            -- Deflect the ball to the left
            ball.dx = -ball.dx
            sounds['ball_hit_bar']:play()
        end

        if ball.y <= 0 then
            -- Deflect the ball to the bottom
            ball.dy = -ball.dy
            ball.y = 0
            sounds['ball_hit_window']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            -- Deflect the ball to the top
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - 4 
            sounds['ball_hit_window']:play()
        end

    end

    barOne:update(dt)
    barTwo:update(dt)

    gameController.playerOneMovement(barOne)
    gameController.playerTwoMovement(barTwo)

    -- Reset the ball position
    if gameState == 'play' then
        ball:update(dt)
    end

end

function love.keypressed(key)

   if key == 'escape' then
    love.event.quit()

   elseif key == 'enter' or key == 'return' then
    if gameState == 'start' then
        gameState = 'play'
    
    elseif gameState == 'victory' then
        gameState = 'start'
        playerOneScore = 0
        playerTwoScore = 0

    elseif gameState == 'serve' then
        gameState = 'play'
        ball:reset()
    end

   end
   
end

--[[
    Called after update, draw anything to the screen, update or otherwise. 
]]
function love.draw()
    push:apply('start')

    love.graphics.clear(62 / 255, 146 / 255, 204 / 255, 255 / 255)

    -- Draw different things based on the state of the game
    love.graphics.setFont(smallFont)

    if gameState == 'start' then

        love.graphics.printf(welcomeMessage, 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf(playMessage, 0, 32, VIRTUAL_WIDTH, 'center')

    elseif gameState == 'serve' then

        love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf(serveMessage, 0, 32, VIRTUAL_WIDTH, 'center')
    
    elseif gameState == 'victory' then

        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winningPlayer) .. " wins!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf(restartMessage, 0, 48, VIRTUAL_WIDTH, 'center')

    end

    love.graphics.setFont(scoreFont)
    love.graphics.print(playerOneScore, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(playerTwoScore, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

    -- Render bars
    barOne:render()
    barTwo:render()

    -- Render ball
    ball:render()

    --[[ displayFPS() ]]

    push:apply('end')
end

--[[ function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40, 20)
    love.graphics.setColor(0, 0, 0, 0)
end ]]