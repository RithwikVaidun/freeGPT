function App() {
  const [input, setInput] = useState();
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
      {
        method: "POST",
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
            color: "#000",
          }}
        >
          <span>
            Model: <strong>{selectedModel}</strong>
          </span>
          <span style={{ marginLeft: "8px" }}>▼</span>
        </button>

        {isDropdownOpen && (
          <div>
            {models.map((model) => (
              <div key={model.id} onClick={() => selectModel(model.id)}>
                <div></div>
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
      </div>

      {/* Response display */}
      <div
        className="card"
        style={{
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
