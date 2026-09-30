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
    /// Draws bitmap content using a material as its tint/mask paint.
    /// Returns false when this backend does not implement painted bitmap drawing.
    @discardableResult
    func drawBitmap(
        data: Data,
        sourceRect: GGBRect?,
        destinationRect: GGBRect,
        opacity: GGBFloat,
        material: GGBMaterial
    ) -> Bool

    /// Offers a specialized command together with its paint.
    /// Returns false when the backend does not handle this painted command.
    @discardableResult
    func drawSpecialData(type: String, data: String, material: GGBMaterial) -> Bool

}

public extension GGBVectorDrawingProtocol {
    @discardableResult
    func drawSpecialData(type: String, data: String) -> Bool {
        false
    }
}

/// Reusable drawing code that can target a native drawer or a recorder.
public typealias GGBVectorDrawingClosure = (_ drawer: any GGBVectorDrawingProtocol) -> Void

// MARK: - Direct Color and Material Drawing

public extension GGBVectorDrawingProtocol {

    func drawLine(from start: GGBPoint, to end: GGBPoint, material: GGBMaterial, thickness: GGBFloat = 1) {
        drawLine(from: start, to: end, stroke: GGBVectorStroke(material: material, thickness: thickness))
    }

    func drawLine(from start: GGBPoint, to end: GGBPoint, color: GGBColor, thickness: GGBFloat = 1) {
        drawLine(from: start, to: end, material: .color(color), thickness: thickness)
    }

    /// Draws this shape with independent outline and interior materials.
    /// Nil omits the corresponding outline or fill.
    func drawRectangle(in rect: GGBRect, strokeMaterial: GGBMaterial?, fillMaterial: GGBMaterial?, thickness: GGBFloat = 1) {
        drawRectangle(in: rect, stroke: strokeMaterial.map { GGBVectorStroke(material: $0, thickness: thickness) }, fill: fillMaterial.map { GGBVectorFill(material: $0) })
    }

    func drawRectangle(in rect: GGBRect, strokeColor: GGBColor?, fillColor: GGBColor?, thickness: GGBFloat = 1) {
        drawRectangle(in: rect, strokeMaterial: strokeColor.map { GGBMaterial.color($0) }, fillMaterial: fillColor.map { GGBMaterial.color($0) }, thickness: thickness)
    }

    /// Filled shapes use the material for their interior; unfilled shapes use it for their outline.
    func drawRectangle(in rect: GGBRect, material: GGBMaterial, thickness: GGBFloat = 1, filled: Bool = true) {
        drawRectangle(in: rect, strokeMaterial: filled ? nil : material, fillMaterial: filled ? material : nil, thickness: thickness)
    }

    func drawRectangle(in rect: GGBRect, color: GGBColor, thickness: GGBFloat = 1, filled: Bool = true) {
        drawRectangle(in: rect, material: .color(color), thickness: thickness, filled: filled)
    }

    /// Draws this shape with independent outline and interior materials.
    /// Nil omits the corresponding outline or fill.
    func drawRoundedRectangle(in rect: GGBRect, cornerRadius: GGBFloat, strokeMaterial: GGBMaterial?, fillMaterial: GGBMaterial?, thickness: GGBFloat = 1) {
        drawRoundedRectangle(in: rect, cornerRadius: cornerRadius, stroke: strokeMaterial.map { GGBVectorStroke(material: $0, thickness: thickness) }, fill: fillMaterial.map { GGBVectorFill(material: $0) })
    }

    func drawRoundedRectangle(in rect: GGBRect, cornerRadius: GGBFloat, strokeColor: GGBColor?, fillColor: GGBColor?, thickness: GGBFloat = 1) {
        drawRoundedRectangle(in: rect, cornerRadius: cornerRadius, strokeMaterial: strokeColor.map { GGBMaterial.color($0) }, fillMaterial: fillColor.map { GGBMaterial.color($0) }, thickness: thickness)
    }

    /// Filled shapes use the material for their interior; unfilled shapes use it for their outline.
    func drawRoundedRectangle(in rect: GGBRect, cornerRadius: GGBFloat, material: GGBMaterial, thickness: GGBFloat = 1, filled: Bool = true) {
        drawRoundedRectangle(in: rect, cornerRadius: cornerRadius, strokeMaterial: filled ? nil : material, fillMaterial: filled ? material : nil, thickness: thickness)
    }

    func drawRoundedRectangle(in rect: GGBRect, cornerRadius: GGBFloat, color: GGBColor, thickness: GGBFloat = 1, filled: Bool = true) {
        drawRoundedRectangle(in: rect, cornerRadius: cornerRadius, material: .color(color), thickness: thickness, filled: filled)
    }

    /// Draws this shape with independent outline and interior materials.
    /// Nil omits the corresponding outline or fill.
    func drawOval(in rect: GGBRect, strokeMaterial: GGBMaterial?, fillMaterial: GGBMaterial?, thickness: GGBFloat = 1) {
        drawOval(in: rect, stroke: strokeMaterial.map { GGBVectorStroke(material: $0, thickness: thickness) }, fill: fillMaterial.map { GGBVectorFill(material: $0) })
    }

