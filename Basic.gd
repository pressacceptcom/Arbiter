tool
class_name PressAccept_Arbiter_Basic

# |=========================================|
# |                                         |
# |          Press Accept: Arbiter          |
# |  Arbitrary Precision Integer Arithmetic |
# |                                         |
# |=========================================|
#
# This library has basic functions and algorithms for arbitrary precision
# integer arithmetic. With this you can compute against values that are much
# higher/lower than the maximum integer sizes of Godot (64 bit 2s-complement
# signed - -9223372036854775808, 9223372036854775807).
#
# The algorithms are fast-enough, but could be faster with more advanced
# algorithms, thus the term "Basic". The coefficient_multiply_by_base and
# convert_bases functions are based on work by Dan Vanderkam (danvk.org)
# specifically https://www.danvk.org/hex2dec.html whose source is release
# under the Apache 2 license (see LICENSE)
#
# |---------------|
# | Documentation |
# |---------------|
#
# A 'place-values array' is an array where each element indicates the place-
# value of a given number, with the farthest element [-1] being the 'ones'
# place and the nearest element [0] being the most-significant (largest). This
# enables the arrays to be read from left-to-right like you might a decimal
# integer written out.
#
# The result of this is that with a base of 256 each place-value element is
# then simply the positive integer interpretation off a given 8-bit byte,
# exactly like the built-in PoolByteArray.
#
# You can use the static functions by themselves to do many operations on
# 'unsigned' integers. If you are interested in having a layer of abstraction
# and operating on different values of different bases of either sign you can
# instantiate this script and use the corresponding instance methods.
#
# NOTE: it's not recommended to use the convert_bases function to convert an
#       integer value to binary, use int_to_binary, and array_to_binary for
#       that purpose.
#
# |--------------|
# | Side Effects |
# |--------------|
#
# Creates the class name 'PressAccept_Arbiter_Basic' globally
#
# To prevent that comment out the class_name line (this will break the test)
#
# |------------------|
# | Meta Information |
# |------------------|
#
# Organization Namespace : PressAccept
# Package Namespace      : Arbiter
# Class                  : Basic
#
# Organization        : Press Accept
# Organization URI    : https://pressaccept.com/
# Organization Social : @pressaccept
#
# Author        : Asher Kadar Wolfstein
# Author URI    : https://wunk.me/ (Personal Blog)
# Author Social : https://incarnate.me/members/asherwolfstein/ (incarnate.me)
#                 @asherwolfstein (Twitter)
#
# Copyright : Press Accept: Arbiter © 2021 The Novelty Factor LLC
#                 (Kadar Development, Asher Kadar Wolfstein)
# License   : MIT (see LICENSE)
#
# |-----------|
# | Changelog |
# |-----------|
#
# 1.0    05/24/2021    First Release
#

# ****************
# | Enumerations |
# ****************

# enumeration used by compare_* and compare
#
# indicates that A is <relationship> than/to B in: A <relationship> B
enum RELATION {
	LESS_THAN = -1,
	EQUAL = 0,
	GREATER_THAN = 1
}

# index value used by subtract_* and subtract
#
# these methods set a a boolean flag at the indices below for indication
enum FLAGS {
	NEGATIVE = 0
}

# index value used by divide_binary_str and divide for results
#
# these methods return an array with the full division information
enum DIVISION {
	QUOTIENT,
	REMAINDER
}

# *************
# | Constants |
# *************

