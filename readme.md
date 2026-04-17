Changes Made to https://github.com/shufps/ESP-Miner-NerdQAxePlus/tree/develop (ESP-Miner-NerdQAxePlus)

ESP-Miner-Nerds (originally forked from ESP-Miner-NerdQAxePlus) has been modified to integrate 3.5" display support and upstream sync automation. Below is a comprehensive list of all changes applied, based on the integration from https://github.com/luclucs/qaxeplus2-large-screen (qaxeplus2-large-screen) and subsequent development tasks.


1. Display and UI Adaptations (qaxeplus2-large-screen)

displayDriver.h:
Updated LCD resolution from 320x170 to 480x320.
Added scaling defines: TDISPLAYS3_SCALE_FACTOR=3.0f, TDISPLAYS3_ZOOM_LEVEL calculation.
Modified panel mirroring and gap settings for the larger display.

displayDriver.cpp:
Adjusted panel configuration for the new resolution.

ui.cpp:
Added scaling functions: scale_x(), scale_y(), zoom_img() for coordinate adjustments.
Updated UI elements to use scaled coordinates.

ui.h:
Added declaration for ui_font_DigitalNumbers40.
main/displays/images/themes/NerdQaxePlus2/:
Replaced all PNG assets with 480x320 resized versions (e.g., backgrounds, icons, fonts).

CMakeLists.txt:
Added board selection preprocessor defines (e.g., CONFIG_BOARD_NERDOCTAXEGAMMA).
Included font references and board-specific compilation flags.

Kconfig.projbuild:
Added board choice menu with default NERDOCTAXEGAMMA.

tasks.json (Docker build task):
Added BOARD=NERDOCTAXEGAMMA environment variable.


2. Build and Configuration Changes
Configured build for NerdQaxePlus2 board (later switched to NerdOctaxeGamma).
Updated sdkconfig.defaults and sdkconfig.ci for ESP32-S3 compatibility.
Used Docker-based build environment (esp-idf-builder) for reproducible firmware generation.
Firmware builds successfully (~3.1MB binary).


3. Git Repository Setup and Branch Management
Initialized Git repository in the workspace.
Set remote origin to https://github.com/RedlineGT/ESP-Miner-Nerds.git.
Created branch Official_Bleeding_Edge_3.5Screen with all adaptations.
Committed changes in two main commits:
Initial commit: ESP-Miner with NerdOctaxeGamma board + 3.5" display adaptation.
Latest commit: Added upstream sync automation scripts and documentation.
Force-pushed the branch to remote, overwriting existing remote branch history.


4. Automation and Documentation Scripts
rebase_upstream.sh (executable script):
Automates Git rebase onto upstream Official_Bleeding_Edge branch.
Includes conflict detection and resolution prompts.

CONFLICT_RESOLUTION.md:
Comprehensive guide for handling merge conflicts during upstream sync.
Covers strategies for display-related files, build configs, and asset updates.

QUICK_REFERENCE.md:
Cheat sheet for sync workflow, commands, and troubleshooting.
Includes steps for rebasing, pushing, and maintaining adaptations.


5. Other Modifications
Resolved build issues: Added missing BOARD environment variable, manually cloned libsecp256k1 submodule.
Updated repository references: Changed upstream from original to https://github.com/RedlineGT/ESP-Miner-Nerds/tree/Official_Bleeding_Edge.
No changes to core mining logic, stratum protocols, or hardware drivers beyond display/UI scaling.


Key Outcomes
Display Support: Firmware now supports 3.5" screens with proper scaling (3x factor) for NerdQaxePlus2/NerdOctaxeGamma boards.
Maintainability: Automation scripts enable easy syncing with upstream updates while preserving customizations.

Repository State: Branch Official_Bleeding_Edge_3.5Screen is live on GitHub with all changes committed and pushed.
All changes are focused on display adaptation and maintenance automation, with no alterations to the core ESP-Miner functionality.