    func drawOval(in rect: GGBRect, strokeColor: GGBColor?, fillColor: GGBColor?, thickness: GGBFloat = 1) {
        drawOval(in: rect, strokeMaterial: strokeColor.map { GGBMaterial.color($0) }, fillMaterial: fillColor.map { GGBMaterial.color($0) }, thickness: thickness)
    }

    /// Filled shapes use the material for their interior; unfilled shapes use it for their outline.
    func drawOval(in rect: GGBRect, material: GGBMaterial, thickness: GGBFloat = 1, filled: Bool = true) {
        drawOval(in: rect, strokeMaterial: filled ? nil : material, fillMaterial: filled ? material : nil, thickness: thickness)
    }

    func drawOval(in rect: GGBRect, color: GGBColor, thickness: GGBFloat = 1, filled: Bool = true) {
        drawOval(in: rect, material: .color(color), thickness: thickness, filled: filled)
    }

    func drawArc(center: GGBPoint, radius: GGBFloat, startAngle: GGBFloat, endAngle: GGBFloat, direction: GGBVectorArcDirection, material: GGBMaterial, thickness: GGBFloat = 1) {
        drawArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, direction: direction, stroke: GGBVectorStroke(material: material, thickness: thickness))
    }

    func drawArc(center: GGBPoint, radius: GGBFloat, startAngle: GGBFloat, endAngle: GGBFloat, direction: GGBVectorArcDirection, color: GGBColor, thickness: GGBFloat = 1) {
        drawArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, direction: direction, material: .color(color), thickness: thickness)
    }

    /// Draws this shape with independent outline and interior materials.
    /// Nil omits the corresponding outline or fill.
    func drawPolygon(points: [GGBPoint], strokeMaterial: GGBMaterial?, fillMaterial: GGBMaterial?, thickness: GGBFloat = 1) {
        drawPolygon(points: points, stroke: strokeMaterial.map { GGBVectorStroke(material: $0, thickness: thickness) }, fill: fillMaterial.map { GGBVectorFill(material: $0) })
    }

    func drawPolygon(points: [GGBPoint], strokeColor: GGBColor?, fillColor: GGBColor?, thickness: GGBFloat = 1) {
        drawPolygon(points: points, strokeMaterial: strokeColor.map { GGBMaterial.color($0) }, fillMaterial: fillColor.map { GGBMaterial.color($0) }, thickness: thickness)
    }

    /// Filled shapes use the material for their interior; unfilled shapes use it for their outline.
    func drawPolygon(points: [GGBPoint], material: GGBMaterial, thickness: GGBFloat = 1, filled: Bool = true) {
        drawPolygon(points: points, strokeMaterial: filled ? nil : material, fillMaterial: filled ? material : nil, thickness: thickness)
    }

    func drawPolygon(points: [GGBPoint], color: GGBColor, thickness: GGBFloat = 1, filled: Bool = true) {
        drawPolygon(points: points, material: .color(color), thickness: thickness, filled: filled)
    }

    func drawQuadraticBezier(from start: GGBPoint, control: GGBPoint, to end: GGBPoint, material: GGBMaterial, thickness: GGBFloat = 1) {
        drawQuadraticBezier(from: start, control: control, to: end, stroke: GGBVectorStroke(material: material, thickness: thickness))
    }

    func drawQuadraticBezier(from start: GGBPoint, control: GGBPoint, to end: GGBPoint, color: GGBColor, thickness: GGBFloat = 1) {
        drawQuadraticBezier(from: start, control: control, to: end, material: .color(color), thickness: thickness)
    }

    func drawCubicBezier(from start: GGBPoint, control1: GGBPoint, control2: GGBPoint, to end: GGBPoint, material: GGBMaterial, thickness: GGBFloat = 1) {
        drawCubicBezier(from: start, control1: control1, control2: control2, to: end, stroke: GGBVectorStroke(material: material, thickness: thickness))
    }

    func drawCubicBezier(from start: GGBPoint, control1: GGBPoint, control2: GGBPoint, to end: GGBPoint, color: GGBColor, thickness: GGBFloat = 1) {
        drawCubicBezier(from: start, control1: control1, control2: control2, to: end, material: .color(color), thickness: thickness)
    }

    /// Default implementations explicitly report unsupported painted bitmap/special operations.
    @discardableResult
    func drawBitmap(data: Data, sourceRect: GGBRect?, destinationRect: GGBRect, opacity: GGBFloat, material: GGBMaterial) -> Bool {
        false
    }

    @discardableResult
    func drawBitmap(data: Data, sourceRect: GGBRect?, destinationRect: GGBRect, opacity: GGBFloat, color: GGBColor) -> Bool {
        drawBitmap(data: data, sourceRect: sourceRect, destinationRect: destinationRect, opacity: opacity, material: .color(color))
    }

    @discardableResult
    func drawSpecialData(type: String, data: String, material: GGBMaterial) -> Bool {
        false
    }

    @discardableResult
    func drawSpecialData(type: String, data: String, color: GGBColor) -> Bool {
        drawSpecialData(type: type, data: data, material: .color(color))
    }
}
