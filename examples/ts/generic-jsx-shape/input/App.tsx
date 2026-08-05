const titleLabel = "保存用户";

export function App() {
  function handleSave() {
    return titleLabel;
  }

  return <ActionButton title={titleLabel} onClick={handleSave}>保存</ActionButton>;
}
