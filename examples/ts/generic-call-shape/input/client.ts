const ITEM_PATH = "/api/items";

export function loadItems() {
  return request(ITEM_PATH);
}
