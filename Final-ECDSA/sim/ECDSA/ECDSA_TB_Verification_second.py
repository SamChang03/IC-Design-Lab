import os
import hashlib
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives.asymmetric.utils import encode_dss_signature, decode_dss_signature
from cryptography.hazmat.backends import default_backend
from cryptography.exceptions import InvalidSignature
from ecdsa import rfc6979

def read_file(file_path):
    """讀取檔案內容並返回字串"""
    with open(file_path, 'r') as f:
        return f.read().strip()

def hex_to_int(hex_string):
    """將16進位字串轉換為整數"""
    return int(hex_string, 16)

def verify_ecdsa_signature(num_files=10):
    """驗證 ECDSA 簽章與隨機數 k 的正確性"""
    for i in range(1, num_files + 1):
        # 檔案名稱
        private_key_file = f"private_key/private_key_{i}.dat"
        public_key_file = f"public_key/public_key_{i}.dat"
        plaintext_file = f"plaintext/plaintext{i}.txt"
        signature_r_file = f"signature_r/signature_r_{i}.dat"
        signature_s_file = f"signature_s/signature_s_{i}.dat"
        k_file = f"k_values/k_{i}.dat"

        # 讀取資料
        private_key_hex = read_file(private_key_file)
        public_key_hex = read_file(public_key_file)
        plaintext_content = read_file(plaintext_file)
        r = hex_to_int(read_file(signature_r_file))
        s = hex_to_int(read_file(signature_s_file))
        k = hex_to_int(read_file(k_file))


        # 生成哈希值
        message_hash = hashlib.sha256(plaintext_content.encode('utf-8')).digest()
        # print(f"message_hash: {message_hash.hex()}")

        # 使用 cryptography 套件建立私鑰和公鑰
        public_numbers = ec.EllipticCurvePublicNumbers(
            x=int.from_bytes(bytes.fromhex(public_key_hex)[:32], 'big'),
            y=int.from_bytes(bytes.fromhex(public_key_hex)[32:], 'big'),
            curve=ec.SECP256K1()
        )

        public_key = public_numbers.public_key(backend=default_backend())
        
        # 直接從私鑰值生成私鑰物件
        private_key = ec.derive_private_key(
            private_value=hex_to_int(private_key_hex),
            curve=ec.SECP256K1(),
            backend=default_backend()
        )

        # 使用 RFC 6979 生成簽名
        rfc6979_signature = private_key.sign(
            plaintext_content.encode('utf-8'),
            ec.ECDSA(hashes.SHA256(), True)
        )

        # 解碼 RFC 6979 簽名以獲取 r 和 s
        rfc6979_r, rfc6979_s = decode_dss_signature(rfc6979_signature)

        # 比較 r 值
        if r == rfc6979_r:
            print(f"File {i}: Signature r value matches RFC 6979 specification.")
        else:
            print(f"File {i}: Signature r value does NOT match RFC 6979 specification.")
            print(f"Expected r: {rfc6979_r}")
            print(f"Got r: {r}")

        # 驗證簽名
        try:
            # 重新編碼實際的 r 和 s 值
            actual_signature = encode_dss_signature(r, s)
            public_key.verify(
                actual_signature,
                plaintext_content.encode('utf-8'),
                ec.ECDSA(hashes.SHA256())
            )
            print(f"File {i}: Signature verification PASSED.")
        except InvalidSignature:
            print(f"File {i}: Signature verification FAILED.")

if __name__ == "__main__":
    verify_ecdsa_signature(num_files=10)
