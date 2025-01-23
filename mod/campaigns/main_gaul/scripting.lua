-------------------------------------------------------------------------------
------------------------------ SCRIPT SETUP -----------------------------------
-------------------------------------------------------------------------------
local core = require "ui/CoreUtils"
local advice = require "lua_scripts.export_advice"

local campaign_name = "main_gaul";
package.loaded["lua_scripts.Campaign_Script_Header"] = nil;
require "lua_scripts.Campaign_Script_Header";
package.path = package.path .. ";data/campaigns/" .. campaign_name .. "/?.lua";

scripting = Setup_Campaign(campaign_name);
EpisodicScripting = scripting;
-- Stephen
-- initialisation of lib_export_triggers
local triggers = require "data.lua_scripts.export_triggers"
out.ting("scripting.lua loaded");

local camera_pan = 0
local new_game = false
local panning = false
local player_faction = ""
local intro_advice_shown = false
local is_exiting_intro = false

--init of event handler

--suspend_contextual_advice_for_campaign();
eh = event_handler:new(scripting.AddEventCallBack);
initialise_timers(eh);
initialise_advice(scripting, eh);
start_campaign_selection_listener(eh);
start_advice_navigation_listener(eh);
init_campaign_ui_state(eh);

-- name of the campaign, sourced from the name of the containing folder
campaign_cm = get_folder_name_and_shortform();

-- name of the local faction, to be filled in later
local_faction = "";

-- include path to other scripts associated with this campaign
package.path = package.path .. ";data/campaigns/" .. campaign_cm .. "/?.lua";
package.path = package.path .. ";data/campaigns/" .. campaign_cm .. "/factions/?.lua";

-- create campaign manager
cm = campaign_manager:new(campaign_cm);

-------------------------------------------------------
-------------------------------------------------------
--	SAVEGAME
-------------------------------------------------------
-------------------------------------------------------

function Save_Values(context)
	output("Saving game")
	scripting.game_interface:save_named_value("current_imperium", current_imperium, context)
	for i,value in pairs(faction_excerpts_played) do
		scripting.game_interface:save_named_value("faction_excerpts_played"..i, value, context)
	--	out.ting("Saving named value: ".."faction_excerpts_played"..i..". Value: "..tostring(value))
	end
	
end

function Load_Values(context)
	output("Loading game")
	current_imperium = scripting.game_interface:load_named_value("current_imperium", 0, context)
	for i,value in pairs(faction_excerpts_played) do
		faction_excerpts_played[i] = scripting.game_interface:load_named_value("faction_excerpts_played"..i, 0, context)
	--	out.ting("Loading named value: ".."faction_excerpts_played"..i..". To index: "..tostring(i))
	end
end

add_loadgame_callback(eh, function(context) Load_Values(context) end)
add_savegame_callback(eh, function(context) Save_Values(context) end)

-------------------------------------------------------
-------------------------------------------------------
--	VALUES
-------------------------------------------------------
-------------------------------------------------------

local Enemies_Of_Rome_All = {
"gaul_aedui",
"gaul_allobroges",
"gaul_arverni",
"gaul_atrebates",
"gaul_ausci",
"gaul_belgae",
"gaul_bellovaci",
"gaul_bituriges",
"gaul_cadurci",
"gaul_cantiaci",
"gaul_carnutes",
"gaul_cenomani",
"gaul_dumnonii",
"gaul_eburones",
"gaul_helvetii",
"gaul_lemovices",
"gaul_lexovii",
"gaul_mandubii",
"gaul_mediomatrici",
"gaul_morini",
"gaul_namnetes",
"gaul_nervii",
"gaul_osismii",
"gaul_parisii",
"gaul_pictones",
"gaul_raurici",
"gaul_redones",
"gaul_remi",
"gaul_ruteni",
"gaul_santones",
"gaul_senones",
"gaul_sequani",
"gaul_sotiates",
"gaul_suessiones",
"gaul_tarbelli",
"gaul_treverii",
"gaul_tulingi",
"gaul_turones",
"gaul_unelli",
"gaul_veneti",
"gaul_vivisci",
"gaul_volcae"
}

local Enemies_Of_Rome_Majors = {
	"gaul_arverni",
	"gaul_nervii",
}

local characters_met = {
	Caesar = 0,
	Ariovistus = 0,
	Vercingetorix = 0,
	Boduognatus = 0
}

faction_excerpts_played = {
["gaul_aedui"] = 0,
["gaul_allobroges"] = 0,
["gaul_arverni"] = 0,
["gaul_belgae"] = 0,
["gaul_bellovaci"] = 0,
["gaul_cantiaci"] = 0,
["gaul_carnutes"] = 0,
["gaul_helvetii"] = 0,
["gaul_mandubii"] = 0,
["gaul_morini"] = 0,
["gaul_nervii"] = 0,
["gaul_osismii"] = 0,
["gaul_pictones"] = 0,
["gaul_redones"] = 0,
["gaul_remi"] = 0,
["gaul_rome"] = 0,
["gaul_ruteni"] = 0,
["gaul_sequani"] = 0,
["gaul_sotiates"] = 0,
["gaul_suebi"] = 0,
["gaul_suessiones"] = 0,
["gaul_tulingi"] = 0,
["gaul_veneti"] = 0,
["gaul_vocontii"] = 0,
["gaul_volcae"] = 0
}

current_imperium = 0
local reinforcement_pos_rome_x = 399
local reinforcement_pos_rome_y = 97


local function OnNewCampaignStarted(context)
	new_game = true
	scripting.game_interface:set_zoom_limit(1.1, 0.8)
	scripting.game_interface:set_map_bounds(0, 700, 900, 0)
end

local function OnUICreated(context)	
	-- Stephen
	-- initialise lib_export_triggers
	triggers.initialise_let(scripting);
end

local function ActivateCinematicCam(l)
	if (l == true) then
		out.ting("Activating cinematic cam")
		scripting.game_interface:override_ui("disable_event_panel_auto_open", true);
		CampaignUI.ToggleCinematicBorders(true)
		scripting.game_interface:take_shroud_snapshot()
		scripting.game_interface:make_neighbouring_regions_visible_in_shroud()
		scripting.game_interface:override_ui("disable_settlement_labels", true)
		scripting.game_interface:override_ui("disable_advice_changes", true)
		scripting.game_interface:steal_user_input(true)
		new_game = false
	else
		out.ting("De-activating cinematic cam")
		scripting.game_interface:override_ui("disable_event_panel_auto_open", false);
		scripting.game_interface:restore_shroud_from_snapshot()
		scripting.game_interface:override_ui("disable_settlement_labels", false)
		scripting.game_interface:override_ui("disable_advice_changes", false)
		scripting.game_interface:steal_user_input(false)
		CampaignUI.ToggleCinematicBorders(false)
	end
end

-------------------------------------------------------------------------------------------------------------------------
--
--
-- FACTION INTROS AND CAMERA PANS
--

-- TRIGGER A PAN BASED UPON A PIECE OF ADVICE TRIGGERING

