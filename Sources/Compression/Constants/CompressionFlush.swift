public enum CompressionFlush: CInt, Sendable, Equatable {
    case noFlush        = 0 //Z_NO_FLUSH
    case particialFlush = 1 //Z_PARTIAL_FLUSH
    case syncFlush      = 2 //Z_SYNC_FLUSH
    case fullFlush      = 3 //Z_FULL_FLUSH
    case finish         = 4 //Z_FINISH
    case block          = 5 //Z_BLOCK
    case trees          = 6 //Z_TREES
}
