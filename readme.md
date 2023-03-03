## ChatGPT from Bash

This is a Bash script that can be sourced in your .bashrc to query the OpenAI GPT model from the command line. It tracks the conversation history in a file /tmp/gpt_cli_conversation.

### Prerequisites

Before you can use this script, you need to set the OPENAI_API_KEY environment variable. You can do this by setting it manually like this:
`export OPENAI_API_KEY=[your_api_key]`
Alternatively, you can use a password manager like pass to get the key:
`export OPENAI_API_KEY=$(pass openaiapikey)`
If the script can't find the API key, it will try to receive it from pass. You can change this behavior in line 16 of the script.

### Usage

To use the script, source it in your .bashrc:
`source /path/to/ChatGPTfromBash.sh`

Then, you can use it like this:
`gpt Hello, who are you?`
This will query the model with the given text and print the response to the console.

You can also reset the conversation by using the --reset flag:
`gpt --reset`
This will clear the conversation history and start a new conversation. Currently only one conversation can be tracked at a time.

### Flags

The following flags are supported:

-h, --help: Show help
--reset: Reset the conversation

### Acknowledgements

This script was co-authored by ChatGPT - just for good measure...

### License

No warranty, no liability, no license. Do as you please.
