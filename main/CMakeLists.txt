idf_component_register(
SRCS
    "main.cpp"
    "nvs_config.cpp"
    "system.cpp"
    "sntp.cpp"
    "utils.cpp"
    "boards/board.cpp"
    "boards/nerdaxe.cpp"
    "boards/nerdaxegamma.cpp"
    "boards/nerdqaxeplus.cpp"
    "boards/nerdqaxeplus2.cpp"
    "boards/nerdoctaxeplus.cpp"
    "boards/nerdoctaxegamma.cpp"
    "boards/nerdhaxegamma.cpp"
    "boards/nerdqx.cpp"
    "boards/nerdeko.cpp"
    "boards/drivers/EMC2302.cpp"
    "boards/drivers/TMP1075.cpp"
    "boards/drivers/TPS53647.cpp"
    "boards/drivers/TPS53667.cpp"
    "boards/drivers/nerdaxe/DS4432U.cpp"
    "boards/drivers/nerdaxe/INA260.cpp"
    "boards/drivers/nerdaxe/EMC2101.cpp"
    "boards/drivers/nerdaxe/TPS546.cpp"
    "boards/drivers/nerdaxe/adc.cpp"
    "boards/drivers/i2c_master.cpp"
    "boards/drivers/tmp451_mux.cpp"
    "history.cpp"
    "discord.cpp"
    "fan_controller.cpp"
    "./pid/PID_v1_bc.cpp"
    "./pid/pid_timer.cpp"
    "./http_server/http_server.cpp"
    "./http_server/http_cors.cpp"
    "./http_server/http_utils.cpp"
    "./http_server/http_websocket.cpp"
    "./http_server/handler_influx.cpp"
    "./http_server/handler_alert.cpp"
    "./http_server/handler_swarm.cpp"
    "./http_server/handler_system.cpp"
    "./http_server/handler_ota.cpp"
    "./http_server/handler_otp.cpp"
    "./http_server/handler_restart.cpp"
    "./http_server/handler_shutdown.cpp"
    "./http_server/handler_file.cpp"
    "./http_server/handler_ota_factory.cpp"
    "./self_test/self_test.cpp"
    "./stratum/stratum_api.cpp"
    "./stratum/stratum_transport.cpp"
    "./stratum/stratum_config.cpp"
    "./stratum/stratum_task.cpp"
    "./stratum/stratum_manager.cpp"
    "./stratum/stratum_manager_fallback.cpp"
    "./stratum/stratum_manager_dual_pool.cpp"
    "./stratum/stratum_transport_noise.cpp"
    "./stratum/stratum_task_v2.cpp"
    "./tasks/create_jobs_task.cpp"
    "./tasks/create_jobs_sv2.cpp"
    "./tasks/mining_info_v2.cpp"
    "./tasks/asic_result_task.cpp"
    "./tasks/influx_task.cpp"
    "./tasks/ping_task.cpp"
    "./tasks/power_management_task.cpp"
    "./tasks/hashrate_monitor_task.cpp"
    "./tasks/apis_task.cpp"
    "./tasks/wifi_health.cpp"
    "./displays/displayDriver.cpp"
    "./displays/ui.cpp"
    "./displays/ui_ipc.cpp"
    "./displays/button.cpp"
    "./displays/ui_helpers.cpp"
    "./displays/images/ui_font_DigitalNumbers16.c"
    "./displays/images/ui_font_DigitalNumbers28.c"
    "./displays/images/ui_font_DigitalNumbers40.c"
    "./displays/images/ui_font_OpenSansBold13.c"
    "./displays/images/ui_font_OpenSansBold14.c"
    "./displays/images/ui_font_OpenSansBold24.c"
    "./displays/images/ui_font_OpenSansBold45.c"
    "./displays/images/ui_font_vt323_21.c"
    "./displays/images/ui_font_vt323_35.c"
    "./displays/images/ui_img_found_block_png.c"
    "./displays/images/ui_img_safe_png.c"
    "./displays/images/themes/themes.c"
    "./otp/otp.cpp"
    "./otp/qrcodegen.cpp"



INCLUDE_DIRS
    "."
    "tasks"
    "http_server"
    "displays"
    "displays/images"
    "boards"
    "boards/drivers"
    "../components/connect/include"
    "../components/dns_server/include"
    "../components/bm1397/include"
    "../components/influx/include"

REQUIRES
    "app_update"
    "driver"
    "esp_adc"
    "esp_app_format"
    "esp_event"
    "esp_http_server"
    "esp_http_client"
    "esp_https_ota"
    "esp_netif"
    "esp_timer"
    "esp_wifi"
    "esp_lcd"
    "esp_psram"
    "arduinojson"
    "tcp_transport"
    "nvs_flash"
    "spiffs"
    "vfs"
    "lvgl"
    "lwip"
    "esp-tls"
    "stratum_v2"
    "libsecp256k1"

)

