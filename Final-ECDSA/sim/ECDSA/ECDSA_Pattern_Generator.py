import os
import random
import hashlib
from ecdsa import SigningKey, SECP256k1, rfc6979
from ecdsa.util import sigdecode_string

# 創建文件目錄
os.makedirs("plaintext", exist_ok=True)
os.makedirs("hex", exist_ok=True)
os.makedirs("signature_r", exist_ok=True)
os.makedirs("signature_s", exist_ok=True)
os.makedirs("private_key", exist_ok=True)
os.makedirs("public_key", exist_ok=True)
os.makedirs("k_values", exist_ok=True)  # 新增存儲 k 值的目錄

def generate_random_ascii_file(file_name, num_lines=10, min_length=10, max_length=50):
    """生成隨機長度的ASCII字符明文文件"""
    lines = []
    for _ in range(num_lines):
        line_length = random.randint(min_length, max_length)
        line = ''.join(random.choices('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()', k=line_length))
        lines.append(line)
    content = '\n'.join(lines)
    with open(file_name, 'w') as f:
        f.write(content)
    return content

def save_hex_file_with_newline(plaintext_content, hex_file_name):
    """將明文內容轉換為HEX，包含換行符，並每行存儲32-bit數據"""
    hex_lines = []
    hex_content = ''.join([char.encode('ascii').hex() if char != '\n' else '0a' for char in plaintext_content])
    hex_chunks = [hex_content[i:i+8] for i in range(0, len(hex_content), 8)]
    hex_lines.append(str(len(hex_chunks)) + ' ' + str(4 - len(hex_chunks[-1]) // 2))
    hex_lines.extend(hex_chunks)
    hex_output = '\n'.join(hex_lines)
    with open(hex_file_name, 'w') as f:
        f.write(hex_output)
    return hex_output

def generate_ecdsa_signature_with_k(plaintext_content, private_key):
    """使用ECDSA生成明文內容的簽章並記錄隨機數 k"""
    # 計算明文的SHA256哈希值
    message_hash = hashlib.sha256(plaintext_content.encode('utf-8')).digest()
    
    signature = private_key.sign_digest_deterministic(message_hash)
    # print(f'signature: {signature}, message_hash: {message_hash}')

    # 使用ECDSA的get_deterministic_k_for_signing方法生成隨機數 k
    k = rfc6979.generate_k(
        private_key.curve.order,
        private_key.privkey.secret_multiplier,  # secexp (私鑰的秘密指數)
        hashlib.sha256,  # hashfunc
        message_hash,  # digest
        retry_gen=0,
        extra_entropy=b''
    )
    # 計算 r 和 s
    r, s = sigdecode_string(signature, private_key.curve.order)
    return r, s, k

def main(num_files=10, num_lines=10, min_length=10, max_length=50):
    """生成明文文件、HEX文件及其ECDSA簽章，並保存 k 值"""

    for i in range(1, num_files + 1):
        # 生成ECDSA私鑰
        private_key = SigningKey.generate(curve=SECP256k1)
        
        private_key_file_name = f"private_key/private_key_{i}.dat"
        with open(private_key_file_name, 'w') as private_key_file:
            private_key_file.write(f"{private_key.to_string().hex()}\n")
        
        # 提取並保存公開金鑰
        public_key = private_key.get_verifying_key()
        print(f'public_key: {public_key}')
        public_key_file_name = f"public_key/public_key_{i}.dat"
        with open(public_key_file_name, 'w') as public_key_file:
            public_key_file.write(f"{public_key.to_string().hex()}\n")
            
        plaintext_file_name = f"plaintext/plaintext{i}.txt"
        hex_file_name = f"hex/hex{i}.dat"
        signature_r_file_name = f"signature_r/signature_r_{i}.dat"
        signature_s_file_name = f"signature_s/signature_s_{i}.dat"
        k_file_name = f"k_values/k_{i}.dat"  # 新增存儲 k 值的檔案

        # 生成隨機明文文件
        plaintext_content = generate_random_ascii_file(plaintext_file_name, num_lines=num_lines, min_length=min_length, max_length=max_length)

        # 生成包含換行符轉換的HEX文件（每行存儲32-bit數據）
        save_hex_file_with_newline(plaintext_content, hex_file_name)

        # 生成ECDSA簽章並記錄 k 值
        r, s, k = generate_ecdsa_signature_with_k(plaintext_content, private_key)

        # 將簽章 (r, s) 以 16 進位 (補零至64位) 寫入文件
        with open(signature_r_file_name, 'w') as signature_r_file:
            signature_r_file.write(f"{hex(r)[2:].zfill(64)}\n")
        with open(signature_s_file_name, 'w') as signature_s_file:
            signature_s_file.write(f"{hex(s)[2:].zfill(64)}\n")

        # 將 k 值以 16 進位存入文件
        with open(k_file_name, 'w') as k_file:
            k_file.write(f"{hex(k)[2:].zfill(64)}\n")

    print(f"{num_files} plaintext, HEX files (32-bit lines with newline conversion), ECDSA signatures, and k values have been generated.")

if __name__ == "__main__":
    main(num_files=10, num_lines=10, min_length=10, max_length=50)
