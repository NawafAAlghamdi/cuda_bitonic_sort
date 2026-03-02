#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <stdio.h>
#include <math.h>
#include <stdlib.h>


__global__ void bitonicSort(int* array, int size, int i, int j, int Sort) //where i is step and j is stage
{
    int k = threadIdx.x + blockDim.x * blockIdx.x;

    if (Sort == 1) {
        if (k % (int)ceil(pow(2, i - j + 1)) < (int)ceil(pow(2, i - j))) {
            if (k / (int)ceil(pow(2, i)) % 2 == 0) {
                if (array[k] > array[k + (int)ceil(pow(2, i - j))]) {
                    int temp = array[k];
                    array[k] = array[k + (int)ceil(pow(2, i - j))];
                    array[k + (int)ceil(pow(2, i - j))] = temp;

                }
            }
            else {
                if (array[k] < array[k + (int)ceil(pow(2, i - j))]) {
                    int temp = array[k];
                    array[k] = array[k + (int)ceil(pow(2, i - j))];
                    array[k + (int)ceil(pow(2, i - j))] = temp;

                }


            }
        }

    }
    else {
        if (k % (int)ceil(pow(2, i - j + 1)) < (int)ceil(pow(2, i - j))) {
            if (k / (int)ceil(pow(2, i)) % 2 == 0) {
                if (array[k] < array[k + (int)ceil(pow(2, i - j))]) {
                    int temp = array[k];
                    array[k] = array[k + (int)ceil(pow(2, i - j))];
                    array[k + (int)ceil(pow(2, i - j))] = temp;

                }
            }
            else {
                if (array[k] > array[k + (int)ceil(pow(2, i - j))]) {
                    int temp = array[k];
                    array[k] = array[k + (int)ceil(pow(2, i - j))];
                    array[k + (int)ceil(pow(2, i - j))] = temp;

                }


            }
        }



    }
}


#define THREADS_PER_BLOCK 256
int main()
{
    int* array;
    int* d_array;
    int nb;
    int N;
    int sortchoice;

    do {
        printf("Enter array size: ");
        scanf("%d", &N);
        if (N < 1) {
            printf("Please enter a vaild number(greater than zero)\n");
        }
    } while (N < 1);

    do {
        printf("Enter 1 for ascending sort or 0 for descending sort: ");
        scanf("%d", &sortchoice);
        if (sortchoice != 0 && sortchoice != 1) {
            printf("Please enter a vaild number(1 or 0)\n");
        }
    } while (sortchoice != 0 && sortchoice != 1);

    nb = N;
    int size = nb * sizeof(int);

    array = (int*)malloc(size);

    for (int i = 0; i < N; i++) {
        array[i] = rand() % 100;
    }


    if (log2(nb) != floor(log2(nb))) {
        int temp = nb;
        int x = ceil(log2(nb));
        nb = (int)pow(2, x);
        int z = nb - temp;

        int* temp_ptr = (int*)realloc(array, nb * sizeof(int));
        if (temp_ptr == NULL) {
            printf("Realloc failed!\n");
            exit(1);
        }
        array = temp_ptr;

        for (int i = 0; i < z; i++) {
            array[temp + i] = 0;
        }

        size = nb * sizeof(int);
    }

    printf("Array Data: ");
    for (int i = 0; i < nb; i++) {
        printf("%d ", array[i]);
    }

    printf("\n");

    cudaMalloc((void**)&d_array, size);
    cudaMemcpy(d_array, array, size, cudaMemcpyHostToDevice);


    int blocks = (nb + THREADS_PER_BLOCK - 1) / THREADS_PER_BLOCK;
    int steps = log2(nb);

    for (int i = 1; i <= steps; i++) {
        for (int j = 1; j <= i; j++) {
            bitonicSort << <blocks, THREADS_PER_BLOCK >> > (d_array, nb, i, j, sortchoice);

        }
    }

    cudaMemcpy(array, d_array, size, cudaMemcpyDeviceToHost);

    int start = 0;

    if (sortchoice == 1) {
        start = nb - N;
    }

    printf("Sorted Array Data: ");
    for (int i = 0; i < N; i++) {
        printf("%d ", array[start + i]);
    }

    free(array);
    cudaFree(d_array);
  return 0;}