local function OnAdviceIssued(context)	
	panning = true
	-- ROME
	if conditions.AdviceJustDisplayed("2139663592", context) and not CampaignUI.IsMultiplayer() and intro_advice_shown == false then
		out.ting("intro advice issued")
		ActivateCinematicCam(true)
		intro_advice_shown = true
		scripting.game_interface:scroll_camera_with_direction(8,	
													{224.0, 82.0, 0.7, -0.3},
													{183.0, 101.0, 0.7, -0.15},
													{191.0, 120.0, 0.7, 0.0},
													{216.0, 117.0, 0.85, 0.1})
		camera_pan = 100
		
	-- ARVERNI
	elseif conditions.AdviceJustDisplayed("2139663593", context) and not CampaignUI.IsMultiplayer() and intro_advice_shown == false then
		out.ting("intro advice issued")
		ActivateCinematicCam(true)
		intro_advice_shown = true
		scripting.game_interface:scroll_camera_with_direction(9,	
													{158.0, 104.0, 0.95, 0.0},
													{158.0, 104.0, 0.95, 0.5})
		camera_pan = 110
	
	-- NERVII
	elseif conditions.AdviceJustDisplayed("2139663596", context) and not CampaignUI.IsMultiplayer() and intro_advice_shown == false then
		out.ting("intro advice issued")
		ActivateCinematicCam(true)
		intro_advice_shown = true
		scripting.game_interface:scroll_camera_with_direction(10,	
													{192.0, 229.0, 0.9, 0.0},
													{192.0, 229.0, 0.75, -0.3})
		camera_pan = 120
	
	-- SUEBI
	elseif conditions.AdviceJustDisplayed("2139663602", context) and not CampaignUI.IsMultiplayer() and intro_advice_shown == false then
		out.ting("intro advice issued")
		ActivateCinematicCam(true)
		intro_advice_shown = true
		scripting.game_interface:scroll_camera_with_direction(8,	
													{269.0, 205.0, 1.05, 0.0},
													{269.0, 205.0, 1.05, -0.6})
		camera_pan = 130
		-- TARBELLI
	elseif conditions.AdviceJustDisplayed("410006", context) and not CampaignUI.IsMultiplayer() and intro_advice_shown == false then
		out.ting("intro advice issued")
		ActivateCinematicCam(true)
		intro_advice_shown = true
		scripting.game_interface:scroll_camera_with_direction(8,	
													{95.0, 60.0, 1.05, 0.0},
													{95.0, 60.0, 1.05, -0.6})
		camera_pan = 140
		-- Massilia
	elseif conditions.AdviceJustDisplayed("410007", context) and not CampaignUI.IsMultiplayer() and intro_advice_shown == false then
		out.ting("intro advice issued")
		ActivateCinematicCam(true)
		intro_advice_shown = true
		scripting.game_interface:scroll_camera_with_direction(8,	
													{195.0, 45.0, 1.05, 0.0},
													{195.0, 45.0, 1.05, -0.6})
		camera_pan = 150
		-- CANTIACI
	elseif conditions.AdviceJustDisplayed("410008", context) and not CampaignUI.IsMultiplayer() and intro_advice_shown == false then
		out.ting("intro advice issued")
		ActivateCinematicCam(true)
		intro_advice_shown = true
		scripting.game_interface:scroll_camera_with_direction(8,	
													{125.0, 250.0, 1.05, 0.0},
													{125.0, 250.0, 1.05, -0.6})
		camera_pan = 160
	end
end

-- TRIGGER A CAMERA PAN BASED UPON A PREVIOUS CAMERA PAN ENDING

