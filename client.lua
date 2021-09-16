local score = 0
local screenScore = 0
local idleTime
local mult = 0.02
local previous = 0
local curAlpha = 0
local driftMode = false

RegisterCommand('driftmode', function(src, args, raw)
    driftMode = not driftMode
end)

CreateThread(function()
    while true do
        local sleep = 1000

        local player = PlayerPedId()
        local tick = GetGameTimer()

        if driftMode then
            sleep = 500

            if not IsPedDeadOrDying(player, 1) and IsPedInAnyVehicle(player, false) and GetPedInVehicleSeat(GetVehiclePedIsUsing(player), -1) == player and IsVehicleOnAllWheels(GetVehiclePedIsUsing(player)) and not IsPedInFlyingVehicle(player)  then
                sleep = 0

                local vehicle = GetVehiclePedIsIn(player, false)
                local angle, velocity = GetVehicleAngle(vehicle)
                local tempBool = tick - (idleTime or 0) < 1850

                if not tempBool and score ~= 0 then
                    previous = score
                    previous = CalculateBonus(previous)
                    score = 0
                end

                if angle ~= 0 then
                    if score == 0 then
                        drifting = true
                    end
                    if tempBool then
                        score = score + math.floor(angle*velocity)*mult
                    else
                        score = math.floor(angle*velocity)*mult
                    end
                    screenScore = CalculateBonus(score)
                    
                    idleTime = tick
                end
            end

            if tick - (idleTime or 0) < 3000 then
                if curAlpha < 255 and curAlpha+10 < 255 then
                    curAlpha = curAlpha+10
                elseif curAlpha > 255 then
                    curAlpha = 255
                elseif curAlpha == 255 then
                    curAlpha = 255
                elseif curAlpha == 250 then
                    curAlpha = 255
                end
            else
                if curAlpha > 0 and curAlpha-10 > 0 then
                    curAlpha = curAlpha-10			elseif curAlpha < 0 then
                    curAlpha = 0
                elseif curAlpha == 5 then
                    curAlpha = 0
                end
            end

            if not screenScore then 
                screenScore = 0 
            end

            DrawHudText(string.format("\nDrift Score > %s",tostring(screenScore)), {255,191,0,curAlpha}, 0.45, 0.0, 0.7, 0.7)
        end

        Wait(sleep)
    end
end)

function CalculateBonus(previous)
    local points = round(previous)
    return points or 0
end


function GetVehicleAngle(pVehicle)
    if not pVehicle then return false end
    local vx,vy,vz = table.unpack(GetEntityVelocity(pVehicle))
    local modV = math.sqrt(vx*vx + vy*vy)
    
    local rx,ry,rz = table.unpack(GetEntityRotation(pVehicle, 0))
    local sn,cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))
    
    if GetEntitySpeed(pVehicle)* 3.6 < 30 or GetVehicleCurrentGear(pVehicle) == 0 then return 0, modV end
    
    local cosX = (sn*vx + cs*vy) / modV

    if cosX > 0.966 or cosX < 0 then 
        return 0, modV
    end

    return math.deg(math.acos(cosX))*0.5, modV
end

function round(number)
    number = tonumber(number)
    number = math.floor(number)
    
    if number < 0.01 then
        number = 0
    elseif number > 999999999 then
        number = 999999999
    end

    return number
end

function DrawHudText(text,colour,coordsX,coordsY,scaleX,scaleY)
    SetTextFont(2)
    SetTextProportional(7)
    SetTextScale(scaleX, scaleY)
    local colourR,colourG,colourB,colourA = table.unpack(colour)
    SetTextColour(colourR,colourG,colourB, colourA)
    SetTextDropshadow(0, 0, 0, 0, colourA)
    SetTextEdge(1, 0, 0, 0, colourA)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    EndTextCommandDisplayText(coordsX,coordsY)
end