# lookup table for binary conversion
#
# why compute 2^X over and over when you can do it once?
const ARR_POWERS_OF_2: Array = [
	1 <<  0, # 1
	1 <<  1, # 2
	1 <<  2, # 4
	1 <<  3, # 8
	1 <<  4, # 16
	1 <<  5, # 32
	1 <<  6, # 64
	1 <<  7, # 128
	1 <<  8, # 256
	1 <<  9, # 512
	1 << 10, # 1,024
	1 << 11, # 2,048
	1 << 12, # 4,096
	1 << 13, # 8,192
	1 << 14, # 16,384
	1 << 15, # 32,768
	1 << 16, # 65,536
	1 << 17, # 131,072
	1 << 18, # 262,144
	1 << 19, # 524,288
	1 << 20, # 1,048,576
	1 << 21, # 2,097,152
	1 << 22, # 4,194,304
	1 << 23, # 8,388,608
	1 << 24, # 16,777,216
	1 << 25, # 33,554,432
	1 << 26, # 67,108,864
	1 << 27, # 134,217,728
	1 << 28, # 268,435,456
	1 << 29, # 536,870,912
	1 << 30, # 1,073,741,824
	1 << 31, # 2,147,483,648
	1 << 32, # 4,294,967,296
	1 << 33, # 8,589,934,592
	1 << 34, # 17,179,869,184
	1 << 35, # 34,359,738,368
	1 << 36, # 68,719,476,736
	1 << 37, # 137,438,953,472
	1 << 38, # 274,877,906,944
	1 << 39, # 549,755,813,888
	1 << 40, # 1,099,511,627,776
	1 << 41, # 2,199,023,255,552
	1 << 42, # 4,398,046,511,104
	1 << 43, # 8,796,093,022,208
	1 << 44, # 17,592,186,044,416
	1 << 45, # 35,184,372,088,832
	1 << 46, # 70,368,744,177,664
	1 << 47, # 140,737,488,355,328
	1 << 48, # 281,474,976,710,656
	1 << 49, # 562,949,953,421,312
	1 << 50, # 1,125,899,906,842,624
	1 << 51, # 2,251,799,813,685,248
	1 << 52, # 4,503,599,627,370,496
	1 << 53, # 9,007,199,254,740,992
	1 << 54, # 18,014,398,509,481,984
	1 << 55, # 36,028,797,018,963,968
	1 << 56, # 72,057,594,037,927,936
	1 << 57, # 144,115,188,075,855,872
	1 << 58, # 288,230,376,151,711,744
	1 << 59, # 576,460,752,303,423,488
	1 << 60, # 1,152,921,504,606,846,976
	1 << 61, # 2,305,843,009,213,693,952
	1 << 62  # 4,611,686,018,427,387,904
			 # 9,223,372,036,854,775,808 - INT_MAX + 1
]

# godot integers are *signed* 64 bit sequences
#
# x << 64 is illegal (invalid operands), length
# 64 - 1 because godot integers are *signed* 2s-complement 64 bit sequences
const INT_MAX_BITS  : int = 64 - 1 # length of ARR_POWERS_OF_2

# dictionary mapping hexadecimal digits to decimal equivalents
#
# key - decimal value, value - hexadecimal digit
const ARR_HEXADECIMAL_DIGITS: Array = [
	'0',
	'1',
	'2',
	'3',
	'4',
	'5',
	'6',
	'7',
	'8',
	'9',
	'A',
	'B',
	'C',
	'D',
	'E',
	'F'
]

# number of expected bits in a byte
#
# change this to change the division of bits in binary_to_array
# and array_to_binary
const INT_BYTE_BITS : int = 8

# the base as an integer that INT_BYTE_BITS results in
const INT_BYTE_BASE : int = 1 << INT_BYTE_BITS

# ***************************
# | Public Static Functions |
# ***************************


# convert integer to binary string representation
#
# Godot uses 2s-complement to indicate negative values
static func int_to_binary(
		int_value : int) -> String: # num bits to output

	var original : int    = int_value
	var ret      : String = ''

	# 2s-complement will return -1 rather than 0
	while int_value != 0 and int_value != -1:
		if int_value & 1:
			ret = '1' + ret
		else:
			ret = '0' + ret
		int_value = int_value >> 1

	# if we are at -1 we are 2s-complement
	if int_value == -1:
		ret = '1' + ret
	else:
		ret = '0' + ret

	ret = ret if ret else '0'

	return ret


# converts straight binary to bytes
#
# does not translate or account for signed 2s-complement values
#
# one INT_BYTE_BITS => one integer from 0 to 2^INT_BYTE_BITS - 1
static func binary_to_array(
		binary_str: String) -> Array:

	# pad_zeros 'formats a number'
	binary_str = binary_str if binary_str else '0'

	var binary_len : int   = binary_str.length()
	var units      : int   = \
		int(binary_len / INT_BYTE_BITS) + \
		(1 if binary_len % INT_BYTE_BITS else 0)
	var bits       : int   = units * INT_BYTE_BITS
	var binary_arr : Array = []

	binary_str = binary_str.pad_zeros(bits)

	for i in range(0, bits, INT_BYTE_BITS):
		var byte_str: String = binary_str.substr(i, INT_BYTE_BITS)
		var byte_int: int    = 0
		for bit in range(INT_BYTE_BITS):
			if not byte_str[-bit - 1] == '0':
				byte_int += ARR_POWERS_OF_2[bit]
		binary_arr.push_back(byte_int)

	return binary_arr


