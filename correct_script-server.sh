#!/bin/bash

show_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --config=PATH                    Specify the configuration file, if specified everything else will be ignored."
    echo "  --port=PORT                      Set the server port. Default is 8080."
    echo "  --context_length=LENGTH          Set the context length. Default is 4096, max is 4096."
    echo "  --max_tokens_to_gen=MAX          Set the maximum tokens to generate. Default is 2048."
    echo "  --num_llm_instances=NUM          Set the number of LLM instances. Default is 2."
    echo "  --model_file=FILE                Specify the model file (required)."
    echo "  --custom_initial_prompt_file=FILE Specify the custom initial prompt file."
    echo "  --help                           Display this help and exit."
    echo ""
}

# Default values
port=8080
context_length=4096
max_tokens_to_gen=2048
num_llm_instances=2
model_file=""
custom_initial_prompt_file=""

# Parse command line arguments
while [ "$1" != "" ]; do
    case "${1%%=*}" in  # Extracts the part of $1 before '=' if it exists
        --config )
            config="${1#*=}"  # Gets the part after '='
            ;;
        --port )
            port="${1#*=}"
            ;;
        --context_length )
            context_length="${1#*=}"
            ;;
        --max_tokens_to_gen )
            max_tokens_to_gen="${1#*=}"
            ;;
        --num_llm_instances )
            num_llm_instances="${1#*=}"
            ;;
        --model_file )
            model_file="${1#*=}"
            ;;
        --custom_initial_prompt_file )
            custom_initial_prompt_file="${1#*=}"
            ;;
        --help )
            show_help
            exit 0
            ;;
        * )
            echo "Invalid option: $1"
            show_help
            exit 1
    esac
    shift
done

# Check required parameter
if [ "$model_file" == "" ] && [ "$config" == "" ]; then
    echo "Model file or configuration must be specified."
    show_help
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
