import GGBIO
import SwiftUI

/// An empty Apple host while the shared game model is being designed.
public struct GGBAppleScene: Scene {
    private let application: GGBApplication

    public init(application: GGBApplication) {
        self.application = application
    }

    public var body: some Scene {
        WindowGroup {
            Color.clear
        }
    }
}
