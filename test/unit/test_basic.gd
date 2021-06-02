extends "res://addons/gut/test.gd"

# |=========================================|
# |                                         |
# |          Press Accept: Arbiter          |
# |  Arbitrary Precision Integer Arithmetic |
# |                                         |
# |=========================================|
#
# This is a 'test suite' to be used by GUT to make sure the included source
# is operating correctly. This code was not developed using TDD methodologies,
# and so these tests most likely break some TDD rules. That being said, they
# perform random checks (adjustable by INT_NUM_TESTS) to see if
# PressAccept_Arbiter_Basic is behaving as expected given a variety of inputs.
#
# If you have ideas for better, more rigorous or less dependent tests then go
# for it. Note that I have adopted this method due to memory constraints I was
# running into with Godot and other issues. (Using temporary files only
# resulted in long run times, and large files)
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
# 1.0.0    05/24/2021    First Release
# 1.0.1    05/25/2021    Added tests for string representation arguments
#                        Formatted to eliminate warnings/errors
#                        Fixed bug of not testing for array arguments
# 1.1.0    06/21/2021    Changed 'Object' type to specific class
#                        Added tests for
#                            hexadecimal_to_array
#                            array_to_octal
#                            octal_to_array
#                            signal_value_change
#                            value_changed signal
#                            to_octal
#                            to_signed_octal
#                            to_signed_hexadecimal
#                            immutable_add
#                            immutable_subtract
#                            immutable_multiply
#

# warning-ignore-all:return_value_discarded

# |---------|
# | Imports |
# |---------|

# shorthand for our library class
var Basic: Script = PressAccept_Arbiter_Basic

# |-----------|
# | Constants |
# |-----------|

# random seed for deterministic randomized tests
var INT_RANDOM_SEED : int = hash('PressAccept_Arbiter_Basic')

# numebr of times to iterate each test
var INT_NUM_TESTS   : int = 32

# |------------------|
# | Helper Functions |
# |------------------|

# turn an integer into a placevalues array (base 10)
func _int_to_array(
		int_value: int) -> Array:

	var int_arr: String = str(int_value)
	var ret: Array = []

	for digit in int_arr:
		ret.push_back(int(digit))

	return ret


# turn a placevalues array (base 10) into an integer
func _array_to_int(
		array_value: Array) -> int:

	var ret: String = ''
	for digit in array_value:
		ret += str(digit)

	return int(ret)


# compare two values like PressAccept_Arbiter_Basic.compare_*
func _compare_ints(
		left_relation_int  : int,
		right_relation_int : int) -> int:

	if left_relation_int > right_relation_int:
		return Basic.RELATION.GREATER_THAN
	elif left_relation_int < right_relation_int:
		return Basic.RELATION.LESS_THAN

	return Basic.RELATION.EQUAL


# access a string index, returning '0' if index is out-of-bounds
func _access_str(
		buffer_str : String,
		index_int  : int) -> String:

	var buffer_len: int = buffer_str.length()

	return '0' if index_int < -buffer_len or index_int >= buffer_len \
		else buffer_str[index_int]


# |-------|
# | Tests |
# |-------|
#
# Tests follow this format -
#
# static method   - test_<method_identifier>
# instance method - test_basic_<method_identifier>
# signal          - test_byter_signal_<signal identifier>
#

func test_int_to_binary() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var comparison: int = random.randi()
		comparison = (comparison << 32) & 0xffffffff00000000
		comparison += random.randi()

		var test: String = Basic.int_to_binary(comparison)

		var failed: bool = false
		for j in range(64):
			if ((comparison & (1 << j)) as bool) != (_access_str(test, -j - 1) == '1'):
				failed = true

		assert_false(failed, test + ' != ' + str(comparison))


func test_binary_to_array() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var comparison: int = random.randi()
		comparison = (comparison << 31) & 0x7fffffff00000000
		comparison += random.randi()

		var pool: Array = Basic.binary_to_array(
			Basic.int_to_binary(comparison)
		)

		var test: int  = 0
		for j in range(pool.size()):
			test += pool[-j - 1] * int(pow(Basic.INT_BYTE_BASE, j))
		assert_eq(test, comparison)


func test_array_to_binary() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var comparison: int = random.randi()
		comparison = (comparison << 31) & 0x7fffffff00000000
		comparison += random.randi()

		var pool: String = Basic.array_to_binary(
			Basic.unsigned_int_to_array(comparison)
		)

		var test: int  = 0
		for j in range(pool.length()):
			test += int(pool[-j - 1]) * Basic.ARR_POWERS_OF_2[j]
		assert_eq(test, comparison)


