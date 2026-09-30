//
//  GGBImageData.swift
//  GGBIO
//
//  Portable image references and standard icon definitions.
//

import Foundation

/// Common semantic icons that each platform maps to its native icon library.
public enum GGBStandardIcon: String, Sendable, CaseIterable {
    /// Generic application icon. Each platform maps this to its normal app/application symbol.
    case app
    case home
    case settings
    case information
    case welcome
    case getStarted
    case whatsNew
    case faq
    case help
    case search
    case add
    case remove
    case check
    case warning
    case error
}

/// Portable image content understood by the current GGBIO backends.
///
/// An icon is image data with a semantic, platform-resolved origin rather than
/// a separate UI concept. Future image work can add encoded bitmap/vector data
/// here once both platform renderers support it. A URL is intentionally not an
/// image-data case: future networking APIs will load a URL and produce
/// `GGBImageData`.
public enum GGBImageData: Sendable, Equatable {
    /// An application asset/resource using its platform resource name.
    case asset(String)

    /// A semantic icon mapped to the native platform icon library.
    case icon(GGBStandardIcon)
}

