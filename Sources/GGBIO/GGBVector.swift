//
//  GGBVector.swift
//  GGB
//
//  Platform-independent vector drawing definitions.
//  Keep this contract identical across projects after substituting the project prefix.
//

import Foundation

// MARK: - Geometry

/// A point in a vector drawing's local coordinate system.
public struct GGBPoint: Codable, Sendable, Equatable {
    public var x: GGBFloat
    public var y: GGBFloat

    public init(x: GGBFloat, y: GGBFloat) {
        self.x = x
        self.y = y
    }
}

/// A size in a vector drawing's local coordinate system.
public struct GGBSize: Codable, Sendable, Equatable {
    public var width: GGBFloat
    public var height: GGBFloat

    public init(width: GGBFloat, height: GGBFloat) {
        self.width = width
        self.height = height
    }
}

/// A rectangle in a vector drawing's local coordinate system.
public struct GGBRect: Codable, Sendable, Equatable {
    public var origin: GGBPoint
    public var size: GGBSize

    public init(origin: GGBPoint, size: GGBSize) {
        self.origin = origin
        self.size = size
    }

    public init(x: GGBFloat, y: GGBFloat, width: GGBFloat, height: GGBFloat) {
        self.init(origin: GGBPoint(x: x, y: y), size: GGBSize(width: width, height: height))
    }
}

// MARK: - Stroke and Fill

public enum GGBVectorLineCap: String, Codable, Sendable, Equatable {
    case butt
    case round
    case square
}

public enum GGBVectorLineJoin: String, Codable, Sendable, Equatable {
    case miter
    case round
    case bevel
}

public enum GGBVectorLinePattern: Codable, Sendable, Equatable {
    case solid
    case dashed(lengths: [GGBFloat], phase: GGBFloat = 0)
}

public struct GGBVectorStroke: Codable, Sendable, Equatable {
    public var material: GGBMaterial
    public var thickness: GGBFloat
    public var pattern: GGBVectorLinePattern
    public var cap: GGBVectorLineCap
    public var join: GGBVectorLineJoin

    public init(
        material: GGBMaterial = .black,
        thickness: GGBFloat = 1,
        pattern: GGBVectorLinePattern = .solid,
        cap: GGBVectorLineCap = .butt,
        join: GGBVectorLineJoin = .miter
    ) {
        self.material = material
        self.thickness = max(0, thickness)
        self.pattern = pattern
        self.cap = cap
        self.join = join
    }

    public init(
        color: GGBColor,
        thickness: GGBFloat = 1,
        pattern: GGBVectorLinePattern = .solid,
        cap: GGBVectorLineCap = .butt,
        join: GGBVectorLineJoin = .miter
    ) {
        self.init(
            material: .color(color),
            thickness: thickness,
            pattern: pattern,
            cap: cap,
            join: join
        )
    }
}

public enum GGBVectorFillPattern: Codable, Sendable, Equatable {
    case material(GGBMaterial)
    case solid(GGBColor)
}

public struct GGBVectorFill: Codable, Sendable, Equatable {
    public var pattern: GGBVectorFillPattern

    public init(pattern: GGBVectorFillPattern) {
        self.pattern = pattern
    }

    public init(material: GGBMaterial) {
        self.pattern = .material(material)
    }

    public init(color: GGBColor) {
        self.pattern = .material(.color(color))
    }
}

// MARK: - Drawing Behavior

public enum GGBVectorArcDirection: String, Codable, Sendable, Equatable {
    case clockwise
    case counterclockwise
}

public enum GGBVectorContentMode: String, Codable, Sendable, Equatable {
    case fit
    case fill
    case stretch
    case original
}

public enum GGBVectorAlignment: String, Codable, Sendable, Equatable {
    case topLeading
    case top
    case topTrailing
    case leading
    case center
    case trailing
    case bottomLeading
    case bottom
    case bottomTrailing
}

/// Issues platform-independent drawing commands in a local coordinate system.
/// The origin is at the upper-left, positive x extends right, and positive y extends down.
public protocol GGBVectorDrawingProtocol: AnyObject {
    /// The logical bounds visible to drawing commands, independent of physical output size.
    var bounds: GGBRect { get }

    func drawLine(from start: GGBPoint, to end: GGBPoint, stroke: GGBVectorStroke)
    func drawRectangle(in rect: GGBRect, stroke: GGBVectorStroke?, fill: GGBVectorFill?)
    func drawRoundedRectangle(
        in rect: GGBRect,
        cornerRadius: GGBFloat,
        stroke: GGBVectorStroke?,
        fill: GGBVectorFill?
    )
    func drawOval(in rect: GGBRect, stroke: GGBVectorStroke?, fill: GGBVectorFill?)

    /// Draws an arc whose zero-degree angle points right. Positive angles follow the clockwise
    /// direction of the local coordinate system unless `direction` specifies otherwise.
    func drawArc(
        center: GGBPoint,
        radius: GGBFloat,
        startAngle: GGBFloat,
        endAngle: GGBFloat,
        direction: GGBVectorArcDirection,
        stroke: GGBVectorStroke
    )

    func drawPolygon(
        points: [GGBPoint],
        stroke: GGBVectorStroke?,
        fill: GGBVectorFill?
    )
    func drawQuadraticBezier(
        from start: GGBPoint,
        control: GGBPoint,
        to end: GGBPoint,
        stroke: GGBVectorStroke
    )
    func drawCubicBezier(
        from start: GGBPoint,
        control1: GGBPoint,
        control2: GGBPoint,
        to end: GGBPoint,
        stroke: GGBVectorStroke
    )

    /// Draws bitmap data, optionally cropping it with `sourceRect`, into `destinationRect`.
    func drawBitmap(
        data: Data,
        sourceRect: GGBRect?,
        destinationRect: GGBRect,
        opacity: GGBFloat
    )

    /// Offers opaque developer-defined data to a specialized drawer.
    /// Returns true when the drawer recognizes and handles the command.
    @discardableResult
    func drawSpecialData(type: String, data: String) -> Bool
}

public extension GGBVectorDrawingProtocol {
    @discardableResult
    func drawSpecialData(type: String, data: String) -> Bool {
        false
    }
}

/// Reusable drawing code that can target a native drawer or a recorder.
public typealias GGBVectorDrawingClosure = (_ drawer: any GGBVectorDrawingProtocol) -> Void
