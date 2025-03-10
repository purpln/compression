public enum CompressionStrategy: CInt, Sendable, Equatable {
    case filtered =    1 //Z_FILTERED
    case huffmanOnly = 2 //Z_HUFFMAN_ONLY
    case rle =         3 //Z_RLE
    case fixed =       4 //Z_FIXED
    case `default` =   0 //Z_DEFAULT_STRATEGY
}
