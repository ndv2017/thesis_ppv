/*
 * LED_pwm.c
 *
 *      Author: Viet Nguyen Duc
 */

#include "LED_pwm.h"

uint8_t u8_DutyCycle = 0;

void Set_duty_cycle_TIM1_CH2(uint8_t u8_DutyCycle)
{
	TIM1->CCR2 = u8_DutyCycle*100;
}

void LED_pwm_Init(void)
{
	for (uint8_t i = 0; i <= 100; i++)
	{
		Set_duty_cycle_TIM1_CH2(i);
		HAL_Delay(20);
	}

	Set_duty_cycle_TIM1_CH2(DUTY_CYCLE_INIT);
}

void LED_pwm_processing(void)
{
	Set_duty_cycle_TIM1_CH2(u8_DutyCycle);
}
