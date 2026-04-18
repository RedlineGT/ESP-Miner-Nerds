#pragma once

#include <stdint.h>

namespace CsvConfig {
    /**
     * Load configuration from config.cvs file in SPIFFS.
     * Parses the CSV file and populates NVS with the values.
     * Returns true if successful, false otherwise.
     */
    bool load_config_from_csv();

    /**
     * Export current NVS configuration to config.cvs file in SPIFFS.
     * Overwrites the existing file.
     * Returns true if successful, false otherwise.
     */
    bool export_config_to_csv();

    /**
     * Check if config.cvs exists in SPIFFS.
     * Returns true if the file exists.
     */
    bool csv_file_exists();
}
