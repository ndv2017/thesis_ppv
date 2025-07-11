/*
 * Encoder_Omron_E6B2_CWZ6C.c
 *
 *      Author: Viet Nguyen Duc
 */

#include "Encoder_Omron_E6B2_CWZ6C.h"

static TIM_HandleTypeDef *encoderTimer;
static uint32_t counter = 0;
static uint32_t last_counter = 0;
static uint32_t pulse_per_specific_time = 0;
static double revolution = 0;
static volatile float official_rpm = 0;
static volatile uint8_t check_over_buffer_flag = 0;

void Encoder_Init(TIM_HandleTypeDef *htim) {
    encoderTimer = htim;
    HAL_TIM_Encoder_Start_IT(encoderTimer, TIM_CHANNEL_ALL);
}

void Encoder_TIM_IC_Callback(TIM_HandleTypeDef *htim) {
    if (htim == encoderTimer) {
        counter = __HAL_TIM_GET_COUNTER(htim);
        if (counter >= 65535)
            ++check_over_buffer_flag;
    }
}

void Encoder_Update(void) {
    if (check_over_buffer_flag) {
        if (counter >= last_counter)
            pulse_per_specific_time = counter - last_counter + 65536;
        else
            pulse_per_specific_time = 65536 - last_counter + counter;
        check_over_buffer_flag = 0;
    } else {
        pulse_per_specific_time = counter >= last_counter ? counter - last_counter : 65536 - last_counter + counter;
    }

    pulse_per_specific_time /= 2;
    revolution = (double) pulse_per_specific_time / 1000.0;  // 1000 pulses per revolution
    official_rpm = revolution * 60.0;

    last_counter = counter;
}

float Encoder_GetRPM(void) {
    return official_rpm;
}

uint32_t Encoder_GetRawPulses(void) {
    return pulse_per_specific_time;
}

