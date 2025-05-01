# Free OpenAI API

Intstead of paying for tokens, convert a mac laptop into an API to make requests for you.

## Demo

https://github.com/user-attachments/assets/41af3589-ab9e-4e82-a5c9-f83f51e9412f

### Implementation

1. The mac runs an web server with an endpoint called "/trigger". Client passes the model and prompt in the payload.
2. When the endpoint is hit, it starts a subprocess that loads and executes a Lua script through Hammerspoon’s CLI.
3. The script essentially controls the mac to open chatGPT, change the model, enter the prompt, wait for the response, and write it to a file.
4. The server waits for the file to appear/change and returns the content of the file.

\* macOS version needs to be > 12.0 and enable accessibility  
\* could get more than 20$ worth API calls with premium account.

ffmpeg -i demo.MOV -an -c:v libx264 -crf 23 -preset fast output.mp4
