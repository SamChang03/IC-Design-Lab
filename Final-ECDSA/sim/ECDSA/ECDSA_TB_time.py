# import time
# start_time = time.time()

# n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
# k = 0xba8a94d307c4a3df7c68fe3a14eac2925ab05c5f63f8d6650613724d42ec414c
# da = 0x730b5e46cd9cec3da94619529477ba2c40bb14bb82d094a13f1b51b04a0e2cc0



# k_inv = pow(k, -1, n)
# # print(f"k_inv = {hex(k_inv)}")

# KIDA = (k_inv * da) % n
# # print(f"KIDA = {hex(KIDA)}")

# plaint_txt = """G3MFav0WWv59e
# gBH1XKHISWaRSY1x*dMPD6OaF
# GF)F@XaY3@Tw
# 6vOEO#$bnp7iCSmed#Q8vNi4c$GX*
# kB5v*RtlHB5r0DMQaBVLCnxJjbA8cnJg*6E!xV
# jNJPhB0y&gEBbuRFiH(r64Jf#f$8(!N4kGLDVPTUaz3$7kFCI
# )x$j7UJc(nrK!9*TMfK0pjTxkOkyM(1*N9D%X
# dHwZvE#!i#5WyliEOnx64$nHg!9BZTum5gB5*p@3$
# SeRm1%Jt%J%DpzV*Y%6XD
# gUeqC!$gV(AUiX#jv"""

# # generate the hash of the plaint_txt
# import hashlib
# hash_txt = hashlib.sha256(plaint_txt.encode()).hexdigest()
# # print(f"hash_txt = {hash_txt}")

# hash_hex = int(hash_txt, 16)
# KIZ = (k_inv * hash_hex) % n
# # print(f"KIZ = {hex(KIZ)}")


# import random
# from ecdsa.curves import SECP256k1
# from ecdsa.ellipticcurve import Point

# # 取得 SECP256k1 曲線的生成點
# G = SECP256k1.generator

# r = (k * G).x() % n
# # print(f"r = {hex(r)}")

# KIRDA = (KIDA * r) % n
# # print(f"KIRDA = {hex(KIRDA)}")

# SIGN = (KIRDA + KIZ) % n
# # print(f"SIGN = {hex(SIGN)}")

# e = int(hash_txt, 16)
# e_len = e.bit_length()
# z = e
# if e_len > n.bit_length():
#     z = e >> (e_len - n.bit_length())

# while True:
#     R = k * G
#     r = R.x() % n
#     if r == 0:
#         continue
    
#     k_inv = pow(k, -1, n)
#     s = (k_inv * ((z + (r*da) % n) % n)) % n
#     if s == 0:
#         continue
#     print(f"r = {hex(r)}")
#     print(f"s = {hex(s)}")
#     break

# end_time = time.time()
# execution_time = end_time - start_time
# print(f"\n執行時間: {execution_time:.4f} 秒")

############################

import gc
gc.collect()
import time
start_time = time.time()

# from ecdsa import ellipticcurve, numbertheory

def point_double_jacobian(X1, Y1, Z1, p, a=0):
    """
    橢圓曲線點倍乘運算 (Jacobian 座標系統)
    參數:
        X1, Y1, Z1: 輸入點的 Jacobian 座標
        p: 模數
        a: 曲線參數 (secp256k1 為 0)
    返回:
        (X3, Y3, Z3): 結果點的 Jacobian 座標
    """
    
    # STEP 1: 計算 XX, YY, YYYY
    XX = (X1 * X1) % p
    YY = (Y1 * Y1) % p
    YYYY = (YY * YY) % p
    
    # STEP 2: 計算 ZZ 和 S
    ZZ = (Z1 * Z1) % p
    S = (2 * ((X1 + YY) ** 2 - XX - YYYY)) % p
    
    # STEP 3: 計算 M
    M = (3 * XX + a * ZZ * ZZ) % p
    
    # STEP 4: 計算 T 和 X3
    T = (M * M - 2 * S) % p
    X3 = T
    
    # STEP 5: 計算 Y3
    Y3 = (M * (S - T) - 8 * YYYY) % p
    
    # STEP 6: 計算 Z3
    Z3 = ((Y1 + Z1) ** 2 - YY - ZZ) % p
    
    return X3, Y3, Z3

def point_add_jacobian(X1, Y1, Z1, X2, Y2, Z2, p):
    if Z1 == 0:
        return X2, Y2, Z2
    if Z2 == 0:
        return X1, Y1, Z1
    # STEP 1: 計算 Z1Z1, Z2Z2, Y1Z2, Y2Z1
    Z1Z1 = (Z1 * Z1) % p
    Z2Z2 = (Z2 * Z2) % p
    Y1Z2 = (Y1 * Z2) % p
    Y2Z1 = (Y2 * Z1) % p

    # STEP 2: 計算 U1, U2, S1, S2
    U1 = (X1 * Z2Z2) % p
    U2 = (X2 * Z1Z1) % p
    S1 = (Y1Z2 * Z2Z2) % p
    S2 = (Y2Z1 * Z1Z1) % p

    # STEP 3: 計算 H 和 R
    H = (U2 - U1) % p
    R = (S2 - S1) % p
    
    if H == 0 and R == 0:
            # P1 = P2, 用倍點公式
            print("P1 = P2")
            return point_double_jacobian(X1, Y1, Z1, p)

    # STEP 4: 計算中間值
    Z1Z2 = (Z1 * Z2) % p
    HH = (H * H) % p
    RR = (R * R) % p
    UD = (2 * U1) % p

    # STEP 5: 計算更多中間值
    HZ1Z2 = (H * Z1Z2) % p
    HHH = (HH * H) % p
    UH2 = (U1 * HH) % p
    UDH2 = (UD * HH) % p

    # STEP 6-10: 計算最終結果
    R2MHHH = (RR - HHH) % p
    V = (R2MHHH - UDH2) % p
    I = (UH2 - V) % p
    RI = (R * I) % p
    SHHH = (S1 * HHH) % p

    X3 = V
    Y3 = (RI - SHHH) % p
    Z3 = HZ1Z2

    return X3, Y3, Z3

