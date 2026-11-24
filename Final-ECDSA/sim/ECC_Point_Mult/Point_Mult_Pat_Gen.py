import random
from ecdsa.curves import SECP256k1
from ecdsa.ellipticcurve import Point

# 取得 SECP256k1 曲線的生成點
G = SECP256k1.generator

# 設定隨機生成 k 的範圍
k_min = 1
k_max = 1000
num_points = 10  # 要生成的點數量

# 檔案名稱
k_file = "pat/random_k_values.txt"
points_file_x = "golden/corresponding_points_x.txt"
points_file_y = "golden/corresponding_points_y.txt"

# 隨機生成 k 值並計算對應點
k_values = []
points_x = []
points_y = []

random.seed(12)

for _ in range(num_points):
    k = random.randint(k_min, k_max)  # 隨機生成 k
    point = k * G  # 計算 k * G
    k_values.append(k)
    points_x.append(hex(point.x())[2:].zfill(64))
    points_y.append(hex(point.y())[2:].zfill(64))

# 將 k 值存入 txt
with open(k_file, "w") as f:
    f.write("\n".join(map(str, k_values)))

# 將對應點存入 txt
with open(points_file_x, "w") as f:
    f.write("\n".join(points_x))

with open(points_file_y, "w") as f:
    f.write("\n".join(points_y))

print(f"隨機生成的 k 值已存入 {k_file}")
print(f"對應的橢圓曲線點已存入 {points_file_x} 和 {points_file_y}")
