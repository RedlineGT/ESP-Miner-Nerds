#include "csv_config.h"
#include "nvs_config.h"
#include "esp_log.h"
#include "esp_spiffs.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

static const char *TAG = "CsvConfig";

// Helper function to trim whitespace
static char* trim(char* str) {
    if (!str) return str;
    
    // Trim leading whitespace
    while (*str && (*str == ' ' || *str == '\t' || *str == '\r')) {
        str++;
    }
    
    // Trim trailing whitespace
    char* end = str + strlen(str) - 1;
    while (end > str && (*end == ' ' || *end == '\t' || *end == '\r' || *end == '\n')) {
        end--;
    }
    *(end + 1) = '\0';
    
    return str;
}

// Helper function to parse CSV line
static bool parse_csv_line(const char* line, char* key, char* type, char* encoding, char* value) {
    if (!line || line[0] == '#' || line[0] == '\0') return false;
    
    const char* p = line;
    int field = 0;
    char* fields[] = {key, type, encoding, value};
    char* current = fields[0];
    int max_len[] = {64, 16, 16, 512};
    int pos = 0;
    bool in_quotes = false;
    
    while (*p && field < 4) {
        if (*p == '"') {
            in_quotes = !in_quotes;
            p++;
            continue;
        }
        
        if (*p == ',' && !in_quotes) {
            current[pos] = '\0';
            field++;
            if (field < 4) {
                current = fields[field];
                pos = 0;
            }
            p++;
            continue;
        }
        
        if (pos < max_len[field] - 1) {
            current[pos++] = *p;
        }
        p++;
    }
    
    if (field == 3) {
        current[pos] = '\0';
        return true;
    }
    
    return false;
}

namespace CsvConfig {

bool csv_file_exists() {
    FILE* f = fopen("/spiffs/config.cvs", "r");
    if (f) {
        fclose(f);
        return true;
    }
    return false;
}

bool load_config_from_csv() {
    FILE* f = fopen("/spiffs/config.cvs", "r");
    if (!f) {
        ESP_LOGW(TAG, "config.cvs not found in SPIFFS");
        return false;
    }
    
    ESP_LOGI(TAG, "Loading configuration from config.cvs");
    
    char line[1024];
    char key[64], type[16], encoding[16], value[512];
    int line_num = 0;
    int loaded = 0;
    
    while (fgets(line, sizeof(line), f)) {
        line_num++;
        
        // Skip header and comments
        if (line_num == 1 || line[0] == '#' || line[0] == '\n' || line[0] == '\r') {
            continue;
        }
        
        if (!parse_csv_line(line, key, type, encoding, value)) {
            continue;
        }
        
        // Trim values
        char* key_trimmed = trim(key);
        char* type_trimmed = trim(type);
        char* value_trimmed = trim(value);
        
        // Skip empty keys
        if (strlen(key_trimmed) == 0 || strlen(value_trimmed) == 0) {
            continue;
        }
        
        // Parse and store based on type
        if (strcmp(type_trimmed, "string") == 0) {
            Config::nvs_config_set_string(key_trimmed, value_trimmed);
            ESP_LOGD(TAG, "Set string %s = %s", key_trimmed, value_trimmed);
            loaded++;
        } else if (strcmp(type_trimmed, "u16") == 0) {
            uint16_t val = (uint16_t)atoi(value_trimmed);
            Config::nvs_config_set_u16(key_trimmed, val);
            ESP_LOGD(TAG, "Set u16 %s = %u", key_trimmed, val);
            loaded++;
        } else if (strcmp(type_trimmed, "u32") == 0) {
            uint32_t val = (uint32_t)atol(value_trimmed);
            Config::nvs_config_set_u64(key_trimmed, val);
            ESP_LOGD(TAG, "Set u32 %s = %lu", key_trimmed, val);
            loaded++;
        } else if (strcmp(type_trimmed, "u64") == 0) {
            uint64_t val = (uint64_t)atoll(value_trimmed);
            Config::nvs_config_set_u64(key_trimmed, val);
            ESP_LOGD(TAG, "Set u64 %s = %llu", key_trimmed, val);
            loaded++;
        }
    }
    
    fclose(f);
    ESP_LOGI(TAG, "Loaded %d configuration values from config.cvs", loaded);
    return true;
}

bool export_config_to_csv() {
    FILE* f = fopen("/spiffs/config.cvs", "w");
    if (!f) {
        ESP_LOGE(TAG, "Failed to open config.cvs for writing");
        return false;
    }
    
    ESP_LOGI(TAG, "Exporting configuration to config.cvs");
    
    // Write header
    fprintf(f, "key,type,encoding,value\n");
    fprintf(f, "main,namespace,,\n\n");
    
    // Network & Stratum config
    fprintf(f, "# ─────────────────────────────────────────────────────────────────────────────\n");
    fprintf(f, "# ↓↓↓ NETWORK & STRATUM CONFIG – Updated from menuconfig ↓↓↓\n");
    fprintf(f, "# ─────────────────────────────────────────────────────────────────────────────\n\n");
    
    fprintf(f, "hostname,data,string,%s\n", Config::getHostname());
    fprintf(f, "wifissid,data,string,%s\n", Config::getWifiSSID());
    fprintf(f, "wifipass,data,string,%s\n", Config::getWifiPass());
    fprintf(f, "stratumurl,data,string,%s\n", Config::getStratumURL());
    fprintf(f, "stratumport,data,u16,%u\n", Config::getStratumPortNumber());
    fprintf(f, "stratumuser,data,string,%s\n", Config::getStratumUser());
    fprintf(f, "stratumpass,data,string,%s\n", Config::getStratumPass());
    fprintf(f, "stratumdiff,data,u64,%lu\n", Config::getStratumDifficulty());
    
    fprintf(f, "\n# ─── Optional fallback configuration ────────────────────────────────────────\n\n");
    
    fprintf(f, "fbstratumurl,data,string,%s\n", Config::getStratumFallbackURL());
    fprintf(f, "fbstratumport,data,u16,%u\n", Config::getStratumFallbackPortNumber());
    fprintf(f, "fbstratumuser,data,string,%s\n", Config::getStratumFallbackUser());
    fprintf(f, "fbstratumpass,data,string,%s\n", Config::getStratumFallbackPass());
    
    fclose(f);
    ESP_LOGI(TAG, "Configuration exported to config.cvs");
    return true;
}

} // namespace CsvConfig
