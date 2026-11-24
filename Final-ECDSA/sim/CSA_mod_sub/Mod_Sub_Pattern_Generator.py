# -*- coding: utf-8 -*-

import random

# 隨機生成 256 位元數字
def generate_256_bit_number():
    return random.getrandbits(256)

# 定義一個素數 p
p = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F  # 使用固定的素數值

def generate_and_save_numbers(n):
    """
    生成 n 對隨機數字，並分別計算其 mod p 結果，存入檔案。
    :param n: 生成的數字對數量
    """
    with open('pat/a.txt', 'w') as file_a, \
         open('pat/b.txt', 'w') as file_b, \
         open('golden/results.txt', 'w') as file_results:
        
        for i in range(n):
            a = generate_256_bit_number()
            b = generate_256_bit_number()
            result_sub_mod_p = (a - b) % p

            # 將 a, b 和結果分別寫入檔案
            file_a.write(f'{hex(a)[2:].zfill(64)}\n')
            file_b.write(f'{hex(b)[2:].zfill(64)}\n')
            file_results.write(f'{hex(result_sub_mod_p)[2:].zfill(64)}\n')

# 調整生成的數量
random.seed(12)
number_of_pairs = 1000  # 修改這裡以決定生成的數字對數量
generate_and_save_numbers(number_of_pairs)