func array_to_hexadecimal() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var comparison_str: String = ''
		var comparison_arr: Array  = []
		for _j in range(12):
			var temp_int: int = random.randi_range(0, 15)

			comparison_str += Basic.ARR_HEXADECIMAL_DIGITS[temp_int]
			comparison_arr.push_back(temp_int)

		var test: String = Basic.array_to_hexadecimal(comparison_arr)

		assert_eq(test, comparison_str)


func array_to_octal() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var comparison_str: String = ''
		var comparison_arr: Array  = []
		for _j in range(12):
			var temp_int: int = random.randi_range(0, 7)

			comparison_str += Basic.ARR_HEXADECIMAL_DIGITS[temp_int]
			comparison_arr.push_back(temp_int)

		var test: String = Basic.array_to_octal(comparison_arr)

		assert_eq(test, comparison_str)


func octal_to_array() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var comparison: int = random.randi()
		comparison = (comparison << 31) & 0x7fffffff00000000
		comparison += random.randi()

		var test_str   : String = "%o" % comparison
		var test_octal : Array = Basic.octal_to_array(test_str)

		var test: int  = 0
		for j in range(test_octal.size()):
			test += test_octal[-j - 1] * int(pow(8, j))
		assert_eq(test, comparison)


func test_hexadecimal_to_array() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var comparison: int = random.randi()
		comparison = (comparison << 31) & 0x7fffffff00000000
		comparison += random.randi()

		var test_str: String = "%x" % comparison
		var test_hex: Array  = Basic.hexadecimal_to_array(test_str)

		var test: int  = 0
		for j in range(test_hex.size()):
			test += test_hex[-j - 1] * int(pow(16, j))
		assert_eq(test, comparison)


func test_add_by_base() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var a: int = random.randi()
		a = (a << 30) & 0x3fffffff00000000
		a += random.randi()

		var b: int = random.randi()
		b = (b << 30) & 0x3fffffff00000000
		b += random.randi()

		var comparison: int = a + b

		var test_a   : Array = Basic.unsigned_int_to_array(a)
		var test_b   : Array = Basic.unsigned_int_to_array(b)
		var test_sum : Array = \
			Basic.add_by_base(test_a, test_b, Basic.INT_BYTE_BASE)

		var test: int = 0
		for j in range(test_sum.size()):
			test += test_sum[-j - 1] * int(pow(Basic.INT_BYTE_BASE, j))

		assert_eq(test, comparison)

		var test_a_10   : Array = _int_to_array(a)
		var test_b_10   : Array = _int_to_array(b)
		var test_sum_10 : Array = Basic.add_by_base(test_a_10, test_b_10, 10)

		test = 0
		for j in range(test_sum_10.size()):
			test += test_sum_10[-j - 1] * int(pow(10, j))
		assert_eq(test, comparison)

		var test_a_16   : String = "%X" % a
		var test_b_16   : String = "%X" % b
		var test_a_arr  : Array  = Basic.hexadecimal_to_array(test_a_16)
		var test_b_arr  : Array  = Basic.hexadecimal_to_array(test_b_16)
		var test_sum_16 : Array  = Basic.add_by_base(test_a_arr, test_b_arr, 16)

		test = 0
		for j in range(test_sum_16.size()):
			test += test_sum_16[-j - 1] * int(pow(16, j))
		assert_eq(test, comparison)


func test_add_binary_str() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var a: int = random.randi()
		a = (a << 30) & 0x3fffffff00000000
		a += random.randi()

		var b: int = random.randi()
		b = (b << 30) & 0x3fffffff00000000
		b += random.randi()

		var comparison: int = a + b

		var test_a   : String = Basic.int_to_binary(a)
		var test_b   : String = Basic.int_to_binary(b)
		var test_sum : String = Basic.add_binary_str(test_a, test_b)

		var test: int  = 0
		for j in range(test_sum.length()):
			test += int(test_sum[-j - 1]) * Basic.ARR_POWERS_OF_2[j]
		assert_eq(test, comparison)


func test_compare_arrays() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var a: int = random.randi()
		a = (a << 30) & 0x3fffffff00000000
		a += random.randi()

		var b: int = random.randi()
		b = (b << 30) & 0x3fffffff00000000
		b += random.randi()

		var comparison: int = _compare_ints(a, b)

		var test_a: Array = Basic.unsigned_int_to_array(a)
		var test_b: Array = Basic.unsigned_int_to_array(b)
		assert_eq(Basic.compare_arrays(test_a, test_b), comparison)

		test_a = _int_to_array(a)
		test_b = _int_to_array(b)
		assert_eq(
			Basic.compare_arrays(test_a, test_b),
			comparison,
			str(a) + " " + str(b)
		)


