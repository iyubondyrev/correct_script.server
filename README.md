# CorrectScript Server

CorrectScript Server is the server-side component of the CorrectScript application, designed to automatically fix Python scripts using LLMs (Large Language Models). It receives Python scripts and error messages from the client, uses LLMs to suggest corrections, and sends the corrected script back to the client.

## Features

- Utilizes LLMs to intelligently analyze and correct Python scripts
- Supports multiple LLM instances for improved performance and scalability
- Provides a simple REST API for easy integration with client applications
- Configurable settings for model file, context length, max tokens to generate, and more
- Supports custom initial prompts for LLMs

## Requirements

- Java Runtime Environment (JRE): Requires Java to run the cli. It is tested with OpenJDK version "17.0.8.1".


## Installation

You can install CorrectScript Server using the provided installation script. Run the following command in your terminal:

```bash
curl -s https://raw.githubusercontent.com/iyubondyrev/correct_script.server/main/install.sh | bash
```

This script will download the latest version of the server artifacts, place them into /opt/correct_script.server/, and set up the necessary directories and permissions.
If you also want to download the pre-trained GGUF model during installation, you can use the following command:

```bash
curl -s https://raw.githubusercontent.com/iyubondyrev/correct_script.server/main/install.sh | DOWNLOAD_MODEL=yes bash
```

This will download quantized (q2) version of the [Phi-3-mini-4k-instruct](https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf) model. q2 version is [here](https://huggingface.co/iyubondyrev/phi_3_mini_quantized/tree/main). It is ~1.5GB.

After installation, you can start the server using the ```correct_script-server``` command.

## Configuration
CorrectScript Server provides flexible configuration options through the `config.yaml` file or command-line arguments. An example of the `config.yaml` file can be found at `src/main/resources/application.yaml`. Here's a sample configuration:

```yaml
ktor:
    application:
        modules:
            - correct_script.server.ApplicationKt.module # this should stay the same
    deployment:
        port: 8080

llama_cpp:
    context_length: 4096
    max_tokens_to_gen: 2048
    num_llm_instances: 3
    model_file: ".gguf" # required
    custom_initial_prompt_file: ".txt"
```

You can specify the configuration file using the --config command-line argument:

```bash
correct_script-server --config=/path/to/config.yaml
```

Alternatively, you can provide the configuration options as command-line arguments:

```bash
correct_script-server --port=8080 --model_file=/path/to/model.gguf
```

For more information about the available command-line arguments, run:

```bash
correct_script-server --help
```

## Usage 

The server exposes a single REST API endpoint:

```POST /fix-script```: Accepts a JSON payload with the following structure:

```json
{
  "script": "Python script to be corrected",
  "error": "Error message from the client"
}
```

It returns a JSON response with the corrected script:
```json
{
  "fixedScript": "Corrected Python script"
}
```

## Model Format

CorrectScript Server utilizes the llama_cpp bindings for Java, which operate with models in the `.gguf` format. This provides flexibility, allowing you to use any compatible LLM model of your choice. To use a specific model, simply provide the server with the corresponding `.gguf` file and adjust the `context_length` parameter according to your model's requirements.

## Customizing the Initial Prompt

CorrectScript Server allows you to customize the initial prompt used by the LLM. The default initial prompt can be found in the `src/main/resources/initial_prompt.txt` file. However, it's important to note that the server expects the model's responses to adhere to a specific JSON format:

```json
{
  "fixedScript": "Corrected Python script"
}
```
To enforce this format, the server utilizes a grammar file located at `src/main/resources/llm_grammar.gbnf` This grammar file defines the structure and constraints for the model's responses, ensuring that the corrected Python script is returned in the expected format.
If you choose to customize the initial prompt, make sure to maintain compatibility with the defined JSON format and the associated grammar file to ensure proper functionality of the server.

