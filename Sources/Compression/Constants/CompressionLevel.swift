public enum CompressionLevel: CInt, Sendable, Equatable {
    case noCompression   = 0 //Z_NO_COMPRESSION
    case bestSpeed       = 1 //Z_BEST_SPEED
    case bestCompression = 9 //Z_BEST_COMPRESSION
    case `default`      = -1 //Z_DEFAULT_COMPRESSION
}
