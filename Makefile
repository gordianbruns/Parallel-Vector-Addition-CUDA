CC = nvcc
CFLAGS = -O0

TARGETS = vector-addition-cuda

all: $(TARGETS)

vector-addition-cuda : vector-addition-cuda.cu
	$(CC) $(CFLAGS) -o $@ $^

clean :
	rm -f vector-addition-cuda
