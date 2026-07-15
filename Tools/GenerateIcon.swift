import AppKit

guard CommandLine.arguments.count == 2 else {
    fputs("usage: GenerateIcon <output.png>\n", stderr)
    exit(2)
}

let outputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)

image.lockFocus()

let background = NSBezierPath(roundedRect: NSRect(x: 48, y: 48, width: 928, height: 928), xRadius: 218, yRadius: 218)
let gradient = NSGradient(colors: [
    NSColor(calibratedRed: 0.00, green: 0.33, blue: 0.99, alpha: 1.0),
    NSColor(calibratedRed: 0.36, green: 0.13, blue: 0.71, alpha: 1.0)
])!
gradient.draw(in: background, angle: -45)

NSColor.white.withAlphaComponent(0.18).setStroke()
background.lineWidth = 12
background.stroke()

let dashboard = NSBezierPath(roundedRect: NSRect(x: 205, y: 230, width: 614, height: 564), xRadius: 72, yRadius: 72)
NSColor.white.withAlphaComponent(0.96).setFill()
dashboard.fill()

NSColor(calibratedWhite: 0.80, alpha: 1.0).setStroke()
let divider = NSBezierPath()
divider.move(to: NSPoint(x: 205, y: 665))
divider.line(to: NSPoint(x: 819, y: 665))
divider.lineWidth = 16
divider.stroke()

let dotColors: [NSColor] = [
    NSColor(calibratedRed: 1.00, green: 0.35, blue: 0.32, alpha: 1.0),
    NSColor(calibratedRed: 1.00, green: 0.72, blue: 0.24, alpha: 1.0),
    NSColor(calibratedRed: 0.25, green: 0.78, blue: 0.38, alpha: 1.0)
]

for (index, color) in dotColors.enumerated() {
    color.setFill()
    NSBezierPath(ovalIn: NSRect(x: 267 + CGFloat(index) * 74, y: 704, width: 38, height: 38)).fill()
}

let nodePoints = [
    NSPoint(x: 365, y: 490),
    NSPoint(x: 520, y: 575),
    NSPoint(x: 665, y: 445),
    NSPoint(x: 485, y: 355)
]

let connections = [(0, 1), (1, 2), (2, 3), (3, 0), (1, 3)]
NSColor(calibratedRed: 0.08, green: 0.25, blue: 0.69, alpha: 0.72).setStroke()

for (start, end) in connections {
    let path = NSBezierPath()
    path.move(to: nodePoints[start])
    path.line(to: nodePoints[end])
    path.lineWidth = 22
    path.lineCapStyle = .round
    path.stroke()
}

for (index, point) in nodePoints.enumerated() {
    let diameter: CGFloat = index == 1 ? 86 : 68
    let rect = NSRect(x: point.x - diameter / 2, y: point.y - diameter / 2, width: diameter, height: diameter)
    NSColor(calibratedRed: 0.00, green: 0.33, blue: 0.99, alpha: 1.0).setFill()
    NSBezierPath(ovalIn: rect).fill()
    NSColor.white.setStroke()
    let border = NSBezierPath(ovalIn: rect.insetBy(dx: 8, dy: 8))
    border.lineWidth = 8
    border.stroke()
}

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else {
    fputs("failed to render icon\n", stderr)
    exit(1)
}

try png.write(to: outputURL)

