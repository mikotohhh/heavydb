#!/bin/bash

set -e 

DATA_DIR="${HOME}/crystal_bench/data"

QUERY_DIR="${HOME}/crystal_bench/queries"

python run_benchmark.py -u admin -p HyperInteractive -s localhost -n heavyai -d ${QUERY_DIR} -e output -i 10 \
-t customer -t lineitem -t nation -t orders  -t part -t partsupp -t region -t supplier -l happy 

