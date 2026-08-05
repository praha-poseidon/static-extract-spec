export function loadUsers() {
  let url;
  url = readConfig("usersUrl");
  return fetch(url);
}
