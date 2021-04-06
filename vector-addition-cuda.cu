#include <stdlib.h>
#include <stdio.h>
#include <getopt.h>


__global__ void add_vector(int *vOne, int *vTwo, int *vResult, int N) {
	int i;

	i = blockDim.x * blockIdx.x + threadIdx.x;

	while (i < N) {
		vResult[i] = vOne[i] + vTwo[i];
		i += blockDim.x;
	}
}
int main(int argc, char* argv[]) {
	int numThreadBlocks, numThreadsPerBlock, size, N, i;
	int *vOne, *vTwo, *vResult;
	int *gpu_vOne, *gpu_vTwo, *gpu_vResult;
	cudaError_t status = (cudaError_t)0;
	int opt = 0, debug = 0;
	char err_msg[128] = "usage: ./vector-addition-cuda -b <number thread blocks> -t <number threads per block> -n <items>\n";
	

	while ((opt = getopt(argc, argv, "d:b:n:t:")) != -1) {
	    switch(opt) {
		case 'd':
		    debug = 1;
		    break;
		case 'b':
		    numThreadBlocks = atoi(optarg);
		    break;
		case 't':
		    numThreadsPerBlock = atoi(optarg);
		    break;
		case 'n':
		    N = atoi(optarg);
		    break;
		default:
		    printf("Use -d for debugging\n");
		    fprintf(stderr, err_msg);
		    exit(-1);
	    }
	}

	size = N * sizeof(int);

	vOne = (int*) malloc(size);
	vTwo = (int*) malloc(size);
	vResult = (int*) malloc(size);

	if ((vOne == NULL) || (vTwo == NULL) || (vResult == NULL)) {
		perror("initial malloc() of mOne, mTwo, and/or mResult failed");
		exit(-1);
	}

	if (numThreadBlocks <= 0 || numThreadsPerBlock <= 0 || N <= 0) {
		fprintf(stderr, err_msg);
		exit(-1);
	}

	if (debug) {
		printf("numThreadBlocks: %d, numThreadsPerBlock: %d, # items: %d\n", numThreadBlocks, numThreadsPerBlock, N);
	}

	for (i = 0; i < N; i++) {
		vOne[i] = 3333;
		vTwo[i] = 7777;
		vResult[i] = 0;
	}

	if ((status = cudaMalloc ((void**) &gpu_vOne, size)) != cudaSuccess) {
		printf("cudaMalloc() FAILED (Block), status = %d (%s)\n", status, cudaGetErrorString(status));
		exit(1);
	}

	if ((status = cudaMalloc ((void**) &gpu_vTwo, size)) != cudaSuccess) {
		printf("cudaMalloc() FAILED (Thread), status = %d (%s)\n", status, cudaGetErrorString(status));
		exit(1);
	}

	if ((status = cudaMalloc ((void**) &gpu_vResult, size)) != cudaSuccess) {
		printf("cudaMalloc() FAILED (GThread), status = %d (%s)\n", status, cudaGetErrorString(status));
		exit(1);
	}
	
	cudaMemcpy(gpu_vOne, vOne, size, cudaMemcpyHostToDevice);
	cudaMemcpy(gpu_vTwo, vTwo, size, cudaMemcpyHostToDevice);

	add_vector <<<numThreadBlocks, numThreadsPerBlock>>>
	  (gpu_vOne, gpu_vTwo, gpu_vResult, N);

	
	cudaMemcpy(vResult, gpu_vResult, size, cudaMemcpyDeviceToHost);

	#ifdef DISPLAY
	for (i = 0; i < 2; i++) {
		printf("vResult[%d] = %d\n", i, vResult[i]);
	}
	#endif

	free(vOne);
	free(vTwo);
	free(vResult);
	cudaFree(gpu_vOne);
	cudaFree(gpu_vTwo);
	cudaFree(gpu_vResult);

	exit(0);
}
