import React from "react";
import { useState } from "react";

function App() {
  const [response, setResponse] = useState("");

  const callApi = async () => {
    try {
      const res = await fetch("http://165.232.190.41:4100/express/");
      const text = await res.text();
      setResponse(text);
    } catch (error) {
      setResponse("Error fetching API");
    }
  };

  return (
    <div>
      <h1>Minimal React App</h1>
      <button onClick={callApi}>Call API</button>
      <div dangerouslySetInnerHTML={{ __html: response }} />
    </div>
  );
}

export default App;
