-- Import the table persistence module
local persistence = require "script._lib.lib_table_persistence"

-- Importing the scripting module for event handling
local scripting = require "lua_scripts.EpisodicScripting"

-- Default options
local default_options = {
    supply_system = "on",  -- Default state for supply system
    population_system = "on",  -- Default state for population system
}

-- Default file path
local default_file_path = "dei_options.txt"

-- Deep copy function (simplified for common use cases)
local function deep_copy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = (type(v) == "table") and deep_copy(v) or v
    end
    return copy
end

-- Options module
local Options = {}
Options.__index = Options

-- Constructor for creating a new Options instance
function Options.new_options(file_path, custom_default_options)
    local self = setmetatable({}, Options)

    self.file_path = file_path or default_file_path
    self.options = deep_copy(custom_default_options or default_options)

    return self
end

-- Load options from the file
function Options:load()
    local success, loaded_options = pcall(function()
        return persistence.load(self.file_path)
    end)

    if success and type(loaded_options) == "table" then
        self.options = loaded_options
    else
        -- Fallback to default options if loading fails or file is invalid
        self.options = deep_copy(default_options)
    end
end

-- Save options to the file
function Options:save()
    local success, err = pcall(function()
        persistence.save(self.options, self.file_path)
    end)

    if not success then
        error("Failed to save options to file: " .. (err or "unknown error"))
    end
end

local PREFIX = "mod_options_" -- Unique prefix for all saved settings

-- Method to save all settings to the saved state
function Options:save_named_values(context)
    for key, value in pairs(self.options) do
        -- Save each setting dynamically with a unique prefix
        local prefixed_key = PREFIX .. key
        scripting.game_interface:save_named_value(prefixed_key, value, context)
    end
end

-- Method to load all settings from the saved state
function Options:load_named_values(context)
    for key, _ in pairs(self.options) do
        -- Load each setting dynamically with a unique prefix
        local prefixed_key = PREFIX .. key
        self.options[key] = scripting.game_interface:load_named_value(prefixed_key, self.options[key], context)
    end
end


-- Set an option value
function Options:set_value(key, value)
    if self.options[key] ~= nil then
        self.options[key] = value
    else
        error("Invalid option key: " .. tostring(key))
    end
end

-- Get an option value
function Options:get_value(key)
    return self.options[key]
end

-- Module return
return Options
