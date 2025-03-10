public enum CompressionStatus: CInt, Sendable, Equatable {
    case ok        = 0 //Z_OK
    case streamEnd = 1 //Z_STREAM_END
    case needDict  = 2 //Z_NEED_DICT
}
