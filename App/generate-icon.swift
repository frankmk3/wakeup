import AppKit

guard CommandLine.arguments.count == 2 else {
    fatalError("Usage: generate-icon.swift <iconset-directory>")
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let files = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024),
]

func scaledPath(_ points: [(CGFloat, CGFloat)], size: CGFloat) -> NSBezierPath {
    let path = NSBezierPath()
    guard let first = points.first else { return path }
    path.move(to: NSPoint(x: first.0 * size, y: first.1 * size))
    for point in points.dropFirst() {
        path.line(to: NSPoint(x: point.0 * size, y: point.1 * size))
    }
    path.close()
    return path
}

func renderIcon(size: Int, destination: URL) throws {
    let dimension = CGFloat(size)
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        fatalError("Could not create icon bitmap")
    }

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    NSGraphicsContext.current?.imageInterpolation = .high

    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: dimension, height: dimension).fill()

    let tile = NSBezierPath(
        roundedRect: NSRect(
            x: dimension * 0.06,
            y: dimension * 0.06,
            width: dimension * 0.88,
            height: dimension * 0.88
        ),
        xRadius: dimension * 0.21,
        yRadius: dimension * 0.21
    )
    NSColor(calibratedRed: 0.96, green: 0.38, blue: 0.08, alpha: 1).setFill()
    tile.fill()

    let highlight = NSBezierPath(ovalIn: NSRect(
        x: dimension * 0.12,
        y: dimension * 0.47,
        width: dimension * 0.76,
        height: dimension * 0.48
    ))
    NSColor(calibratedRed: 1, green: 0.58, blue: 0.16, alpha: 0.32).setFill()
    highlight.fill()

    NSColor.white.setFill()
    let cup = NSBezierPath(
        roundedRect: NSRect(
            x: dimension * 0.26,
            y: dimension * 0.29,
            width: dimension * 0.43,
            height: dimension * 0.30
        ),
        xRadius: dimension * 0.075,
        yRadius: dimension * 0.075
    )
    cup.fill()

    let handle = NSBezierPath()
    handle.appendArc(
        withCenter: NSPoint(x: dimension * 0.69, y: dimension * 0.46),
        radius: dimension * 0.13,
        startAngle: -80,
        endAngle: 80
    )
    handle.lineWidth = dimension * 0.065
    handle.lineCapStyle = .round
    NSColor.white.setStroke()
    handle.stroke()

    let saucer = NSBezierPath()
    saucer.move(to: NSPoint(x: dimension * 0.23, y: dimension * 0.25))
    saucer.curve(
        to: NSPoint(x: dimension * 0.75, y: dimension * 0.25),
        controlPoint1: NSPoint(x: dimension * 0.34, y: dimension * 0.18),
        controlPoint2: NSPoint(x: dimension * 0.64, y: dimension * 0.18)
    )
    saucer.lineWidth = dimension * 0.055
    saucer.lineCapStyle = .round
    saucer.stroke()

    for x in [0.39, 0.55] as [CGFloat] {
        let steam = NSBezierPath()
        steam.move(to: NSPoint(x: dimension * x, y: dimension * 0.65))
        steam.curve(
            to: NSPoint(x: dimension * (x + 0.025), y: dimension * 0.81),
            controlPoint1: NSPoint(x: dimension * (x - 0.06), y: dimension * 0.71),
            controlPoint2: NSPoint(x: dimension * (x + 0.08), y: dimension * 0.75)
        )
        steam.lineWidth = dimension * 0.045
        steam.lineCapStyle = .round
        steam.stroke()
    }

    NSGraphicsContext.restoreGraphicsState()

    guard let png = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Could not encode icon PNG")
    }
    try png.write(to: destination)
}

for (name, size) in files {
    try renderIcon(size: size, destination: outputDirectory.appendingPathComponent(name))
}
