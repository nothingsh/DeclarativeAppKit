import AppKit

@MainActor
public extension NSImageView {

    @discardableResult
    func image(_ value: NSImage?) -> Self {
        self.image = value
        return self
    }

    @discardableResult
    func imageScaling(_ value: NSImageScaling) -> Self {
        self.imageScaling = value
        return self
    }

    @discardableResult
    func imageAlignment(_ value: NSImageAlignment) -> Self {
        self.imageAlignment = value
        return self
    }

    @discardableResult
    func contentTintColor(_ value: NSColor?) -> Self {
        self.contentTintColor = value
        return self
    }
}
