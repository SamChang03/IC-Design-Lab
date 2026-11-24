import os
import random
import hashlib

os.makedirs("plaintext", exist_ok=True)
os.makedirs("hex", exist_ok=True)
os.makedirs("hash", exist_ok=True)

def generate_random_ascii_file(file_name, num_lines=10, min_length=10, max_length=50):
    """生成隨機長度的ASCII字符明文文件"""
    lines = []
    for _ in range(num_lines):
        # 每行生成隨機長度的ASCII字符
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
    # 將內容按字符處理，包含換行符的HEX轉換
    hex_content = ''.join([char.encode('ascii').hex() if char != '\n' else '0a' for char in plaintext_content])
    # 將HEX數據分割為32-bit塊 (每塊8字符)
    hex_chunks = [hex_content[i:i+8] for i in range(0, len(hex_content), 8)]
    # 第一行爲總行數以及最後一行bit數
    hex_lines.append(str(len(hex_chunks)) + ' ' + str(4 - len(hex_chunks[-1]) // 2))
    hex_lines.extend(hex_chunks)
    hex_output = '\n'.join(hex_lines)
    with open(hex_file_name, 'w') as f:
        f.write(hex_output)
    return hex_output

def calculate_sha256_from_plaintext(plaintext_content):
    """直接從明文內容計算SHA256"""
    sha256 = hashlib.sha256()
    sha256.update(plaintext_content.encode('utf-8'))
    
    sha_lines = []
    for i in range(0, len(sha256.hexdigest()), 8):
        sha_lines.append(sha256.hexdigest()[i:i+8])
    return '\n'.join(sha_lines)

def main(num_files=10, num_lines=10, min_length=10, max_length=50):
    """生成明文文件、HEX文件及其SHA256雜湊"""
    for i in range(1, num_files + 1):
        plaintext_file_name = f"plaintext/plaintext{i}.txt"
        hex_file_name = f"hex/hex{i}.dat"
        hash_file_name = f"hash/hash{i}.dat"

        # 生成隨機明文文件
        plaintext_content = generate_random_ascii_file(plaintext_file_name, num_lines=num_lines, min_length=min_length, max_length=max_length)

        # 生成包含換行符轉換的HEX文件（每行存儲32-bit數據）
        save_hex_file_with_newline(plaintext_content, hex_file_name)

        # 計算SHA256雜湊值
        sha256_hash = calculate_sha256_from_plaintext(plaintext_content)

        # 將SHA256寫入文件
        with open(hash_file_name, 'w') as hash_file:
            hash_file.write(f"{sha256_hash}\n")

    print(f"{num_files} plaintext, HEX files (32-bit lines with newline conversion), and their SHA256 hashes have been generated.")

if __name__ == "__main__":
    main(num_files=10, num_lines=10, min_length=10, max_length=50)
