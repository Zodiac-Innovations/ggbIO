import Foundation
import Testing
@testable import GGBIO

private final class PaintContractDrawer: GGBVectorDrawingProtocol {
    let bounds = GGBRect(x: 0, y: 0, width: 100, height: 100)
    var stroke: GGBVectorStroke?
    var fill: GGBVectorFill?
    var bitmapMaterial: GGBMaterial?
    var specialMaterial: GGBMaterial?

    func drawLine(from start: GGBPoint, to end: GGBPoint, stroke: GGBVectorStroke) { self.stroke = stroke }
    func drawRectangle(in rect: GGBRect, stroke: GGBVectorStroke?, fill: GGBVectorFill?) { self.stroke = stroke; self.fill = fill }
    func drawRoundedRectangle(in rect: GGBRect, cornerRadius: GGBFloat, stroke: GGBVectorStroke?, fill: GGBVectorFill?) { self.stroke = stroke; self.fill = fill }
    func drawOval(in rect: GGBRect, stroke: GGBVectorStroke?, fill: GGBVectorFill?) { self.stroke = stroke; self.fill = fill }
    func drawArc(center: GGBPoint, radius: GGBFloat, startAngle: GGBFloat, endAngle: GGBFloat, direction: GGBVectorArcDirection, stroke: GGBVectorStroke) { self.stroke = stroke }
    func drawPolygon(points: [GGBPoint], stroke: GGBVectorStroke?, fill: GGBVectorFill?) { self.stroke = stroke; self.fill = fill }
    func drawQuadraticBezier(from start: GGBPoint, control: GGBPoint, to end: GGBPoint, stroke: GGBVectorStroke) { self.stroke = stroke }
    func drawCubicBezier(from start: GGBPoint, control1: GGBPoint, control2: GGBPoint, to end: GGBPoint, stroke: GGBVectorStroke) { self.stroke = stroke }
    func drawBitmap(data: Data, sourceRect: GGBRect?, destinationRect: GGBRect, opacity: GGBFloat) {}
    func drawBitmap(data: Data, sourceRect: GGBRect?, destinationRect: GGBRect, opacity: GGBFloat, material: GGBMaterial) -> Bool { bitmapMaterial = material; return true }
    func drawSpecialData(type: String, data: String, material: GGBMaterial) -> Bool { specialMaterial = material; return true }
}

@Test("Material registration rejects references and retains the existing terminal value")
func paintRegistrationValidation() {
    let registry = GGBMaterialRegistry()
    #expect(registry.register(key: "piece", color: .red))
    #expect(!registry.register(key: "piece", material: .registered("other")))
    #expect(registry.resolve(.registered("piece")) == .color(.red))
    #expect(!registry.register(key: " ", color: .blue))
    #expect(!registry.register(key: "piece", imageName: " "))
    #expect(registry.register(key: "piece", imageName: "rook.png"))
    #expect(registry.resolve(.registered("piece")) == .image("rook.png"))
    registry.remove(key: "piece")
    #expect(registry.material(forKey: "piece") == nil)
    #expect(registry.resolve(.registered("piece")) == .black)
}

@Test("Shared colors and all material forms preserve JSON round trips")
func paintSerializationRoundTrip() throws {
    let colors: [GGBColor] = [.rgba(0.2, 0.4, 0.6, 0.8), .accent, .clear]
    for color in colors {
        #expect(try JSONDecoder().decode(GGBColor.self, from: JSONEncoder().encode(color)) == color)
    }
    for material in [GGBMaterial.color(.blue), .image("rook.png"), .registered("piece")] {
        #expect(try JSONDecoder().decode(GGBMaterial.self, from: JSONEncoder().encode(material)) == material)
    }
    #expect(GGBColor.rgba(-1, 2, 0.5, 3) == .rgba(red: 0, green: 1, blue: 0.5, alpha: 1))
}

@Test("Every geometry command forwards material and color paint")
func paintGeometryForwarding() {
    let concrete = PaintContractDrawer()
    let drawer: any GGBVectorDrawingProtocol = concrete
    let p = GGBPoint(x: 1, y: 2)
    let q = GGBPoint(x: 3, y: 4)
    let r = concrete.bounds
    let material = GGBMaterial.registered("piece")
    drawer.drawLine(from: p, to: q, material: material, thickness: 3)
    #expect(concrete.stroke?.material == material)
    #expect(concrete.stroke?.thickness == 3)
    drawer.drawArc(center: p, radius: 5, startAngle: 0, endAngle: 90, direction: .clockwise, color: .blue)
    #expect(concrete.stroke?.material == .color(.blue))
    drawer.drawQuadraticBezier(from: p, control: q, to: p, material: material)
    #expect(concrete.stroke?.material == material)
    drawer.drawCubicBezier(from: p, control1: q, control2: p, to: q, color: .red)
    #expect(concrete.stroke?.material == .color(.red))
    drawer.drawRectangle(in: r, strokeMaterial: material, fillMaterial: .image("paper.png"), thickness: 2)
    #expect(concrete.stroke?.material == material)
    #expect(concrete.fill == GGBVectorFill(material: .image("paper.png")))
    drawer.drawRoundedRectangle(in: r, cornerRadius: 4, color: .green)
    #expect(concrete.stroke == nil)
    #expect(concrete.fill == GGBVectorFill(color: .green))
    drawer.drawOval(in: r, material: material, filled: false)
    #expect(concrete.stroke?.material == material)
    #expect(concrete.fill == nil)
    drawer.drawPolygon(points: [p, q, p], strokeColor: .red, fillColor: .blue)
    #expect(concrete.stroke?.material == .color(.red))
    #expect(concrete.fill == GGBVectorFill(color: .blue))
}

@Test("Painted bitmap and special commands dispatch through the protocol")
func paintedSpecialDispatch() {
    let concrete = PaintContractDrawer()
    let drawer: any GGBVectorDrawingProtocol = concrete
    #expect(drawer.drawBitmap(data: Data([1]), sourceRect: nil, destinationRect: concrete.bounds, opacity: 1, color: .blue))
    #expect(concrete.bitmapMaterial == .color(.blue))
    #expect(drawer.drawSpecialData(type: "example", data: "{}", material: .registered("piece")))
    #expect(concrete.specialMaterial == .registered("piece"))
}
