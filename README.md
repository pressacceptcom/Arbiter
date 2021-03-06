# Press Accept: Arbiter
## Arbitrary Precision Integer Arithmetic

This library has basic functions and algorithms for arbitrary precision integer arithmetic. With this, you can compute against values that are much higher/lower than the maximum integer sizes of Godot (64 bit 2s-complement signed - -9223372036854775808, 9223372036854775807).

The algorithms are fast-enough, but could be faster with more advanced algorithms, thus the term "Basic". The coefficient_multiply_by_base and convert_bases functions are based on work by Dan Vanderkam (https://danvk.org/) specifically https://www.danvk.org/hex2dec.html whose source is release under the Apache 2 license (see LICENSE)

### Documentation

A 'place-values array' is an array where each element indicates the place-value of a given number, with the farthest element [-1] being the 'ones' place and the nearest element [0] being the most-significant (largest). This enables the arrays to be read from left-to-right like you might a decimal integer written out.

The result of this is that with a base of 256 each place-value element is then simply the positive integer interpretation off a given 8-bit byte, exactly like the built-in PoolByteArray.

You can use the static functions by themselves to do many operations on 'unsigned' integers. If you are interested in having a layer of abstraction and operating on different values of different bases of either sign you can instantiate this script and use the corresponding instance methods.

NOTE: it’s not recommended to use the convert_bases function to convert an integer value to binary, use int_to_binary, and array_to_binary for that purpose.

### Side Effects

Creates the class name 'PressAccept_Arbiter_Basic' globally

To prevent that comment out the class_name line (replace PressAccept_Arbiter_Basic with a script load.)

### Testing

This package relies on bitwes/Gut for running a test suite to ensure the code works as expected.

### Installation

Recommended installation for these files is (from the root of your project): addons/PressAccept/Arbiter/

### Meta Information

#### Namespace

- Organization Namespace: PressAccept
- Package Namespace: Arbiter
- Class: Basic

#### Organization Information

- Organization - Press Accept
- Organization URI - https://pressaccept.com/
- Organization Social - @pressacceptcom

#### Author Information

- Author - Asher Kadar Wolfstein
- Author URI - https://wunk.me/
- Author Social - https://incarnate.me/members/asherwolfstein/, @asherwolfstein

#### Copyright And License

Copyright - Press Accept: Arbiter © 2021 The Novelty Factor LLC, (Kadar Development, Asher Kadar Wolfstein)

License - MIT (see LICENSE)

#### Changelog

- 1.0 05/24/2021 First Release
- 1.1 06/01/2021
  - Added String as passable value to init and set_value
  - Added signal_value_changed boolean to Basic
  - Added value_changed signal to Basic
  - Added static functions: octal_to_array array_to_octal
  - Added instance methods: to_octal to_signed_octal to_signed_hexadecimal immutable* (add, subtract, multiply)

### Notes On Style

I knowingly took liberties with the Godot Coding Style Guide. It's easier on my eyes despite it's collaborative drawbacks. There is no need to notify me that it doesn't follow the style guide.