function usersUrl() {
  return readConfig("usersUrl");
}

export function loadUsers() {
  return fetch(usersUrl());
}
