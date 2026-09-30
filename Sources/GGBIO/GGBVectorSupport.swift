//
//  GGBVectorSupport.swift
//  GGB
//
//  Portable values required by the shared vector drawing contract.
//

import Foundation

public typealias GGBFloat = Double

/// Semantic colors that each native platform resolves using its current appearance/theme.
public enum GGBSemanticColor: String, Codable, Sendable, Equatable {
    case primary
    case secondary
    case accent
    case background
    case error
    case warning
    case success
}

/// Portable color used by GGB presentation capabilities.
public enum GGBColor: Codable, Sendable, Equatable {
    case semantic(GGBSemanticColor)
    case rgba(red: Double, green: Double, blue: Double, alpha: Double)

    public static let primary = GGBColor.semantic(.primary)
    public static let secondary = GGBColor.semantic(.secondary)
    public static let accent = GGBColor.semantic(.accent)
    public static let background = GGBColor.semantic(.background)
    public static let error = GGBColor.semantic(.error)
    public static let warning = GGBColor.semantic(.warning)
    public static let success = GGBColor.semantic(.success)

    public static let clear = GGBColor.rgba(red: 0, green: 0, blue: 0, alpha: 0)
    public static let black = GGBColor.rgba(red: 0, green: 0, blue: 0, alpha: 1)
    public static let white = GGBColor.rgba(red: 1, green: 1, blue: 1, alpha: 1)
    public static let red = GGBColor.rgba(red: 1, green: 0, blue: 0, alpha: 1)
    public static let green = GGBColor.rgba(red: 0, green: 1, blue: 0, alpha: 1)
    public static let blue = GGBColor.rgba(red: 0, green: 0, blue: 1, alpha: 1)
    public static let gray = GGBColor.rgba(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)

    /// Creates an explicit RGBA color. Component values are clamped to 0...1.
    public static func rgba(_ red: Double, _ green: Double, _ blue: Double, _ alpha: Double = 1) -> GGBColor {
        .rgba(
            red: min(max(red, 0), 1),
            green: min(max(green, 0), 1),
            blue: min(max(blue, 0), 1),
            alpha: min(max(alpha, 0), 1)
        )
    }
}

public enum GGBMaterialType: Codable, Sendable, Equatable {
    case color(GGBColor)
    case registered(key: String)
    case image(name: String)
}

public struct GGBMaterial: Codable, Sendable, Equatable {
    public var type: GGBMaterialType

    public init(type: GGBMaterialType) {
        self.type = type
    }

    public static func color(_ color: GGBColor) -> GGBMaterial {
        GGBMaterial(type: .color(color))
    }

    public static func registered(_ key: String) -> GGBMaterial {
        GGBMaterial(type: .registered(key: key))
    }

    public static func image(_ name: String) -> GGBMaterial {
        GGBMaterial(type: .image(name: name))
    }

    public static let black = GGBMaterial.color(.black)

}