func test_compare_binary_str() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var a: int = random.randi()
		a = (a << 30) & 0x3fffffff00000000
		a += random.randi()

		var b: int = random.randi()
		b = (b << 30) & 0x3fffffff00000000
		b += random.randi()

		var comparison: int = _compare_ints(a, b)

		var test_a: String = Basic.int_to_binary(a)
		var test_b: String = Basic.int_to_binary(b)
		assert_eq(Basic.compare_binary_str(test_a, test_b), comparison)


func test_subtract_by_base() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var a: int = random.randi()
		a = (a << 30) & 0x3fffffff00000000
		a += random.randi()

		var b: int = random.randi()
		b = (b << 30) & 0x3fffffff00000000
		b += random.randi()

		var comparison       : int
		var comparison_flags : Dictionary = {}
		if a > b:
			comparison = a - b
			comparison_flags[Basic.FLAGS.NEGATIVE] = false
		else:
			comparison = b - a
			comparison_flags[Basic.FLAGS.NEGATIVE] = true

		var test_flags : Dictionary = {}
		var test_a     : Array      = Basic.unsigned_int_to_array(a)
		var test_b     : Array      = Basic.unsigned_int_to_array(b)
		var test_sum   : Array      = Basic.subtract_by_base(
			test_a,
			test_b,
			test_flags,
			Basic.INT_BYTE_BASE
		)

		var test: int = 0
		for j in range(test_sum.size()):
			test += test_sum[-j - 1] * int(pow(Basic.INT_BYTE_BASE, j))

		assert_eq(test, comparison)
		assert_eq_shallow(test_flags, comparison_flags)

		var test_a_10   : Array = _int_to_array(a)
		var test_b_10   : Array = _int_to_array(b)
		var test_sum_10 : Array = \
			Basic.subtract_by_base(test_a_10, test_b_10, test_flags, 10)

		test = 0
		for j in range(test_sum_10.size()):
			test += test_sum_10[-j - 1] * int(pow(10, j))
		assert_eq(test, comparison)
		assert_eq_shallow(test_flags, comparison_flags)

		var test_a_16   : String = "%X" % a
		var test_b_16   : String = "%X" % b
		var test_a_arr  : Array  = Basic.hexadecimal_to_array(test_a_16)
		var test_b_arr  : Array  = Basic.hexadecimal_to_array(test_b_16)
		var test_sum_16 : Array  = \
			Basic.subtract_by_base(test_a_arr, test_b_arr, test_flags, 16)

		test = 0
		for j in range(test_sum_16.size()):
			test += test_sum_16[-j - 1] * int(pow(16, j))
		assert_eq(test, comparison)
		assert_eq_shallow(test_flags, comparison_flags)


func test_subtract_binary_str() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var a: int = random.randi()
		a = (a << 30) & 0x3fffffff00000000
		a += random.randi()

		var b: int = random.randi()
		b = (b << 30) & 0x3fffffff00000000
		b += random.randi()

		var comparison       : int
		var comparison_flags : Dictionary = {}
		if a > b:
			comparison = a - b
		else:
			comparison = b - a
			comparison_flags[Basic.FLAGS.NEGATIVE] = true

		var test_a    : String     = Basic.int_to_binary(a)
		var test_b    : String     = Basic.int_to_binary(b)
		var flags     : Dictionary = {}
		var test_diff : String     = \
			Basic.subtract_binary_str(test_a, test_b, flags)

		var test  : int  = 0
		for j in range(test_diff.length()):
			test += int(test_diff[-j - 1]) * Basic.ARR_POWERS_OF_2[j]
		assert_eq(test, comparison)
		assert_eq_shallow(flags, comparison_flags)


func test_coefficient_multiply_by_base() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var a          : int   = random.randi() >> 1
		var b          : int   = random.randi()
		var comparison : int   = a * b

		var coefficient  : Array = Basic.unsigned_int_to_array(a)
		var multiplicand : Array = Basic.unsigned_int_to_array(b)
		var product      : Array = Basic.coefficient_multiply_by_base(
			coefficient,
			multiplicand,
			Basic.INT_BYTE_BASE
		)

		var test: int = 0
		for j in range(product.size()):
			test += product[-j - 1] * int(pow(Basic.INT_BYTE_BASE, j))
		assert_eq(test, comparison)

		var multiplicand_10: Array  = _int_to_array(b)
		product = Basic.coefficient_multiply_by_base(
			coefficient,
			multiplicand_10,
			10
		)

		test = 0
		for j in range(product.size()):
			test += product[-j - 1] * int(pow(10, j))
		assert_eq(test, comparison)

		var multiplicand_16_str : String = "%X" % b
		var multiplicand_16     : Array  = \
			Basic.hexadecimal_to_array(multiplicand_16_str)
		product = Basic.coefficient_multiply_by_base(
			coefficient,
			multiplicand_16,
			16
		)

		test = 0
		for j in range(product.size()):
			test += product[-j - 1] * int(pow(16, j))
		assert_eq(test, comparison)


