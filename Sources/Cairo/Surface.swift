//
//  Surface.swift
//  Cairo
//
//  Created by Alsey Coleman Miller on 1/31/16.
//  Copyright © 2016 PureSwift. All rights reserved.
//

import CCairo

public final class Surface {
    
    // MARK: - Internal Properties
    
    internal var internalPointer: OpaquePointer
    
    // MARK: - Initialization
    
    deinit {
        
        cairo_surface_destroy(internalPointer)
    }
    
    public init(_ internalPointer: OpaquePointer) {
        
        self.internalPointer = internalPointer
    }
    
    public init(format: ImageFormat, width: Int, height: Int) {
        
        let internalFormat = cairo_format_t(rawValue: format.rawValue)
        
        self.internalPointer = cairo_image_surface_create(internalFormat, Int32(width), Int32(height))
    }
    
    public init(svg filename: String, width: Double, height: Double) {
        
        self.internalPointer = cairo_svg_surface_create(filename, width, height)
    }
    
    public init(pdf filename: String, width: Double, height: Double) {
        
        self.internalPointer = cairo_pdf_surface_create(filename, width, height)
    }
    
    // MARK: - Methods
    
    public func flush() {
        
        cairo_surface_flush(internalPointer)
    }
    
    public func markDirty() {
        
        cairo_surface_mark_dirty(internalPointer)
    }
    
    public func writePNG(to filepath: String) {
        
        cairo_surface_write_to_png(internalPointer, filepath)
    }
    
    struct ByteBuffer {
        var bytesPointer: UnsafeMutableRawPointer
        var capacity: Int
        var savedOffset: Int
        
        init(capacity: Int) {
            self.capacity = capacity
            self.bytesPointer = UnsafeMutableRawPointer.allocate(bytes: capacity,
                                                                 alignedTo: MemoryLayout<UInt8>.alignment)
            self.savedOffset = 0
        }
        
        var savedBytes: [UInt8] {
            var bytes: [UInt8] = []
            for i in 0..<self.savedOffset {
                let byte = self.bytesPointer.advanced(by: i).load(as: UInt8.self)
                bytes.append(byte)
            }
            
            return bytes
        }
    }
    
    public func pngBytes() -> [UInt8] {
        
        let width = Int(cairo_image_surface_get_width(internalPointer))
        let height = Int(cairo_image_surface_get_height(internalPointer))
        let bytesPerPixel = 4
        
        var bytesBuffer = ByteBuffer(capacity: width * height * bytesPerPixel)
        
        cairo_surface_write_to_png_stream(internalPointer, {
            (context: UnsafeMutableRawPointer?,       // void *
             dataChunkPointer: UnsafePointer<UInt8>?, // const uint8_t *
             dataChunkLength: UInt32)
             -> cairo_status_t in
            
            var bytesBuffer = context!.load(as: ByteBuffer.self)
            
            let bytesCount = Int(dataChunkLength)
            for i in 0..<bytesCount {
                let currentBytePointer = dataChunkPointer!.advanced(by: i)
                let currentByte = currentBytePointer.pointee
                
                let savedOffset = bytesBuffer.savedOffset
                bytesBuffer.bytesPointer
                    .advanced(by: savedOffset+i)
                    .storeBytes(of: currentByte, as: UInt8.self)
            }
            
            bytesBuffer.savedOffset += bytesCount
            
            context!.copyBytes(from: &bytesBuffer, count: MemoryLayout<ByteBuffer>.size)
            
            return CAIRO_STATUS_SUCCESS
        }, &bytesBuffer)
        
        return bytesBuffer.savedBytes
    }
    
    // MARK: - Accessors
    
    public var type: SurfaceType {
        
        let value = cairo_surface_get_type(internalPointer)
        
        guard let surfaceType = SurfaceType(rawValue: value.rawValue)
            else { fatalError("Invalid surface type: \(value)") }
        
        return surfaceType
    }
    
}

