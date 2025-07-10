/*
 * CAN_processing.c
 *
 *      Author: Viet Nguyen Duc
 */

#include "CAN_processing.h"

uCAN_MSG txMessage;
uCAN_MSG rxMessage;

static void Led_C13_blink_check(uint8_t cnt, uint32_t time_unit)
{
	setTimer2(time_unit, 0);
	while(1)
	{
		if (timer2_flags[0])
		{
			if (!cnt--)	break;
			setTimer2(time_unit, 0);
			HAL_GPIO_TogglePin(LEDC13_GPIO_Port, LEDC13_Pin);
		}
	}
}


void CAN_Init(void)
{
	Led_C13_blink_check(12, 70);

	MCP2515_Reset();
	CANSPI_Initialize();
}

void CAN_Send_Message(uint32_t u32_id, uint8_t u8_dlc, float value)
{
	union {
		float f;
		uint8_t bytes[4];
	} data;
	data.f = value;

	txMessage.frame.idType = dSTANDARD_CAN_MSG_ID_2_0B;
	txMessage.frame.id = u32_id;
	txMessage.frame.dlc = u8_dlc;
    txMessage.frame.data0 = data.bytes[0];
    txMessage.frame.data1 = data.bytes[1];
    txMessage.frame.data2 = data.bytes[2];
    txMessage.frame.data3 = data.bytes[3];
//	txMessage.frame.data4 = 0;
//	txMessage.frame.data5 = 0;
//	txMessage.frame.data6 = 0;
//	txMessage.frame.data7 = 0;

	CANSPI_Transmit(&txMessage);
}

void CAN_Processing(void)
{
	if (CANSPI_Receive(&rxMessage))
	{
		if (CHECK_SENSORS_ID == rxMessage.frame.id)
		{
			Led_C13_blink_check(20, 50);

			int cnt = 5;
			setTimer2(35, 0);
			while(1)
			{
				if (timer2_flags[0])
				{
					if (!cnt--)	break;
					setTimer2(35, 0);
					CAN_Send_Message(CHECK_SENSORS_RESPOND_ID, 0, 0);
				}
			}
		}
		else if (DATA_SENSORS_ID == rxMessage.frame.id)
		{
			u8_DutyCycle = rxMessage.frame.data2;
			LED_pwm_processing();
			Led_C13_blink_check(20, 50);
		}
	}
}