func test_multiply_by_base() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var a          : int   = random.randi() >> 1
		var b          : int   = random.randi()
		var comparison : int   = a * b

		var coefficient  : Array = Basic.unsigned_int_to_array(a)
		var multiplicand : Array = Basic.unsigned_int_to_array(b)
		var product      : Array = Basic.multiply_by_base(
			coefficient,
			multiplicand,
			Basic.INT_BYTE_BASE
		)

		var test: int = 0
		for j in range(product.size()):
			test += product[-j - 1] * int(pow(Basic.INT_BYTE_BASE, j))
		assert_eq(test, comparison)

		var coefficient_10  : Array = _int_to_array(a)
		var multiplicand_10 : Array = _int_to_array(b)
		product = Basic.multiply_by_base(
			coefficient_10,
			multiplicand_10,
			10
		)

		test = 0
		for j in range(product.size()):
			test += product[-j - 1] * int(pow(10, j))
		assert_eq(test, comparison)

		var coefficient_16_str  : String = "%X" % a
		var coefficient_16      : Array  = \
			Basic.hexadecimal_to_array(coefficient_16_str)
		var multiplicand_16_str : String = "%X" % b
		var multiplicand_16     : Array  = \
			Basic.hexadecimal_to_array(multiplicand_16_str)
		product = Basic.multiply_by_base(
			coefficient_16,
			multiplicand_16,
			16
		)

		test = 0
		for j in range(product.size()):
			test += product[-j - 1] * int(pow(16, j))
		assert_eq(test, comparison)


func test_shift_binary_str_left() -> void:

	var comparison : String = '01011011101111011111'
	var test       : String = comparison

	while '1' in comparison:
		comparison = comparison.substr(1) + '0'
		test = Basic.shift_binary_str_left(test)
		assert_eq(test, comparison)


func test_shift_binary_str_right() -> void:

	var comparison : String = '01011011101111011111'
	var test       : String = comparison

	while '1' in comparison:
		comparison = '0' + comparison.substr(0, comparison.length() - 1)
		test = Basic.shift_binary_str_right(test)
		assert_eq(test, comparison)


func test_divide_binary_str() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var a: int = random.randi()
		a = (a << 30) & 0x7fffffff00000000
		a += random.randi()

		var b: int = random.randi()
		b = (b << 30) & 0x7fffffff00000000
		b += random.randi()

		# warning-ignore:integer_division
		var comparison_quotient  : int = int(a / b)
		var comparison_remainder : int = a % b

		var a_binary : String = Basic.int_to_binary(a)
		var b_binary : String = Basic.int_to_binary(b)
		var result   : Array  = Basic.divide_binary_str(a_binary, b_binary)

		var test_quotient: int = 0
		for j in range(result[Basic.DIVISION.QUOTIENT].length()):
			test_quotient += \
				int(result[Basic.DIVISION.QUOTIENT][-j -1]) * \
				Basic.ARR_POWERS_OF_2[j]

		var test_remainder: int = 0
		for j in range(result[Basic.DIVISION.REMAINDER].length()):
			test_remainder += \
				int(result[Basic.DIVISION.REMAINDER][-j -1]) * \
				Basic.ARR_POWERS_OF_2[j]

		assert_eq(
			[ test_quotient      , test_remainder       ],
			[ comparison_quotient, comparison_remainder ]
		)


func test_convert_bases() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var comparison: int = random.randi()
		comparison = (comparison << 30) & 0x7fffffff00000000
		comparison += random.randi()

		var comparison_base_256    : Array  = Basic.unsigned_int_to_array(comparison)
		var comparison_base_16_str : String = "%X" % comparison
		var comparison_base_16     : Array  = \
			Basic.hexadecimal_to_array(comparison_base_16_str)
		var comparison_base_10     : Array  = _int_to_array(comparison)

		assert_eq(Basic.convert_bases(comparison_base_16 ,  16,  256), comparison_base_256)
		assert_eq(Basic.convert_bases(comparison_base_10 ,  10,  256), comparison_base_256)
		assert_eq(Basic.convert_bases(comparison_base_256, 256,   16), comparison_base_16 )
		assert_eq(Basic.convert_bases(comparison_base_10 ,  10,   16), comparison_base_16 )
		assert_eq(Basic.convert_bases(comparison_base_256, 256,   10), comparison_base_10 )
		assert_eq(Basic.convert_bases(comparison_base_16 ,  16,   10), comparison_base_10 )


