-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("vrp_hud",cRP)
vSERVER = Tunnel.getInterface("vrp_garages")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local hour = 0
local voice = 2
local minute = 0
local month = ""
local dayMonth = 0
local sede = 0
local fome = 0
local varDay = "th"
local showHud = true
local showMovie = false
local showRadar = false
local radioDisplay = ""
local radioFrequency = 0
local sBuffer = {}
local seatbelt = false
local ExNoCarro = false
local timedown = 0
local talking = false
local hudActived = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- GCPHONE
-----------------------------------------------------------------------------------------------------------------------------------------
local menu_celular = false
RegisterNetEvent("status:celular")
AddEventHandler("status:celular",function(status)
	menu_celular = status
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CALCULATETIMEDISPLAY
-----------------------------------------------------------------------------------------------------------------------------------------
function calculateTimeDisplay()
	hour = GetClockHours()
	minute = GetClockMinutes()
	if hour <= 9 then
		hour = "0"..hour
	end
	if minute <= 9 then
		minute = "0"..minute
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOKOVOIP
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vrp_hud:Tokovoip")
AddEventHandler("vrp_hud:Tokovoip",function(status)
	voice = status
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOKOVOIPTALKING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vrp_hud:TokovoipTalking")
AddEventHandler("vrp_hud:TokovoipTalking",function(status)
	talking = status
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TOKOVOIP
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vrp_hud:RadioDisplay")
AddEventHandler("vrp_hud:RadioDisplay",function(number)
	radioFrequency = parseInt(number)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FOME
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("statusFome")
AddEventHandler("statusFome",function(number)
	fome = parseInt(number)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FOME
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("statusSede")
AddEventHandler("statusSede",function(number)
	sede = parseInt(number)
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUDACTIVE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hudActived")
AddEventHandler("hudActived",function()
	hudActived = true
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUDDEACTIVED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hudDeactived")
AddEventHandler("hudDeactived",function()
	hudActived = false
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADHUD
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		if IsPauseMenuActive() or IsScreenFadedOut() or menu_celular or not hudActived then
			SendNUIMessage({ hud = false, movie = false })
		else
			local ped = PlayerPedId()
			local armour = GetPedArmour(ped)
			local health = GetEntityHealth(ped)-100
			local stamina = GetPlayerSprintStaminaRemaining(PlayerId())
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))
			calculateTimeDisplay()
			if dayOfMonth == 1 then
				varDay = "st"
			elseif dayOfMonth == 2 then
				varDay = "nd"
			elseif dayOfMonth == 3 then
				varDay = "rd"
			else
				varDay = "th"
			end
			if radioFrequency <= 0 then
				radioDisplay = ""
			else
				if radioFrequency == 911 then
					radioDisplay = "Rádio: <b>Polícia</b>"
				elseif radioFrequency == 112 then
					radioDisplay = "Rádio: <b>Paramédico</b>"
				elseif radioFrequency == 443 then
					radioDisplay = "Rádio: <b>Mecânico</b>"
				else
					radioDisplay = "Rádio: <b>"..radioFrequency..".0Mhz </b>"
				end
			end
			local ped = PlayerPedId()
			local car = GetVehiclePedIsIn(ped)
			if not showHud then 
				showRadar = false 
			end
			if IsPedOnAnyBike(ped) then
				showRadar = true
			end
			if not IsPedInAnyVehicle(ped) then 
				showRadar = false
				DisplayRadar(showRadar)
			end
			if IsPedInAnyVehicle(ped) then
				local vehicle = GetVehiclePedIsIn(ped)
				local fuel = GetVehicleFuelLevel(vehicle)
				local speed = GetEntitySpeed(vehicle) * 3.6
				SendNUIMessage({ hud = showHud, movie = showMovie, car = true, day = dayMonth..varDay, month = month, hour = hour, minute = minute, street = street, radio = radioDisplay, voice = voice, talking = talking, health = (health), armour = parseInt(armour), sede = parseInt(sede), fome = parseInt(fome), stamina = parseInt(stamina), fuel = parseInt(fuel), speed = parseInt(speed), seatbelt = seatbelt })
			else
				SendNUIMessage({ hud = showHud, movie = showMovie, car = false, day = dayMonth..varDay, month = month, hour = hour, minute = minute, street = street, radio = radioDisplay, voice = voice, talking = talking, health = (health), armour = parseInt(armour), sede = parseInt(sede), fome = parseInt(fome), stamina = parseInt(stamina) })
			end
		end
		Citizen.Wait(200)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("hud",function(source,args)
	showHud = not showHud
	showRadar = not showRadar
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- MOVIE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("movie",function(source,args)
	showMovie = not showMovie
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADHEALTHREDUCE
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local ped = PlayerPedId()
		local health = GetEntityHealth(ped)
		if health > 101 then
			if fome >= 80 and fome <= 90 then
				SetFlash(0,0,500,1000,500)
				SetEntityHealth(ped,health-1)
			elseif fome > 90 then
				SetFlash(0,0,500,1000,500)
				SetEntityHealth(ped,health-2)
			end
			if sede >= 80 and sede <= 90 then
				SetFlash(0,0,500,1000,500)
				SetEntityHealth(ped,health-1)
			elseif sede > 90 then
				SetFlash(0,0,500,1000,500)
				SetEntityHealth(ped,health-2)
			end
		end
		Citizen.Wait(5000)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- SEATBELT
-----------------------------------------------------------------------------------------------------------------------------------------
IsCar = function(veh)
	local vc = GetVehicleClass(veh)
	return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 15 and vc <= 20)
end

Citizen.CreateThread(function()
	while true do
		local ORTiming = 500
		local ped = PlayerPedId()
		local car = GetVehiclePedIsIn(ped)
		if car ~= 0 and (ExNoCarro or IsCar(car)) then
			ExNoCarro = true
			if seatbelt then
				DisableControlAction(0,75)
			end
			ORTiming = 4
			sBuffer[2] = sBuffer[1]
			sBuffer[1] = GetEntitySpeed(car)
			if sBuffer[2] ~= nil and not seatbelt and GetEntitySpeedVector(car,true).y > 1.0 and sBuffer[1] > 10.25 and (sBuffer[2] - sBuffer[1]) > (sBuffer[1] * 0.255) then
				SetEntityHealth(ped,GetEntityHealth(ped)-10)
				TaskLeaveVehicle(ped,GetVehiclePedIsIn(ped),4160)
				timedown = 10
			end
			if IsControlJustReleased(1,47) then
				if seatbelt then
					TriggerEvent("vrp_sound:source","unbelt",0.5)
					showRadar = false
					seatbelt = false
				else
					TriggerEvent("vrp_sound:source","belt",0.5)
					seatbelt = true
					showRadar = true
				end
			end
			if not seatbelt and not showHud then 
				showRadar = false
			end
		elseif ExNoCarro then
			ExNoCarro = false
			seatbelt = false
			sBuffer[1],sBuffer[2] = 0.0,0.0
		end
		DisplayRadar(showRadar)
		Citizen.Wait(ORTiming)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TIMEDOWN
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local ped = PlayerPedId()
		if timedown > 0 and GetEntityHealth(ped) > 101 then
			timedown = timedown - 1
			if timedown <= 1 then
				TriggerServerEvent("vrp_inventory:Cancel")
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- RAGDOLL
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		local ped = PlayerPedId()
		if timedown > 1 and GetEntityHealth(ped) > 101 then
			if not IsEntityPlayingAnim(ped,"anim@heists@ornate_bank@hostages@hit","hit_react_die_loop_ped_a",3) then
				vRP.playAnim(false,{"anim@heists@ornate_bank@hostages@hit","hit_react_die_loop_ped_a"},true)
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- DISABLE
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local ORTiming = 500
		if timedown > 0 then
			ORTiming = 4
			DisableControlAction(0,288,true)
			DisableControlAction(0,289,true)
			DisableControlAction(0,170,true)
			DisableControlAction(0,187,true)
			DisableControlAction(0,189,true)
			DisableControlAction(0,190,true)
			DisableControlAction(0,188,true)
			DisableControlAction(0,57,true)
			DisableControlAction(0,105,true)
			DisableControlAction(0,167,true)
			DisableControlAction(0,20,true)
			DisableControlAction(0,29,true)
		end
		Citizen.Wait(ORTiming)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- VEHBONES
-----------------------------------------------------------------------------------------------------------------------------------------
local vehBones = {
	"exhaust",
	"exhaust_2"
}