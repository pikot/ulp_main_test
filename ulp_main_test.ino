/* ULP Example

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.
*/
/*
 * Must allocate more memory for the ulp in 
 * esp32/tools/sdk/include/sdkconfig.h 
 * -> #define CONFIG_ULP_COPROC_RESERVE_MEM
 * for this sketch to compile. 8192 2048b seems 
 * good.
 */

#include <stdio.h>
#include <math.h>

#include "esp_sleep.h"
#include "soc/rtc_cntl_reg.h"
#include "soc/rtc_io_reg.h"  
#include "soc/sens_reg.h"
#include "soc/soc.h"
#include "driver/rtc_io.h"
#include "esp32/ulp.h"
#include "sdkconfig.h"
#include "ulp_main.h"
#include "ulptool.h"
#include "UlpDebug.h"

extern const uint8_t ulp_main_bin_start[] asm("_binary_ulp_main_bin_start");
extern const uint8_t ulp_main_bin_end[]   asm("_binary_ulp_main_bin_end");

const gpio_num_t GPIO_SCL = GPIO_NUM_26;
const gpio_num_t GPIO_SDA = GPIO_NUM_25;

static void init_ulp_program();
static void start_ulp_program();

void setup() {
 // esp_sleep_wakeup_cause_t cause = esp_sleep_get_wakeup_cause();
    Serial.begin(115200);
    Serial.flush();

    

    // Slow memory initialization
    memset(RTC_SLOW_MEM, 0, 8192);

    esp_sleep_wakeup_cause_t cause = esp_sleep_get_wakeup_cause();
    Serial.printf("CONFIG_ULP_COPROC_RESERVE_MEM = %d, ulp app size %d, %p\n" , CONFIG_ULP_COPROC_RESERVE_MEM,
                  (ulp_main_bin_end - ulp_main_bin_start), ulp_entry  ) ;
    init_run_ulp(1000 * 1000 );


    if (cause != ESP_SLEEP_WAKEUP_ULP) {
         printf("! ULP wakeup, printing status\n");
    }
    else {
        printf("ULP wakeup, printing status\n");     
    }

    Serial.printf("Entering deep sleep\n\n");
}

void loop() {
        ulpDump();

        Serial.printf("iter %d; \n", ulp_sample_counter);
        //print_max30100_data("setup: "); ;      
        sleep(10);
}

static void init_run_ulp(uint32_t usec) {
    // initialize ulp variable
    ulp_set_wakeup_period(0, usec);
    esp_err_t err = ulptool_load_binary(0, ulp_main_bin_start, (ulp_main_bin_end - ulp_main_bin_start) / sizeof(uint32_t));
    // ulp coprocessor will run on its own now
//    ulp_count = 0;
    err = ulp_run((&ulp_entry - RTC_SLOW_MEM) / sizeof(uint32_t));
    if (err) Serial.println("Error Starting ULP Coprocessor");
}