func test_basic_initialization() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var comparison: int = (random.randi() << 32) + random.randi()

		var test: PressAccept_Arbiter_Basic = Basic.new(comparison)

		if comparison < 0:
			assert_true(test.negative_bool)
			assert_true(test.flags_dict[Basic.FLAGS.NEGATIVE])

		assert_eq(test.to_decimal(), str(comparison))

		test = Basic.new(comparison, (random.randi() % 32) + 3)

		if comparison < 0:
			assert_true(test.negative_bool)
			assert_true(test.flags_dict[Basic.FLAGS.NEGATIVE])

		assert_eq(test.to_decimal(), str(comparison))

		comparison  = (random.randi() << 31) & 0x7fffffff00000000
		comparison += random.randi()

		var comparison_arr = _int_to_array(comparison)

		test = Basic.new(comparison_arr, 10)

		assert_eq(test.to_decimal(), str(comparison))

		var test_obj: PressAccept_Arbiter_Basic = Basic.new(test)

		assert_eq(test_obj.to_decimal(), test.to_decimal())


func test_basic_signal_value_change() -> void:

	var test: PressAccept_Arbiter_Basic = Basic.new()

	test.signal_value_change = true

	assert_true(test.signal_value_change)

	test.signal_value_change = false

	assert_false(test.signal_value_change)


func test_basic_signal_value_changed() -> void:

	var test: PressAccept_Arbiter_Basic = Basic.new(123456789)

	test.signal_value_change = true

	watch_signals(test)

	test.set_negative(true)

	assert_signal_emitted_with_parameters(
		test,
		'value_changed',
		[ '-123456789', '123456789', test ]
	)

	test.set_negative(true)

	assert_signal_emit_count(test, 'value_changed', 1)

	test.set_negative(false)

	assert_signal_emitted_with_parameters(
		test,
		'value_changed',
		[ '123456789', '-123456789', test ]
	)

	test.set_value(123456)
	
	assert_signal_emitted_with_parameters(
		test,
		'value_changed',
		[ '123456', '123456789', test ]
	)

	test.set_value('1234567')
	
	assert_signal_emitted_with_parameters(
		test,
		'value_changed',
		[ '1234567', '123456', test ]
	)

	var byte_array: Array = [ 1, 0 ]

	test.set_value(byte_array, Basic.INT_BYTE_BASE)

	assert_signal_emitted_with_parameters(
		test,
		'value_changed',
		[ '256', '1234567', test ]
	)

	var test_2: PressAccept_Arbiter_Basic = Basic.new()

	test.set_value(test_2)

	assert_signal_emitted_with_parameters(
		test,
		'value_changed',
		[ '0', '256', test ]
	)

	test.add(12)

	assert_signal_emitted_with_parameters(
		test,
		'value_changed',
		[ '12', '0', test ]
	)

	test.subtract(4)

	assert_signal_emitted_with_parameters(
		test,
		'value_changed',
		[ '8', '12', test ]
	)

	test.multiply(7)

	assert_signal_emitted_with_parameters(
		test,
		'value_changed',
		[ '56', '8', test ]
	)

	test.immutable_add(1)
	
	assert_signal_emit_count(test, 'value_changed', 9)

	test.immutable_subtract(1)

	assert_signal_emit_count(test, 'value_changed', 9)

	test.immutable_multiply(2)

	assert_signal_emit_count(test, 'value_changed', 9)


func test_basic_set_value() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var comparison: int = (random.randi() << 32) + random.randi()

		var test: PressAccept_Arbiter_Basic = Basic.new()
		test.set_value(comparison)

		if comparison < 0:
			assert_true(test.negative_bool)
			assert_true(test.flags_dict[Basic.FLAGS.NEGATIVE])

		assert_eq(test.to_decimal(), str(comparison))

		test = Basic.new()
		test.set_value(comparison, Basic.INT_BYTE_BASE, (random.randi() % 32) + 3)

		if comparison < 0:
			assert_true(test.negative_bool)
			assert_true(test.flags_dict[Basic.FLAGS.NEGATIVE])

		assert_eq(test.to_decimal(), str(comparison))

		comparison  = (random.randi() << 31) & 0x7fffffff00000000
		comparison += random.randi()

		var comparison_arr = _int_to_array(comparison)

		test = Basic.new()
		test.set_value(comparison_arr, 10)

		assert_eq(test.to_decimal(), str(comparison))

		var test_obj: PressAccept_Arbiter_Basic = Basic.new(test)

		assert_eq(test_obj.to_decimal(), test.to_decimal())

		test = Basic.new()
		test.set_value(str(comparison))

		assert_eq(test.to_decimal(), str(comparison))


