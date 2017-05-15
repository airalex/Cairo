//
//  SurfaceTests.swift
//  Cairo
//
//  Created by Alexander Juda on 15/05/2017.
//
//

import XCTest
import Foundation
@testable import Cairo

class SurfaceTests: XCTestCase {

    func testPNGBytes() {
        // Generate a surface, write it to file using Cairo's cairo_surface_write_to_png
        // and compare the result file with bytes generated using pngBytes()
        
        // Given
        let surface = generateTestingSurface()
        
        // When
        let pngBytes = surface.pngBytes()
        let pngData = Data(bytes: pngBytes)
        
        // Then
        let expectedPNGPath = outputDirectoryURL().appendingPathComponent("line.png")
        surface.writePNG(to: expectedPNGPath.relativePath)
        let expectedPNGData = try! Data(contentsOf: expectedPNGPath)
        
        XCTAssertEqual(pngData, expectedPNGData)
        
        // Clean up
        try! FileManager.default.removeItem(at: expectedPNGPath)
    }

}

extension SurfaceTests {
    func generateTestingSurface() -> Surface {
        let surface = Surface(format: .argb32, width: 600, height: 400)
        let context = Context(surface: surface)
        
        context.setSource(color: (red: 1.0, green: 1.0, blue: 1.0))
        context.addRectangle(x: 0, y: 0, width: 600, height: 400)
        context.fill()
        
        context.setSource(color: (red: 0.5, green: 0.0, blue: 1.0))
        context.move(to: (x: 100, y: 100))
        context.line(to: (x: 300, y: 300))
        context.stroke()
        
        return surface
    }
    
    func outputDirectoryURL() -> URL {
        let outputDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("CairoTests")
            .appendingPathComponent("GeneratedFiles")
        
        if !FileManager.default.fileExists(atPath: outputDirectoryURL.absoluteString) {
            try! FileManager.default.createDirectory(at: outputDirectoryURL,
                                                     withIntermediateDirectories: true)
        }
        
        return outputDirectoryURL
    }
}

extension SurfaceTests {
    static var allTests: [(String, (SurfaceTests) -> () throws -> Void)] {
        return [
            ("testAddCheck", testPNGBytes)
        ]
    }

}
