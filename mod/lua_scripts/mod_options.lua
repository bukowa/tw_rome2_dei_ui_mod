-- Importing necessary libraries for logging and options management
local lib_logging = require "script._lib.lib_logging"
local lib_options = require "script._lib.lib_mod_options"

-- Importing the scripting module for event handling
local scripting = require "lua_scripts.EpisodicScripting"

-- Initialize global variable for the root UI component (m_root is nil by default)
m_root = nil

-- Initialize logger with a file and log level
local logger = lib_logging.new_logger("log_lib_header.txt", "DEBUG")

-- Load and manage mod options
local options = lib_options.new_options()

-- Function to initialize the frontend UI and handle options
local function start_frontend()
    -- Load options from a configuration file
    options:load()
    
    
    local function logit(context)
        local c = UIComponent(context.component)
        logger:debug("compontent: " .. context.string .. " state " .. c:CurrentState())
    end
    
    scripting.AddEventCallBack("ComponentMouseOn", logit)
    
    -- Helper function to load checkbox states based on saved options
    local function OptCheckboxLoad(component, option_key)
        local value = options:get_value(option_key)
        if value == "on" then
            component:SetState("selected")
        else
            component:SetState("active")
        end
    end

    -- Helper function to save checkbox states based on user interaction
    local function OptCheckboxSave(component, option_key)
        -- Get the current state of the checkbox
        state = component:CurrentState()

        -- Update the options based on the checkbox state
        if component:CurrentState() == "selected" then
            options:set_value(option_key, "on")
        else
            options:set_value(option_key, "off")
        end
        
        -- Save the updated options to the configuration file
        options:save()
    end

    -- Track whether mod options have been loaded
    local loaded = false
    
    -- Function to load mod options if they haven't been loaded yet
    local function LoadModOptions(context)
        if loaded == true then return end
        -- checkbox_dei_population_script
        local population_system = m_root:Find("checkbox_dei_population_script")
        if population_system then
            loaded = true
            OptCheckboxLoad(UIComponent(population_system), "population_system")
        end
        
        -- checkbox_dei_supply_script
        local supply_system = m_root:Find("checkbox_dei_supply_script")
        if supply_system then
            loaded = true
            OptCheckboxLoad(UIComponent(supply_system), "supply_system")
        end
    end
    
    -- Function to save mod options when user clicks the "OK" button
    local function SaveModOptions(context)
    
        -- checkbox_dei_population_script
        local population_system = m_root:Find("checkbox_dei_population_script")
        if population_system then
            OptCheckboxSave(UIComponent(population_system), "population_system")
        end
        
        -- checkbox_dei_supply_script
        local supply_system = m_root:Find("checkbox_dei_supply_script")
        if supply_system then
            OptCheckboxSave(UIComponent(supply_system), "supply_system")
        end
    end

    -- Event handler for left mouse button click up event
    local function OnComponentLClickUp(context)
        local component = UIComponent(context.component)

        -- Save mod options if the "OK" button was clicked
        if context.string == "button_ok" then
            SaveModOptions(context)
            loaded = false
        end
    end

    -- Register event handlers for UI component interactions
    scripting.AddEventCallBack("ComponentMouseOn", function(context) logger:pcall(LoadModOptions, context) end)
    scripting.AddEventCallBack("ComponentLClickUp", function(context) logger:pcall(OnComponentLClickUp, context) end)
end

-- Return the function to start the frontend with logging support
return {
    start_frontend = function() logger:pcall(start_frontend) end,
}