func test_basic_set_base_int() -> void:

	var comparison        : int    = 1234567890
	var comparison_arr    : Array  = Basic.unsigned_int_to_array(comparison)
	var comparison_16_str : String = "%X" % comparison
	var comparison_16_arr : Array  = Basic.hexadecimal_to_array(comparison_16_str)
	var comparison_10_arr : Array  = _int_to_array(comparison)

	var test: PressAccept_Arbiter_Basic = Basic.new(comparison)

	assert_eq(test.value_arr, comparison_arr)
	assert_eq(test.base_int, Basic.INT_BYTE_BASE)

	test.base_int = 16
	assert_eq(test.value_arr, comparison_16_arr)
	assert_eq(test.base_int, 16)

	test.base_int = 10
	assert_eq(test.value_arr, comparison_10_arr)
	assert_eq(test.base_int, 10)


func test_basic_setget_negative() -> void:

	var test: PressAccept_Arbiter_Basic = Basic.new()

	test.set_negative(true)

	assert_true(test.negative_bool)
	assert_true(test.get_negative())
	assert_true(test.flags_dict[Basic.FLAGS.NEGATIVE])

	test.negative_bool = false

	assert_false(test.negative_bool)
	assert_false(test.get_negative())
	assert_false(test.flags_dict[Basic.FLAGS.NEGATIVE])


func test_basic_to_array() -> void:

	var comparison     : int   = 1234567890
	var comparison_arr : Array = Basic.unsigned_int_to_array(comparison)
	var test           : PressAccept_Arbiter_Basic = Basic.new(comparison)

	assert_eq(test.to_array(), comparison_arr)

	comparison = -1234567890
	test       = Basic.new(comparison)

	# if we convert a negative int to a pool, we get 2s complement
	# so we must compare the positive (turned negative), and then check the flag
	comparison_arr.push_front(-1)

	assert_eq(test.to_array(), comparison_arr)
	assert_true(test.negative_bool)

	comparison = 1234567890

	var comparison_16_str : String = "%X" % comparison
	var comparison_16_arr : Array  = Basic.hexadecimal_to_array(comparison_16_str)
	var comparison_10_arr : Array  = _int_to_array(comparison)

	test = Basic.new(comparison)

	assert_eq(test.to_array(16), comparison_16_arr)
	assert_eq(test.to_array(10), comparison_10_arr)


func test_basic_to_binary() -> void:

	var comparison     : int    = 12345678890
	var comparison_str : String = Basic.int_to_binary(comparison)
	var test           : PressAccept_Arbiter_Basic = Basic.new(comparison)

	assert_eq(test.to_binary(), comparison_str)

	comparison     = -1234567890
	comparison_str = Basic.int_to_binary(comparison)
	test           = Basic.new(comparison)

	assert_eq(test.to_binary(), comparison_str)


func test_basic_to_decimal() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var comparison : int = (random.randi() << 32) + random.randi()
		var test       : PressAccept_Arbiter_Basic = Basic.new(comparison)

		assert_eq(test.to_decimal(), str(comparison))


func test_basic_to_octal() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var comparison : int = (random.randi() << 32) + random.randi()
		var test       : PressAccept_Arbiter_Basic = Basic.new(comparison)

		assert_eq(test.to_octal(), "%o" % comparison)


func test_basic_to_signed_octal() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var comparison : int = (random.randi() << 32) + random.randi()
		var test       : PressAccept_Arbiter_Basic = Basic.new(comparison)

		var comparison_octal_str: String = ''
		if comparison > 0:
			comparison_octal_str = "%o" % comparison
		else:
			var comparison_octal_arr: Array = Basic.convert_bases(
				Basic.binary_to_array(test.to_binary()),
				Basic.INT_BYTE_BASE,
				8
			)

			# fill in 1's to the left
			for i in range(2, -1, -1):
				if not comparison_octal_arr[0] & (1 << i):
					comparison_octal_arr[0] += (1 << i)
				else:
					break

			comparison_octal_str = Basic.array_to_octal(comparison_octal_arr)
		if comparison > 0:
			match comparison_octal_str[0]:
				'4', '5', '6', '7': # 100, 101, 110, 111
					comparison_octal_str = '0' + comparison_octal_str

		var test_octal_str: String = test.to_signed_octal()

		assert_eq(test_octal_str, comparison_octal_str)


func test_basic_to_hexadecimal() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var comparison : int = (random.randi() << 32) + random.randi()
		var test       : PressAccept_Arbiter_Basic = Basic.new(comparison)

		assert_eq(test.to_hexadecimal(), "%x" % comparison)

