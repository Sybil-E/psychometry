# Psychometry
Psychometry is a steganography library of the D programming language.
Implementation of steganographic algorithm is modularized in this library, so we will be able to add various types of algorithm. 

# Usage
## LSB Steganography(encode)
```D
import imageformats;
import psychometry;

IFImage raw_image = read_png("before_lsb_steg.png");
string s = "Free Software, Free Society";
ubyte[] secret_data = cast(ubyte[])(s.dup);
Converter converter = new Converter(new LSBMode(64));

ubyte[] covered_data = converter.encode(raw_image.pixels, secret_data);

write_png("after_lsb_steg.png", raw_image.w, raw_image.h, covered_data);
```
## LSB Steganography(decode)
```D
import imageformats;
import psychometry;

IFImage covered_image = read_png("after_lsb_steg.png");
Converter converter = new Converter(new LSBMode(64));
string s = cast(string)(converter.decode(covered_image.pixels));
```