# converts an array of INT_BYTE_BITS back into a binary string representation
#
# negative values in the array will result in 2s-complement bits (inverse)
static func array_to_binary(
		byte_arr: Array) -> String:

	var ret: String = ''

	for byte in byte_arr:
		var byte_str: String = ''

		for i in INT_BYTE_BITS:
			if (byte >> i) & 1:
				byte_str = '1' + byte_str
			else:
				byte_str = '0' + byte_str

		ret += byte_str

	ret = ret.lstrip('0')

	if not ret:
		ret = '0'

	return ret if ret else '0'


# convert array of hexadecimal place-values (0 - 15) to a string of hex digits
#
# passing an array of values other than 0 - 15 will have an undefined result
static func array_to_hexadecimal(
		digits_arr: Array) -> String:

	var ret: String = ''

	for digit in digits_arr:
		ret += ARR_HEXADECIMAL_DIGITS[digit]

	return ret


# convert a hexadecimal string to an array of hexadecimal place-values (0 - 15)
#
# will return -1 for a place-value if the hexadecimal digit is not 0 - F
static func hexadecimal_to_array(
		hexadecimal_str: String) -> Array:

	var digits_arr: Array = []

	for digit in hexadecimal_str:
		digits_arr.push_back(ARR_HEXADECIMAL_DIGITS.find(digit))

	return digits_arr


# convert 'unsigned' int (positive) into a series of INT_BYTE_* place-values
#
# this is focused on the measure of the integer, not it's binary representation
# and thus operates on the absolute value of int_value to avoid 2s-complement
# issues
static func unsigned_int_to_array(
		int_value: int) -> PoolByteArray:

	if int_value < 0:
		int_value = int(abs(int_value))

	var ret: PoolByteArray = PoolByteArray()

	while int_value > 0:
		var byte: int = int_value & (INT_BYTE_BASE - 1)

		ret.push_back(byte)
		int_value = int_value >> 8

	ret.invert()

	_normalize([ ret ])

	return ret


# strip a given value off the front of an array of integers
#
# NOTE: the array must be solely of integers
#
# leaves the given value as a single element if the array is rendered empty
static func lstrip(
		buffer_arr      : Array,
		strip_value_int : int) -> Array:

	var buffer: Array = buffer_arr.duplicate()
	while buffer and buffer[0] == strip_value_int:
		buffer.pop_front()

	if not buffer:
		buffer.push_back(strip_value_int)

	return buffer


# adds place-values array with another place-values array by the given base
#
# NOTE: negative place-values will result in undefined behavior
#
# only 'unsigned' positive values are accounted for, to add signed values
# please see the included Class definition below
static func add_by_base(
		augend_arr : Array,
		addend_arr : Array,
		base_int   : int = INT_BYTE_BASE) -> Array:

	_normalize([ augend_arr, addend_arr ])

	var ret     : Array = Array()
	var max_len : int   = \
		int(max(augend_arr.size(), addend_arr.size())) + 1

	ret.resize(max_len)

	var carry: int = 0
	for i in range(max_len):
		var augend : int = _access(augend_arr, -i - 1)
		var addend : int = _access(addend_arr, -i - 1)
		var sum    : int = augend + addend + carry

		carry  = int(sum / base_int)
		ret[-i - 1] = sum % base_int

	return lstrip(ret, 0)

# adds two binary string representations
#
# only 'unsigned' positive values are accounted for, any 2s-complement will be
# interpreted as a positive binary string. To add signed values please see the
# included Class definition below
static func add_binary_str(
		augend_str: String,
		addend_str: String) -> String:

	augend_str = augend_str if augend_str else '0'
	addend_str = addend_str if addend_str else '0'

	var ret     : String = ''
	var max_len : int    = \
		int(max(augend_str.length(), addend_str.length()))

	augend_str = augend_str.pad_zeros(max_len)
	addend_str = addend_str.pad_zeros(max_len)

	var carry: bool = false
	for i in range(max_len - 1, -1, -1):
		match [ augend_str[i], addend_str[i] ]:
			[ '0', '0' ]:
				ret = ('0' if not carry else '1') + ret
				carry = false
			[ '0', '1' ], [ '1', '0' ]:
				ret = ('0' if carry else '1') + ret
			[ '1', '1' ]:
				ret = ('0' if not carry else '1') + ret
				carry = true

	ret = ('1' if carry else '0') + ret

	ret = ret.lstrip('0')

	return ret if ret else '0'


