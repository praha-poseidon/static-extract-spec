declare const API_URL: string;

export function loadUsers() {
  return fetch(API_URL);
}
