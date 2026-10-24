// Types stdin text as keystrokes into the frontmost app; stops when Escape is held/pressed.
import Cocoa

let text = String(data: FileHandle.standardInput.readDataToEndOfFile(), encoding: .utf8) ?? ""
let delay = UInt32((Double(CommandLine.arguments.dropFirst().first ?? "") ?? 0.02) * 1_000_000)
let source = CGEventSource(stateID: .hidSystemState)
let escape: CGKeyCode = 53

func escapePressed() -> Bool { CGEventSource.keyState(.combinedSessionState, key: escape) }

func post(_ char: Character) {
  if char == "\n" || char == "\r" { return key(36) }
  if char == "\t" { return key(48) }
  let utf16 = Array(String(char).utf16)
  for down in [true, false] {
    let e = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: down)
    e?.keyboardSetUnicodeString(stringLength: utf16.count, unicodeString: utf16)
    e?.post(tap: .cghidEventTap)
  }
}

func key(_ code: CGKeyCode) {
  CGEvent(keyboardEventSource: source, virtualKey: code, keyDown: true)?.post(tap: .cghidEventTap)
  CGEvent(keyboardEventSource: source, virtualKey: code, keyDown: false)?.post(tap: .cghidEventTap)
}

usleep(250_000) // let the launcher hand focus back to the target field
for char in text {
  if escapePressed() { print("cancelled"); exit(2) }
  post(char)
  usleep(delay + UInt32.random(in: 0...(delay / 2 + 1))) // slight jitter feels human
}
print("done")
