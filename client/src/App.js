import React, { useState } from "react";

function App() {
  const [response, setResponse] = useState("");

  // Read API URL from environment variable
  const API_BASE_URL = process.env.REACT_APP_API_URL || "http://localhost:4000";

  const callApi = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/express/`);
      const text = await res.text();
      setResponse(text);
    } catch (error) {
      setResponse("Error fetching API");
    }
  };

  return (
    <div>
      <h1>Minimal React App Updated1</h1>
      <button onClick={callApi}>Call API</button>
      <div dangerouslySetInnerHTML={{ __html: response }} />
    </div>
  );
}

export default App;
