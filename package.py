import shutil
import sys
import os

# Get the directory path of the current Python file
current_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(current_dir)

# version
name="CooldownSync"
major=1
minor=0
version=""

# read in version.txt
file_name = "version.txt"
try:
    with open(file_name, "r") as file:
        lines = file.readlines()

    # parse out major/minor
    for line in lines:
        if line.startswith("MAJOR="):
            major = int(line.split("=")[1])
        elif line.startswith("MINOR="):
            minor = int(line.split("=")[1])
except:
    print('Could not read version from file')

# increment minor and update version string
minor = minor + 1
version = f"{major}.{minor}"

# write back to file
with open(file_name, "w") as file:
    file.write(f"MAJOR={major}\n")
    file.write(f"MINOR={minor}\n")

# update version in the config panel
file_name = "CooldownSync/config_panels.lua"

# Read the contents of the file
try:
    with open(file_name, "r") as file:
        file_contents = file.read()

    # replace version
    modified_contents = file_contents.replace("<VERSION>", version)

    # Write the modified contents back to the file
    with open(file_name, "w") as file:
        file.write(modified_contents)
except:
    print('Failed to update UI file')
    
zip_file = f"{name}_{version}_Release"
shutil.make_archive(zip_file, 'zip', base_dir=name)