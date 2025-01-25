from pathlib import Path
import subprocess
import sys

# Paths
app = Path("C:/xampp/htdocs/etwng-master/ui/bin/ui2xml")
work_dir = Path("C:/xampp/htdocs/etwng-master/ui")
iterate_dir = Path("C:/xampp/htdocs/twwh2_ctm-master/game/ui")
output_dir = Path.cwd() / 'uiout'  # Create output directory in the current working directory

# Validate required paths
if not app.exists() or not app.is_file():
    print(f"Error: The application '{app}' does not exist or is not a file.")
    sys.exit(1)

if not work_dir.exists() or not work_dir.is_dir():
    print(f"Error: The working directory '{work_dir}' does not exist or is not a directory.")
    sys.exit(1)

if not iterate_dir.exists() or not iterate_dir.is_dir():
    print(f"Error: The input directory '{iterate_dir}' does not exist or is not a directory.")
    sys.exit(1)

try:
    # Ensure the output directory exists
    output_dir.mkdir(parents=True, exist_ok=True)

    # Find all files in iterate_dir recursively
    files = [f for f in iterate_dir.rglob('*') if f.is_file() and not f.suffix]
    if not files:
        print(f"No files found in {iterate_dir} without extensions.")
        sys.exit(0)

    print(f"Found {len(files)} files to process.")

    for file in files:
        try:
            # Define output path in 'uiout' directory with .xml extension
            relative_path = file.relative_to(iterate_dir)
            output_file = output_dir / relative_path.parent / f"{file.stem}.xml"

            # Ensure the output subdirectory structure exists
            output_file.parent.mkdir(parents=True, exist_ok=True)

            print(f"Processing file: {file}")
            print(f"Output will be saved to: {output_file}")

            # Prepare the command to execute
            command = ["ruby", str(app), str(file), str(output_file)]
            print(f"Executing command: {command}")

            # Execute the app with the file and output file as arguments
            result = subprocess.run(
                command, cwd=work_dir, check=True, text=True, capture_output=True, shell=True
            )

            # Log success
            print(f"Successfully processed: {file} -> {output_file}")

            # Check the generated file for error messages
            if output_file.exists():
                with open(output_file, 'r', encoding='utf-8') as f:
                    first_lines = f.readlines()[:10]  # Read the first 10 lines for any error message
                    for line in first_lines:
                        if "<error msg=" in line:
                            print(f"Error found in output file {output_file}, deleting it.")
                            output_file.unlink()  # Delete the file
                            break  # Exit once an error is found

        except subprocess.CalledProcessError as e:
            # Handle errors in subprocess execution
            print(f"Error processing {file}: {e}")
            print(f"Subprocess Output: {e.stdout}")
            print(f"Subprocess Error: {e.stderr}")
        except Exception as e:
            # Handle any other file-specific errors
            print(f"Unexpected error with {file}: {e}")

except Exception as e:
    print(f"An unexpected error occurred: {e}")
