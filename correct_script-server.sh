#!/bin/bash

# Default values
port=8080
context_length=4096
max_tokens_to_gen=2048
num_llm_instances=3
model_file=""
custom_initial_prompt_file=""

# Parse command line arguments
while [ "$1" != "" ]; do
    case $1 in
        --config )                    shift
                                      config=$1
                                      ;;
        --port )                      shift
                                      port=$1
                                      ;;
        --context_length )            shift
                                      context_length=$1
                                      ;;
        --max_tokens_to_gen )         shift
                                      max_tokens_to_gen=$1
                                      ;;
        --num_llm_instances )         shift
                                      num_llm_instances=$1
                                      ;;
        --model_file )                shift
                                      model_file=$1
                                      ;;
        --custom_initial_prompt_file ) shift
                                      custom_initial_prompt_file=$1
                                      ;;
        * )                           echo "Invalid option: $1"
                                      exit 1
    esac
    shift
done

# Check required parameter
if [ "$model_file" == "" ]; then
    echo "Model file must be specified."
    exit 1
fi

# Construct the command
if [ "$config" != "" ]; then
    # If config is specified
    command="java -jar /opt/correct_script.server/correct_script.server.jar -config=$config"
else
    # If config is not specified, build command with all parameters
    command="java -jar /opt/correct_script.server/correct_script.server.jar -P:ktor.deployment.port=$port -P:llama_cpp.model_file=\"$model_file\" -P:llama_cpp.context_length=$context_length -P:llama_cpp.max_tokens_to_gen=$max_tokens_to_gen -P:llama_cpp.num_instances=$num_llm_instances"

    # Append optional parameters if provided
    [ "$custom_initial_prompt_file" != "" ] && command+=" -P:llama_cpp.custom_initial_prompt_file=\"$custom_initial_prompt_file\""
fi

# Execute the command
echo "Executing command:"
echo $command
eval $command
