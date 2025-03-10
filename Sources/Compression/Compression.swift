import zlib

public class Compression {
    internal var stream = z_stream()
    
    internal init() throws(CompressionError) {}
    
    internal func reset(with function: (z_streamp) -> CInt) {
        do {
            let status = try call({
                function(&stream)
            }).get()
            guard status == .ok else {
                preconditionFailure("unexpected return result: \(status)")
            }
        } catch {
            print("reset error: \(error)")
        }
    }
}

public class Deflater: Compression {
    public init(level scale: Int?) throws(CompressionError) {
        try super.init()
        
        let level: CInt
        if let scale = scale, (0...9).contains(scale) {
            level = CInt(scale)
        } else {
            level = CompressionLevel.default.rawValue
        }
        let strategy: CompressionStrategy = .default
        let size = CInt(MemoryLayout<z_stream>.size)
        let status = try call({
            deflateInit2_(&stream, level, Z_DEFLATED, MAX_WBITS + 16, MAX_MEM_LEVEL, strategy.rawValue, ZLIB_VERSION, size)
        }).get()
        guard status == .ok else {
            preconditionFailure("unexpected status: \(status)")
        }
    }
    
    public func compress(bytes: [UInt8], flush: Bool) throws(CompressionError) -> [UInt8] {
        guard !(bytes.isEmpty && !flush) else { return [] }
        
        let length = Int(compressBound(UInt(bytes.count)))
        let pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
        defer {
            pointer.deallocate()
        }
        if !bytes.isEmpty {
            stream.next_in = UnsafeMutablePointer(mutating: bytes)
            stream.avail_in = uInt(bytes.count)
        } else {
            stream.next_in = nil
            stream.avail_in = 0
        }
        let flush: CompressionFlush = flush ? .finish : .noFlush
        
        var status: CompressionStatus = .ok
        var result: [UInt8] = []
        repeat {
            stream.next_out = pointer
            stream.avail_out = uInt(length)
            
            status = try call({
                deflate(&stream, flush.rawValue)
            }).get()
            
            let count = uInt(length) - stream.avail_out
            let buffer = UnsafeRawBufferPointer(start: pointer, count: Int(count)).map({ $0 })
            result.append(contentsOf: buffer)
        } while stream.avail_out == 0 && status == .ok
        return result
    }
    
    deinit {
        reset(with: deflateEnd)
    }
}

public class Inflater: Compression {
    public override init() throws(CompressionError) {
        try super.init()
        
        let size = CInt(MemoryLayout<z_stream>.size)
        let status = try call({
            inflateInit2_(&stream, MAX_WBITS + 32, ZLIB_VERSION, size)
        }).get()
        guard status == .ok else {
            preconditionFailure("unexpected status: \(status)")
        }
    }
    
    public func decompress(bytes: [UInt8]) throws(CompressionError) -> [UInt8] {
        guard !bytes.isEmpty else { return [] }
        
        stream.next_in = UnsafeMutablePointer<UInt8>(mutating: bytes)
        stream.avail_in = uInt(bytes.count)
        
        var status: CompressionStatus = .ok
        var result = [UInt8](repeating: 0, count: bytes.count * 2)
        repeat {
            if Int(stream.total_out) >= result.count {
                let chunk = [UInt8](repeating: 0, count: bytes.count / 2)
                result.append(contentsOf: chunk)
            }
            
            stream.avail_out = uInt(result.count) - uInt(stream.total_out)
            
            result.withUnsafeMutableBufferPointer({ buffer in
                let pointer = buffer.baseAddress!.advanced(by: Int(stream.total_out))
                pointer.withMemoryRebound(to: Bytef.self, capacity: Int(stream.avail_out), {
                    stream.next_out = $0
                })
            })
            
            status = try call({
                inflate(&stream, Z_SYNC_FLUSH)
            }).get()
        } while status == .ok
        result.removeLast(result.count - Int(stream.total_out))
        return result
    }
    
    deinit {
        reset(with: inflateEnd)
    }
}

private func call(_ handle: () -> CInt) -> Result<CompressionStatus, CompressionError> {
    let result = handle()
    switch result {
    case 0...2: return .success(CompressionStatus(rawValue: result)!)
    case -6...(-1): return .failure(CompressionError(rawValue: result)!)
    default: preconditionFailure("unexpected return value: \(result)")
    }
}

#if hasFeature(TypedThrows)
#endif
#if hasFeature(AccessLevelOnImport)
#endif
#if hasFeature(InternalImportsByDefault)
#endif