# compare two place-value arrays (of the same base)
#
# NOTE: negative place-values will result in undefined behavior
#
# This is of the relation left_relation_arr <relation> right_relation_arr
#
# E.g. 1, 2 will result in RELATION.LESS_THAN
#      2, 1 will result in RELATION.GREATER_THAN
#
# to compare signed values please see the included Class definition below
static func compare_arrays(
		left_relation_arr  : Array,
		right_relation_arr : Array) -> int:

	_normalize([ left_relation_arr, right_relation_arr ])

	var left_relation      : Array = left_relation_arr.duplicate()
	var right_relation     : Array = right_relation_arr.duplicate()
	var right_relation_len : int   = right_relation.size()

	while left_relation.size() < right_relation_len:
		left_relation.push_front(0)

	var left_relation_len: int = left_relation.size()
	while right_relation.size() < left_relation_len:
		right_relation.push_front(0)

	for i in range(left_relation_len):
		var left  : int = left_relation[i]
		var right : int = right_relation[i]

		if left > right:
			return RELATION.GREATER_THAN
		elif left < right:
			return RELATION.LESS_THAN

	return RELATION.EQUAL


# compares two binary string representations
#
# only 'unsigned' positive values are accounted for, any 2s-complement will be
# interpreted as a positive binary string. To compare signed values please see
# the included Class definition below.
static func compare_binary_str(
		left_relation_str  : String,
		right_relation_str : String) -> int:

	left_relation_str  = left_relation_str  if left_relation_str  else '0'
	right_relation_str = right_relation_str if right_relation_str else '0'

	var ret     : String = ''
	var max_len : int    = \
		int(max(left_relation_str.length(), right_relation_str.length())) + 1

	left_relation_str = left_relation_str.pad_zeros(max_len)
	right_relation_str = right_relation_str.pad_zeros(max_len)

	for i in range(max_len):
		match [ left_relation_str[i], right_relation_str[i] ]:
			[ '1', '0' ]:
				return RELATION.GREATER_THAN
			[ '0', '1' ]:
				return RELATION.LESS_THAN

	return RELATION.EQUAL


# subtracts place-values array from another place-values array of given base
#
# NOTE: negative place-values will result in undefined behavior
#
# only 'unsigned' positive values are accounted for, to subtract signed values
# please see the included Class definition below. If the result is negative
# then the FLAGS.NEGATIVE index of the passed dictionary is set to true,
# otherwise it is SET to false
static func subtract_by_base(
		minuend_arr    : Array,
		subtrahend_arr : Array,
		flags          : Dictionary,
		base_int       : int = INT_BYTE_BASE) -> Array:

	_normalize([ minuend_arr, subtrahend_arr ])

	flags[FLAGS.NEGATIVE] = false

	if compare_arrays(minuend_arr, subtrahend_arr) == RELATION.LESS_THAN:
		var temp: Array = minuend_arr
		minuend_arr = subtrahend_arr
		subtrahend_arr = temp
		flags[FLAGS.NEGATIVE] = true

	var ret      : Array = Array()
	var max_len  : int   = \
		int(max(minuend_arr.size(), subtrahend_arr.size()))
	var _minuend : Array = minuend_arr.duplicate()

	ret.resize(max_len)

	for i in range(max_len):
		var minuend    : int = _access(_minuend, -i - 1)
		var subtrahend : int = _access(subtrahend_arr, -i - 1)

		if minuend < subtrahend:
			var carry_from: int = i + 1
			while _minuend[-carry_from - 1] == 0:
				_minuend[-carry_from - 1] = base_int - 1
				carry_from += 1
			_minuend[-carry_from - 1] -= 1
			minuend += base_int

		ret[-i - 1] = minuend - subtrahend

	return lstrip(ret, 0)


# subtracts two binary string representations
#
# only 'unsigned' positive values are accounted for, any 2s-complement will be
# interpreted as a positive binary string. To subtract signed values please see
# the included Class definition below. If the result is negative
# then the FLAGS.NEGATIVE index of the passed dictionary is set to true,
# otherwise it is SET to false
static func subtract_binary_str(
		minuend_str    : String,
		subtrahend_str : String,
		flags          : Dictionary) -> String:

	minuend_str    = minuend_str    if minuend_str    else '0'
	subtrahend_str = subtrahend_str if subtrahend_str else '0'

	if compare_binary_str(minuend_str, subtrahend_str) == RELATION.LESS_THAN:
		var temp: String = minuend_str
		minuend_str = subtrahend_str
		subtrahend_str = temp
		flags[FLAGS.NEGATIVE] = true

	var ret     : String = ''
	var max_len : int    = \
		int(max(minuend_str.length(), subtrahend_str.length()))

	minuend_str    = minuend_str.pad_zeros(max_len)
	subtrahend_str = subtrahend_str.pad_zeros(max_len)

	for i in range(max_len - 1, -1, -1):
		match [ minuend_str[i], subtrahend_str[i] ]:
			[ '0', '1' ]:
				var carry_from: int = i - 1
				while minuend_str[carry_from] == '0':
					minuend_str[carry_from] = '1'
					carry_from -= 1
				minuend_str[carry_from] = '0'
				ret = '1' + ret
			[ '1', '0' ]:
				ret = '1' + ret
			[ '0', '0' ], [ '1', '1' ]:
				ret = '0' + ret

	ret = ret.lstrip('0')

	return ret if ret else '0'


