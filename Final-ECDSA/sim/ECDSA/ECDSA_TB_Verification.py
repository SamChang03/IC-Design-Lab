import os
import hashlib
from ecdsa import VerifyingKey, SigningKey, SECP256k1, rfc6979

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

        # 還原私鑰與公鑰
        private_key = SigningKey.from_string(bytes.fromhex(private_key_hex), curve=SECP256k1)
        public_key = VerifyingKey.from_string(bytes.fromhex(public_key_hex), curve=SECP256k1)
        
        # 將 r 和 s 組合成簽章格式
        from ecdsa.util import sigencode_string
        signature = sigencode_string(r, s, private_key.curve.order)

        # 驗證簽章
        try:
            public_key.verify(signature, plaintext_content.encode('utf-8'), hashfunc=hashlib.sha256)
            print(f"File {i}: Signature verification PASSED.")
        except Exception as e:
            print(f"File {i}: Signature verification FAILED. {e}")

        # 驗證隨機數 k 是否正確
        k_compare = rfc6979.generate_k(
            private_key.curve.order,
            private_key.privkey.secret_multiplier,  # secexp (私鑰的秘密指數)
            hashlib.sha256,  # hashfunc
            message_hash,  # digest
            retry_gen=0,
            extra_entropy=b''
        )
        # print(f'k_compare: {k_compare}')
        # print(f'k: {k}')
        if k_compare == k:
            print(f"File {i}: Random value k verification PASSED.")
        else:
            print(f"File {i}: Random value k verification FAILED. Expected r={k_compare}, but got r={k}.")
            
if __name__ == "__main__":
    verify_ecdsa_signature(num_files=10)