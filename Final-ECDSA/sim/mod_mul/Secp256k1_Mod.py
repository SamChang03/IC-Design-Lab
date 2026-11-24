def secp256k1_mod(x):
    """
    Perform modular reduction for a 512-bit integer using the secp256k1 curve parameter.

    Args:
        x (int): A 512-bit integer (input value).

    Returns:
        int: A 256-bit integer result after modular reduction.
    """
    # p = 2^256 - 2^32 - 977
    p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F

    # secp256k1 parameter (2^32 + 977)
    secp256k1_parameter = 0x1000003D1

    # Split the input x into high and low 256 bits
    x_high = x >> 256  # Extract the high 256 bits
    x_low = x & ((1 << 256) - 1)  # Extract the low 256 bits

    # Perform the first reduction
    x_high_reduced = x_high * secp256k1_parameter
    reduced_1 = (x_high_reduced & ((1 << 256) - 1)) + x_low
    print(f'reduced_1: {hex(reduced_1)}')

    # Perform the second reduction
    reduced_2_temp = (x_high_reduced >> 256) * secp256k1_parameter + reduced_1
    if reduced_2_temp >= p:
        reduced_2 = reduced_2_temp - p
    else:
        reduced_2 = reduced_2_temp

    # Final 256-bit result
    return reduced_2 & ((1 << 256) - 1)

# Example usage
if __name__ == "__main__":
    # Example 512-bit input
    x = 0x2619_5c2d_adc2_7605_68a6_8901_b94b_47e9_6789_c964_d7c0_e0aa_04b0_259e_432c_2bd6_f2ba_6ae0_eec4_8e19_d8cc_dd39_822d_4670_2bcd_327b_2b6b_40b0_8744_65fd_701e_d2f6
    result = secp256k1_mod(x)
    print(f"Input (512-bit): {hex(x)}")
    print(f"Output (256-bit): {hex(result)}")
