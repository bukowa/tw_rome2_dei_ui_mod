

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

require("pel_start");
require("callias_peace");
require("persian_escalation");
require("pel_regions");
require("capital_penalty");
require("season_message");

------------------------------------------------------------------------------------------------------------------
-- Start Population scripts magnar + Litharion
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
-- Feature switcher
------------------------------------------------------------------------------------------------------------------
-- Importing necessary libraries for options management
local lib_options = require "script._lib.lib_mod_options"
local options = lib_options.new_options()
options:load()
-- Feature switch for population_system
local population = nil
if options:get_value("population_system") == "on" then
    local population_script = "lua_scripts.population"
    -- Use a version without supply if supply_system is disabled
    if options:get_value("supply_system") ~= "on" then
        population_script = "lua_scripts.population_without_supply"
    end
    population = require(population_script)
end

-- DEI Scripts
local mac_wars = require "lua_scripts.mac_wars";
local reforms = require "lua_scripts.reforms";
local army_caps = require "lua_scripts.army_caps";
local PublicOrder  = require "lua_scripts.PublicOrder";
local money = require "lua_scripts.money";
-- feature switch supply_system
local supply_system = nil
if options:get_value("supply_system") == "on" then
    supply_system  = require "lua_scripts.supply_system";
end
local changeCapital = require "lua_scripts.changeCapital";
local auto_resolve  = require "lua_scripts.auto_resolve_bonus";