# multiplies a place-values array (of base) by a coefficient (in base 256)
#
# NOTE: coefficient MUST be an integer in base 256 (use unsigned_int_to_array)
static func coefficient_multiply_by_base(
		coefficient_arr  : Array,
		multiplicand_arr : Array,
		base_int         : int = INT_BYTE_BASE) -> Array:

	_normalize([ coefficient_arr, multiplicand_arr ])

	var coefficient_str : String = array_to_binary(coefficient_arr)
	var power           : Array  = multiplicand_arr.duplicate()
	var ret             : Array

	while '1' in coefficient_str:
		if coefficient_str.ends_with('1'):
			ret = add_by_base(ret, power, base_int)

		coefficient_str = shift_binary_str_right((coefficient_str))

		if not '1' in coefficient_str:
			break

		power = add_by_base(power, power, base_int)

	return ret


# multiply place-values array by another place-values array of a given base
#
# NOTE: negative place-values will have undefined results, to multiply signed
#       values please see the included Class definition below
static func multiply_by_base(
		multiplier_arr   : Array,
		multiplicand_arr : Array,
		base_int         : int = INT_BYTE_BASE) -> Array:

	_normalize([ multiplier_arr, multiplicand_arr ])

	if _is_zero(multiplier_arr) or _is_zero(multiplicand_arr):
		return [ 0 ]

	var partial_products : Array = []
	var multiplier_len   : int = multiplier_arr.size()

	var multiplicand_shift: int = 0
	for i in range(multiplicand_arr.size()):
		var multiplier       : int = multiplicand_arr[-i - 1]
		var multiplier_shift : int = 0
		var partials         : Array

		for j in range(multiplier_len):
			var partial_product : Array
			var result          : int = multiplier * multiplier_arr[-j - 1]

			if result > base_int - 1:
				var units: int = int(result / base_int)

				partial_product = Array([ units, result - (units * base_int) ])
			else:
				partial_product = Array([result])

			for k in range(multiplier_shift + multiplicand_shift):
				partial_product.push_back(0)

			partials.push_back(partial_product)
			multiplier_shift += 1

		var total: Array
		for partial in partials:
			total = add_by_base(partial, total, base_int)
		partial_products.push_back(total)

		multiplicand_shift += 1

	var total: Array
	for partial_product in partial_products:
		total = add_by_base(partial_product, total, base_int)

	return lstrip(total, 0)


# shift a binary string representation of any length one place to the left
#
# (inserts a zero digit on the end)
static func shift_binary_str_left(
		binary_str: String) -> String:

	return binary_str.substr(1) + '0'


# shift a binary string representation of any length one place to the right
#
# (inserts a zero digit at the beginning)
static func shift_binary_str_right(
		binary_str: String) -> String:

	return '0' + binary_str.substr(0, binary_str.length() - 1)


# divide two binary strings
#
# NOTE: does not recognize signed values, any 2s-complement will be read as a
#       positive integer. To divide signed values please see the invluded Class
#       definition below.
#
# returns an array where [DIVISION.QUOTIENT] is the quotient in as a binary
# string representation and [DIVISION.REMAINDER] is the remainder as a binary
# string representation
static func divide_binary_str(
		dividend_str : String,
		divisor_str  : String) -> Array:

	dividend_str = dividend_str if dividend_str else '0'
	divisor_str  = divisor_str  if divisor_str  else '0'

	if not '1' in divisor_str:
		return []

	var remainder : String = '0'
	var quotient  : String = '0'
	var max_len   : int    = \
		int(max(dividend_str.length(), divisor_str.length()))

	dividend_str = dividend_str.pad_zeros(max_len)
	divisor_str  = divisor_str.pad_zeros(max_len)
	remainder    = remainder.pad_zeros(max_len)
	quotient     = dividend_str

	for i in range(max_len):
		var remainder_quotient: String = \
			shift_binary_str_left( remainder + quotient)
		remainder = remainder_quotient.substr(0, max_len)
		quotient  = remainder_quotient.substr(max_len)

		var comparison: int = compare_binary_str(remainder, divisor_str)
		if comparison == RELATION.GREATER_THAN or comparison == RELATION.EQUAL:
			remainder = \
				subtract_binary_str(remainder, divisor_str, {})\
				.pad_zeros(max_len)
			quotient  = add_binary_str(quotient, '1').pad_zeros(max_len)

	return [ quotient.lstrip('0'), remainder.lstrip('0') ]


