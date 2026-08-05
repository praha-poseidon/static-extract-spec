const label = "Open";
const href = "/users";

function submit() {
  return href;
}

export function App() {
  return <a label={label} href={href} action={submit}>Go {label}</a>;
}