local function OnCameraMoverFinished(context)
	if camera_pan ~= 0 then
		out.ting("DEBUG: OnCameraMoverFinished:"..tostring(camera_pan))
	end
	
	-- ROME
	if camera_pan == 100 then
		scripting.game_interface:scroll_camera_with_direction(2,
												{216.0, 117.0, 0.85, 0.1},
												{216.0, 117.0, 0.85, 0.0})
		camera_pan = 101
	elseif camera_pan == 101 then
		scripting.game_interface:scroll_camera_with_direction(2,
												{216.0, 117.0, 0.85, 0.0},
												{207.0, 157.0, 0.85, 0.0})
		camera_pan = 102
	elseif camera_pan == 102 then
		scripting.game_interface:scroll_camera_with_direction(3,
												{207.0, 157.0, 0.85, 0.0},
												{207.0, 157.0, 0.85, 0.2})
		camera_pan = 103
	elseif camera_pan == 103 then
		scripting.game_interface:scroll_camera_with_direction(10,
												{207.0, 157.0, 0.85, 0.2},
												{214.0, 186.0, 0.8, 0.2},
												{235.0, 174.0, 0.8, 0.2},
												{233.0, 156.0, 0.8, 0.2},
												{186.0, 134.0, 0.9, 0.2})
		camera_pan = 104
	elseif camera_pan == 104 then
		scripting.game_interface:scroll_camera_with_direction(9,
												{186.0, 134.0, 0.9, 0.2},
												{186.0, 134.0, 0.9, -0.2})
		camera_pan = 105
	elseif camera_pan == 105 then
		scripting.game_interface:scroll_camera_with_direction(9,
												{186.0, 134.0, 0.9, -0.2},
												{158.0, 106.0, 0.75, -0.2},
												{182.0, 99.0, 0.75, -0.2},
										--		{212.0, 89.0, 0.85, -0.2},
										--		{254.0, 78.0, 0.9, 0.0})
												{191.0, 119.0, 0.75, 0.0})
		camera_pan = 106
	elseif camera_pan == 106 then
		scripting.game_interface:scroll_camera_with_direction(2,
												{191.0, 119.0, 0.75, 0.0},
												{191.0, 119.0, 1.05, 0.0})
		camera_pan = 108
	elseif camera_pan == 108 then
		scripting.game_interface:scroll_camera_with_direction(1,
												{191.0, 119.0, 1.05, 0.0},
												{191.0, 119.0, 1.0501, 0.0})
		camera_pan = 109
	elseif camera_pan == 109 then
		panning = false
		ActivateCinematicCam(false)
		CampaignUI.SetCameraZoom(1.05)
		CampaignUI.SetCameraHeading(0.0)
		CampaignUI.SetCameraTargetInstant(191.0, 119.0)
		camera_pan = 0
		scripting.game_interface:add_time_trigger("gaul_intro_mission_rome", 0.01)
	
	--ARVERNI
	elseif camera_pan == 110 then
		scripting.game_interface:scroll_camera_with_direction(2,
												{158.0, 104.0, 0.95, 0.5},
												{158.0, 104.0, 0.7, 0.5})
		camera_pan = 111
	elseif camera_pan == 111 then
		scripting.game_interface:scroll_camera_with_direction(7,
												{158.0, 104.0, 0.7, 0.5},
												{151.0, 100.0, 0.7, 0.6},
												{150.0, 89.0, 0.7, 0.85},
												{163.0, 81.0, 0.7, 0.85})
		camera_pan = 112
	elseif camera_pan == 112 then
		scripting.game_interface:scroll_camera_with_direction(3,
												{163.0, 81.0, 0.7, 0.85},
												{186.0, 135.0, 0.9, 0.65})
		camera_pan = 113
	elseif camera_pan == 113 then
		scripting.game_interface:scroll_camera_with_direction(3,
												{186.0, 135.0, 0.9, 0.65},
												{186.0, 135.0, 0.9, 0.2})
		camera_pan = 114
	elseif camera_pan == 114 then
		scripting.game_interface:scroll_camera_with_direction(2,
												{186.0, 135.0, 0.9, 0.2},
												{181.0, 101.0, 0.9, 0.2})
		camera_pan = 115
	elseif camera_pan == 115 then
		scripting.game_interface:scroll_camera_with_direction(3,
												{181.0, 101.0, 0.9, 0.2},
												{181.0, 101.0, 0.9, 0.0})
		camera_pan = 116
	elseif camera_pan == 116 then
		scripting.game_interface:scroll_camera_with_direction(14,
												{181.0, 101.0, 0.9, 0.0},
												{192.0, 120.0, 0.85, 0.0},
												{199.0, 100.0, 0.85, 0.0},
												{188.0, 74.0, 0.85, 0.0},
												{163.0, 74.0, 0.85, 0.0},
												{158.0, 104.0, 0.85, 0.0})
		camera_pan = 117
	elseif camera_pan == 117 then
		scripting.game_interface:scroll_camera_with_direction(2,
												{158.0, 104.0, 0.85, 0.0},
												{158.0, 104.0, 0.95, 0.0})
		camera_pan = 118
	elseif camera_pan == 118 then
		scripting.game_interface:scroll_camera_with_direction(1,
												{158.0, 104.0, 0.95, 0.0},
												{158.0, 104.0, 0.9501, 0.0})
		camera_pan = 119
	elseif camera_pan == 119 then
		panning = false
		ActivateCinematicCam(false)
		CampaignUI.SetCameraZoom(0.95)
		CampaignUI.SetCameraHeading(0.0)
		CampaignUI.SetCameraTargetInstant(158.0, 104.0)
		camera_pan = 0
		scripting.game_interface:add_time_trigger("gaul_intro_mission_arverni", 0.01)
		
	--NERVII
	elseif camera_pan == 120 then
		scripting.game_interface:scroll_camera_with_direction(8,
												{192.0, 229.0, 0.75, -0.3},
												{159.0, 228.0, 0.75, -0.3})
		camera_pan = 121
	elseif camera_pan == 121 then
		scripting.game_interface:scroll_camera_with_direction(6,
												{159.0, 228.0, 0.75, -0.3},
												{159.0, 228.0, 0.75, 0.0})
		camera_pan = 122
	elseif camera_pan == 122 then
		scripting.game_interface:scroll_camera_with_direction(3,
												{159.0, 228.0, 0.75, 0.0},
												{197.0, 193.0, 0.75, 0.0})
		camera_pan = 123
	elseif camera_pan == 123 then
		scripting.game_interface:scroll_camera_with_direction(4,
												{197.0, 193.0, 0.75, 0.0},
												{197.0, 193.0, 0.75, 0.2})
		camera_pan = 124
	elseif camera_pan == 124 then
		scripting.game_interface:scroll_camera_with_direction(15,
												{197.0, 193.0, 0.75, 0.2},
												{193.0, 227.0, 0.7, 0.2},
												{125.0, 252.0, 0.7, 0.2},
												{98.0, 235.0, 0.7, 0.0},
												{142.0, 223.0, 0.7, 0.0},
												{192.0, 229.0, 0.9, 0.0})
		camera_pan = 128
	elseif camera_pan == 128 then
		scripting.game_interface:scroll_camera_with_direction(1,
												{192.0, 229.0, 0.9, 0.0},
												{192.0, 229.0, 0.9001, 0.0})
		camera_pan = 129
	elseif camera_pan == 129 then
		panning = false
		ActivateCinematicCam(false)
		CampaignUI.SetCameraZoom(0.9)
		CampaignUI.SetCameraHeading(0.0)
		CampaignUI.SetCameraTargetInstant(192.0, 229.0)
		camera_pan = 0
		scripting.game_interface:add_time_trigger("gaul_intro_mission_nervii", 0.01)
		
	--SUEBI
	elseif camera_pan == 130 then
		scripting.game_interface:scroll_camera_with_direction(7,
												{269.0, 205.0, 1.05, -0.6},
												{260.0, 181.0, 0.75, -0.6},
												{252.0, 148.0, 0.75, -0.6})
		camera_pan = 131
	elseif camera_pan == 131 then
		scripting.game_interface:scroll_camera_with_direction(3,
												{252.0, 148.0, 0.75, -0.6},
												{252.0, 148.0, 0.75, -0.3})
		camera_pan = 132
	elseif camera_pan == 132 then
		scripting.game_interface:scroll_camera_with_direction(4,
												{252.0, 148.0, 0.75, -0.3},
												{207.0, 158.0, 0.75, -0.6})
		camera_pan = 133
	elseif camera_pan == 133 then
		scripting.game_interface:scroll_camera_with_direction(5,
												{207.0, 158.0, 0.75, -0.6},
												{207.0, 158.0, 0.75, 0.0})
		camera_pan = 134
	elseif camera_pan == 134 then
		scripting.game_interface:scroll_camera_with_direction(12,
												{207.0, 158.0, 0.75, 0.0},
												{218.0, 192.0, 0.75, 0.0},
												{223.0, 214.0, 0.75, 0.0},
												{239.0, 202.0, 0.85, 0.0},
												{269.0, 205.0, 1.05, 0.0})
		camera_pan = 138
	elseif camera_pan == 138 then
		scripting.game_interface:scroll_camera_with_direction(1,
												{269.0, 205.0, 1.05, 0.0},
												{269.0, 205.0, 1.0501, 0.0})
		camera_pan = 139
	elseif camera_pan == 139 then
		panning = false
		ActivateCinematicCam(false)
		CampaignUI.SetCameraZoom(1.05)
		CampaignUI.SetCameraHeading(0.0)
		CampaignUI.SetCameraTargetInstant(269.0, 205.0)
		camera_pan = 0
		scripting.game_interface:add_time_trigger("gaul_intro_mission_suebi", 0.01)
	--	show_advice("test");
	--	add_infotext(1, "test_info");
	--TARBELLI
	elseif camera_pan == 140 then
		scripting.game_interface:scroll_camera_with_direction(7,
												{95.0, 60.0, 1.05, -0.6},
												{95.0, 60.0, 0.75, -0.6},
												{95.0, 60.0, 0.75, -0.6})
		camera_pan = 149
	elseif camera_pan == 149 then
		panning = false
		ActivateCinematicCam(false)
		CampaignUI.SetCameraZoom(1.05)
		CampaignUI.SetCameraHeading(0.0)
		CampaignUI.SetCameraTargetInstant(95.0, 60.0)
		camera_pan = 0
		scripting.game_interface:add_time_trigger("gaul_intro_mission_tarbelli", 0.01)
		--MASSILIA
	elseif camera_pan == 150 then
		scripting.game_interface:scroll_camera_with_direction(7,
												{195.0, 45.0, 1.05, -0.6},
												{195.0, 45.0, 0.75, -0.6},
												{195.0, 45.0, 0.75, -0.6})
		camera_pan = 159
	elseif camera_pan == 159 then
		panning = false
		ActivateCinematicCam(false)
		CampaignUI.SetCameraZoom(1.05)
		CampaignUI.SetCameraHeading(0.0)
		CampaignUI.SetCameraTargetInstant(195.0, 45.0)
		camera_pan = 0
		scripting.game_interface:add_time_trigger("gaul_intro_mission_massilia", 0.01)
		--CANTIACI
	elseif camera_pan == 160 then
		scripting.game_interface:scroll_camera_with_direction(7,
												{125.0, 250.0, 1.05, -0.6},
												{125.0, 250.0, 0.75, -0.6},
												{125.0, 250.0, 0.75, -0.6})
		camera_pan = 169
	elseif camera_pan == 169 then
		panning = false
		ActivateCinematicCam(false)
		CampaignUI.SetCameraZoom(1.05)
		CampaignUI.SetCameraHeading(0.0)
		CampaignUI.SetCameraTargetInstant(125.0, 250.0)
		camera_pan = 0
		scripting.game_interface:add_time_trigger("gaul_intro_mission_cantiaci", 0.01)
	end
		
