import json
import os
import subprocess
import tempfile
import time

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://localhost:5000",
        "https://12fb-76-235-133-200.ngrok-free.app",
        "https://12fb-76-235-133-200.ngrok-free.app",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post("/test")
async def test(request: Request):
    print("test")
    return {"message": f"i hate frontend"}


@app.post("/trigger")
async def trigger(request: Request):
    data = await request.json()
    user_input = data.get("message", "")
    model = data.get("model", "")

    # lua_file_path = "/Users/rithwik/rithwik/projects/auto_gpt/test.lua"
    # hs_command = (
    #     f'dofile("{lua_file_path}"); local text = {json.dumps(user_input)}; test(text)'
    # )

    lua_file_path = "/Users/rithwik/rithwik/projects/auto_gpt/hack.lua"

    hs_command = f"""
    dofile("{lua_file_path}")
    local text = {json.dumps(user_input)}
    local model = {json.dumps(model)}
    selectModel(model)
    hs.timer.usleep(500000) 
    askGPTSmart(text)
    """

    output_file = "/Users/rithwik/rithwik/projects/auto_gpt/text.md"

    try:
        before_mod_time = os.path.getmtime(output_file)
    except FileNotFoundError:
        before_mod_time = 0  # File doesn't exist yet

    try:

        print("Starting Hammerspoon subprocess")
        result = subprocess.run(
            ["hs", "-c", hs_command],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )

        print("from hammerspoon stdout:", result.stdout)

        if result.returncode != 0:
            return {"error": "Hammerspoon error", "details": result.stderr}

        timeout = 20
        polling_interval = 0.5
        start_time = time.time()

        while True:
            try:
                current_mod_time = os.path.getmtime(output_file)
                if current_mod_time > before_mod_time:

                    break
            except FileNotFoundError:

                pass

            if time.time() - start_time > timeout:
                raise TimeoutError("Timeout waiting for file update.")

            time.sleep(polling_interval)

        with open(output_file, "r") as f:
            content = f.read()

        return {"message": content.strip()}

    except Exception as e:
        return {"error": str(e)}


@app.post("/selectModel")
async def change(request: Request):
    data = await request.json()
    user_input = data.get("message", "")
    model = data.get("model", "")
    print(f"model: {model}")

    # lua_file_path = "/Users/rithwik/rithwik/projects/auto_gpt/test.lua"
    # hs_command = (
    #     f'dofile("{lua_file_path}"); local text = {json.dumps(user_input)}; test(text)'
    # )

    lua_file_path = "/Users/rithwik/rithwik/projects/auto_gpt/hack.lua"
    # hs_command = f'dofile("{lua_file_path}"); local text = {json.dumps(user_input)}; askGPTSmart(text)'
    hs_command = f'dofile("{lua_file_path}"); local model = {json.dumps(model)}; selectModel(model)'

    try:
        # Step 2: Run the hs -c Lua process
        result = subprocess.run(
            ["hs", "-c", hs_command],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )

        print("from hammerspoon stdout:", result.stdout)

        if result.returncode != 0:
            return {"error": "Hammerspoon error", "details": result.stderr}

        return {"message": "success"}

    except Exception as e:
        return {"error": str(e)}
