from ecdsa.ellipticcurve import PointJacobi
from ecdsa.curves import SECP256k1
from ecdsa.util import randrange_from_seed__trytryagain
import os

os.makedirs("pat", exist_ok=True)
os.makedirs("golden", exist_ok=True)

# 定義曲線與基點
curve = SECP256k1.curve
generator = SECP256k1.generator
order = SECP256k1.order

# 保存點的坐標到檔案
def save_point_to_file(point, filename_prefix):
    coords = point._PointJacobi__coords
    with open(f"{filename_prefix}_x.txt", "w") as fx:
        fx.write(hex(coords[0])[2:].zfill(64))
    with open(f"{filename_prefix}_y.txt", "w") as fy:
        fy.write(hex(coords[1])[2:].zfill(64))
    with open(f"{filename_prefix}_z.txt", "w") as fz:
        fz.write(hex(coords[2])[2:].zfill(64))

# 生成任意數量的隨機點
def generate_random_points_and_save(num_points):
    for i in range(1, num_points + 1):
        # 隨機生成數字 k
        k = randrange_from_seed__trytryagain(None, order)

        # 計算點 P = k * G
        P = k * generator

        # 將 P 轉為 Jacobian 坐標
        P_jacobian = PointJacobi.from_affine(P)

        # 計算倍增結果
        P_double = P_jacobian.double()

        # 保存原始點與倍增點
        save_point_to_file(P_jacobian, f"pat/point_{i}")
        save_point_to_file(P_double, f"golden/double_{i}")

        print(f"點 {i} 已保存：原始點與倍增點")

# 設定生成的點數量
num_points = 1000  # 可更改數量
generate_random_points_and_save(num_points)

print(f"已生成 {num_points} 個隨機點並保存對應檔案！")
