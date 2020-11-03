#!/bin/bash
killJobs() {
    for i in $(seq 1 $1); do
        kill %$i
    done
}