# Board selection defines
# Suppress LVGL enum conversion warnings that don't affect functionality (C++ only)
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    target_compile_options(${COMPONENT_TARGET} PRIVATE $<$<COMPILE_LANGUAGE:CXX>:-Wno-deprecated-enum-enum-conversion>)
endif()

# Board selection defines and image conversion
if(CONFIG_BOARD_NERDQAXEPLUS)
    target_compile_definitions(${COMPONENT_TARGET} PUBLIC NERDQAXEPLUS)
    set(BOARD_THEME_NAME "NerdQaxePlus")
endif()
if(CONFIG_BOARD_NERDQAXEPLUS2)
    target_compile_definitions(${COMPONENT_TARGET} PUBLIC NERDQAXEPLUS2)
    set(BOARD_THEME_NAME "NerdQaxePlus2")
endif()
if(CONFIG_BOARD_NERDOCTAXEPLUS)
    target_compile_definitions(${COMPONENT_TARGET} PUBLIC NERDOCTAXEPLUS)
    set(BOARD_THEME_NAME "NerdOctaxePlus")
endif()
if(CONFIG_BOARD_NERDAXE)
    target_compile_definitions(${COMPONENT_TARGET} PUBLIC NERDAXE)
    set(BOARD_THEME_NAME "NerdAxe")
endif()
if(CONFIG_BOARD_NERDOCTAXEGAMMA)
    target_compile_definitions(${COMPONENT_TARGET} PUBLIC NERDOCTAXEGAMMA)
    set(BOARD_THEME_NAME "NerdOctaxeGamma")
endif()
if(CONFIG_BOARD_NERDAXEGAMMA)
    target_compile_definitions(${COMPONENT_TARGET} PUBLIC NERDAXEGAMMA)
    set(BOARD_THEME_NAME "NerdAxeGamma")
endif()
if(CONFIG_BOARD_NERDHAXEGAMMA)
    target_compile_definitions(${COMPONENT_TARGET} PUBLIC NERDHAXEGAMMA)
    set(BOARD_THEME_NAME "NerdHaxeGamma")
endif()
if(CONFIG_BOARD_NERDEKO)
    target_compile_definitions(${COMPONENT_TARGET} PUBLIC NERDEKO)
    set(BOARD_THEME_NAME "NerdEko")
endif()
if(CONFIG_BOARD_NERDQX)
    target_compile_definitions(${COMPONENT_TARGET} PUBLIC NERDQX)
    set(BOARD_THEME_NAME "NerdQX")
endif()

# Add custom command to run image conversion script before compilation
if(DEFINED BOARD_THEME_NAME)
    set(CONVERT_SCRIPT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/displays/images/themes/${BOARD_THEME_NAME}")
    set(CONVERT_SCRIPT "${CONVERT_SCRIPT_DIR}/convert.sh")
    
    if(EXISTS "${CONVERT_SCRIPT}")
        add_custom_target(convert_images
            COMMAND bash "${CONVERT_SCRIPT}"
            WORKING_DIRECTORY "${CONVERT_SCRIPT_DIR}"
            COMMENT "Converting images for ${BOARD_THEME_NAME}..."
            VERBATIM
        )
        # Make the component depend on image conversion
        add_dependencies(${COMPONENT_TARGET} convert_images)
        message(STATUS "Image conversion enabled for board: ${BOARD_THEME_NAME}")
    else()
        message(WARNING "Convert script not found at ${CONVERT_SCRIPT}")
    endif()
endif()


set(WEB_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/http_server/axe-os")

option(BUILD_WEB "Enable web UI build" ON)

if(BUILD_WEB)
    message(STATUS "Web UI build enabled")

    if("$ENV{GITHUB_ACTIONS}" STREQUAL "true")
        spiffs_create_partition_image(www ${WEB_SRC_DIR}/dist/axe-os FLASH_IN_PROJECT)
    else()
        find_program(NPM_EXECUTABLE npm)
        if(NOT NPM_EXECUTABLE AND NOT EXISTS ${WEB_SRC_DIR}/dist)
            message(FATAL_ERROR "npm is not found! Please install it to proceed.")
        endif()

        ExternalProject_Add(
            web_ui_dist
            PREFIX ${CMAKE_BINARY_DIR}/web_ui_dist
            SOURCE_DIR ${WEB_SRC_DIR}
            DOWNLOAD_COMMAND ""
            CONFIGURE_COMMAND ${NPM_EXECUTABLE} i
            BUILD_COMMAND ${NPM_EXECUTABLE} run build
            INSTALL_COMMAND ""
            BUILD_ALWAYS OFF
            BUILD_IN_SOURCE TRUE
        )

        add_dependencies(${COMPONENT_LIB} web_ui_dist)

        spiffs_create_partition_image(www ${WEB_SRC_DIR}/dist/axe-os FLASH_IN_PROJECT DEPENDS web_ui_dist)
    endif()
else()
    message(STATUS "Web UI build disabled – using prebuilt dist/ directory.")
    spiffs_create_partition_image(www ${WEB_SRC_DIR}/dist/axe-os FLASH_IN_PROJECT)
endif()
