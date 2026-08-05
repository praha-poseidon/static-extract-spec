const BASE = "/users";

function Area(_path: string) {
  return () => undefined;
}

function Action(_path?: string) {
  return () => undefined;
}

@Area(BASE)
export class UsersController {
  @Action("/:id")
  findOne() {
    return "ok";
  }
}