# convert a place-values array from one base to another base
static func convert_bases(
		input     : Array,
		from_base : int,
		to_base   : int) -> Array:

	var out           : Array = []
	var power         : Array = [1]
	var from_base_arr : = unsigned_int_to_array(from_base)

	for i in range(input.size()):
		if input[-i - 1]:
			out = add_by_base(
				out,
				coefficient_multiply_by_base(
					unsigned_int_to_array(input[-i - 1]),
					power,
					to_base
				),
				to_base
			)

		power = coefficient_multiply_by_base(from_base_arr, power, to_base)

	out = lstrip(out, 0)

	return out


# ****************************
# | Private Static Functions |
# ****************************


# returns a value of 0 for any index outside of the bounds of an array
#
# useful for iterating over place-values without having to resize arrays
static func _access(
		buffer_arr : Array,
		index_int  : int) -> int:

	var buffer_len: int = buffer_arr.size()

	return 0 if index_int < -buffer_len or index_int >= buffer_len \
		else buffer_arr[index_int]


# ensures that all arrays in the passed array have at least one element
#
# NOTE: arrays_arr must be an array of arrays
static func _normalize(
		arrays_arr: Array):

	for array in arrays_arr:
		if not array:
			array.push_back(0)


# is this place-values array equal to zero?
static func _is_zero(
		value_arr: Array) -> bool:

	if not value_arr:
		return true

	if value_arr.size() == 1 and value_arr[0] == 0:
		return true

	return false


# |------------------|
# | Class Definition |
# |------------------|
#
# use the following to instantiate an object containing a given value in an
# arbitrary-precision format by a given base. Instance methods provided can
# perform signed arithmetic on this value (addition, subtraction,
# multiplication, division) by passing either an integer, an array of
# place-values with their respective base, or another PressAccept_Arbiter_Basic
# instance.
#
# NOTE: the 'place-value arrays' of this instance are marked as being negative
#       or positive by having a -1 element at index [0]. These are output as
#       well as expected as arguments. values_arr is NOT represented this way:
#       to verify if an instance is negative itself use negative_bool or flags.
#

# *********************
# | Public Properties |
# *********************

# place-values array representing internal value (not signed)
var value_arr  : Array      = [ 0 ]

# any flags about this integer indicating additional information
#
# currently only NEGATIVE is supported
var flags_dict : Dictionary = {
	FLAGS.NEGATIVE: false
}

# the base of the internal place-values array value_arr
#
# setting this will convert values_arr to that base
var base_int      : int = INT_BYTE_BASE setget set_base_int

# shorthand for the information in flags_dict[FLAGS.NEGATIVE]
var negative_bool : bool setget set_negative, get_negative


# ***************
# | Constructor |
# ***************


# constructor(INT|ARRAY|OBJECT, int)
#
# If the first argument is an array, then init_base represents the radix of
# that array and will be the radix of the new values_arr, otherwise init_base
# indicates the radix by which the new value will be stored
func _init(
		init_value     = 0,
		init_base: int = INT_BYTE_BASE) -> void:

	match typeof(init_value):
		TYPE_ARRAY:
			self.negative_bool = false
			init_value = init_value if init_value else [ 0 ]
			if init_value[0] < 0:
				self.negative_bool = true
				init_value.pop_front()

			value_arr = init_value
			base_int = init_base

		_:
			set_value(init_value, INT_BYTE_BASE, init_base)


# ******************
# | SetGet Methods |
# ******************


# consequence of instance.base_int = x
#
# re-evaluates the internal value according to the given base
func set_base_int(
		new_base_int: int) -> void:

	if new_base_int != base_int:
		value_arr = convert_bases(value_arr, base_int, new_base_int)
		base_int = new_base_int


# consequence of instance.negative_bool = x
#
# sets flags_dict[FLAGS.NEGATIVE] to new_value
func set_negative(
		new_value: bool) -> void:

	flags_dict[FLAGS.NEGATIVE] = new_value


# consequence of instance.negative_bool
#
# returns the value of flags_dict[FLAGS.NEGATIVE]
func get_negative() -> bool:

	return flags_dict[FLAGS.NEGATIVE]


