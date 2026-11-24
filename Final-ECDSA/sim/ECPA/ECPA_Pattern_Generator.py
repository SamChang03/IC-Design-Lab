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

# 保存所有點的坐標到檔案
def save_points_to_files(points, filename_prefix):
    # 開啟三個檔案用於存儲 x, y, z 坐標
    with open(f"{filename_prefix}_x.txt", "w") as fx, \
         open(f"{filename_prefix}_y.txt", "w") as fy, \
         open(f"{filename_prefix}_z.txt", "w") as fz:
        
        # 遍歷所有點
        for point in points:
            coords = point._PointJacobi__coords
            # 將每個坐標寫入對應檔案的新行
            fx.write(hex(coords[0])[2:].zfill(64) + "\n")
            fy.write(hex(coords[1])[2:].zfill(64) + "\n")
            fz.write(hex(coords[2])[2:].zfill(64) + "\n")

# 生成任意數量的隨機點
def generate_random_points_and_save(num_points):
    original_point_X1 = []
    original_point_X2 = []
    add_point_X = []
    
    for i in range(1, num_points + 1):
        # 隨機生成數字 k
        k1 = randrange_from_seed__trytryagain(i, order)
        k2 = randrange_from_seed__trytryagain(i + 12345, order)
        # 計算點 P = k * G
        P1 = k1 * generator
        P2 = k2 * generator

        # 將 P 轉為 Jacobian 坐標
        P1_jacobian = PointJacobi.from_affine(P1)
        P2_jacobian = PointJacobi.from_affine(P2)

        # calculate P1 + P2
        P_add = P1_jacobian + P2_jacobian

        # 將點加入列表
        original_point_X1.append(P1_jacobian)
        original_point_X2.append(P2_jacobian)
        add_point_X.append(P_add)

        print(f"已生成點 {i} 的原始點與倍增點")

    # 批量保存所有點
    save_points_to_files(original_point_X1, "pat/points_X1")
    save_points_to_files(original_point_X2, "pat/points_X2")
    save_points_to_files(add_point_X, "golden/adds")

# 設定生成的點數量
num_points = 1000  # 可更改數量
generate_random_points_and_save(num_points)

print(f"已生成 {num_points} 個隨機點並保存對應檔案！")