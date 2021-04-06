# File: run-vector-addition.sh

for block in 1 2 4 8 16 32 64 128 256 512 1024; do echo "blocks = `echo $block`"; (for thread in 1 2 4 8 16 32 64 128 256 512 1024 2048 4096 10000 20000 50000 100000 200000 500000 1000000; do echo "threads = `echo $thread`"; time (./vector-addition-cuda -b $block -t $thread -n 2000000 -d 1); done); done
