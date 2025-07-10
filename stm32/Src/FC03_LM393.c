/*
 * FC03_LM393.c
 *
 *      Author: Viet Nguyen Duc
 */

#include "FC03_LM393.h"

extern TIM_HandleTypeDef htim3;

static GPIO_TypeDef* fc03_input_port = NULL;
static uint16_t fc03_input_pin = 0;

static TIM_HandleTypeDef* fc03_timer = NULL;

static volatile uint16_t last_interrupt_time = 0;
static volatile uint32_t pulse_count = 0;
static volatile float last_rpm = 0;

void FC03_LM393_Init(GPIO_TypeDef* inputPort, uint16_t inputPin, TIM_HandleTypeDef* timerHandle)
{
    fc03_input_port = inputPort;
    fc03_input_pin = inputPin;

    fc03_timer = timerHandle;

    last_interrupt_time = __HAL_TIM_GET_COUNTER(fc03_timer);
    pulse_count = 0;
}

uint32_t FC03_LM393_GetCount(void)
{
    return pulse_count;
}

float FC03_LM393_GetRPM(void)
{
    // RPM = (pulses in specific time / pulses per rev) * 60
    last_rpm = ((float)pulse_count / FC03_PULSES_PER_REV) * 60.0f;
	pulse_count = 0;
    return last_rpm;
}

void FC03_LM393_EXTI_Callback(uint16_t GPIO_Pin)
{
    if (GPIO_Pin == fc03_input_pin)
    {
        uint16_t now = __HAL_TIM_GET_COUNTER(fc03_timer);
        uint16_t elapsed_us = (uint16_t)(now - last_interrupt_time); // typecasting for overflow-safe

        if (elapsed_us > 100) // debounce time in us
        {
            pulse_count++;
            last_interrupt_time = now;

//            /* RPM = (60 sec/min * 1,000,000 µs/sec) / (pulses_per_rev * elapsed_us) */
//            last_rpm = (60.0f * 1e6f) / ((float)FC03_PULSES_PER_REV * (float)elapsed_us);
        }
    }
}
