#!/bin/bash

set -e -x

TABLES=("customer" "lineitem" "nation" "orders" "part" "partsupp" "region" "supplier")

<<<<<<< HEAD
DATA_DIR="${HOME}/crystal_bench/data"

DDL_DIR="tpch_ddl"

# Iterate over each table in the array
for TABLE in "${TABLES[@]}"; do
    python3 run_benchmark_import.py -u admin -p HyperInteractive -s localhost -n heavyai -l TestLabel -f \
    "${DATA_DIR}/${TABLE}.csv" -c "${DDL_DIR}/${TABLE}.ddl" -e output -t $TABLE --no-drop-table-after
=======
# Iterate over each table in the array
for TABLE in "${TABLES[@]}"; do
    python3 run_benchmark_import.py -u admin -p HyperInteractive -s localhost -n heavyai -l TestLabel -f \
    "/home/misaka/tpch-dbgen/${TABLE}.csv" -c "/home/misaka/tpch-dbgen/${TABLE}.ddl" -e output -t $TABLE --no-drop-table-after
>>>>>>> a77582fd325afc90f3194a1ad00554663d97bb90
done