end

-- IF CAMERA PAN GETS INTERRUPTED

local function OnAdviceDismissed(context)
	
	if camera_pan ~= 0 then
		out.ting("Advice was running, and now it's Dismissed")
		if (camera_pan == 100)  or (camera_pan == 101) or (camera_pan == 102) or (camera_pan == 103) or (camera_pan == 104) or (camera_pan == 105) or (camera_pan == 106) or (camera_pan == 107) or (camera_pan == 108) then
			camera_pan = 109
			OnCameraMoverFinished(context)
		elseif (camera_pan == 110)  or (camera_pan == 111) or (camera_pan == 112) or (camera_pan == 113) or (camera_pan == 114) or (camera_pan == 115) or (camera_pan == 116) or (camera_pan == 117) or (camera_pan == 118) then
			camera_pan = 119
			OnCameraMoverFinished(context)
		elseif (camera_pan == 120)  or (camera_pan == 121) or (camera_pan == 122) or (camera_pan == 123) or (camera_pan == 124) or (camera_pan == 125) or (camera_pan == 126) or (camera_pan == 127) or (camera_pan == 128) then
			camera_pan = 129
			OnCameraMoverFinished(context)
		elseif (camera_pan == 130)  or (camera_pan == 131) or (camera_pan == 132) or (camera_pan == 133) or (camera_pan == 134) or (camera_pan == 135) or (camera_pan == 136) or (camera_pan == 137) or (camera_pan == 138) then
			camera_pan = 139
			OnCameraMoverFinished(context)
			elseif (camera_pan == 140)  or (camera_pan == 141) or (camera_pan == 142) or (camera_pan == 143) or (camera_pan == 144) or (camera_pan == 145) or (camera_pan == 146) or (camera_pan == 147) or (camera_pan == 148) then
			camera_pan = 149
			OnCameraMoverFinished(context)
		elseif (camera_pan == 150)  or (camera_pan == 151) or (camera_pan == 152) or (camera_pan == 153) or (camera_pan == 154) or (camera_pan == 155) or (camera_pan == 156) or (camera_pan == 157) or (camera_pan == 158) then
			camera_pan = 159
			OnCameraMoverFinished(context)
		elseif (camera_pan == 160)  or (camera_pan == 161) or (camera_pan == 162) or (camera_pan == 163) or (camera_pan == 164) or (camera_pan == 165) or (camera_pan == 166) or (camera_pan == 167) or (camera_pan == 168) then
			camera_pan = 169
			OnCameraMoverFinished(context)
		end
	end
	
end


-- TURNSTART

local function IntroCameraAndObjectives(context)
	player_faction = context.string
	--TIMER: CHECK IF INTRO CAMERA PAN IS RUNNING AT THE START OF THE SP GAME. IF IT'S NOT RUNNING FOR ANY REASON, GIVE THE CHAPTER OBJECTIVES
	if conditions.TurnNumber(context) == 1 and not CampaignUI.IsMultiplayer() and conditions.FactionIsLocal(context) then
		out.ting("Turn 1, single player")
		out.ting("Playing as: ".. context.string)
		scripting.game_interface:add_time_trigger("check_intro_runs", 0.01)
	end
	-- IF THERE'S NO INTRO CAMERA, THE CAMERA STARTPOS SHOULD BE SET ON TURN 1
	
	if conditions.FactionIsLocal(context) and conditions.TurnNumber(context) == 1 then
		if conditions.FactionName("gaul_rome", context) and conditions.FactionIsHuman("gaul_rome", context) and camera_pan==0 then
			out.ting("local player is Rome and intro camera pan is not being played")
			CampaignUI.SetCameraZoom(1.05)
			CampaignUI.SetCameraHeading(0.0)
			CampaignUI.SetCameraTargetInstant(191.0, 119.0)
		elseif conditions.FactionName("gaul_arverni", context) and conditions.FactionIsHuman("gaul_arverni", context) and camera_pan==0 then
			out.ting("local player is Arverni and intro camera pan is not being played")
			CampaignUI.SetCameraZoom(0.95)
			CampaignUI.SetCameraHeading(0.0)
			CampaignUI.SetCameraTargetInstant(158.0, 104.0)
		elseif conditions.FactionName("gaul_nervii", context) and conditions.FactionIsHuman("gaul_nervii", context) and camera_pan==0 then
			out.ting("local player is Nervii and intro camera pan is not being played")
			CampaignUI.SetCameraZoom(0.9)
			CampaignUI.SetCameraHeading(0.0)
			CampaignUI.SetCameraTargetInstant(192.0, 229.0)
		elseif conditions.FactionName("gaul_suebi", context) and conditions.FactionIsHuman("gaul_suebi", context) and camera_pan==0 then
			out.ting("local player is Suebi and intro camera pan is not being played")
			CampaignUI.SetCameraZoom(1.05)
			CampaignUI.SetCameraHeading(0.0)
			CampaignUI.SetCameraTargetInstant(269.0, 205.0)
			elseif conditions.FactionName("gaul_tarbelli", context) and conditions.FactionIsHuman("gaul_tarbelli", context) and camera_pan==0 then
			out.ting("local player is Tarbelli and intro camera pan is not being played")
			CampaignUI.SetCameraZoom(1.05)
			CampaignUI.SetCameraHeading(0.0)
			CampaignUI.SetCameraTargetInstant(95.0, 60.0)
		elseif conditions.FactionName("gaul_massilia", context) and conditions.FactionIsHuman("gaul_massilia", context) and camera_pan==0 then
			out.ting("local player is Massilia and intro camera pan is not being played")
			CampaignUI.SetCameraZoom(1.05)
			CampaignUI.SetCameraHeading(0.0)
			CampaignUI.SetCameraTargetInstant(195.0, 45.0)
		elseif conditions.FactionName("gaul_cantiaci", context) and conditions.FactionIsHuman("gaul_cantiaci", context) and camera_pan==0 then
			out.ting("local player is Cantiaci and intro camera pan is not being played")
			CampaignUI.SetCameraZoom(1.05)
			CampaignUI.SetCameraHeading(0.0)
			CampaignUI.SetCameraTargetInstant(125.0, 250.0)
		end
	end
end

--IMPERIUM BASED THINGS AND ARMY SPAWNING

