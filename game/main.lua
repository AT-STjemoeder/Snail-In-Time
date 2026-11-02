     local getJoysticks = love.joystick.getJoysticks
    
    local graphics = love.graphics
    local circle = graphics.circle
    
    local player2 = {x = 200, y = 120, speed = 2, color = {1, 0.3, 0.3}}
    local player = {x = 200, y= 120,speed = 2, color ={0.3, 0.3, 1}}

    local gravity = 0.3
    local velocityY = 0
    local onGround = false

    local surface = "ground"
    local released = false
    local climbspeed = 2
    local fallButtonWasDown = false

    local objects = {
        {x = 50, y = 160, width = 100, height = 20},
        {x = 200, y = 130, width = 80, height = 20},
        {x = 300, y = 170, width = 60, height = 20} 
    }

    local groundY = 200
    
    local snail
    local idleFrames = {}
    local walkFrames = {}
    
    local currentFrame = 1
    local currentAnimation = "idle"
    local animationTimer = 0
    local animationSpeed = 0.15

    local facing = 1

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
    
        if pad:isGamepadDown("dpright") then
            p1dx = p1dx + 1
        end 

        if pad:isGamepadDown("dpleft") then
            p1dx = p1dx - 1
        end

        local fallButtonDown = pad:isGamepadDown("dpdown")

        if fallButtonDown and not fallButtonWasDown then
            released = true
            surface = "falling"
        end

        fallButtonWasDown = fallButtonDown

        if pad:isGamepadDown("a") then
            p2dx = p2dx + 1
        end
        if pad:isGamepadDown("y") then
            p2dx = p2dx - 1
        end
 
        -- Horizontal movement
        player.x = player.x + (p1dx * player.speed)

        --checked of de slak op de grond zit of het plafon
        local foundSurface = false

        if surface == "ground" then
            if player.y + 32 >= groundY then
                player.y = groundY - 32
                foundSurface = true
            end
        end

        for i, object ipairs(objects) do

            -- landen op bovenkant van een platform

            if velocityY >= 0 
            and player.x + 20 > object.x
            and player.x - 20 < object.x + object.width
            and player.y + 32 >= object.y
            and player.y + 32 - velocityY <= object.groundY then

                player.x = object.x - 20
                surface = "wall"
                foundSurface = true
            end

            --een muur aan de rechterkant detecteren

            if p1dx > 0
            and player.x + 20 >= object.x
            and player.x + 20 - player.speed < object.x
            and player.y + 20 > object.y
            and player.y - 20 < object.y + object.height then

                player.x = object.x - 20
                surface = "wall"
                foundSurface = true
            end

            -- een muur aan de rechterkant detecteren

            if p1dx < 0
            and player.x - 20 <= object.x + object.width
            and player.x - 20 + player.speed > object.x + object.width
            and player.y + 20 > object.y
            and player.y - 20 < object.y + object.height then
                
                player.x = object.x + object.width + 20
                surface = "wall"
                foundSurface = true
            end
        end

        -- fallen als er geen platform is of heeft laten vallen
        
        if surface == "wall" and not released then
            player.y = player.y - climbspeed
        end
        
        if not foundSurface or released then
            surface = "falling"
            velocityY = velocityY + gravity
            player.y = player.y + velocityY
        else
            velocityY = 0 
        end

        if surface == "falling" and player.y + 32 >= groundY then
            player.y = groundY - 32 
            velocityY = 0
            surface = "ground"
            released = false
        end


        player2.x = player2.x + (p2dx * player2.speed)
        player2.y = player2.y + (p2dy * player2.speed)

        if p1dx > 0 then
            facing = 1
        elseif p1dx < 0 then
            facing = -1
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
        -- Draw the game on the upper screen
        graphics.setColor(1,1,1)

        local frame

        if currentAnimation == "idle" then
            frame = idleFrames[currentFrame]
        else
            frame = walkFrames[currentFrame]
        end

        graphics.setColor(0.5,0.5,0.5)

        for i, object in ipairs(objects) do
            graphics.rectangle(
                "fill",
                object.x,
                object.y,
                object.width,
                object.height
            )
        end

        graphics.setColor(1,1,1)

        graphics.draw(
            snail,
            frame,
            player.x,
            player.y,
            0,
            facing,
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