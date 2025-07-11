/*
 * CAN_processing.c
 *
 *      Author: Viet Nguyen Duc
 */

#include "CAN_processing.h"

uCAN_MSG txMessage;
uCAN_MSG rxMessage;

float rpm = 0.0;
float current = 0.0;
float temp = 0.0;
float torque = 0.0;

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
		else if (REQUEST_DATA_SENSORS_ID == rxMessage.frame.id)
		{
			Send_Data_Processing();
//			u8_DutyCycle = rxMessage.frame.data2;
//			LED_pwm_processing();
//			Led_C13_blink_check(20, 50);
		}
	}
}

void Send_Data_Processing(void)
{
	// reset values
	rpm = 0.0;
	current = 0.0;
	temp = 0.0;
	torque = 0.0;

	setTimer2(TIME_EACH_SEND, 1);
	while (1)
	{
		/* RPM Encoder */
		Encoder_Update();
		rpm = Encoder_GetRPM();

		/* Current */
		current = TIDA_GetCurrent();

		/* Temp */
		temp = DS18B20_GetTemp();

		/* Torque */
		int weight = HX711_Weigh();						// in milligrams
		torque = (((float)weight)*10/1000000) * 70;		// N.mm

		if (CANSPI_Receive(&rxMessage))
		{
			if ((REQUEST_DATA_SENSORS_ID == rxMessage.frame.id) && (rxMessage.frame.data0 == 1))
			{
				Led_C13_blink_check(40, 50);
				Set_duty_cycle_TIM1_CH2(0);		// Turn off DC motor
				break;
			}
		}

		if (timer2_flags[1])
		{
			setTimer2(TIME_EACH_SEND, 1);

			/* RPM Encoder */
			CAN_Send_Message(RPM_ENCODER_ID, 4, rpm);

			/* Current */
			CAN_Send_Message(CUR_SENSOR_ID, 4, torque);

			/* Temp */
			CAN_Send_Message(TEMP_SENSOR_ID, 4, temp);

			/* Torque */
			CAN_Send_Message(TORQ_SENSOR_ID, 4, torque);
		}
	}
}

