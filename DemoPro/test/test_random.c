
#ifdef TEST

#include "unity.h"
#include "random.h"
#include "mock_gpio.h"
#include "mock_device.h"

void setUp(void)
{
}

void tearDown(void)
{
}

void test_random_NeedToImplement(void)
{
    TEST_IGNORE_MESSAGE("Need to Implement random");
}

//Traceability requirements for test cases, design ,code module


// REQ: CONT-101
void test_LedTwitch_should_turn_on_led_with_1s_delay(void)
{
    uint32_t testPin = DEVICE_GPIO_PIN_LED1;
    GPIO_writePin_Expect(testPin, 1);
    SysCtl_delay_Expect(1000000);
    LedTwitch_on(testPin);
}
// REQ: CONT-102
void test_LedTwitch_should_turn_off_led_with_1s_delay(void)
{
    uint32_t testPin = DEVICE_GPIO_PIN_LED1;
    GPIO_writePin_Expect(testPin, 0);
    SysCtl_delay_Expect(1000000);
    LedTwitch_off(testPin);
}

// REQ: CONT-103
void test_random_blinkusecase(void)
{

}

// REQ: CONT-104
void test_LedTwitch_offusecase(void)
{

}

// REQ: CONT-105
void test_LedTwitch_onusecase(void)
{

}

// REQ: CONT-106
void test_LedTwitch_startusecase(void)
{

}

// REQ: CONT-107
void test_LedTwitch_stopusecase(void)
{

}

#endif // TEST
