import axios from "axios";

export function App() {
  function handleSave() {
    axios.post("/api/users");
  }

  return <button onClick={handleSave}>保存</button>;
}