function position_near_enemy_units(x, y, radius, subject_faction_name)
	local faction_list = scripting.game_interface:model():world():faction_list()
	
	for i = 0, faction_list:num_items() - 1 do
		local curr_faction = faction_list:item_at(i)
		if curr_faction:name() ~= subject_faction_name then
			local char_list = curr_faction:character_list()
			
			for j = 0, char_list:num_items() - 1 do
				local curr_char = char_list:item_at(j)
				
				if distance_2D(curr_char:logical_position_x(), curr_char:logical_position_y(), x, y) < radius then
					return true
				end
			end
		end
	end
	
	return false
end

function GetPlayerFactions()
	local player_factions = {}
	local faction_list = scripting.game_interface:model():world():faction_list()
	for i = 0, faction_list:num_items() - 1 do
		local curr_faction = faction_list:item_at(i)
		if (curr_faction:is_human() == true) then
			table.insert(player_factions, curr_faction)
		end
	end
	return player_factions
end

function distance_2D(ax, ay, bx, by)
	return ((bx - ax) ^ 2 + (by - ay) ^ 2) ^ 0.5
end

local function SpawnExtraArmiesForAI(context,spawntype)	
	if spawntype == "start" then
		if conditions.FactionName("gaul_rome", context) then
			scripting.game_interface:create_force("gaul_rome", "CiG_Rom_Legionaries,CiG_Rom_Legionaries,CiG_Rom_Legionaries,CiG_Cel_Warriors,CiG_Cel_Skirm", "gaul_liguria_genua", 349, 100, "gaul_rome_AI_army_1", true);
		elseif conditions.FactionName("gaul_arverni", context) then
			scripting.game_interface:create_force("gaul_arverni", "Cel_Warriors,Cel_Warriors,Cel_Light_Horse,Cel_Skirm,Cel_Skirm", "gaul_gergovia_nemossos", 236, 147, "gaul_arverni_AI_army_1", true);
		elseif conditions.FactionName("gaul_nervii", context) then
			scripting.game_interface:create_force("gaul_nervii", "Cel_Fierce_Swords,Cel_Levy_Freemen,Cel_Light_Horse,Cel_Slingers,Cel_Skirm", "gaul_germania_inferior_bagacum", 281, 300, "gaul_nervii_AI_army_1", true);
		elseif conditions.FactionName("gaul_suebi", context) then
			scripting.game_interface:create_force("gaul_suebi", "Ger_Spear_Brothers,Ger_Club_Levy,Ger_Club_Levy,Ger_Scout_Riders,Ger_Slingers", "gaul_silva_nigra_uburzis", 397, 267, "gaul_suebi_AI_army_1", true);
		end
	else
		--further reinforcements for Rome, position validity check required
		local region_Genua = scripting.game_interface:model():world():region_manager():region_by_key("gaul_liguria_genua")
		local owner_Genua = region_Genua:owning_faction():name()
		if owner_Genua~="gaul_rome" then
			out.ting("Can't spawn Roman extra army, Genua is owned by filthy barbarians!!")
			return
		elseif position_near_enemy_units(reinforcement_pos_rome_x, reinforcement_pos_rome_y, 7, "gaul_rome") then
			out.ting("Can't spawn Roman extra army, foriegn army nearby the spawnposition")
			return
		end
		if spawntype == "first_divide" then
			scripting.game_interface:create_force("gaul_rome", "CiG_Rom_First_Cohort,CiG_Rom_Legionaries,CiG_Rom_Legionaries,CiG_Rom_Legionaries,CiG_Rom_Legionaries,CiG_Rom_Legionaries,CiG_Rom_Ballista,CiG_Rom_Ballista,CiG_Rom_Scorpion,CiG_Rom_Scorpion", "gaul_liguria_genua", reinforcement_pos_rome_x, reinforcement_pos_rome_y, "gaul_rome_AI_army_3", true);
		elseif spawntype == "second_divide" then
			scripting.game_interface:create_force("gaul_rome", "CiG_Rom_First_Cohort,CiG_Rom_Vet_Legionaries,CiG_Rom_Vet_Legionaries,CiG_Rom_Vet_Legionaries,CiG_Rom_Vet_Legionaries,CiG_Rom_Vet_Legionaries,CiG_Rom_Vet_Legionaries,CiG_Rom_Large_Onager,CiG_Rom_Large_Onager,CiG_Rom_Onager,CiG_Rom_Scorpion,CiG_Rom_Scorpion,CiG_Rom_Scorpion", "gaul_liguria_genua", reinforcement_pos_rome_x, reinforcement_pos_rome_y, "gaul_rome_AI_army_4", true);
		elseif spawntype == "early_reinforcement" then
			scripting.game_interface:create_force("gaul_rome", "CiG_Rom_Legionaries,CiG_Rom_Legionaries,CiG_Rom_Legionaries,CiG_Rom_Legionaries,CiG_Rom_Ballista,CiG_Rom_Scorpion", "gaul_liguria_genua", reinforcement_pos_rome_x, reinforcement_pos_rome_y, "gaul_rome_AI_army_2", true);
		end
	end
end

local function GetWorstStanceTowardsPlayers(faction_name)
	local players = GetPlayerFactions()
	local worst_stance = 3
	for i,value in pairs(players) do
		local stance = scripting.game_interface:model():campaign_ai():strategic_stance_between_factions(faction_name, players[i]:name())
		if stance < worst_stance then
			worst_stance = stance
		end
	end
	
	return worst_stance
end

local function GetDistanceOfClosestArmiesOfFactions(curr_faction, target_faction)
	local min_distance = 10000
	local curr_faction_military_list = curr_faction:military_force_list()
	local target_faction_military_list = target_faction:military_force_list()
	for i = 0, curr_faction_military_list:num_items() - 1 do
		if curr_faction_military_list:item_at(i):is_army() == true then
			local curr_faction_military_commander = curr_faction_military_list:item_at(i):general_character()
			for j = 0, target_faction_military_list:num_items() - 1 do
				local target_faction_military_commander = target_faction_military_list:item_at(j):general_character()
				local settlement_distance = distance_2D(curr_faction_military_commander:logical_position_x(), curr_faction_military_commander:logical_position_y(), target_faction_military_commander:logical_position_x(), target_faction_military_commander:logical_position_y())
				if (settlement_distance < min_distance) then
					min_distance = settlement_distance
				end
			end
		end
	end
	out.ting("Min distance between: "..curr_faction:name().." and "..target_faction:name()..": "..tostring(min_distance))
	return min_distance
end

