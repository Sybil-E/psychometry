module psychometry.mode.lsb_mode;

import psychometry.mode.base_mode;

import std.exception;
import std.conv;
import std.array;
import std.algorithm.mutation;

class LSBMode : BaseMode {
    private int secret_data_offset_length;

    this(int secret_data_offset_length) {
        this.secret_data_offset_length = secret_data_offset_length;
    }

    override ubyte[] encode(ubyte[] cover_data_binarray, ubyte[] secret_data_binarray) {
        ubyte[] covered_data_binarray = cover_data_binarray.dup; 
        bool cover_smaller_than_secret = (long(cover_data_binarray.length-secret_data_offset_length)/8 < long(secret_data_binarray.length));
        ubyte[] secret_data_length_offset = (to!(ubyte[])(to!string(ulong(secret_data_binarray.length), 2).split(""))).array;
        bool secret_too_big = secret_data_offset_length < secret_data_length_offset.length;

        if (cover_smaller_than_secret || secret_too_big) {
            throw new SteganographyEncodeException("Cover data is too small or secret data is too big."); 
        }

        long embedded_array_index = secret_data_offset_length + 7;

        reverse(secret_data_length_offset);
        secret_data_length_offset.length = secret_data_offset_length;
        reverse(secret_data_length_offset);

        foreach(e; secret_data_binarray) {
            covered_data_binarray[embedded_array_index] = e;
            embedded_array_index += 8;
        }

        covered_data_binarray[0 .. secret_data_offset_length] = secret_data_length_offset;
 
        return covered_data_binarray;
    }

    override ubyte[] decode(ubyte[] covered_data_binarray) {
        if (covered_data_binarray.length < secret_data_offset_length) {
            throw new SteganographyDecodeException("Covered data is smaller than secret data offset.");
        }

        ubyte[] decode_data_binarray = [];
        ubyte[] secret_data_length_offset = covered_data_binarray[0 .. secret_data_offset_length].dup;
        long secret_data_length = to!long(to!(string[])(secret_data_length_offset).array.join, 2);
        long embedded_array_index = secret_data_offset_length + 7;

        for (long i = 0; i < secret_data_length; i++) {
            decode_data_binarray ~= covered_data_binarray[embedded_array_index];
            embedded_array_index += 8;
        }

        return decode_data_binarray;
    }
}

unittest {
    BaseMode lsb_mode = new LSBMode(64);

    ubyte[] secret_data_binarray = [1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1];
    ubyte[] cover_data_binarray = new ubyte[200];

    //Check coincidence of data size before and after encode. 
    ubyte[] covered_data_binarray = lsb_mode.encode(cover_data_binarray, secret_data_binarray);
    assert(covered_data_binarray.length == cover_data_binarray.length);

    //Check exception when cover data is smaller than secret data offset length. 
    assertThrown!SteganographyEncodeException(
        lsb_mode.encode(new ubyte[63], new ubyte[1])
    );

    //Check exception when cover data is smaller than secret data. 
    assertThrown!SteganographyEncodeException(
        lsb_mode.encode(new ubyte[1000], new ubyte[1000])
    );

    //Check coincidence of data before encode and after decode. 
    ubyte[] decode_data_binarray = lsb_mode.decode(covered_data_binarray);
    assert(decode_data_binarray == secret_data_binarray);

    //Check exception when covered data is smaller than secret data offset length. 
    assertThrown!SteganographyDecodeException(
        lsb_mode.decode(new ubyte[10])
    );
}
