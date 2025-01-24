

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	CAMPAIGN SCRIPT
--
--	First file that gets loaded by a scripted campaign.
--	This shouldn't need to be changed by per-campaign, except for the
--	require and callback commands at the bottom of the file
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

out.ting("scripting.lua loading");

-- change this to false to not load the script
local load_script = true;

if not load_script then
	out.ting("*** WARNING: Not loading script for campaign " .. campaign_start_file .. " as load_script variable is set to false! Edit lua file at " .. debug.getinfo(1).source .. " to change this back ***");
	return;
end;

-- force reloading of the lua script library
package.loaded["lua_scripts.Campaign_Script_Header"] = nil;
require "lua_scripts.Campaign_Script_Header";

-- name of the campaign, sourced from the name of the containing folder
campaign_name = get_folder_name_and_shortform();

-- name of the local faction, to be filled in later
local_faction = "";

-- include path to other scripts associated with this campaign
package.path = package.path .. ";data/campaigns/" .. campaign_name .. "/?.lua";
package.path = package.path .. ";data/campaigns/" .. campaign_name .. "/factions/?.lua";

-- create campaign manager
cm = campaign_manager:new(campaign_name);

-- require a file in the factions subfolder that matches the name of our local faction
cm:register_ui_created_callback(
	function()
		-- place this here for now cause we need the game interface to actually set zoom limits
		cm:set_default_zoom_limit(2.0, 0.2);
		
		CampaignUI.SetCameraMaxTiltAngle(0.9)
		CampaignUI.SetCameraMinDistance(14)

		-- copy camera zoom and heading from faction start; use typical values
		CampaignUI.SetCameraZoom(0.8);  
		CampaignUI.SetCameraHeading(0.0);	


		local_faction = cm:get_local_faction();
		
		if not (local_faction == "") then
			output("Loading faction script for faction " .. local_faction);
			inc_tab();
			_G.script_env = getfenv(1);
			
			-- faction scripts loaded here
			if load_faction_script(local_faction) and load_faction_script(local_faction .. "_intro") then
				dec_tab();
				output("Faction scripts loaded");
			else
				dec_tab();
			end;
		end

	end
);


-- try and load a faction script
function load_faction_script(scriptname)
	local success, err_code = pcall(function() require(scriptname) end);
			
	if success then
		output(scriptname .. ".lua loaded");
	else
		script_error("ERROR: Tried to load faction script " .. scriptname .. " without success - either the script is not present or it is not valid. See error below");
		output("*************");
		output("Returned lua error is:");
		output(err_code);
		output("*************");
	end;
	
	return success;
end;



-------------------------------------------------------
--	function to call when the first tick occurs
-------------------------------------------------------

cm:register_first_tick_callback(
	function()

		if is_function(start_game_for_faction) then
			start_game_for_faction(true);		-- set to false to not show cutscene
		else
			script_error("start_game_for_faction() function is being called but hasn't been loaded - the script has gone wrong somewhere else, investigate!");
		end;

		start_game_all_factions();
	end
);

-------------------------------------------------------
--	additional script files to load
-------------------------------------------------------

require("invasion_start");

--
local function OnRegionChangedFaction(context)
	local region = context:region()
	--out.ting("OnRegionChangedFaction: Name: " .. region:name() .. "; Province: " .. region:province_name() .. "; New Faction: " .. region:owning_faction():name())
	if region:owning_faction():is_human() == true and region:owning_faction():culture() == "rom_Roman" and region:name() == "emp_latium_roma" then
		scripting.game_interface:trigger_custom_dilemma(region:owning_faction():name(), "move_capital_rome", "payload { set_capital emp_latium_roma; }", "", true)
	end
end


------------------------------------------------------------
--
--  Callback to check custom per-faction technology requirements
--
------------------------------------------------------------

function CheckAdditionalTechnologyRequirements(faction, technology_key)
	--out.ting("Faction " .. faction:name() .. " checks for availability of technology " .. technology_key)
	if ((technology_key == "inv_rome_military_via_exercitae_mountain_dues") and faction:region_list():num_items() < 1) then
		return false
	end

	return true
