/*
 * Encoder_Omron_E6B2_CWZ6C.h
 *
 *      Author: Viet Nguyen Duc
 */

#ifndef INC_ENCODER_OMRON_E6B2_CWZ6C_H_
#define INC_ENCODER_OMRON_E6B2_CWZ6C_H_

#include "stm32f1xx_hal.h"

extern TIM_HandleTypeDef htim4;

void Encoder_Init(TIM_HandleTypeDef *htim);
void Encoder_Update(void);
float Encoder_GetRPM(void);
uint32_t Encoder_GetRawPulses(void);

#endif /* INC_ENCODER_OMRON_E6B2_CWZ6C_H_ */
