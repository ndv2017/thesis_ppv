/*
 * TIDA_01421.c
 *
 *      Author: Viet Nguyen Duc
 */

#include "TIDA_01421.h"

extern ADC_HandleTypeDef hadc1;

#define VREF_ADC        3.3f                // ADC reference voltage
#define ADC_RESOLUTION  4095.0f             // 12-bit ADC
#define RSENSE          0.003f              // Shunt resistor (Ohm)
#define INA_GAIN        50.0f               // INA240-Q1 Gain
#define VREF_BIAS       1.25f               // ADCMOTOR bias voltage (center when current = 0)
#define ADC_SAMPLES		100
#define CALIBRATION		(3.5/1.5)

float TIDA_GetCurrent()
{
	uint32_t sum = 0;
	for (int i = 0; i < ADC_SAMPLES; i++) {
		HAL_ADC_PollForConversion(&hadc1, 1000);
		sum += HAL_ADC_GetValue(&hadc1);
	}

	uint32_t avgValue = sum / ADC_SAMPLES;

    // Convert ADC raw value to voltage
	float Vadc = ((float)avgValue / ADC_RESOLUTION) * VREF_ADC;

    // Formula: I = (V_ADCMOTOR - V_BIAS) / (INA_GAIN * RSENSE)
    float current = 2.0f * (Vadc - VREF_BIAS) / (INA_GAIN * RSENSE) * CALIBRATION;

    return current; // A
}
