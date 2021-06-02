# Press Accept: Byter
## Byte-Wise Arbitrary Radix Conversions

This library has basic functions and algorithms for converting between various radii, (radixes) including binary, decimal, octal, hexadecimal, base 36 \[0-9a-z\], base 62 \[0-9a-zA-Z\], and arbitrary bases (place values defined by a string). These functions are binary consistent and can operate with 2s-complement negative numbers. With help from the Arbiter library, values can grow beyond the limitations of the signed 64-bit integer type built-in to Godot (large integers are represented in decimal using a string).

There is also a Byter class that can be instantiated with which you can set the internal value through the various radix conduits and then retrieve the equivalent value as a property (or through a method call) in another radix.

This library requires Arbiter 1.1 and above (1.0 is missing required functionality)

Both Byter and Arbiter expect to be installed at:

- res://addons/PressAccept/Arbiter/
- res://addons/PressAccept/Byter/

### Documentation

When using Binary, a positive unsigned value will always return a leading '0' digit. Sometimes this is undesired, so you'll have to use lstrip() to mitigate this. The function returns a '0' because signed values always return with a leading '1' digit. Also, because of the 2s-complement, signed values aren't merely a matter of flipping a bit, but rather, a signed value interprets 1s and 0s backward. Keep this in mind.

Hexadecimal and octal values, when converted to and from binary, rely on a string replacement algorithm rather than actually computing the base values. This string replacement means that returned values are 'padded' to the nearest binary representation of each digit. For hexadecimal, this is 4 bits, and for octal, this is 3 bits. Also, please make note that signed values must thus pad with 1's rather than 0's, so it's essential in some instances to indicate the sign of the value (such as when converting from a binary representation).

You might note there is no 'Decimal' module. Decimal conversion is provided by Arbiter and its 'to_decimal' function. There are signed and unsigned decimal value functions for each base, but not a module dedicated to 'outputting' decimal. With Arbiter's decimal parsing and decimal outputs, it's unnecessary to implement another Decimal module.

Higher bases don't necessarily have a straightforward digit-to-binary conversion method. 36 and 62 aren't powers of 2 and thus don't have defined binary boundaries in terms of digits (if we relied on that, there'd be missing values, turning this into an exercise in decimal-binary). In this library, it's assumed that any binary value converted to such a base simply starts with a '1', as there's no proper way to record a leading '0' without a defined digit-binary boundary like hexadecimal or octal. Thus, when interpreting a higher base value, you must know whether you want to retrieve a signed or unsigned value (as it would, starting with a '1', default to signed)

The ArbitraryBase class is like a module with static functions, except it's configurable. That makes it an instantiable object that acts as a module. Its internal state contains the configurations necessary for translating to a given base but does not hold a value itself (much like Binary, Octal, Hexadecimal, etc.). To maintain an internal value, use the Byter class.

### Testing

These computations aren't the fastest out there. Improved algorithms and other factors (like writing the processes in something less interpreted, like C), Godot threading, etc., could improve the speed. At 32 tests per cycle (as defined in the testing constant), it still takes my fairly advanced machine (large # cores and a large amount of ram) with this codebase (one executing GDScript thread) 317 seconds to run 16254 tests using GUT.

### Side Effects

Creates the following class names:

- PressAccept\_Byter\_ArbitraryBase
- PressAccept\_Byter\_Base36
- PressAccept\_Byter\_Base62
- PressAccept\_Byter\_Binary
- PressAccept\_Byter\_Byter
- PressACcept\_Byter\_Formats
- PressAccept\_Byter\_Octal
- PressAccept\_Byter\_Hexadecimal
- PressAccept\_Byter\_Test\_Utilities

### Meta Information

#### Namespace

Organization Namespace: PressAccept

Package Namespace: Byter

Class: ArbitraryBase, Base36, Base62, Binary, Byter, Formats, Hexadecimal, Octal

#### Organization Information

Organization - Press Accept

Organization URI - https://pressaccept.com/

Organization Social - [@pressacceptcom](https://twitter.com/pressacceptcom)

#### Author Information

Author - Asher Kadar Wolfstein

Author URI - https://wunk.me/

Author Social - https://incarnate.me/members/asherwolfstein/, [@asherwolfstein](https://twitter.com/asherwolfstein)

#### Copyright And License

Copyright - Press Accept: Byter © 2021 The Novelty Factor LLC, (Press Accept, Asher Kadar Wolfstein)

License - MIT (see LICENSE)

### Changelog

1.0.0 06/01/2021 First Release

### Notes On Style

I knowingly took liberties with the Godot Coding Style Guide. It's easier on my eyes despite its collaborative drawbacks. There is no need to notify me that it doesn't follow the style guide.