def mod_inv(a, p):
    # 使用擴展歐幾里得算法求反元素 a^(-1) mod p
    return pow(a, p-2, p)  # 對於 p 為質數的情況(Fermat's little theorem)

def jacobian_to_affine(X, Y, Z, p):
    # 將 Jacobian 座標 (X:Y:Z) 轉為仿射座標 (x, y)
    if Z == 0:
        # 無窮遠點 (Affine: None)
        return None, None
    Z_inv = mod_inv(Z, p)
    Z_inv2 = (Z_inv * Z_inv) % p
    x = (X * Z_inv2) % p
    y = (Y * Z_inv2 * Z_inv) % p
    return x, y

def montgomery_ladder(k, Xg, Yg, p, a=0):
    """
    使用 Montgomery ladder 計算 G*k，其中:
    k: 整數標量
    (Xg, Yg): 基點 G 的仿射座標
    p: 模數 (如 secp256k1 的 p)
    a: 橢圓曲線方程 y^2 = x^3 + a*x + b 中的 a (secp256k1 為 0)
    """
    # 初始化:
    # R0 為無窮遠點（Jacobian可表示為 Z=0），X、Y 可任意設置，此處 X=0, Y=1, Z=0 代表無窮遠
    X0, Y0, Z0 = 0, 1, 0
    # R1 = G (Jacobian 座標需要 Z=1)
    X1, Y1, Z1 = Xg, Yg, 1

    # 取得 k 的位元長度
    k_bits = k.bit_length()

    for i in reversed(range(k_bits)):
        bit = (k >> i) & 1
        # print(f"bit = {bit}")
        if bit == 0:
            # 若位元為0: R1 = R0+R1, R0 = 2*R0
            X1, Y1, Z1 = point_add_jacobian(X0, Y0, Z0, X1, Y1, Z1, p)
            X0, Y0, Z0 = point_double_jacobian(X0, Y0, Z0, p, a)
        else:
            # 若位元為1: R0 = R0+R1, R1 = 2*R1
            X0, Y0, Z0 = point_add_jacobian(X0, Y0, Z0, X1, Y1, Z1, p)
            X1, Y1, Z1 = point_double_jacobian(X1, Y1, Z1, p, a)
        # print(f"X0 = {hex(X0)}")
        # print(f"Y0 = {hex(Y0)}")
        # print(f"Z0 = {hex(Z0)}")
        # print(f"X1 = {hex(X1)}")
        # print(f"Y1 = {hex(Y1)}")
        # print(f"Z1 = {hex(Z1)}")

    # 計算結束後，R0 = G*k (Jacobian 座標)
    x, y = jacobian_to_affine(X0, Y0, Z0, p)
    return x, y

# 以下以secp256k1為例，請在使用前填入對應參數
# secp256k1 參數:
p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
a = 0
b = 7
# 基點 G：
Xg = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
Yg = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8

# 測試計算 G*k
k = 0xba8a94d307c4a3df7c68fe3a14eac2925ab05c5f63f8d6650613724d42ec414c
x_res, y_res = montgomery_ladder(k, Xg, Yg, p, a)
# print("G*k = (x, y) = ({}, {})".format(hex(x_res), hex(y_res)))

# end_time = time.time()
# execution_time = end_time - start_time
# print(f"\n執行時間: {execution_time:.4f} 秒")

n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
k = 0xba8a94d307c4a3df7c68fe3a14eac2925ab05c5f63f8d6650613724d42ec414c
da = 0x730b5e46cd9cec3da94619529477ba2c40bb14bb82d094a13f1b51b04a0e2cc0



k_inv = pow(k, -1, n)
# print(f"k_inv = {hex(k_inv)}")

KIDA = (k_inv * da) % n
# print(f"KIDA = {hex(KIDA)}")

plaint_txt = """G3MFav0WWv59e
gBH1XKHISWaRSY1x*dMPD6OaF
GF)F@XaY3@Tw
6vOEO#$bnp7iCSmed#Q8vNi4c$GX*
kB5v*RtlHB5r0DMQaBVLCnxJjbA8cnJg*6E!xV
jNJPhB0y&gEBbuRFiH(r64Jf#f$8(!N4kGLDVPTUaz3$7kFCI
)x$j7UJc(nrK!9*TMfK0pjTxkOkyM(1*N9D%X
dHwZvE#!i#5WyliEOnx64$nHg!9BZTum5gB5*p@3$
SeRm1%Jt%J%DpzV*Y%6XD
gUeqC!$gV(AUiX#jv"""

# generate the hash of the plaint_txt
import hashlib
hash_txt = hashlib.sha256(plaint_txt.encode()).hexdigest()
# print(f"hash_txt = {hash_txt}")

hash_hex = int(hash_txt, 16)
KIZ = (k_inv * hash_hex) % n
# print(f"KIZ = {hex(KIZ)}")

KIRDA = (KIDA * x_res) % n
# print(f"KIRDA = {hex(KIRDA)}")

SIGN = (KIRDA + KIZ) % n
print(f"SIGN = {hex(SIGN)}")

end_time = time.time()
execution_time = end_time - start_time
print(f"\n執行時間: {execution_time:.4f} 秒")


