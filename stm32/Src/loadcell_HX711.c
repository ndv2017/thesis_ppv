/*
 * loadcell_HX711.c
 *
 *      Author: Viet Nguyen Duc
 */

#include "loadcell_HX711.h"

static TIM_HandleTypeDef *loadcellTimer;
static uint32_t tare = 8467416;
static float knownMass_mg = 179000;
static int32_t rawValue = 206826;

void HX711_Init(TIM_HandleTypeDef *htim) {
    loadcellTimer = htim;

    HAL_TIM_Base_Start(loadcellTimer);
    HAL_GPIO_WritePin(SCK_PORT, SCK_PIN, GPIO_PIN_SET);
    HAL_Delay(10);
    HAL_GPIO_WritePin(SCK_PORT, SCK_PIN, GPIO_PIN_RESET);
    HAL_Delay(10);
}

static void microDelay(uint16_t delay) {
    __HAL_TIM_SET_COUNTER(loadcellTimer, 0);
    while (__HAL_TIM_GET_COUNTER(loadcellTimer) < delay);
}

int32_t HX711_ReadRaw(void) {
    uint32_t data = 0;
    uint32_t startTime = HAL_GetTick();

    while (HAL_GPIO_ReadPin(DT_PORT, DT_PIN) == GPIO_PIN_SET) {
        if (HAL_GetTick() - startTime > 200)
            return 0;
    }

    for (int8_t len = 0; len < 24; len++) {
        HAL_GPIO_WritePin(SCK_PORT, SCK_PIN, GPIO_PIN_SET);
        microDelay(1);
        data = data << 1;
        HAL_GPIO_WritePin(SCK_PORT, SCK_PIN, GPIO_PIN_RESET);
        microDelay(1);
        if (HAL_GPIO_ReadPin(DT_PORT, DT_PIN) == GPIO_PIN_SET)
            data++;
    }

    data = data ^ 0x800000;

    HAL_GPIO_WritePin(SCK_PORT, SCK_PIN, GPIO_PIN_SET);
    microDelay(1);
    HAL_GPIO_WritePin(SCK_PORT, SCK_PIN, GPIO_PIN_RESET);
    microDelay(1);

    return data;
}

int HX711_Weigh(void) {
    int32_t total = 0;
    int samples = 3;
    float coefficient;

    for (int i = 0; i < samples; i++) {
        total += HX711_ReadRaw();
    }

    int32_t avg = total / samples;
    coefficient = knownMass_mg / rawValue;
    int weight = (int)(avg - tare) * coefficient;

    return weight;
}

void HX711_Tare(void) {
    int32_t total = 0;
    for (int i = 0; i < 50; i++) {
        total += HX711_ReadRaw();
    }
    tare = total / 50;
}
