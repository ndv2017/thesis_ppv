/*
 * CAN_processing.c
 *
 *      Author: Viet Nguyen Duc
 */

#include "CAN_processing.h"

uCAN_MSG txMessage;
uCAN_MSG rxMessage;

void CAN_Init(void)
{
	uint8_t cnt = 6;
	setTimer1(70);
	while(1)
	{
		if (timer1_flag)
		{
			if (!cnt--)	break;
			setTimer1(70);
			HAL_GPIO_TogglePin(LEDC13_GPIO_Port, LEDC13_Pin);
		}
	}

	MCP2515_Reset();
	CANSPI_Initialize();
}

void CAN_Send_Specific_Message(int id_message)
{
	txMessage.frame.idType = dSTANDARD_CAN_MSG_ID_2_0B;
	txMessage.frame.id = id_message;
	txMessage.frame.dlc = 8;
	txMessage.frame.data0 = 1;
	txMessage.frame.data1 = 0;
	txMessage.frame.data2 = 2;
	txMessage.frame.data3 = 3;
	txMessage.frame.data4 = 6;
	txMessage.frame.data5 = 5;
	txMessage.frame.data6 = 9;
	txMessage.frame.data7 = 7;
	CANSPI_Transmit(&txMessage);
}

void CAN_Processing(void)
{
	if (CANSPI_Receive(&rxMessage))
	{
		HAL_GPIO_TogglePin(LEDC13_GPIO_Port, LEDC13_Pin);
		if (0x103 == rxMessage.frame.id)
		{
			uint8_t cnt = 20;
			setTimer1(10);
			while(1)
			{
				if (timer1_flag)
				{
					if (!cnt--)	break;
					setTimer1(10);
					HAL_GPIO_TogglePin(LEDC13_GPIO_Port, LEDC13_Pin);
				}
			}

			txMessage.frame.id = 0x103;
			cnt = 5;
			setTimer1(35);
			while(1)
			{
				if (timer1_flag)
				{
					if (!cnt--)	break;
					setTimer1(35);
					CAN_Send_Specific_Message(txMessage.frame.id);
				}
			}
		}
		else if ((0x104 == rxMessage.frame.id) && (1 == rxMessage.frame.data1))
		{
			u8_DutyCycle = rxMessage.frame.data2;
			LED_pwm_processing();
			uint8_t cnt = 40;
			setTimer1(5);
			while (1)
			{
				if (timer1_flag)
				{
					if (!cnt--)	break;
					setTimer1(5);
					HAL_GPIO_TogglePin(LEDC13_GPIO_Port, LEDC13_Pin);
				}
			}
		}
	}
}