end



------------------------------------------------------------
--
--  Callback to check custom per-faction occupation decision
--
------------------------------------------------------------

function OccupationDecisionAvailableForFaction(faction, occupation_decision)
	out.ting("Faction " .. faction:name() .. " checks for occupation decision " .. occupation_decision)

	local faction_name = faction:name()
	local faction_culture = faction:culture()
	local faction_sub_culture = faction:subculture()

	-- valid occupation_decision strings are:
	-- "occupation_decision_loot",
	-- "occupation_decision_sack",
	-- "occupation_decision_raze",
	-- "occupation_decision_occupy",
	-- "occupation_decision_liberate",
	-- "occupation_decision_vassal"

	if (faction_name == "inv_senones") then
		if (occupation_decision == "occupation_decision_occupy") then
			return false
		end
	end

	return true
end


------------------------------------------------------------
--
--    Custom scripted actions related to government types
--
------------------------------------------------------------
function FactionPoliticsGovernmentActionViable(faction, action_key)
	if action_key == "inv_taranto_scientific_commission" then
		return faction:has_researched_all_technologies() == false
	end
	return true
end

local function OnFactionPoliticsGovernmentActionTriggered(context)
    local faction = context:faction()
	local faction_key = faction:name()
	local action_key = context:action_key()
	
	-- Most of the current actions trigger a random campaign incident from a particular set
	local incidents = {
		inv_etruscan_summit               = { "inv_etruscan_summit_incident_",                  6 },
		inv_taranto_write_treatise        = { "inv_greek_philosophers_incident_",               6 },
		inv_insubre_divine_will           = { "inv_insubre_druids_divine_will_incident_",       5 },
		inv_insubre_motivate_populace     = { "inv_insubre_druids_motivate_populace_incident_", 7 },
		inv_senone_divination             = { "inv_senone_druids_divination_incident_",         6 },
		inv_senone_war_decree             = { "inv_senone_druids_war_decree_incident_",         6 },
		inv_iolei_sardinian_tournament    = { "inv_iolei_sardinian_tournament_",                9 },
		inv_taranto_scientific_commission = "inv_greek_philosophers_research_incident",
		inv_syracuse_colony			      = "inv_colony_set_sail",
		inv_veneti_breed_civil            = "inv_veneti_breed_civil",                          
        inv_veneti_breed_military         = "inv_veneti_breed_military",
	    inv_samnites_ver_sacrum           = "inv_samnites_ver_sacrum",
	}
	
	local key_set = incidents[action_key]

	if type(key_set) == "table" then
		local i = context:faction():model():random_number(1, key_set[2])
		--out.ting("Selected incident: " .. key_set[1] .. tostring(i) .. ".")
        scripting.game_interface:trigger_custom_incident(faction_key, key_set[1] .. tostring(i), " ")
	elseif type(key_set) == "string" then
        scripting.game_interface:trigger_custom_incident(faction_key, key_set)
	end
end


local scripting = require "lua_scripts.EpisodicScripting"
scripting.AddEventCallBack("RegionChangedFaction", OnRegionChangedFaction)
scripting.AddEventCallBack("FactionPoliticsGovernmentActionTriggered", OnFactionPoliticsGovernmentActionTriggered)
out.ting("scripting.lua loaded");

----------------------------
---ROR Scripts
------------------------------
local RoR_DeI = require "lua_scripts.RoR_DeI"

------------------------------------------------------------------------------------------------------------------
-- Start Population scripts magnar + Litharion
------------------------------------------------------------------------------------------------------------------
local population = require "lua_scripts.population"
--------------------------------------------------------------------------------------------------------------------
-- Start external scripts of DEI
--------------------------------------------------------------------------------------------------------------------
local army_caps = require "lua_scripts.army_caps";
local PublicOrder  = require "lua_scripts.PublicOrder";
local supply_system  = require "lua_scripts.supply_system";
local money = require "lua_scripts.money";
local changeCapital = require "lua_scripts.changeCapital";
local auto_resolve  = require "lua_scripts.auto_resolve_bonus";