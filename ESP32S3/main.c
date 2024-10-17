///////////////////////////////////////////////////////////

#include <stdio.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "esp_timer.h"
#include "esp_heap_caps.h"
#include "spi_interface.h"
#include "wifi.h"
#include "tcp.h"

///////////////////////////////////////////////////////////

const int SPI_FRAME_BITLEN = 1632;
const int SPI_FRAME_SIZE = SPI_FRAME_BITLEN/8;
const int WIFI_FRAME = 100; // 16 spi frames forms a spi frame
const int WIFI_LEN = 4096*2;

#define N  10000

char seq_log[N] = {0};
uint64_t time_log[N] = {0};
uint64_t cnt = 0;

char* spi_buf = NULL;
char* wifi_buf = NULL;
char* tmp_buf = NULL;
char* send_buf = NULL;
TaskHandle_t h_wifi_task = NULL;
TaskHandle_t h_spi_task = NULL;
bool spi_frame_rdy;


void wifiTask();
void spiTask();

///////////////////////////////////////////////////////////

void app_main(void)
{  
    //initWiFi();
    //initTCP();
    initSPI();

    /*
    uint8_t* rxbuf = heap_caps_malloc(SPI_FRAME_SIZE, MALLOC_CAP_DMA);
    recvFromSPI((char*)rxbuf, SPI_FRAME_SIZE);
    uint8_t last_seq = rxbuf[0];

    int n_repeat = 0;
    int n_seq_err = 0;
    int n_data_err = 0;
    uint64_t start = esp_timer_get_time();
    for (int n = 0; n < N; n++) {
        recvFromSPI((char*)rxbuf, SPI_FRAME_SIZE);
        sendToTcp((char*)rxbuf,SPI_FRAME_SIZE);
        //printf("send %d frame\n",n);
        if (last_seq == rxbuf[0]) {
            n_repeat++;
        } else if ((uint8_t)(last_seq+1) != rxbuf[0]) {
            n_seq_err++;
        }
        //printf("seq id: %d \n",(int)rxbuf[0]);
        for (int i = 1; i < SPI_FRAME_SIZE; i++) {
            if (rxbuf[i] != rxbuf[i-1]) {
                n_data_err++;
                break;
            }
        }
        last_seq = rxbuf[0];
    }
    uint64_t end = esp_timer_get_time();
    printf("\n");
    printf("bit rate  = %.4f Mbps\n", (double)(N*SPI_FRAME_BITLEN)/(end-start));
    printf("n_repeat  = %d\n", n_repeat);
    printf("n_seq_err = %d\n", n_seq_err);
    printf("n_pld_err = %d\n", n_data_err);
    printf("\n");
    */
 
    spi_buf  = heap_caps_malloc(SPI_FRAME_SIZE, MALLOC_CAP_DMA);
    wifi_buf = heap_caps_malloc(SPI_FRAME_SIZE, MALLOC_CAP_DMA);
    wifi_buf = heap_caps_malloc(SPI_FRAME_SIZE, MALLOC_CAP_DMA);
    send_buf  = heap_caps_malloc(SPI_FRAME_SIZE*WIFI_FRAME, MALLOC_CAP_DMA);
    // wifi vairation 
    for ( int i=0; i < WIFI_LEN; i = i + 1){
        send_buf[i] = 12;
    }
    /*
    while (true) {
        uint64_t start = esp_timer_get_time();
        uint64_t i = 0;
        while ( true ){
            sendToTcp(send_buf,WIFI_LEN);
            uint64_t end = esp_timer_get_time();
            i = i + WIFI_LEN*8;
            if ( (end-start) > 1e6 ) {
                printf("Wifi rate: %.4f Mbps\n", (double)((i)/(end-start)));
                break;
            }
        }
    }*/

    // spi 
    
    assert(xTaskCreatePinnedToCore(spiTask,
                                   "spiTask",
                                   4096,
                                   NULL,
                                   10,
                                   &h_spi_task,
                                   1)
    == pdPASS);

    assert(xTaskCreatePinnedToCore(wifiTask,
                                   "wifiTask",
                                   4096,
                                   NULL,
                                   10,
                                   &h_wifi_task,
                                   0)
    == pdPASS);
    
    while (true) {
        vTaskDelay(500/portTICK_PERIOD_MS);
    }
    
}

inline void swap(char** a, char** b) 
{
    char* tmp = *a;
    *a = *b;
    *b = tmp;
}

