import axios from "axios";

const USERS_PATH = "/api/users";

export function UsersPage() {
  async function loadUsers() {
    await axios.get(USERS_PATH);
  }

  async function createUser() {
    await axios.post("/api/users");
  }

  return <button>Load users</button>;
}
