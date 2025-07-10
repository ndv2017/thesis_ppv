/*
 * CAN_processing.h
 *
 *      Author: Viet Nguyen Duc
 */

#ifndef INC_CAN_PROCESSING_H_
#define INC_CAN_PROCESSING_H_

#include "software_timer2.h"
#include "main.h"
#include "CANSPI.h"
#include "MCP2515.h"
#include "LED_pwm.h"

#define	CHECK_SENSORS_ID			0x100
#define	CHECK_SENSORS_RESPOND_ID	0x001
#define	DATA_SENSORS_ID				0x200

void CAN_Init(void);
//void CAN_Send_Message(uint32_t u32_id, uint8_t u8_dlc, float value);
void CAN_Processing(void);

#endif /* INC_CAN_PROCESSING_H_ */
