import { USERS_URL } from "./config";

export function loadUsers() {
  return fetch(USERS_URL);
}
