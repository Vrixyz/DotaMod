--[[
Dota PvP game mode
]]

print( "Dota PvP game mode loaded." )

if DotaPvP == nil then
	DotaPvP = class({})
end


function Precache( context )
	--[[
		This function is used to precache resources/units/items/abilities that will be needed
		for sure in your game and that cannot or should not be precached asynchronously or 
		after the game loads.
		See GameMode:PostLoadPrecache() in barebones.lua for more information
		]]

		print("Performing pre-load precache")

		-- Particles can be precached individually or by folder
		-- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
		PrecacheResource("particle", "particles/econ/events/coal/coal_projectile.vpcf", context)

		-- Models can also be precached by folder or individually
		-- PrecacheModel should generally used over PrecacheResource for individual models
		--PrecacheModel("models/buildings/building_plain_reference.vmdl", context)
    --PrecacheModel("models/props_winter/egg.vmdl", context)
    
		-- Entire items can be precached by name
		-- Abilities can also be precached in this way despite the name
		PrecacheItemByNameSync("example_ability", context)
		PrecacheItemByNameSync("item_poop", context)
end

--------------------------------------------------------------------------------
-- ACTIVATE
--------------------------------------------------------------------------------
function Activate()
    GameRules.DotaPvP = DotaPvP()
    GameRules.DotaPvP:InitGameMode()
end

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------
function DotaPvP:InitGameMode()
	local GameMode = GameRules:GetGameModeEntity()

	-- Enable the standard Dota PvP game rules
	GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled( true )

	-- Register Think
	GameMode:SetContextThink( "DotaPvP:GameThink", function() return self:GameThink() end, 0.25 )

	-- Register Game Events
end

--------------------------------------------------------------------------------
function DotaPvP:GameThink()
	return 0.25
end