local function CollectFactionsWithStanceTowardsTarget(target_faction, stance_restriction, stance_better_than, distance)
	--collect factions that have at least (or maximum) the given stance towards the target, if distance is not -1 then we filter these factions by proximity to the target faction
	local collected_factions = {}
	local faction_list = scripting.game_interface:model():world():faction_list()
	
	for i = 0, faction_list:num_items() - 1 do
		local curr_faction = faction_list:item_at(i)
		if curr_faction:is_human() == false and curr_faction:name()~="gaul_rome" and curr_faction:name()~="gaul_suebi" and curr_faction:name()~="gaul_nervii" and curr_faction:name()~="gaul_arverni" then 
			local curr_stance = scripting.game_interface:model():campaign_ai():strategic_stance_between_factions(curr_faction:name(), target_faction:name())
			local l = false
			if (stance_better_than == true and curr_stance>stance_restriction) then
				l = true
			elseif (stance_better_than == false and curr_stance<stance_restriction) then
				l = true
			end
			if (l == true) then
				out.ting(curr_faction:name().." have met the stance restrictions towards "..target_faction:name())
				--TODO check if we have distance restrictions, and if yes, check if it's fulfilled
				local is_within_distance = true
				if distance >-1 then
					local min_distance = GetDistanceOfClosestArmiesOfFactions(curr_faction, target_faction)
					if min_distance > distance then
						is_within_distance = false		--faction is farther than the specified distance
					end
				end
				if is_within_distance == true then
					out.ting("...and they're close enough to the target")
					table.insert(collected_factions, curr_faction)
				end
			end
		end
	end
	
	return collected_factions	--we return the factions that fulfil the stance and proximity requirements
end

