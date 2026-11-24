`timescale 1ns/1ps
`define END_CYCLE 10000000

module tb_ecc_scalar_mult;
    // 模擬時鐘和重置信號
    reg clk;
    reg reset_n;

    // 輸入給 ECC 模組的 k 值
    reg [255:0] k_in;        // 假設 k 是 256-bit，實際位寬需視設計而定
    reg         k_valid;     // 表示 k_in 有效
    reg         k_last;      // 表示 k_in 是最后一個數據
    
    // ECC 模組輸出 (k*G = (X, Y))
    wire        ecc_ready;
    wire [255:0] x_out;      // ECC 模組輸出 X 坐標 (位寬依照設計規格)
    // wire [255:0] y_out;      // ECC 模組輸出 Y 坐標
    wire         x_valid;   // 表示 X, Y 已計算完成並有效

    // 檔案操作相關變數
    integer k_file, points_file_x, points_file_y;
    integer k_r, p_r;
    integer i, num_points, t;
    
    // 用於儲存從檔案讀入的 k 值及對應正確答案點座標
    reg [255:0]   k_values_mem [0:1023]; // 假設最多 1024 筆 k
    
    reg [255:0] golden_x_mem [0:1023];
    reg [255:0] golden_y_mem [0:1023];
    
    integer line_idx;
    reg [1023:0] x_str, y_str;  // 用來暫存每行座標的字串
    reg [1023:0] hex_str;

    // ********************************** Waveform ***********************************
    // Not neccessary 
    // Dump waveform if you need it
    initial begin
        $fsdbDumpfile("ecc_scalar_mult.fsdb");
        $fsdbDumpvars("+mda");
    end
    // *******************************************************************************
    
    // *****************************
    // 假設 ecc_top 模組介面 (需自行替換為實際設計)
    // *****************************
    ECC_top ecc_inst (
        .clk    (clk),
        .rst_n  (reset_n),
        .SHA_ECC_valid  (k_valid),
        .SHA_ECC_last   (k_last),
        .SHA_ECC_data   (k_in),
        .SHA_ECC_ready  (ecc_ready),
        .ECC_SIGN_valid (x_valid),
        // .ECC_SIGN_last  (1'b1),
        .ECC_SIGN_data  (x_out)
    );

    // 時鐘生成
    always #5 clk = ~clk;

    // 初始化
    initial begin
        clk = 0;
        reset_n = 0;
        k_in = 0;
        k_valid = 0;

        // 重置信號
        #20 reset_n = 1;
    end

    // 檔案讀取流程
    initial begin
        // 從 pat/random_k_values.txt 中讀取 k 值
        k_file = $fopen("pat/random_k_values.txt", "r");
        if (k_file == 0) begin
            $display("Error: Cannot open random_k_values.txt");
            $finish;
        end
        
        // 從 golden/corresponding_points.txt 中讀取對應正確的 (x, y)
        points_file_x = $fopen("golden/corresponding_points_x.txt", "r");
        if (points_file_x == 0) begin
            $display("Error: Cannot open corresponding_points_x.txt");
            $finish;
        end
        points_file_y = $fopen("golden/corresponding_points_y.txt", "r");
        if (points_file_y == 0) begin
            $display("Error: Cannot open corresponding_points_y.txt");
            $finish;
        end

        // 將整個 k 列表與 (x,y) 數據讀取至暫存陣列
        i = 0;
        // 讀取 k_values (一行一個整數)
        while (!$feof(k_file)) begin
            k_r = $fscanf(k_file, "%h\n", k_values_mem[i]);
            // $display("k_values_mem[%0d]: %h", i, k_values_mem[i]);
            i = i + 1;
        end
        num_points = i; // 紀錄讀取到多少組
        $fclose(k_file);

        // 讀取對應點座標 (x,y)
        i = 0;
        while (!$feof(points_file_x)) begin
            t = $fscanf(points_file_x, "%h\n", golden_x_mem[i]);
            // $display("golden_x_mem[%0d]: %h", i, golden_x_mem[i]);
            i = i + 1;
        end
        $fclose(points_file_x);

        i = 0;
        while (!$feof(points_file_y)) begin
            t = $fscanf(points_file_y, "%h\n", golden_y_mem[i]);
            // $display("golden_y_mem[%0d]: %h", i, golden_y_mem[i]);
            i = i + 1;
        end
        $fclose(points_file_y);

        @(posedge clk);

        // 輸入 k 至 ECC 模組並比對計算結果
        for (i = 0; i < num_points; i = i + 1) begin
            // 輸入 k
            k_in = k_values_mem[i]; // 假設 k_values_mem[i] 符合 256-bit
            while (!ecc_ready) @(posedge clk);
            k_valid = 1;
            @(posedge clk);
            k_valid = 0;

            // 等待 x_valid 為 1，表示輸出計算完成
            while (!x_valid) @(posedge clk);
            
            // 比對 x_out, y_out
            if (x_out !== golden_x_mem[i]) begin
                $display("Test failed at index %0d: Expected X: %h, Got: %h",
                         i, golden_x_mem[i], x_out);
                $finish;
            end else begin
                $display("Pass index %0d: X: %h == %h",
                         i, x_out, golden_x_mem[i]);
            end
        end

        $display("################################");
        $display("恭喜! 所有測試均通過! :D");
        $display("################################");
        $finish;
    end

    // 若模擬超出週期數，強制結束
    initial begin
        #`END_CYCLE
        $display("Simulation too long, end at %d", $time);
        $finish;
    end

endmodule
