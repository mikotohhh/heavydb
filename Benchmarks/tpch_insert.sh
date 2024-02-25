#!/bin/bash

set -e -x

TABLES=("customer" "lineitem" "nation" "orders" "part" "partsupp" "region" "supplier")

# Iterate over each table in the array
for TABLE in "${TABLES[@]}"; do
    python3 run_benchmark_import.py -u admin -p HyperInteractive -s localhost -n heavyai -l TestLabel -f \
    "/home/misaka/tpch-dbgen/${TABLE}.csv" -c "/home/misaka/tpch-dbgen/${TABLE}.ddl" -e output -t $TABLE --no-drop-table-after
done