local function MakeFactionsAttackTarget(target_faction, num_of_attackers, max_stance_towards_target, new_stance_with_attacker, distance)	
	--look for factions who hate the target (at least max_stance_towards_target)
	--take these factions and find factions they're at war with (or at least very_unfriendly towards them)
	--make them acquire the new_stance_with_attacker stance (usually neutral)
	--make them hate the target_faction
	--> this way they'll make peace with their current enemies and turn against the target

	local nearby_factions_dislike_target = CollectFactionsWithStanceTowardsTarget(target_faction, -1, false, distance)
	if (#nearby_factions_dislike_target<num_of_attackers) then
		num_of_attackers = #nearby_factions_dislike_target
	end
	
	local third_party_enemies = {}	--factions that hate the ones we need to attack the player
	for i = 1, num_of_attackers do
		third_party_enemies = CollectFactionsWithStanceTowardsTarget(nearby_factions_dislike_target[i], -1, false, -1)
		--make them like each other
		for j,value in pairs(third_party_enemies) do
			if value ~= target_faction then
				--note: we're not using the new_stance_with_attacker parameter, it's set to FRIENDLY now
				out.ting(nearby_factions_dislike_target[i]:name().." and "..value:name().." will now become neutral towards each other to stop their wars")
				scripting.game_interface:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(nearby_factions_dislike_target[i]:name(), value:name(), "CAI_STRATEGIC_STANCE_FRIENDLY")
				scripting.game_interface:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(value:name(), nearby_factions_dislike_target[i]:name(), "CAI_STRATEGIC_STANCE_FRIENDLY")
			end
		end
		--make them hate the target
		out.ting(nearby_factions_dislike_target[i]:name().." now hates "..target_faction:name())
		scripting.game_interface:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(nearby_factions_dislike_target[i]:name(), target_faction:name(), "CAI_STRATEGIC_STANCE_BITTER_ENEMIES")
	end
	
end

local function TriggerRealmDivideBasedOnImperiumLevel(context)
	local campaign_type = scripting.game_interface:model():campaign_type()
	if conditions.FactionIsHuman(context) == true and campaign_type ~= 2 and campaign_type ~= 3 then	--if it's not a versus MP
		local new_imperium = context:faction():imperium_level()
		local difficulty = scripting.game_interface:model():difficulty_level()
		out.ting("player's previous imperium: "..current_imperium)
		out.ting("player's current imperium: "..new_imperium)
		
		if new_imperium > current_imperium then
			out.ting("player's imperium level has increased")
			current_imperium = new_imperium
			local allegiance = 1	
			if context.string == "gaul_rome" or context.string == "gaul_suebi" then
				allegiance = 0 
			end
			
			if new_imperium == 4 then
				out.ting("player's imperium level triggers total realm divide")
				if allegiance == 0 then
					--make all "enemies of Rome" hate the Conqueror and like each other
					for f,name in pairs(Enemies_Of_Rome_All) do
						--Gallic factions will turn against the conqueror. Based on difficulty level, some of them might stay friendly with them
						local stance = scripting.game_interface:model():campaign_ai():strategic_stance_between_factions(name, context.string)
						
						if (stance+difficulty)<1 then	--if the stance is bad enough already, and/or the difficulty is high, the faction will turn against the player
							out.ting(name.." as an enemy of the Conqueror will now hate the Conqueror: "..context.string)
							scripting.game_interface:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(name, context.string, "CAI_STRATEGIC_STANCE_BITTER_ENEMIES")
							--block then from signing peace
							scripting.game_interface:force_diplomacy(name, context.string, "peace", false, false)
						end
						for g,subname in pairs(Enemies_Of_Rome_All) do
							if f~=g then
								out.ting(name.." will now like "..subname)
								scripting.game_interface:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(name, subname, "CAI_STRATEGIC_STANCE_BEST_FRIENDS")
							end
						end
					end
				else
					--make Rome hate others and get more troops
					for f,name in pairs(Enemies_Of_Rome_Majors) do
						out.ting("Rome will now hate "..name)
						scripting.game_interface:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction("gaul_rome", name, "CAI_STRATEGIC_STANCE_BITTER_ENEMIES")
						--block then from signing peace
						scripting.game_interface:force_diplomacy("gaul_rome", name, "peace", false, false)
					end
					--make Rome's friends turn against the Gauls unless they're best friends of Gaul
					for f,name in pairs(Enemies_Of_Rome_All) do
						if (name ~= "gaul_arverni") and (name ~= "gaul_nervii") then
							local stance_towards_rome = scripting.game_interface:model():campaign_ai():strategic_stance_between_factions(name, "gaul_rome")
							if stance_towards_rome > 0 then	--if they're at least friendly towards Rome
								local worst_stance_towards_players = GetWorstStanceTowardsPlayers(name)
								if worst_stance_towards_players < 3 then	--if not best friends with the player (or both players in MP)
									out.ting("Roman influence has turned the"..name.."against the Gauls!")
									scripting.game_interface:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(name, "gaul_arverni", "CAI_STRATEGIC_STANCE_BITTER_ENEMIES")
									scripting.game_interface:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(name, "gaul_nervii", "CAI_STRATEGIC_STANCE_BITTER_ENEMIES")
								end
							end
						end
					end
					
					--spawn more armies
					SpawnExtraArmiesForAI(context,"second_divide")
				end
			elseif new_imperium == 3 then
				out.ting("player's imperium level triggers minor realm divide")
				if allegiance == 0 then
					--pick nearby factions that already hates the cunquerors, make them become neutral with their enemies, and turn against the conqueror
					out.ting("Difficulty: "..tostring(difficulty))
					if difficulty == 1 then 
						MakeFactionsAttackTarget(context:faction(), 1, 0, 0, 50)
					elseif difficulty == 0 then 
						MakeFactionsAttackTarget(context:faction(), 2, 0, 0, 50)
					elseif difficulty == -1 then 
						MakeFactionsAttackTarget(context:faction(), 3, 1, 0, 60)
					elseif difficulty == -2 then 
						MakeFactionsAttackTarget(context:faction(), 3, 1, 0, 60)
					elseif difficulty == -3 then 
						MakeFactionsAttackTarget(context:faction(), 4, 1, 0, 60)
					end
					--make major factions dislike the Conqueror and like each other
					for f,name in pairs(Enemies_Of_Rome_Majors) do
						out.ting(name.." as a major enemy of the Conqueror will now dislike the Conqueror: "..context.string)
						scripting.game_interface:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(name, context.string, "CAI_STRATEGIC_STANCE_VERY_UNFRIENDLY")
						scripting.game_interface:force_diplomacy(name, context.string, "peace", false, false)
						for g,subname in pairs(Enemies_Of_Rome_Majors) do
							if f~=g then
								out.ting(name.." will now like "..subname)
								scripting.game_interface:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(name, subname, "CAI_STRATEGIC_STANCE_VERY_FRIENDLY")
							end
						end
					end
				else
					--make Rome hate others and gets troops
					for f,name in pairs(Enemies_Of_Rome_Majors) do
						out.ting("Rome will now dislike "..name)
						scripting.game_interface:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction("gaul_rome", name, "CAI_STRATEGIC_STANCE_VERY_UNFRIENDLY")
						scripting.game_interface:force_diplomacy("gaul_rome", name, "peace", false, false)						
					end
					--make Rome's good friends turn against the Gauls unless they're best friends of Gaul
					for f,name in pairs(Enemies_Of_Rome_All) do
						if (name ~= "gaul_arverni") and (name ~= "gaul_nervii") then
							local stance_towards_rome = scripting.game_interface:model():campaign_ai():strategic_stance_between_factions(name, "gaul_rome")
							if stance_towards_rome > 1 then	--if they're at least very friendly towards Rome
								local worst_stance_towards_players = GetWorstStanceTowardsPlayers(name)
								if worst_stance_towards_players < 2 then	--if not very friendly with the player (or both players in MP)
									out.ting("Roman influence has turned the"..name.."against the Gauls!")
									scripting.game_interface:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(name, "gaul_arverni", "CAI_STRATEGIC_STANCE_BITTER_ENEMIES")
									scripting.game_interface:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(name, "gaul_nervii", "CAI_STRATEGIC_STANCE_BITTER_ENEMIES")
								end
							end
						end
					end
					
					SpawnExtraArmiesForAI(context,"first_divide")
				end
			elseif new_imperium == 2 then
				out.ting("player's imperium level triggers initial bad relations")
				if allegiance == 0 then
					--pick a nearby faction that already hates the cunquerors, make them become neutral with their enemies, and turn against the conqueror
					MakeFactionsAttackTarget(context:faction(), 1, 0, 0, 55)		
					--make major factions dislike the Conqueror and like each other
					for f,name in pairs(Enemies_Of_Rome_Majors) do
					--	out.ting(name.." as a major enemy of the Conquerors will now slightly dislike the Conqueror: "..context.string)
					--	scripting.game_interface:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(name, context.string, "CAI_STRATEGIC_STANCE_UNFRIENDLY")
						for g,subname in pairs(Enemies_Of_Rome_Majors) do
							if f~=g then
								out.ting(name.." will now slightly like "..subname)
								scripting.game_interface:cai_strategic_stance_manager_promote_specified_stance_towards_target_faction(name, subname, "CAI_STRATEGIC_STANCE_FRIENDLY")
							end
						end
					end
				else
					--add an initial reinforcing army to Rome
					SpawnExtraArmiesForAI(context,"early_reinforcement")
				end
			end	
		end
	end
end

local function InitExcerpts(context)	--switches off the excerpts for the player's own settlements
	if conditions.FactionIsHuman(context) == true and conditions.FactionIsLocal(context) == true then
			faction_excerpts_played[context.string] = 1
	end
end

local function OnFactionTurnStart(context)
	IntroCameraAndObjectives(context)	--checks if the intro camera is running, triggers chapter objectives if not
	if conditions.TurnNumber(context) == 1 then
		InitExcerpts(context)
	    if not conditions.FactionIsHuman(context) then
			SpawnExtraArmiesForAI(context,"start")	--spawns extra armies for major AI factions
		end
	end
	TriggerRealmDivideBasedOnImperiumLevel(context)	--checks if the player's imperium level is high enough to trigger AI stance changes, and/or army spawning
end

-------------------------------------------------------------------------------------------------------------------------
--
-- TIME TRIGGERS
--

local function OnTimeTrigger(context)
-- INTRO MISSIONS, ONLY IN SP
-- WE EITHER GIVE THEM AFTER THE INTRO CAMERA PANS, OR IF THE INTRO CAMERA PAN WAS NOT TRIGGERED FOR SOME REASON

	if (context.string == "gaul_intro_mission_rome") or ((context.string == "check_intro_runs") and (intro_advice_shown == false) and (player_faction == "gaul_rome")) then
		scripting.game_interface:trigger_custom_mission("gaul_rome", "objective_cig_rome_1_primary")
		out.ting("DEBUG: Intro advice shown:"..tostring(intro_advice_shown))
	elseif (context.string == "gaul_intro_mission_arverni") or ((context.string == "check_intro_runs") and (intro_advice_shown == false) and (player_faction == "gaul_arverni")) then
		scripting.game_interface:trigger_custom_mission("gaul_arverni", "objective_cig_arverni_1_primary")
		out.ting("DEBUG: Intro advice shown:"..tostring(intro_advice_shown))
	elseif (context.string == "gaul_intro_mission_nervii") or ((context.string == "check_intro_runs") and (intro_advice_shown == false) and (player_faction == "gaul_nervii")) then
		scripting.game_interface:trigger_custom_mission("gaul_nervii", "objective_cig_nervii_1_primary")
		out.ting("DEBUG: Intro advice shown:"..tostring(intro_advice_shown))
	elseif (context.string == "gaul_intro_mission_suebi") or ((context.string == "check_intro_runs") and (intro_advice_shown == false) and (player_faction == "gaul_suebi")) then
		scripting.game_interface:trigger_custom_mission("gaul_suebi", "objective_cig_suebi_1_primary")
		out.ting("DEBUG: Intro advice shown:"..tostring(intro_advice_shown))
	end
end

-- PENDING BATTLE, AUTORESOLVER BONUSES
local function CheckIfFactionIsPlayersAlly(players, faction)
	local l = false
	for i,value in pairs(players) do
		if (l == false) and (value:allied_with(faction)==true) then 
			l = true
		end
	end
	return l
end

local function CheckIfPlayerIsNearFaction(players, force)
	--go through every army of every player and get their distance to the subject faction's army
	local l = false
	local force_general = force:general_character()
	local radius = 20
	for i,value in pairs(players) do
		local player_force_list = value:military_force_list()
		local j = 0
		while (l == false) and (j<player_force_list:num_items()) do
			local player_character = player_force_list:item_at(j):general_character()
			local distance = distance_2D(force_general:logical_position_x(), force_general:logical_position_y(), player_character:logical_position_x(), player_character:logical_position_y())
			l = (distance < radius)
			j = j+1
		--	out.ting("Testing distance between minor faction's general: "..force_general:get_surname().." "..force_general:get_forename().." and player faction's general: "..player_character:get_surname().." "..player_character:get_forename())
		--	out.ting("Distance: "..tostring(distance))
		end
	end
	
	return l
end

local function OnPendingBattle(context)
	--IF A MAJOR AI FACTION FIGHTS AGAINST A MINOR AI, WE APPLY AUTORESOLVER BONUSES TO THE MAJOR (unless the minor faction is a military ally of the player, or it's nearby one of the player's armies/navies
--	out.ting("pending battle between:"..context:pending_battle():attacker():faction():name().." v "..context:pending_battle():defender():faction():name())
	local attacking_faction = context:pending_battle():attacker():faction()
	local defending_faction = context:pending_battle():defender():faction()
	local attacker_is_major = false
	local defender_is_major = false
	
	if attacking_faction:is_human() == false and defending_faction:is_human() == false then
		if attacking_faction:name() == "gaul_rome" or attacking_faction:name() == "gaul_arverni" or attacking_faction:name() == "gaul_nervii" or attacking_faction:name() == "gaul_suebi" then 
			attacker_is_major = true 
--			out.ting("attacker is major")
		end
		if defending_faction:name() == "gaul_rome" or defending_faction:name() == "gaul_arverni" or defending_faction:name() == "gaul_nervii" or defending_faction:name() == "gaul_suebi" then 
			defender_is_major = true 
--			out.ting("defender is major")
		end
		
		if attacker_is_major == true and defender_is_major == false then
			--out.ting("major attacker v minor defender")
			local player_factions = GetPlayerFactions()	--get the player faction (or factions in multiplayer)
			local ally_involved = CheckIfFactionIsPlayersAlly(player_factions, defending_faction)	--if the minor faction is the player's military ally, we don't give bonuses to the major faction
			--out.ting("Minor faction is player's ally: "..tostring(ally_involved))
			if ally_involved == false then
				local player_nearby = CheckIfPlayerIsNearFaction(player_factions, context:pending_battle():defender():military_force())	--if any of the player's armies/navies is close to the battle, the major faction won't receive the bonuses
				--out.ting("Minor faction is close to player: "..tostring(player_nearby))
				if player_nearby == false then
					scripting.game_interface:modify_next_autoresolve_battle(5, 0.1, 0.1, 5, false)	--attacker win chance, defender win chance, attacker losses modifier, defender losses modifier
				end
			end
		elseif attacker_is_major == false and defender_is_major == true then
			--out.ting("minor attacker v major defender")
			local player_factions = GetPlayerFactions()
			local ally_involved = CheckIfFactionIsPlayersAlly(player_factions, attacking_faction)	--if the minor faction is the player's military ally, we don't give bonuses to the major faction
			--out.ting("Minor faction is player's ally: "..tostring(ally_involved))
			if ally_involved == false then
				local player_nearby = CheckIfPlayerIsNearFaction(player_factions, context:pending_battle():attacker():military_force())	--if any of the player's armies/navies is close to the battle, the major faction won't receive the bonuses
				--out.ting("Minor faction is close to player: "..tostring(player_nearby))
				if player_nearby == false then
					scripting.game_interface:modify_next_autoresolve_battle(0.1, 5, 5, 0.1, false)
				end
			end
		elseif attacker_is_major == true and defender_is_major == true then
			--if two major factions clash and one of them is Rome, Rome gets a bonus
			if attacking_faction:name()=="gaul_rome" then
				scripting.game_interface:modify_next_autoresolve_battle(0.7, 0.3, 0, 2, false)
			elseif defending_faction:name()=="gaul_rome" then
				scripting.game_interface:modify_next_autoresolve_battle(0.3, 0.7, 2, 0, false)
			end
		end
	else
--		out.ting("attacker and/or defender is player")
	end
end

-- EXCERPTS SCRIPTING
local function OnFactionEncountersOtherFaction(context)
	
end

local function OnCharacterSelected(context)
	
end

local function OnSettlementSelected(context)
	if not CampaignUI.IsMultiplayer() then
		local owning_faction = context:garrison_residence():faction()

		for i,v in pairs(faction_excerpts_played) do
			if i==owning_faction:name() then
				if v == 0 then 
					faction_excerpts_played[i] = 1
					show_advice("CiG.Excerpt.Faction."..owning_faction:name());
					add_infotext(1, "CiG.Excerpt.Faction."..owning_faction:name()..".Info");
				--	set_objective("Rom.Pro.Camp2.Objective_04");
				--	add_callback(function() set_objective("Rom.Pro.Camp2.Objective_08") end, 1);
				end
			end
        end
	end
end



-------------------------------------------------------------------------------------------------------------------------
--
-- SET UP THE ESCAPE KEY TO CIRCUMVENT PLAYER INTERACTION LOCKING
--

function OnKeyPressed(key, is_key_up)
	if is_key_up == true then
		out.ting("Key pressed up")
		if key == "ESCAPE" or key == "SPACE" then
			out.ting("Escape or space pressed")
			if camera_pan ~= 0 and is_exiting_intro == false then		
				is_exiting_intro = true
				out.ting("Escape or space pressed, Cancelling the advice")
				scripting.game_interface:stop_camera()
				scripting.game_interface:dismiss_advice()				
			end
		end
	end
end

--
-- IF CLICKING ON THE CLOSE ADVISOR BUTTON DURING THE PAN, THEN END WITHOUT LOCKING THE CAMERA
--

local function OnComponentLClickUp(context)
	if conditions.IsComponentType("button_close", context) and (camera_pan>0) and is_exiting_intro == false then
		is_exiting_intro = true
		out.ting("Cancelling the advice")
		scripting.game_interface:stop_camera()
		ActivateCinematicCam(false)		--if I don't call this, the game will freeze if someone presses the X button and then hits ESC. No idea why, and this solution shouldn't work, but it works. Magic...
	end
end


--------------------------------------------------------------------------------------------------------------------
-- Add event callbacks
-- For a list of all events supported create a "documentation" directory in your empire directory, run a debug build of the game and see
-- the events.txt file
--------------------------------------------------------------------------------------------------------------------

scripting.AddEventCallBack("NewCampaignStarted", OnNewCampaignStarted)
scripting.AddEventCallBack("UICreated", OnUICreated)

scripting.AddEventCallBack("AdviceIssued", OnAdviceIssued)
scripting.AddEventCallBack("AdviceDismissed", OnAdviceDismissed)
scripting.AddEventCallBack("CameraMoverFinished", OnCameraMoverFinished)
scripting.AddEventCallBack("FactionTurnStart", OnFactionTurnStart)
scripting.AddEventCallBack("ComponentLClickUp", OnComponentLClickUp)

scripting.AddEventCallBack("TimeTrigger", OnTimeTrigger)
scripting.AddEventCallBack("PendingBattle", OnPendingBattle)
scripting.AddEventCallBack("FactionEncountersOtherFaction", OnFactionEncountersOtherFaction)
scripting.AddEventCallBack("CharacterSelected", OnCharacterSelected)
scripting.AddEventCallBack("SettlementSelected", OnSettlementSelected)

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
-- Selea, Litharion
--------------------------------------------------------------------------------------------------------------------

local reforms = require "lua_scripts.reforms";
local army_caps = require "lua_scripts.army_caps";
local PublicOrder  = require "lua_scripts.PublicOrder";
local money = require "lua_scripts.money";
local changeCapital = require "lua_scripts.changeCapital";
local auto_resolve  = require "lua_scripts.auto_resolve_bonus";
