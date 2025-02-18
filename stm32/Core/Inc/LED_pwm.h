/*
 * LED_pwm.h
 *
 *      Author: Viet Nguyen Duc
 */

#ifndef INC_LED_PWM_H_
#define INC_LED_PWM_H_

#include "main.h"

#define	DUTY_CYCLE_INIT		0		// 0-100%

extern uint8_t u8_DutyCycle;

void Set_duty_cycle_TIM1_CH2(uint8_t u8_DutyCycle);
void LED_pwm_Init(void);
void LED_pwm_processing(void);

#endif /* INC_LED_PWM_H_ */
