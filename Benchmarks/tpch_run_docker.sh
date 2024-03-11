c#!/bin/bash

set -e 

DATA_DIR="/working_dir/data"

QUERY_DIR="/working_dir/heavydb_queries"

# python3 run_benchmark.py -u admin -p HyperInteractive -s localhost -n heavyai -d ${QUERY_DIR} -i 2 \
# -t customer -t lineitem -t nation -t orders  -t part -t partsupp -t region -t supplier -l happy \
# -e file_json -j "/working_dir/output/heavydb.json"

# python3 run_benchmark.py -u admin -p HyperInteractive -s localhost -n heavyai \
# -t customer -t lineitem -t nation -t orders  -t part -t partsupp -t region -t supplier \
# -l happy -d ${QUERY_DIR} -i 2 -e output 

python3 run_benchmark.py -u admin -p HyperInteractive -s localhost -n heavyai -d ${QUERY_DIR} -e output -i 10 \
-t customer -t lineitem -t nation -t orders  -t part -t partsupp -t region -t supplier -l happy 