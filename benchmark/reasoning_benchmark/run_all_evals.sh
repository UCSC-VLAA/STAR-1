#!/bin/bash

# Create output directories
mkdir -p eval_out/full

# Define models
MODELS=(
    "DeepSeek-R1-Distill-Qwen-7B"
    "DeepSeek-R1-Distill-Llama-8B"
    "DeepSeek-R1-Distill-Qwen-7B-STAR1"
    "DeepSeek-R1-Distill-Llama-8B-STAR1"
)

# Define common evaluation parameters
RANDOM_SEED=46
DEBUG=False

# Function to run evaluation for a specific benchmark
run_eval() {
    local benchmark=$1
    local model=$2
    local gpu_ids=$3
    local max_tokens=$4
    local ngpu=$5
    local output_dir=$6

    echo "Running ${benchmark} evaluation for model: ${model}"
    CUDA_VISIBLE_DEVICES=${gpu_ids} python simple_evals.py \
        --model="${model}" \
        --eval_mode="${benchmark}" \
        --debug ${DEBUG} \
        --random_seed=${RANDOM_SEED} \
        --ngpu ${ngpu} \
        --max_tokens ${max_tokens} \
        > ${output_dir}/${benchmark}_${model##*/}.out 2>&1
}

echo "Starting evaluations for all benchmarks with random seed ${RANDOM_SEED}..."

# AIME evaluations
echo "Running AIME evaluations..."
run_eval "aime" "${MODELS[0]}" "0,1" 16384 2 "eval_out/full" &
run_eval "aime" "${MODELS[1]}" "2,3" 16384 2 "eval_out/full" &
run_eval "aime" "${MODELS[2]}" "4,5" 16384 2 "eval_out/full" &
run_eval "aime" "${MODELS[3]}" "6,7" 16384 2 "eval_out/full" &
wait

# HumanEval evaluations
echo "Running HumanEval evaluations..."
run_eval "humaneval" "${MODELS[0]}" "0,1" 16384 2 "eval_out/full" &
run_eval "humaneval" "${MODELS[1]}" "2,3" 16384 2 "eval_out/full" &
run_eval "humaneval" "${MODELS[2]}" "4,5" 16384 2 "eval_out/full" &
run_eval "humaneval" "${MODELS[3]}" "6,7" 16384 2 "eval_out/full" &
wait

# GPQA evaluations
echo "Running GPQA evaluations..."
run_eval "gpqa" "${MODELS[0]}" "0,1" 32768 2 "eval_out/full" &
run_eval "gpqa" "${MODELS[1]}" "2,3" 32768 2 "eval_out/full" &
run_eval "gpqa" "${MODELS[2]}" "4,5" 32768 2 "eval_out/full" &
run_eval "gpqa" "${MODELS[3]}" "6,7" 32768 2 "eval_out/full" &
wait

# MATH evaluations
echo "Running MATH evaluations..."
run_eval "math" "${MODELS[0]}" "0,1" 16384 2 "eval_out/full" &
run_eval "math" "${MODELS[1]}" "2,3" 16384 2 "eval_out/full" &
run_eval "math" "${MODELS[2]}" "4,5" 16384 2 "eval_out/full" &
run_eval "math" "${MODELS[3]}" "6,7" 16384 2 "eval_out/full" &
wait

# MMLU Pro evaluations for 7B models
echo "Running MMLU Pro evaluations for 7B models..."
run_eval "mmlu_pro" "${MODELS[1]}" "0,1,2,3" 4096 4 "eval_out/full" &
run_eval "mmlu_pro" "${MODELS[3]}" "4,5,6,7" 4096 4 "eval_out/full" &
wait

# MMLU Pro evaluations for 8B models
echo "Running MMLU Pro evaluations for 8B models..."
run_eval "mmlu_pro" "${MODELS[0]}" "0,1,2,3" 4096 4 "eval_out/full" &
run_eval "mmlu_pro" "${MODELS[2]}" "4,5,6,7" 4096 4 "eval_out/full" &
wait

echo "All evaluations completed!"
echo "Results are saved in result/ directory"
echo "Logs are saved in eval_out/full/ directory"