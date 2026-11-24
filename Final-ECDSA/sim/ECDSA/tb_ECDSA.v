`define END_CYCLE 10000
`timescale 1ns/1ps

module tb_ECDSA;
    // 模擬時鐘和重置信號
    reg clk;
    reg reset_n;

    // AXI-Stream 接口信號
    reg [31:0] tdata;   // 傳輸數據
    reg [2-1:0] tdata_len; // 輸入數據有效長度 (0-32 bits)
    reg tvalid;         // 數據有效標誌
    reg tlast;          // 最後一個數據標誌
    wire tready;        // 接收準備信號

    // ECDSA 模組輸出
    wire ecdsa_valid;
    wire [255:0] ecdsa_r;
    wire [255:0] ecdsa_s;
    
    // 文件操作相關變數
    integer pat_file, k_file, signature_r_file, signature_s_file, da_file;
    integer pat_r, k_r, signature_r_r, signature_s_r, da_r;
    reg [255:0] k_data;
    reg [255:0] da_data;
    reg [255:0] signature_r_data;
    reg [255:0] signature_s_data;
    reg [31:0] pat_data[0:511];  // 存儲測試數據
    reg [4:0] pat_data_len[0:511];  // 存儲每行數據有效長度 (1-32 bits)
    integer i, j, lines, last_len;
    integer file_count = 1; // 假設有 3 組文件
    reg [256*8:1] pat_path;
    reg [256*8:1] k_path;
    reg [256*8:1] da_path;
    reg [256*8:1] signature_r_path;
    reg [256*8:1] signature_s_path;
    reg jump;
    // ********************************** Waveform ***********************************
    // Not neccessary 
    // Dump waveform if you need it
    initial begin
        $fsdbDumpfile("ecdsa_presim.fsdb");
        $fsdbDumpvars("+mda");
    end
    // *******************************************************************************

    // 被測模組實例化
    ECDSA_top ecdsa_inst (
        .clk(clk),
        .rst_n(reset_n),
        .tvalid(tvalid),
        .tlast(tlast),
        .tdata(tdata),
        .tdata_len(tdata_len),
        .k(k_data),
        .da(da_data),
        .tready(tready),
        .ecdsa_valid(ecdsa_valid),
        .ecdsa_r(ecdsa_r),
        .ecdsa_s(ecdsa_s)
    );

    // 時鐘生成
    always #5 clk = ~clk;

    
    // cycle accumulator
    integer total_cycle;
    initial begin
        total_cycle = 0;
        while(1) begin
            @(negedge clk);
            if (reset_n == 0) begin
                total_cycle = 0;
            end else begin
                total_cycle = total_cycle + 1;
            end
        end
    end

    // 初始區塊
    initial begin
        // 初始化信號
        clk = 0;
        // reset_n = 0;
        tvalid = 0;
        tlast = 0;
        tdata = 0;
        tdata_len = 0;

        // 重置信號
        // #20 reset_n = 1;

        // 測試每組文件
        for (i = 1; i <= file_count; i = i + 1) begin
            // reset
            reset_n = 0;
            #20 reset_n = 1;

            // 構造文件路徑
            $sformat(pat_path, "./hex/hex%0d.dat", i);
            $sformat(k_path, "./k_values/k_%0d.dat", i);
            $sformat(da_path, "./private_key/private_key_%0d.dat", i);
            $sformat(signature_r_path, "./signature_r/signature_r_%0d.dat", i);
            $sformat(signature_s_path, "./signature_s/signature_s_%0d.dat", i);

            // 打開測試數據文件
            pat_file = $fopen(pat_path, "r");
            if (pat_file == 0) begin
                $display("Error: Cannot open pattern file %s", pat_path);
                $finish;
            end

            // 讀取總行數
            pat_r = $fscanf(pat_file, "%d %d\n", lines, last_len);

            // 讀取測試數據 (逐行)
            j = 0;
            while (!$feof(pat_file)) begin
                // 假設每行可能不足 32 位，逐行讀取並計算長度
                pat_r = $fscanf(pat_file, "%h\n", pat_data[j]);
                j = j + 1;
            end

            for (j = 0; j < lines; j = j + 1) begin
                pat_data_len[j] = 0;
            end
            pat_data_len[j - 1] = last_len;

            $fclose(pat_file);

            // 打開 k 值文件
            k_file = $fopen(k_path, "r");
            if (k_file == 0) begin
                $display("Error: Cannot open k file %s", k_path);
                $finish;
            end

            // 讀取 k 值
            k_r = $fscanf(k_file, "%h\n", k_data);
            // $display("k_data: %h", k_data);
            $fclose(k_file);

            // 打開 da 文件
            da_file = $fopen(da_path, "r");
            if (da_file == 0) begin
                $display("Error: Cannot open da file %s", da_path);
                $finish;
            end

            // 讀取 da
            da_r = $fscanf(da_file, "%h\n", da_data);
            // $display("da_data: %h", da_data);
            $fclose(da_file);

            // 打開 signature_r 文件
            signature_r_file = $fopen(signature_r_path, "r");
            if (signature_r_file == 0) begin
                $display("Error: Cannot open signature_r file %s", signature_r_path);
                $finish;
            end 

            // 讀取 signature_r
            signature_r_r = $fscanf(signature_r_file, "%h\n", signature_r_data);
            // $display("signature_r_data: %h", signature_r_data);
            $fclose(signature_r_file);

            // 打開 signature_s 文件
            signature_s_file = $fopen(signature_s_path, "r");
            if (signature_s_file == 0) begin
                $display("Error: Cannot open signature_s file %s", signature_s_path);
                $finish;
            end

            // 讀取 signature_s
            signature_s_r = $fscanf(signature_s_file, "%h\n", signature_s_data);
            // $display("signature_s_data: %h", signature_s_data);
            $fclose(signature_s_file);


            // 模擬數據輸入
            for (j = 0; j < lines; j = j + 1) begin
                tdata = pat_data[j];
                tdata_len = pat_data_len[j];
               
                tlast = (j == lines - 1) ? 1 : 0;
                while (!tready) @(negedge clk);
                tvalid = 1;
                @(negedge clk);
                
                // @(negedge clk);
                // $display("--------------------------------");
                // $display("tdata: %h\ntdata_len: %d\ntvalid: %d\ntlast: %d", tdata, tdata_len, tvalid, tlast);
                // $display("--------------------------------");

                // $finish;
                
                tvalid = 0;
            end

            while (!ecdsa_valid) @(negedge clk);
            if (ecdsa_r === signature_r_data && ecdsa_s === signature_s_data) begin
                $display("Test passed for file (%0d/%0d), Cycle: %d", i, file_count, total_cycle);
                $display("--------------------------------");
                $display("ecdsa_r : %h", ecdsa_r);
                $display("golden r: %h", signature_r_data);
                $display("ecdsa_s : %h", ecdsa_s);
                $display("golden s: %h", signature_s_data);
                $display("--------------------------------");
            end else begin
                $display("Test failed for file (%0d/%0d) %s", i, file_count, pat_path);
                $display("--------------------------------");
                $display("ecdsa_r : %h", ecdsa_r);
                $display("golden r: %h", signature_r_data);
                $display("ecdsa_s : %h", ecdsa_s);
                $display("golden s: %h", signature_s_data);
                $display("--------------------------------");
                $finish;
            end
            // $finish;
        end

        // 所有測試完成
        $display("################################");
        $display("Congratulations! All tests passed! :D");
        $display("################################");
        $finish;
    end

    // end simulation
    initial begin
        // #`END_CYCLE
        // $display("Simulation too long, end at %d", $time);
        // $finish;
        if (total_cycle > `END_CYCLE) begin
            $display("Simulation too long, end at %d", $time);
            $finish;
        end
    end
endmodule