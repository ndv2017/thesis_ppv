/*
 * FC03_LM393.h
 *
 *      Author: Viet Nguyen Duc
 */

#ifndef INC_FC03_LM393_H_
#define INC_FC03_LM393_H_

#include "main.h"

#define FC03_PULSES_PER_REV 20

void FC03_LM393_Init(GPIO_TypeDef* inputPort, uint16_t inputPin, TIM_HandleTypeDef* timerHandle);
uint32_t FC03_LM393_GetCount(void);
float FC03_LM393_GetRPM(void);
void FC03_LM393_EXTI_Callback(uint16_t GPIO_Pin);

#endif /* INC_FC03_LM393_H_ */
