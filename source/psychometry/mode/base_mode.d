module psychometry.mode.base_mode;

class SteganographyEncodeException : Exception {
    this(string msg) { super(msg); }
}

class SteganographyDecodeException : Exception {
    this(string msg) { super(msg); }
}

interface BaseMode {
    ubyte[] encode(ubyte[] cover_data_binarray, ubyte[] secret_data_binarray);
    ubyte[] decode(ubyte[] covered_data_binarray);
}