void wifiTask()
{
    
    xTaskNotifyGive(h_spi_task);
    int n_repeat = 0;
    int n_seq_err = 0;
    int n_data_err = 0;
    uint64_t start = esp_timer_get_time();
    uint64_t last_seq = 0;
    uint8_t prev_id = 0;
    uint8_t err = 0;
    //uint8_t id_arr[N] = {0};
    for (int j=0;j<N;j++) {
    //while (true) {
        ulTaskNotifyTake(pdTRUE, portMAX_DELAY);
        swap(&spi_buf, &wifi_buf);
        xTaskNotifyGive(h_spi_task);
        
        //if ( j>0 && j%WIFI_FRAME ==0){
         //   sendToTcp(send_buf,SPI_FRAME_SIZE*WIFI_FRAME);
        //    memcpy(send_buf+(j%WIFI_FRAME)*SPI_FRAME_SIZE,wifi_buf,SPI_FRAME_SIZE);
        //} else
        //   memcpy(send_buf+(j%WIFI_FRAME)*SPI_FRAME_SIZE,wifi_buf,SPI_FRAME_SIZE);
        //uint8_t spi_frame_id = wifi_buf[0];
        //id_arr[j] = wifi_buf[0];
        //if ( spi_frame_id - prev_id != 1 ||  spi_frame_id - prev_id != -255)
         //   err++;
        //uint16_t spi_bit_len = (wifi_buf[2])<<8|wifi_buf[3];
        //printf("frame id: %d \n",spi_frame_id);

        //printf("Frame id: %d seq id: %d last byte1: %02X last byte2: %02X last byte3: %02X last byte4: %02X LAST BYTE5 %02X\n",wifi_buf[0],wifi_buf[1],wifi_buf[5],wifi_buf[6],wifi_buf[100],wifi_buf[101],wifi_buf[102]);
        /*if (j >= 1){
            if (last_seq == wifi_buf[0]) {
                n_repeat++;
            } else if ((uint8_t)(last_seq+1) != wifi_buf[0]) {
                n_seq_err++;
            }
            for (int i = 1; i < SPI_FRAME_SIZE; i++) {
                if (wifi_buf[i] != wifi_buf[i-1]) {
                    n_data_err++;
                    break;
                }
            }
        }*/
        //printf("seq id: %d \n",(int)wifi_buf[0]);
        //last_seq = wifi_buf[0];
        
    }
    uint64_t end = esp_timer_get_time();
    printf("\n");
    printf("bit rate  = %.4f Mbps\n", (double)(N*SPI_FRAME_BITLEN)/(end-start));
    for ( int i=0;i<SPI_FRAME_BITLEN/8;i++)
        printf("byte  = %d\n", wifi_buf[i]);
    /*printf("Running time: %.4f\n",(double)(end-start)*1e-6);
    printf("n_repeat  = %d\n", n_repeat);
    printf("n_seq_err = %d\n", n_seq_err);
    printf("n_pld_err = %d\n", n_data_err);*/
    printf("\n");

    while (true){
         vTaskDelay(500/portTICK_PERIOD_MS);
    }
}

/*
void spiTask() 
{

    for (int i=0;i<N;i++) {
        //ulTaskNotifyTake(pdTRUE, portMAX_DELAY);
        if(i%16==0){
                ulTaskNotifyTake(pdTRUE, portMAX_DELAY);
                recvFromSPI(spi_buf,SPI_FRAME_SIZE); 
        }
        recvFromSPI(spi_buf,SPI_FRAME_SIZE); 
        //xTaskNotifyGive(h_wifi_task);
        memcpy(tmp_buf+(i%WIFI_FRAME)*SPI_FRAME_SIZE,spi_buf,SPI_FRAME_SIZE);
        if(i%16==15){
            printf("Assemble frame %d\n",(int)(i+1)/16);
            xTaskNotifyGive(h_wifi_task);
            //ulTaskNotifyTake(pdTRUE, portMAX_DELAY);
        }
    }
    
    while (true){
         vTaskDelay(500/portTICK_PERIOD_MS);
    }
}*/

void spiTask() 
{
    
    
    for (int i=0;i<N;i++) {
    //while ( true ){
        ulTaskNotifyTake(pdTRUE, portMAX_DELAY);
        recvFromSPI(spi_buf,SPI_FRAME_SIZE);    
        xTaskNotifyGive(h_wifi_task);
    }
    
    while (true){
         vTaskDelay(500/portTICK_PERIOD_MS);
    }
}

