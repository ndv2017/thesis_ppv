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
#include "ds18b20.h"
#include "loadcell_HX711.h"
#include "Encoder_Omron_E6B2_CWZ6C.h"
#include "TIDA_01421.h"

#define	CHECK_SENSORS_ID			0x100
#define	CHECK_SENSORS_RESPOND_ID	0x001
#define	REQUEST_DATA_SENSORS_ID		0x200

#define	RPM_ENCODER_ID				0x101
#define CUR_SENSOR_ID				0x102
#define	TEMP_SENSOR_ID				0x103
#define TORQ_SENSOR_ID				0x104

#define TIME_EACH_SEND				1000	/* >= 1000ms */

void CAN_Init(void);
void CAN_Send_Message(uint32_t u32_id, uint8_t u8_dlc, float value);
void CAN_Processing(void);
void Send_Data_Processing(void);
void test_all();

#endif /* INC_CAN_PROCESSING_H_ */