# ******************
# | Public Methods |
# ******************


# set the internal value and (optionally) its radix
#
# the second argument is the radix for the first argument if it is an array
# otherwise it is ignored, the third argument is the target radix for the
# internal value
func set_value(
		new_value            = 0,
		new_value_base : int = INT_BYTE_BASE,
		new_base       : int = 0) -> void:

	if not new_base:
		new_base = base_int

	self.negative_bool = false

	match typeof(new_value):
		TYPE_INT:
			if new_value < 0:
				self.negative_bool = true
				new_value = int(abs(new_value))
			value_arr = unsigned_int_to_array(new_value)

			if new_base != INT_BYTE_BASE:
				value_arr = convert_bases(
					value_arr,
					INT_BYTE_BASE,
					new_base
				)

		TYPE_ARRAY:
			new_value = new_value if new_value else [ 0 ]
			if new_value[0] < 0:
				self.negative_bool = true
				new_value.pop_front()

			var temp_value: PressAccept_Arbiter_Basic = \
				get_script().new(new_value, new_value_base)

			temp_value.base_int = new_base
			value_arr = temp_value.value_arr

		TYPE_OBJECT:
			self.negative_bool = new_value.negative_bool
			value_arr     = convert_bases(
				new_value.value_arr,
				new_value.base_int,
				new_base
			)

	base_int = new_base


# is the internal value equal to zero?
func is_zero() -> bool:

	return _is_zero(value_arr)


# returns a *signed* place-values array from the internal array
#
# pass an integer to optionally convert to that base
#
# NOTE: if the internal value is negative the resulting array will be prefaced
#       with an element equal to -1
func to_array(
		in_base: int = base_int) -> Array:

	var ret: Array = value_arr.duplicate()

	if in_base != base_int:
		ret = convert_bases(ret, base_int, in_base)

	if self.negative_bool:
		ret.push_front(-1)

	return ret


# returns a signed 2s complement binary representation of the internal value
#
# NOTE: positive thus is prefaced by a '0'
func to_binary() -> String:

	var bytes: Array

	if base_int != INT_BYTE_BASE:
		bytes = convert_bases(value_arr, base_int, INT_BYTE_BASE)
	else:
		bytes = value_arr

	# account for 2s-complement
	if self.negative_bool:
		bytes = subtract_by_base(bytes, [ 1 ], {}, INT_BYTE_BASE)

	var binary : String = array_to_binary(bytes)
	var ret    : String

	if self.negative_bool and not is_zero():
		ret += '1'
		for i in range(binary.length()):
			ret += '1' if binary[i] == '0' else '0'
	else:
		ret = '0' + binary

	return ret


# returns a string of decimal digits representing the internal value
#
# NOTE: negative values are prefaced by a '-'
func to_decimal() -> String:

	var digits: Array

	if base_int != 10:
		digits = convert_bases(value_arr, base_int, 10)
	else:
		digits = value_arr

	var ret: String = '-' if self.negative_bool and not is_zero() else ''
	for i in range(digits.size()):
		ret += str(digits[i])

	return ret


# returns a string of hexadecimal digits representing the internal value
#
# NOTE: negative values are prefaced by a '-'
func to_hexadecimal() -> String:

	var digits: Array

	if base_int != 16:
		digits = convert_bases(value_arr, base_int, 16)
	else:
		digits = value_arr

	return ('-' if self.negative_bool and not is_zero() else '') + \
		array_to_hexadecimal(digits)


# adds addend (integer, array, or object) to internal value
#
# NOTE: addend_base_int is ignored unless addend is array
func add(
		addend,
		addend_base_int: int = INT_BYTE_BASE) -> PressAccept_Arbiter_Basic:

	addend = _normalize_operand(addend, addend_base_int)

	if not addend:
		return null

	var flags: Dictionary = {}
	match [ addend.negative_bool, self.negative_bool ]:
		[ false, false ], [ true, true ]:
			value_arr = add_by_base(value_arr, addend.value_arr, base_int)
		[ false, true ]:
			value_arr = \
				subtract_by_base(value_arr, addend.value_arr, flags, base_int)
			self.negative_bool = not flags[FLAGS.NEGATIVE]
		[ true,  false ]:
			value_arr = \
				subtract_by_base(value_arr, addend.value_arr, flags, base_int)
			self.negative_bool = flags[FLAGS.NEGATIVE]

	return self


