import { Action, ActionPanel, closeMainWindow, environment, Form, showHUD, showToast, Toast } from "@raycast/api";
import { spawn } from "child_process";
import { chmodSync } from "fs";
import { join } from "path";

type Values = { text: string; speed: string };

async function typeText({ text, speed }: Values) {
  if (!text) { await showToast({ style: Toast.Style.Failure, title: "Paste some text first" }); return; }
  const helper = join(environment.assetsPath, "typer-helper");
  chmodSync(helper, 0o755);
  await closeMainWindow({ clearRootSearch: true });
  const child = spawn(helper, [speed]);
  child.stdin.end(text);
  child.on("close", (code) => showHUD(code === 2 ? "Typer cancelled" : code === 0 ? "Typer done" : "Typer failed — allow Tinycast in Accessibility"));
}

export default function Command() {
  return (
    <Form actions={<ActionPanel><Action.SubmitForm title="Type It" onSubmit={typeText} /></ActionPanel>}>
      <Form.TextArea id="text" title="Text" placeholder="Paste text, then press ⌘↵ (Esc cancels while typing)" autoFocus />
      <Form.Dropdown id="speed" title="Speed" defaultValue="0.02" storeValue>
        <Form.Dropdown.Item value="0.06" title="Human" />
        <Form.Dropdown.Item value="0.02" title="Fast" />
        <Form.Dropdown.Item value="0.005" title="Instant" />
      </Form.Dropdown>
    </Form>
  );
}
