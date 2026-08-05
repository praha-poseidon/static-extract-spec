function auth(_req: unknown, _res: unknown, next: () => void) {
  next();
}

function updateUser() {
  return "ok";
}

function createHandler() {
  return updateUser;
}

const controller = {
  handler() {
    return "ok";
  }
};

const map = {
  patch(_path: string) {
    return "ignored";
  }
};

map.patch("/ignored");
router.get("/users", updateUser);
router.post("/users", auth, controller.handler);
router.put("/users/:id", createHandler());
router.patch("/users/:id", auth, async () => {});
router.delete("/users/:id", function(_req: unknown, _res: unknown) {});
