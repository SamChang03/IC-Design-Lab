def karatsuba_256bit(A, B):
    """
    Perform 256-bit Karatsuba multiplication on integers A and B.
    """
    # Split A and B into 128-bit halves
    mask_128 = (1 << 128) - 1
    a = A >> 128
    b = A & mask_128
    c = B >> 128
    d = B & mask_128

    # Compute three products using Karatsuba method
    ac = a * c
    print(f'ac: {hex(ac)}')
    bd = b * d
    print(f'bd: {hex(bd)}')
    ab_cd = (a + b) * (c + d) - ac - bd
    print(f'ab_cd: {hex(ab_cd)}')

    # Combine results to form the final product
    product = (ac << 256) + (ab_cd << 128) + bd

    return product

# Example usage
A = 0x26d23a136732f7a097caf3c349c33583dc390b7a4cca4865c122ecbbca3a9b66
B = 0xfb3ced2a543a3a882418c08c8a8695e7c840b480836e5d23dfaae22ebe366119
result = karatsuba_256bit(A, B)
print(f'result: {hex(result)}')
P = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
print(f'result % P: {hex(result % P)}')
