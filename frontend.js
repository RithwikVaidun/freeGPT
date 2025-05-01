import { useState } from "react";
import reactLogo from "./assets/react.svg";
import viteLogo from "/vite.svg";
import "./App.css";

function App() {
  const [input, setInput] = useState(
    "tell me something interesting in one sentence",
  );
  const [responseMessage, setResponseMessage] = useState("");
  const [selectedModel, setSelectedModel] = useState("o4"); // Default selected model
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const models = [
    { id: "4o", name: "4o" },
    { id: "o3", name: "o3" },
    { id: "o4", name: "o4" },
    { id: "o4 mini high", name: "o4 mini high" },
  ];

  const trigger = async () => {
    setIsLoading(true);
    try {
      const response = await fetch(
        "https://501b-76-235-133-200.ngrok-free.app/trigger",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "ngrok-skip-browser-warning": "true",
          },
          body: JSON.stringify({
            message: input,
            model: selectedModel,
          }),
        },
      );
      const data = await response.json();
      setResponseMessage(data.message);
    } finally {
      setIsLoading(false);
    }
  };

  const test = async () => {
    const response = await fetch(
      "https://501b-76-235-133-200.ngrok-free.app/test",
      // "http://127.0.0.1:8000/test",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: JSON.stringify({
          message: input,
          model: selectedModel,
        }),
      },
    );
    const data = await response.json();
    setResponseMessage(data.message);
  };

  const runModel = async () => {
    const response = await fetch(
      "https://501b-76-235-133-200.ngrok-free.app/selectModel",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "true",
        },
        body: JSON.stringify({
          message: input,
          model: selectedModel,
        }),
      },
    );
    const data = await response.json();
    setResponseMessage(data.message);
  };

  const toggleDropdown = () => {
    setIsDropdownOpen(!isDropdownOpen);
  };

  const selectModel = (model) => {
    setSelectedModel(model);
    setIsDropdownOpen(false);
  };

  return (
    <>
      <h1>FREE OpenAI API</h1>

      {/* Model Picker Dropdown */}
      <div
        className="model-picker"
        style={{ position: "relative", marginBottom: "20px" }}
      >
        <button
          onClick={toggleDropdown}
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            width: "180px",
            padding: "8px 12px",
            fontSize: "14px",
            borderRadius: "8px",
            border: "1px solid #ccc",
            backgroundColor: "#fff",
            cursor: "pointer",
            color: "#000", // Explicitly setting text color to black
          }}
        >
          <span>
            Model: <strong>{selectedModel}</strong>
          </span>
          <span style={{ marginLeft: "8px" }}>▼</span>
        </button>

        {isDropdownOpen && (
          <div
            style={{
              position: "absolute",
              top: "100%",
              left: "0",
              width: "180px",
              backgroundColor: "#fff",
              boxShadow: "0 2px 10px rgba(0,0,0,0.1)",
              borderRadius: "8px",
              marginTop: "4px",
              zIndex: 10,
              color: "#000", // Explicitly setting text color to black
            }}
          >
            {models.map((model) => (
              <div
                key={model.id}
                onClick={() => selectModel(model.id)}
                style={{
                  padding: "10px 12px",
                  cursor: "pointer",
                  borderBottom: "1px solid #f0f0f0",
                  display: "flex",
                  alignItems: "center",
                  backgroundColor:
                    selectedModel === model.id ? "#f0f0f0" : "transparent",
                  color: "#000", // Explicitly setting text color to black
                }}
              >
                <div
                  style={{
                    width: "10px",
                    height: "10px",
                    borderRadius: "50%",
                    marginRight: "10px",
                    backgroundColor:
                      selectedModel === model.id ? "#4285f4" : "#ccc",
                  }}
                ></div>
                {model.name}
              </div>
            ))}
          </div>
        )}
      </div>

      <div className="card">
        <input
          type="text"
          placeholder="Type your message"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          style={{ padding: "8px", fontSize: "16px", width: "300px" }}
        />
        <button onClick={trigger} style={{ marginLeft: "10px" }}>
          Send
        </button>

        {/* <button onClick={runModel} style={{ marginLeft: "10px" }}> */}
        {/*   change model */}
        {/* </button> */}
        {/**/}
        {/* <button onClick={test} style={{ marginLeft: "10px" }}> */}
        {/*   test */}
        {/* </button> */}
      </div>
      {isLoading && (
        <div style={{ marginTop: "20px" }}>
          <div
            style={{
              width: "24px",
              height: "24px",
              border: "4px solid #ccc",
              borderTop: "4px solid #4285f4",
              borderRadius: "50%",
              animation: "spin 1s linear infinite",
              margin: "auto",
            }}
          ></div>
        </div>
      )}

      {/* Response display */}
      <div
        className="card"
        style={{
          marginTop: "20px",
          padding: "10px",
          border: "1px solid #ccc",
          borderRadius: "8px",
          backgroundColor: "#f9f9f9",
          color: "#333",
          width: "320px",
          wordWrap: "break-word",
        }}
      >
        <strong>Response:</strong> {responseMessage}
      </div>
    </>
  );
}

export default App;
