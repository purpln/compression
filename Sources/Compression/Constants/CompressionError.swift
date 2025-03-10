import zlib

public enum CompressionError: CInt, Error, Sendable, Equatable {
    case errno   = -1 //Z_ERRNO
    case stream  = -2 //Z_STREAM_ERROR
    case data    = -3 //Z_DATA_ERROR
    case memory  = -4 //Z_MEM_ERROR
    case buffer  = -5 //Z_BUF_ERROR
    case version = -6 //Z_VERSION_ERROR
}

extension CompressionError: CustomStringConvertible {
    public var description: String {
        String(cString: zError(rawValue))
    }
}
/*
file error
stream error
data error
insufficient memory
buffer error
incompatible version
*/
