import Cocoa

class PasteableSecureTextField: NSSecureTextField {
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        // Command+V
        if event.type == .keyDown && event.modifierFlags.contains(.command) && event.characters == "v" {
            if let pasteboardString = NSPasteboard.general.string(forType: .string) {
                self.stringValue = pasteboardString
                return true
            }
        }
        return super.performKeyEquivalent(with: event)
    }
} 