    local getJoysticks = love.joystick.getJoysticks
    
    local graphics = love.graphics
    local circle = graphics.circle
    
    local player2 = {x = 200, y = 120, speed = 2, color = {1, 0.3, 0.3}}
    local player = {x = 200, y= 120,speed = 2, color ={0.3, 0.3, 1}}

    local gravity = 0.3
    local velocityY = 0

    local surface = "ground"
    local wallSide = nil

    local groundY = 200
    
    local snail
    local idleFrames = {}
    local walkFrames = {}
    
    local currentFrame = 1
    local currentAnimation = "idle"
    local animationTimer = 0
    local animationSpeed = 0.15

    local facing = 1

    local rotation = 0

    local debugMovement = 0

function love.load()
snail = graphics.newImage("snail_3ds_sprite_sheet_256.t3x")

-- maakt de quads aan 
    for i = 0, 3 do
        idleFrames [i + 1] = graphics.newQuad(
            i * 64, 0, 64, 64,
            snail:getWidth(),
            snail:getHeight()
        )
    end
    for i = 0,  10 do 
        local frameIndex = i + 4
        local column = frameIndex % 4 
        local row = math.floor(frameIndex / 4)

        walkFrames[i + 1] = graphics.newQuad(
            column * 64, row * 64, 64, 64,
            snail:getWidth(),
            snail:getHeight()

        )
    end 


end

function love.update(dt)

    local joysticks = getJoysticks()
    local pad =joysticks [1]

    if pad then
        local p1dx, p1dy = 0,0
       
        local p2dx, p2dy = 0,0

        if pad:isGamepadDown("dpup") then
            p1dy = -1
        end

        if pad:isGamepadDown("dpdown") then
            p1dy = 1
        end
    
        if pad:isGamepadDown("dpright") then
            p1dx = p1dx + 1
            
        end 

        if pad:isGamepadDown("dpleft") then
            p1dx = p1dx - 1
            
        end


        if pad:isGamepadDown("a") then
            p2dx = p2dx + 1
        end
        if pad:isGamepadDown("y") then
            p2dx = p2dx - 1
        end
 



        player2.x = player2.x + (p2dx * player2.speed)
        player2.y = player2.y + (p2dy * player2.speed)

        if p1dx > 0 then
            facing = 1
        elseif p1dx < 0 then
            facing = -1
        end

        -- TEST: detecteer de linker muur
        if player.x <= 40 then
            player.x = 40
            surface = "wall"
            wallSide = "left"
        end

-- TEST: detecteer de rechter muur
        if player.x >= 360 then
            player.x = 360
            surface = "wall"
            wallSide = "right"
        end
       -- Movement on ground
        if surface == "ground" then

            player.y = groundY - 32
            player.x = player.x + (p1dx * player.speed)

        elseif surface == "wall" then

    -- D-pad down lets go
            if pad:isGamepadDown("dpdown") then
                surface = "falling"
                wallSide = nil
                velocityY = 0

            elseif wallSide == "left" then

                if p1dx < 0 then
                    player.y = player.y - player.speed
                elseif p1dx > 0 then
                    player.y = player.y + player.speed
                end

            elseif wallSide == "right" then

                if p1dx > 0 then
                    player.y = player.y - player.speed
                elseif p1dx < 0 then
                    player.y = player.y + player.speed
                end
            end

        elseif surface == "falling" then

            player.x = player.x + (p1dx * player.speed)
            velocityY = velocityY + gravity
            player.y = player.y + velocityY
        end

-- Wall collision


        -- Reach the ground from the wall
        if surface == "wall" and player.y + 32 >= groundY then
            player.y = groundY - 32
            surface = "ground"
            wallSide = nil
            velocityY = 0
        end

        -- Land on ground while falling
        if surface == "falling" and player.y + 32 >= groundY then
            player.y = groundY - 32
            velocityY = 0
            surface = "ground"
            wallSide = nil
        end

        -- Stop at the top of the screen
        if player.y < 32 then
            player.y = 32
        end
  


        if p1dx ~= 0 or p1dy ~= 0 then
            currentAnimation = "walk"
        else
            currentAnimation = "idle"
        end

        animationTimer = animationTimer + dt

        if animationTimer >= animationSpeed then
            animationTimer = 0
            currentFrame = currentFrame + 1
        end

        if currentAnimation == "idle" then
            if currentFrame > #idleFrames then
                currentFrame = 1
            end
        else
            if currentFrame > #walkFrames then
             currentFrame = 1
            end
        end   
    end  
end
function love.draw(screen)
    if screen ~= "bottom" then

        graphics.setColor(1, 1, 1)
        graphics.print("Surface: " .. surface, 10, 10)
        graphics.print("Wall: " .. tostring(wallSide), 10, 30)
        graphics.print("X: " .. player.x, 10, 50)
        graphics.print("player x: " .. tostring(debugMovement), 10, 90)
        -- Draw the game on the upper screen
        graphics.setColor(1,1,1)

        local frame

        if currentAnimation == "idle" then
            frame = idleFrames[currentFrame]
        else
            frame = walkFrames[currentFrame]
        end

        graphics.setColor(0.5,0.5,0.5)



        graphics.setColor(1,1,1)
        local drawRotation = 0
        local drawFacing = facing

        if wallSide == "left" then
            drawRotation = -math.pi / 2
            drawFacing = -1
        elseif wallSide == "right" then
            drawRotation = math.pi / 2
            drawFacing = 1
        end

        graphics.draw(
            snail,
            frame,
            player.x,
            player.y,
            drawRotation,
            drawFacing,
            1,
            32,
            32
        )
        
        graphics.setColor(0.3, 0.8, 0.3)
        graphics.rectangle("fill",0, groundY, 400,40)
        graphics.setColor(1,1,1)
    else
        -- Draw the game on the lower screen
        graphics.setColor(player2.color)
        circle("fill", player2.x, player2.y, 20)
        graphics.setColor(1,1,1)
    end

end