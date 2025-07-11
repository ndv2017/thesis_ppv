/*
 * loadcell_HX711.h
 *
 *      Author: Viet Nguyen Duc
 */

#ifndef INC_LOADCELL_HX711_H_
#define INC_LOADCELL_HX711_H_

#include "stm32f1xx_hal.h"

#define DT_PIN GPIO_PIN_8
#define DT_PORT GPIOB
#define SCK_PIN GPIO_PIN_9
#define SCK_PORT GPIOB

extern TIM_HandleTypeDef htim2;

void HX711_Init(TIM_HandleTypeDef *htim);
int32_t HX711_ReadRaw(void);
int HX711_Weigh(void);
void HX711_Tare(void);


#endif /* INC_LOADCELL_HX711_H_ */