func test_basic_to_signed_hexadecimal() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var comparison : int = (random.randi() << 32) + random.randi()
		var test       : PressAccept_Arbiter_Basic = Basic.new(comparison)

		var comparison_hex_str: String = ''
		if comparison > 0:
			comparison_hex_str = "%x" % comparison
		else:
			var comparison_hex_arr: Array = Basic.convert_bases(
				Basic.binary_to_array(test.to_binary()),
				Basic.INT_BYTE_BASE,
				16
			)

			# fill in 1's to the left
			for i in range(3, -1, -1):
				if not comparison_hex_arr[0] & (1 << i):
					comparison_hex_arr[0] += (1 << i)
				else:
					break

			comparison_hex_str = Basic.array_to_hexadecimal(comparison_hex_arr)
		if comparison > 0:
			match comparison_hex_str[0]:
				'8', '9', 'a', 'b', 'c', 'd', 'e', 'f':
				# 1000, 1001, 1010, 1011, 1100, 1101, 1110, 1111
					comparison_hex_str = '0' + comparison_hex_str

		var test_hex_str: String = test.to_signed_hexadecimal()

		assert_eq(test_hex_str, comparison_hex_str)


func test_basic_add() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var a: int = random.randi()
		if random.randi_range(0, 1) < 1:
			a *= -1

		var b: int = random.randi()
		if random.randi_range(0, 1) < 1:
			b *= -1

		var comparison: int = a + b

		var test: PressAccept_Arbiter_Basic = Basic.new(a)
		test.add(b)

		assert_eq(test.to_decimal(), str(comparison))

		var b_arr: Array = Basic.unsigned_int_to_array(b)
		if b < 0:
			b_arr.push_front(-1)

		test = Basic.new(a)
		test.add(b_arr, Basic.INT_BYTE_BASE)

		assert_eq(test.to_decimal(), str(comparison))

		b_arr = _int_to_array(b)

		test = Basic.new(a)
		test.add(b, 10)

		assert_eq(test.to_decimal(), str(comparison))

		var test_b: PressAccept_Arbiter_Basic = Basic.new(b, 16)

		test = Basic.new(a)
		test.add(test_b)

		assert_eq(test.to_decimal(), str(comparison))

		test = Basic.new(a)
		test.add(str(b))

		assert_eq(test.to_decimal(), str(comparison))


func test_basic_immutable_add() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var a: int = random.randi()
		if random.randi_range(0, 1) < 1:
			a *= -1

		var b: int = random.randi()
		if random.randi_range(0, 1) < 1:
			b *= -1

		var comparison : int = a + b
		var test_a     : PressAccept_Arbiter_Basic = Basic.new(a)

		var test_b: PressAccept_Arbiter_Basic = test_a.immutable_add(b)

		assert_eq(test_a.to_decimal(), str(a))

		assert_eq(test_b.to_decimal(), str(comparison))



func test_basic_compare() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var a: int = random.randi()
		if random.randi_range(0, 1) < 1:
			a *= -1

		var b: int = random.randi()
		if random.randi_range(0, 1) < 1:
			b *= -1

		var comparison: int = _compare_ints(a, b)

		var test: PressAccept_Arbiter_Basic = Basic.new(a)

		assert_eq(test.compare(b), comparison)

		var test_b_arr: Array = Basic.unsigned_int_to_array(int(abs(b)))
		if b < 0:
			test_b_arr.push_front(-1)

		assert_eq(test.compare(test_b_arr), comparison)

		var test_b_obj: PressAccept_Arbiter_Basic = PressAccept_Arbiter_Basic.new(b)
		assert_eq(test.compare(test_b_obj), comparison)

		assert_eq(test.compare(str(b)), comparison)


func test_basic_subtract() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var a: int = random.randi()
		if random.randi_range(0, 1) < 1:
			a *= -1

		var b: int = random.randi()
		if random.randi_range(0, 1) < 1:
			b *= -1

		var comparison: int = a - b

		var test: PressAccept_Arbiter_Basic = Basic.new(a)
		test.subtract(b)

		assert_eq(test.to_decimal(), str(comparison))

		var b_arr: Array = Basic.unsigned_int_to_array(b)
		if b < 0:
			b_arr.push_front(-1)

		test = Basic.new(a)
		test.subtract(b_arr, Basic.INT_BYTE_BASE)

		assert_eq(test.to_decimal(), str(comparison))

		b_arr = _int_to_array(b)

		test = Basic.new(a)
		test.subtract(b, 10)

		assert_eq(test.to_decimal(), str(comparison))

		var test_b: PressAccept_Arbiter_Basic = Basic.new(b, 16)

		test = Basic.new(a)
		test.subtract(test_b)

		assert_eq(test.to_decimal(), str(comparison))

		test = Basic.new(a)
		test.subtract(str(b))

		assert_eq(test.to_decimal(), str(comparison))


func test_basic_immutable_subtract() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var a: int = random.randi()
		if random.randi_range(0, 1) < 1:
			a *= -1

		var b: int = random.randi()
		if random.randi_range(0, 1) < 1:
			b *= -1

		var comparison : int = a - b
		var test_a     : PressAccept_Arbiter_Basic = Basic.new(a)

		var test_b: PressAccept_Arbiter_Basic = test_a.immutable_subtract(b)

		assert_eq(test_a.to_decimal(), str(a))

		assert_eq(test_b.to_decimal(), str(comparison))


