import os
import shutil

import chardet

def add_start_end_to_lua_files(directory, start_var, end_var):
  """
  Iterates through all files in the given directory (recursively) and
  adds the specified start and end variables to the beginning and end
  of each .lua file.

  Args:
    directory: The path to the directory to search.
    start_var: The string to add at the beginning of each .lua file.
    end_var: The string to add at the end of each .lua file.
  """
  for root, dirs, files in os.walk(directory):
    for file in files:
      if file.endswith(".lua"):
        file_path = os.path.join(root, file)
        try:
          with open(file_path, "rb") as f:
              rawdata = f.read()
              encoding = chardet.detect(rawdata)['encoding']
              if encoding is None:
                  encoding = 'utf-8'  # Default to UTF-8 if detection fails
              with open(file_path, "r+") as f:
                  content = f.read()
                  f.seek(0)  # Move the cursor to the beginning of the file
                  f.write(f"{start_var.format(file_path[len(directory)+1:].replace("\\", "/"))}\n{content}\n{end_var}")
        except Exception as e:
          print(f"Error processing file {file_path}: {e}")

if __name__ == "__main__":
  shutil.rmtree("./mod") ; shutil.copytree("./rome2_scripts", "./mod")
  directory_to_process = "mod"
  start_string = """
local function ASDwrite_log(path, text)
  local logfile, err = io.open(path, "a")
  if not logfile then
    error("Failed to open log file: " .. (err or "Unknown error"))
  end

  logfile:write(text .. "\\n")
  logfile:close()
end
ASDwrite_log("debugging.txt", "{}")
""".lstrip()
  end_string = ""
  add_start_end_to_lua_files(directory_to_process, start_string, end_string)
  shutil.copy("./lib_logging.lua", "./mod/script/_lib/lib_logging.lua")