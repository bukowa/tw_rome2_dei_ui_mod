

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
			_G.script_env = getfenv(1);
			
			-- try and require() this script, if the command fails throw a script assert (but continue - the script file hasn't been created)
			if not pcall(function() require(local_faction) end) then
				script_error("WARNING: could not find faction script for faction " .. tostring(local_faction) .. ", one should created (usually in the factions subfolder)");
			end;
		end
	end
);



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

require("pun_start");




------------------------------------------------------------------------------------------------------------------
-- Mod options feature switcher
------------------------------------------------------------------------------------------------------------------

-- Importing necessary libraries for logging and options management
local lib_options = require "script._lib.lib_mod_options"
local lib_logging = require "script._lib.lib_logging"

-- Initialize logger with a file and log level
local logger = lib_logging.new_logger("dei_mod_options.log.txt", "INFO")

-- create new instance of options
local options = lib_options.new_options()
options:load()

-- supply_system
if options:get_value("supply_system") == "on" then
    logger:debug("loading supply system")
    supply_system  = require "lua_scripts.supply_system";
end

-- population_system
if options:get_value("population_system") == "on" then
    logger:debug("loading population system")
    population = require "lua_scripts.population"
end

--------------------------------------------------------------------------------------------------------------------
-- Start external scripts of DEI
-- Selea
--------------------------------------------------------------------------------------------------------------------

local reforms = require "lua_scripts.reforms";
local army_caps = require "lua_scripts.army_caps";
local PublicOrder  = require "lua_scripts.PublicOrder";
local money = require "lua_scripts.money";
local changeCapital = require "lua_scripts.changeCapital";
local auto_resolve  = require "lua_scripts.auto_resolve_bonus";
