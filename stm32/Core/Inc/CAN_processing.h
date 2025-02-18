/*
 * CAN_processing.h
 *
 *      Author: Viet Nguyen Duc
 */

#ifndef INC_CAN_PROCESSING_H_
#define INC_CAN_PROCESSING_H_

#include "main.h"
#include "CANSPI.h"
#include "MCP2515.h"
#include "software_timer.h"
#include "LED_pwm.h"

void CAN_Init(void);
void CAN_Send_Specific_Message(int id_message);
void CAN_Processing(void);

#endif /* INC_CAN_PROCESSING_H_ */