func test_basic_multiply() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var a: int   = random.randi() >> 1
		var b: int   = random.randi()

		if random.randi_range(0, 1) < 1:
			a *= -1

		if random.randi_range(0, 1) < 1:
			b *= -1

		var comparison: int = a * b

		var test: PressAccept_Arbiter_Basic = Basic.new(a)
		test.multiply(b)

		assert_eq(test.to_decimal(), str(comparison))

		var b_arr: Array = Basic.unsigned_int_to_array(b)
		if b < 0:
			b_arr.push_front(-1)

		test = Basic.new(a)
		test.multiply(b_arr, Basic.INT_BYTE_BASE)

		assert_eq(test.to_decimal(), str(comparison))

		b_arr = _int_to_array(b)
		if b < 0:
			b_arr.push_front(-1)

		test = Basic.new(a)
		test.multiply(b_arr, 10)

		assert_eq(test.to_decimal(), str(comparison))

		var test_b: PressAccept_Arbiter_Basic = Basic.new(b, 16)

		test = Basic.new(a)
		test.multiply(test_b)

		assert_eq(test.to_decimal(), str(comparison))

		test = Basic.new(a)
		test.multiply(0)

		assert_eq(test.to_decimal(), str(0))

		test = Basic.new(a)
		test.multiply(str(b))

		assert_eq(test.to_decimal(), str(comparison))


func test_basic_immutable_multiplied() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var a: int   = random.randi() >> 1
		var b: int   = random.randi()

		if random.randi_range(0, 1) < 1:
			a *= -1

		if random.randi_range(0, 1) < 1:
			b *= -1

		var comparison : int = a * b
		var test_a     : PressAccept_Arbiter_Basic = Basic.new(a)

		var test_b: PressAccept_Arbiter_Basic = test_a.immutable_multiply(b)

		assert_eq(test_a.to_decimal(), str(a))

		assert_eq(test_b.to_decimal(), str(comparison))


func test_basic_divide() -> void:

	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = INT_RANDOM_SEED

	for _i in range(INT_NUM_TESTS):
		var a: int   = random.randi() >> 1
		var b: int   = random.randi()

		if random.randi_range(0, 1) < 1:
			a *= -1

		if random.randi_range(0, 1) < 1:
			b *= -1

		# warning-ignore:integer_division
		var comparison_quotient  : int = int(a / b)
		var comparison_remainder : int = a % b

		var test           : PressAccept_Arbiter_Basic = Basic.new(a)
		var test_result    : Array  = test.divide(b)
		var test_quotient  : String = test_result[Basic.DIVISION.QUOTIENT].to_decimal()
		var test_remainder : String = test_result[Basic.DIVISION.REMAINDER].to_decimal()

		assert_eq(test_quotient , str(comparison_quotient) )
		assert_eq(test_remainder, str(comparison_remainder))

		var b_arr: Array = Basic.unsigned_int_to_array(b)
		if b < 0:
			b_arr.push_front(-1)

		test           = Basic.new(a)
		test_result    = test.divide(b_arr, Basic.INT_BYTE_BASE)
		test_quotient  = test_result[Basic.DIVISION.QUOTIENT].to_decimal()
		test_remainder = test_result[Basic.DIVISION.REMAINDER].to_decimal()

		assert_eq(test_quotient , str(comparison_quotient) )
		assert_eq(test_remainder, str(comparison_remainder))

		b_arr = _int_to_array(b)

		test           = Basic.new(a)
		test_result    = test.divide(b, 10)
		test_quotient  = test_result[Basic.DIVISION.QUOTIENT].to_decimal()
		test_remainder = test_result[Basic.DIVISION.REMAINDER].to_decimal()

		assert_eq(test_quotient , str(comparison_quotient) )
		assert_eq(test_remainder, str(comparison_remainder))

		var test_b: PressAccept_Arbiter_Basic = Basic.new(b, 16)

		test           = Basic.new(a)
		test_result    = test.divide(test_b)
		test_quotient  = test_result[Basic.DIVISION.QUOTIENT].to_decimal()
		test_remainder = test_result[Basic.DIVISION.REMAINDER].to_decimal()

		assert_eq(test_quotient , str(comparison_quotient) )
		assert_eq(test_remainder, str(comparison_remainder))

		test           = Basic.new(a)
		test_result    = test.divide(str(b))
		test_quotient  = test_result[Basic.DIVISION.QUOTIENT].to_decimal()
		test_remainder = test_result[Basic.DIVISION.REMAINDER].to_decimal()

		assert_eq(test_quotient , str(comparison_quotient) )
		assert_eq(test_remainder, str(comparison_remainder))

