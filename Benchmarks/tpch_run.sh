#!/bin/bash

set -e 

DATA_DIR="../../data"

QUERY_DIR="../../queries"

python3 run_benchmark.py -u admin -p HyperInteractive -s localhost -n heavyai -d ${QUERY_DIR} \
    -e file_json -j "../../output/heavydb.out" -i 2 \
    -t customer -t lineitem -t nation -t orders  -t part -t partsupp -t region -t supplier -l happy 