# compares comparison (integer, array, or object) to internal value
#
# NOTE: comparison_base_int is ignore unelss comparison is array
#
# returns value in RELATION enumeration (GREATER_THAN, LESS_THAN, EQUAL)
#     -2 on error (improper argument)
func compare(
		comparison,
		comparison_base_int: int = INT_BYTE_BASE) -> int:

	comparison = _normalize_operand(comparison, comparison_base_int)

	if not comparison:
		return -2

	match [ self.negative_bool, comparison.negative_bool ]:
		[ true, false ]:
			return RELATION.LESS_THAN
		[ false, true ]:
			return RELATION.GREATER_THAN

	var ret: int = compare_arrays(value_arr, comparison.value_arr)

	if self.negative_bool and comparison.negative_bool:
		ret *= -1

	return ret


# subtracts subtrahend (integer, array, or object) from internal value
#
# NOTE: subtrahend_base_int is ignored unless subtrahend is array
func subtract(
		subtrahend,
		subtrahend_base_int: int = INT_BYTE_BASE) -> PressAccept_Arbiter_Basic:

	subtrahend = _normalize_operand(subtrahend, subtrahend_base_int)

	if not subtrahend:
		return null

	var flags: Dictionary = {}
	match [ subtrahend.negative_bool, self.negative_bool ]:
		[ false, false ]:
			value_arr = subtract_by_base(
				value_arr,
				subtrahend.value_arr,
				flags, base_int
			)

			self.negative_bool = flags[FLAGS.NEGATIVE]
		[ false, true ], [ true, false ]:
			value_arr = add_by_base(value_arr, subtrahend.value_arr, base_int)
		[ true,  true ]:
			value_arr = subtract_by_base(
				value_arr,
				subtrahend.value_arr,
				flags,
				base_int
			)

			self.negative_bool = not flags[FLAGS.NEGATIVE]

	return self


# multiplies multiplicand (integer, array, or object) by internal value
#
# NOTE: multiplicand_base_int is ignored unless multiplicand is array
func multiply(
		multiplicand,
		multiplicand_base_int: int = INT_BYTE_BASE
		) -> PressAccept_Arbiter_Basic:

	multiplicand = _normalize_operand(multiplicand, multiplicand_base_int)

	if not multiplicand:
		return null

	value_arr = multiply_by_base(value_arr, multiplicand.value_arr, base_int)

	if is_zero():
		self.negative_bool = false

	match [ multiplicand.negative_bool, self.negative_bool ]:
		[ false, false ], [ true, true  ]:
			self.negative_bool = false
		[ false, true  ], [ true, false ]:
			self.negative_bool = true

	return self


# divides internal value by divisor (integer, array, or object)
#
# NOTE: divisor_base_int is ignored unless divisor is array
#
# returns an array where [DIVISION.QUOTIENT] equals the quotient as object of
# same base and [DIVISION.REMAINDER] equals the remainder as object of same
# base 
func divide(
		divisor,
		divisor_base_int: int = INT_BYTE_BASE) -> Array:

	divisor = _normalize_operand(divisor, divisor_base_int)

	if not divisor or divisor.is_zero():
		return []

	var save_negative    : bool = self.negative_bool
	var divisor_negative : bool = divisor.negative_bool
	self.negative_bool    = false
	divisor.negative_bool = false

	var value_binary   : String = to_binary()
	var divisor_binary : String = divisor.to_binary()
	var result         : Array  = \
		divide_binary_str(value_binary, divisor_binary)

	self.negative_bool    = save_negative
	divisor.negative_bool = divisor_negative

	var quotient  : Object = get_script().new(
		binary_to_array(result[DIVISION.QUOTIENT]),
		INT_BYTE_BASE
	)

	var remainder : Object = get_script().new(
		binary_to_array(result[DIVISION.REMAINDER]),
		INT_BYTE_BASE
	)

	match [ divisor.negative_bool, self.negative_bool ]:
		[ false, false ], [ true, true  ]:
			quotient.negative_bool = false
		[ false, true  ], [ true, false ]:
			quotient.negative_bool = true

	remainder.negative_bool = self.negative_bool

	quotient.base_int = base_int
	remainder.base_int = base_int

	return [ quotient, remainder ]


# *******************
# | Private Methods |
# *******************


# converts argument from an integer, array, or object to object of same radix
func _normalize_operand(
		operand,
		operand_base_init: int = INT_BYTE_BASE) -> PressAccept_Arbiter_Basic:

	match typeof(operand):
		TYPE_OBJECT:
			pass
		TYPE_INT:
			operand = get_script().new(operand, base_int)
		TYPE_ARRAY:
			operand = get_script().new(operand, operand_base_init)
		_:
			return null

	operand.base_int = base_int

	return operand
