import os
import subprocess


def convert_xml_to_ui(xml_dir, tool_path):
    """
    Converts all .xml files in the specified directory using the given tool.

    Args:
        xml_dir (str): The directory containing the .xml files.
        tool_path (str): The path to the `xml2ui` binary tool.
    """
    if not os.path.exists(tool_path):
        print(f"Error: Tool '{tool_path}' does not exist.")
        return

    if not os.path.isdir(xml_dir):
        print(f"Error: Directory '{xml_dir}' does not exist.")
        return

    # Iterate recursively over all .xml files in the directory and its subdirectories
    for root, dirs, files in os.walk(xml_dir):
        for file_name in files:
            if file_name.endswith(".xml"):
                input_file = os.path.join(root, file_name)
                output_file = os.path.join(root, file_name.rsplit(".xml", 1)[0])

                # Execute the xml2ui tool
                print(f"Processing: {input_file} -> {output_file}")
                try:
                    subprocess.run(["ruby", tool_path, input_file, output_file], check=True)
                    print(f"Successfully converted: {file_name}")
                except subprocess.CalledProcessError as e:
                    print(f"Error processing {file_name}: {e}")
                except Exception as e:
                    print(f"Unexpected error: {e}")


if __name__ == "__main__":
    # Define paths
    ui_dir = r"c:/xampp/htdocs/etwng-master/ui"
    xml2ui_tool = os.path.join(ui_dir, "bin", "xml2ui")
    ui_files_dir = os.path.join(os.getcwd(), "mod/ui")

    # Run the conversion
    convert_xml_to_ui(ui_files_dir, xml2ui_tool)
