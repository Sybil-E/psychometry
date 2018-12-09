module psychometry.converter;

import psychometry.mode;

import std.algorithm.mutation;
import std.conv;
import std.array;
import std.range;
import imageformats;


class Converter {
    private BaseMode mode; 
    this(BaseMode mode) {
        this.mode = mode;
    }

    ubyte[] encode(ubyte[] cover_data, ubyte[] secret_data) {
        return convert_binarray_to_ubytearray(mode.encode(convert_ubytearray_to_binarray(cover_data), convert_ubytearray_to_binarray(secret_data)));
    }

    ubyte[] decode(ubyte[] covered_data) {
        return convert_binarray_to_ubytearray(mode.decode(convert_ubytearray_to_binarray(covered_data)));
    }

  private:

    ubyte[] convert_ubytearray_to_binarray(ubyte[] ubytearray) {
        ubyte[] binarray = [];

        foreach(e; ubytearray) {
            ubyte[] raw_bin_element = to!(ubyte[])(to!string(e, 2).split(""));

            reverse(raw_bin_element);
            raw_bin_element.length = 8;
            reverse(raw_bin_element);

            binarray ~= raw_bin_element;
        }

        return binarray;
    }

    ubyte[] convert_binarray_to_ubytearray(ubyte[] binarray) {
        ubyte[] ubytearray = [];

        foreach(e; chunks(binarray, 8)) {
            ubytearray ~= cast(ubyte)(to!int(to!(string[])(e).join, 2));
        }

        return ubytearray;
    }
}

unittest {
    IFImage raw_image = read_png("testdata/before_lsb_steg.png");
    string s = "Free Software, Free Society";
    ubyte[] secret_data = cast(ubyte[])(s.dup);
    Converter converter = new Converter(new LSBMode(64));

    //Check coincidence of data before encode and after decode using real png data. 
    ubyte[] covered_data = converter.encode(raw_image.pixels, secret_data);
    assert(secret_data == converter.decode(covered_data));

    write_png("testdata/after_lsb_steg.png", raw_image.w, raw_image.h, covered_data);

    IFImage covered_image = read_png("testdata/after_lsb_steg.png");
    assert(secret_data == converter.decode(covered_image.pixels));
}
