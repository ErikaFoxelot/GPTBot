# GPTBot

GPTBot is a command line tool for interacting with OpenAI's chat models. It provides a convenient way to communicate with the models using a simple command line interface.

## Usage

To use GPTBot, follow these steps:

1. Clone this repository.

2. Build the project by running `swift build` in the project directory.

3. Run the GPTBot command by executing the binary produced in the previous step. The command has the following structure:

   ```
   gptbot [--debug] [--stream] [--stats] [--api-key <API_KEY>] [--org <ORG>] [--input-files <INPUT_FILES>] [--system-prompt-file <SYSTEM_PROMPT_FILE>] [--output-file <OUTPUT_FILE>] [--temperature <TEMPERATURE>] [--max-tokens <MAX_TOKENS>] [--model <MODEL>] [prompt]
   ```

   - `--debug`: Enable debug mode.
   - `--stream`: Enable streaming mode, which emits the response as it comes in.
   - `--stats`: Include performance statistics in the response.
   - `--api-key <API_KEY>`: OpenAI API key. If not specified, the `OPENAI_API_KEY` environment variable will be used.
   - `--org <ORG>`: OpenAI API organization. If not specified, the `OPENAI_ORGANIZATION` environment variable will be used.
   - `--input-files <INPUT_FILES>`: Path to file or files to include with the user prompt. If input files are used, a prompt does not need to be specified. If a file is binary, prefix its path with '!'. To read from standard input, use 'stdin' as the path.
   - `--system-prompt-file <SYSTEM_PROMPT_FILE>`: Path to a file to use as the system prompt. If not specified, a default system prompt will be used.
   - `--output-file <OUTPUT_FILE>`: Path to output the response to. This file will be overwritten if it already exists. If specified, the response will not be printed to the console.
   - `--temperature <TEMPERATURE>`: Temperature to use for the model. Value between 0 and 1.
   - `--max-tokens <MAX_TOKENS>`: Max tokens to use for the model. Value between 1 and 4096.
   - `--model <MODEL>`: The model to use for the response. See [OpenAI's documentation](https://platform.openai.com/docs/models/) for a list of available models.
   - `prompt`: The prompt to use for the response. Can be left empty if input files are used.

4. Review the response from the GPT model.

## Example

Here is an example command to run GPTBot:

```
gptbot --stream --api-key YOUR_API_KEY --model gpt-3.5-turbo "What is the meaning of life?"
```

This command runs GPTBot in debug mode, using your OpenAI API key and the `gpt-3.5-turbo` model. The prompt is set to "What is the meaning of life?".

## License

GPTBot is released under the [MIT License](LICENSE.md).

## Acknowledgements

GPTBot uses [MacPaw's OpenAI Swift](https://github.com/MacPaw/OpenAI.git) for communicating with OpenAI's API, and [alfianlosari's GPTEncoder](https://github.com/alfianlosari/GPTEncoder.git) for calculating token usage.

## Contributing

Contributions to GPTBot are welcome!