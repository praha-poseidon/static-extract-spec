const config = {
  get(key: string) {
    return key;
  }
};

export function loadUsers() {
  return fetch(config.get("usersUrl"));
}
