import shutil
import sys
import os
from distutils.dir_util import copy_tree

version = "1.1"
addon_name = "CooldownSync"
staging_folder_name = "build"

def create_staging_folder(folder_name):
    if not os.path.exists(folder_name):
        # Create the new folder
        os.mkdir(folder_name)
        print(f"Folder '{folder_name}' created successfully.")
    else:
        print(f"Folder '{folder_name}' already exists.")

def cleanup_staging_folder(folder_name):
    shutil.rmtree(folder_name)

def copy_to_staging_folder(addon_name, folder_name):
    outdir = os.path.join(folder_name, addon_name)
    copy_tree(addon_name, outdir)

def update_version(addon_name, folder_name, version):
    
    # Read the contents of the file
    try:
        file_name = os.path.join(addon_name, addon_name, "config_panels.lua")
        with open(file_name, "r") as file:
            file_contents = file.read()

        # replace version
        modified_contents = file_contents.replace("<VERSION>", version)

        # Write the modified contents back to the file
        with open(file_name, "w") as file:
            file.write(modified_contents)
    except:
        print('failed to update version')

def main():

    try:

        # ensure local path is set
        current_dir = os.path.dirname(os.path.abspath(__file__))
        os.chdir(current_dir)

        # copy files to staging folder
        create_staging_folder(staging_folder_name)
        copy_to_staging_folder(addon_name, staging_folder_name)

        # remove existing zip file
        zip_file = f"{addon_name}_{version}_Release"
        os.remove(zip_file)

        # generate new zip file
        shutil.make_archive(zip_file, 'zip', base_dir=os.path.join(staging_folder_name, addon_name))
    except:
        pass
    finally:
        cleanup_staging_folder(staging_folder_name)

if __name__ == "__main__":
    main()

