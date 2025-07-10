/*
 * ds18b20.c
 *
 *      Author: Viet Nguyen Duc
 */

#include "ds18b20.h"

static int presence = 0, isRxed = 0;
static uint8_t RxData[8], Temp_LSB = 0, Temp_MSB = 0;
static int16_t Temp;
float Temperature;

void uart_Init(uint32_t baud)
{
	huart2.Instance = USART2;
	huart2.Init.BaudRate = baud;
	huart2.Init.WordLength = UART_WORDLENGTH_8B;
	huart2.Init.StopBits = UART_STOPBITS_1;
	huart2.Init.Parity = UART_PARITY_NONE;
	huart2.Init.Mode = UART_MODE_TX_RX;
	huart2.Init.HwFlowCtl = UART_HWCONTROL_NONE;
	huart2.Init.OverSampling = UART_OVERSAMPLING_16;
	if (HAL_HalfDuplex_Init(&huart2) != HAL_OK)
	{
		Error_Handler();
	}
}

int DS18B20_Start(void)
{
	uint8_t data = 0xF0;
	uart_Init(9600);
	HAL_UART_Transmit(&huart2, &data, 1, 100);  // low for 500+ms
	if (HAL_UART_Receive(&huart2, &data, 1, 1000) != HAL_OK)	return -1;   // failed.. check connection
	uart_Init(115200);
	if (data == 0xF0)	return -2;  // no response.. check connection
	return 1;  // response detected
}

void DS18B20_Write(uint8_t data)
{
	uint8_t buffer[8];
	for (int i = 0; i < 8; i++)
	{
		if (data & (1 << i))  // if the bit is high
		{
			buffer[i] = 0xFF;  // write 1
		}
		else  // if the bit is low
		{
			buffer[i] = 0;  // write 0
		}
	}
	HAL_UART_Transmit(&huart2, buffer, 8, 100);
}

uint8_t DS18B20_Read(void)
{
	uint8_t buffer[8];
	uint8_t value = 0;
	for (int i = 0; i < 8; i++)
	{
		buffer[i] = 0xFF;
	}

	HAL_UART_Transmit_DMA(&huart2, buffer, 8);
	HAL_UART_Receive_DMA(&huart2, RxData, 8);

	while (isRxed == 0);
	for (int i = 0; i < 8; i++)
	{
		if (RxData[i] == 0xFF)  // if the pin is HIGH
		{
			value |= 1<<i;  // read = 1
		}
	}
	isRxed = 0;
	return value;
}

void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart)
{
	isRxed = 1;
}

/* delay must be >= 1 sec each time this func being invoked */
void DS18B20_Processing(void)
{
	presence = DS18B20_Start();
	DS18B20_Write(0xCC);  // skip ROM
	DS18B20_Write(0x44);  // convert t

	presence = DS18B20_Start();
	DS18B20_Write (0xCC);  // skip ROM
	DS18B20_Write (0xBE);  // Read Scratch-pad

	Temp_LSB = DS18B20_Read();
	Temp_MSB = DS18B20_Read();
	Temp = (Temp_MSB << 8) | Temp_LSB;
	Temperature = (float)Temp/16.0;  // resolution is 0.0625

//	HAL_Delay(1000);
}

float DS18B20_GetTemp(void)
{
	DS18B20_Processing();
	return Temperature;
}
