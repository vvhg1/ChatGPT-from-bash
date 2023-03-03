#!/bin/bash

# This script is used to query the ChatGPT model from the command line.
# It tracks the conversation history in a file: /tmp/gpt_cli_conversation
# To use it, source it in your .bashrc like this:
# source /path/to/ChatGPTfromBash.sh
# Then you can use it like this:
# gpt Hello, who are you?

# Before you can use it, you need to set the OPENAI_API_KEY environment variable.
# You can do this here
# This version of the script uses pass to get the key from the password store
# If you don't use pass, you can set the key manually like this: export OPENAI_API_KEY=[your_api_key]
addopenaiapikey() {
    #do whatever here to get the key e.g. pass or set it manually
    export OPENAI_API_KEY=$(pass openaiapikey)
    if [ -z "$OPENAI_API_KEY" ]; then
        echo "environment variable OPENAI_API_KEY is not set, exiting..."
        return 1
    fi
    return 0
}

gpt() {

    show_help() {
        echo "gpt"
        echo ""
        echo "Description:"
        echo "This script is used to query the ChatGPT model from the command line."
        echo "It tracks the conversation history in a file: /tmp/gpt_cli_conversation"
        echo ""
        echo "Usage: gpt <query>"
        echo "Or: gpt --reset to reset the conversation"
        echo ""
        echo "Flags"
        echo ""
        echo "-h, --help: Show help"
        echo ""
        echo "--reset: Reset the conversation"
        echo ""
        return 0
    }

    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        show_help
        return 0
    fi
    # path to the temporary file holding the conversation
    conversation_file=/tmp/gpt_cli_conversation
    query="$@"
    system_prompt='{"role": "system", "content": "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly."}, {"role": "user", "content": " Hello, who are you?"}, {"role": "assistant", "content": "I am an AI created by OpenAI. How can I help you today?"},'
    for arg in "$@"; do
        case $arg in
        --reset)
            if [[ "$@" == *"--reset"* ]]; then
                #clear the conversation file, just echo the general system prompt
                echo -e "$system_prompt" >"$conversation_file"
                return 0
            fi
            ;;
        esac
    done

    if [ -z "$OPENAI_API_KEY" ]; then
        if ! addopenaiapikey; then
            echo "no api key found, exiting..."
            return 1
        fi
    fi
    if [ -z "$query" ]; then
        echo "no query provided, exiting..."
        return 1
    fi
    # read the conversation history from the file, if it exists
    if [ -f "$conversation_file" ]; then
        conversation=$(cat "$conversation_file")
    else
        conversation="$system_prompt"
    fi

    read -r -d '' conversation <<EOF
      $conversation
        {"role": "user", "content": "$query"}
EOF
    read -r -d '' messages <<EOF
  "messages": [
      $conversation
  ]
EOF
    response=$(curl -s https://api.openai.com/v1/chat/completions \
        -H 'Content-Type: application/json' \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "{
  \"model\": \"gpt-3.5-turbo\",
  $messages
        }" \
        --insecure)

    ai_response=$(echo "$response" | jq -r '.choices[0].message.content')
    # cut everything before "choices":[{"message":
    response=${response#*choices\":[{\"message\":}
    # cut this off the end ,"finish_reason
    response=${response%,\"finish_reason*}

    read -r -d '' conversation_for_file <<EOF
        $conversation, $response,
EOF
    echo "$conversation_for_file" >"$conversation_file"

    echo
    echo -e $ai_response
}
