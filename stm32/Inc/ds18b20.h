/*
 * ds18b20.h
 *
 *      Author: Viet Nguyen Duc
 */

#ifndef INC_DS18B20_H_
#define INC_DS18B20_H_

#include "main.h"

extern UART_HandleTypeDef huart2;
extern float Temperature;

void DS18B20_Processing(void);
float DS18B20_GetTemp(void);

#endif /* INC_DS18B20_H_ */
