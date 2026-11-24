`define END_CYCLE 10000000

module tb_sha256_variable_length;
    // 模擬時鐘和重置信號
    reg clk;
    reg reset_n;

    // AXI-Stream 接口信號
    reg [31:0] tdata;   // 傳輸數據
    reg [2-1:0] tdata_len; // 輸入數據有效長度 (0-32 bits)
    reg tvalid;         // 數據有效標誌
    reg tlast;          // 最後一個數據標誌
    wire tready;        // 接收準備信號
    reg r_ready;

    // SHA256 模組輸出
    wire [31:0] sha256_out;
    wire sha256_valid;
    wire sha256_last;
    // 文件操作相關變數
    integer pat_file, golden_file;
    integer pat_r, golden_r;
    reg [31:0] pat_data[0:511];  // 存儲測試數據
    reg [4:0] pat_data_len[0:511];  // 存儲每行數據有效長度 (1-32 bits)
    reg [31:0] golden_hash[0:19];  // 存儲正確的 SHA256 哈希值
    integer i, j, lines, last_len;
    integer file_count = 1000; // 假設有 3 組文件
    reg [256*8:1] pat_path;
    reg [256*8:1] golden_path;
    reg jump;
    // ********************************** Waveform ***********************************
    // Not neccessary 
    // Dump waveform if you need it
    initial begin
        $fsdbDumpfile("sha256.fsdb");
        $fsdbDumpvars("+mda");
    end
    // *******************************************************************************

    // // 被測模組實例化
    sha256_top sha256_inst (
        .clk(clk),
        .rst_n(reset_n),
        .tvalid(tvalid),
        .tlast(tlast),
        .tdata(tdata),
        .tdata_len(tdata_len),
        .tready(tready),
        .r_ready(r_ready),
        .sha256_valid(sha256_valid),
        .sha256_last(sha256_last),
        .sha256_out(sha256_out)
    );

    // 時鐘生成
    always #5 clk = ~clk;

    // 初始區塊
    initial begin
        // 初始化信號
        clk = 0;
        // reset_n = 0;
        tvalid = 0;
        tlast = 0;
        tdata = 0;
        tdata_len = 0;
        r_ready = 0;
        
        // 重置信號
        // #20 reset_n = 1;

        // 測試每組文件
        for (i = 1; i <= file_count; i = i + 1) begin
            // reset
            reset_n = 0;
            #20 reset_n = 1;

            r_ready = 1;

            
            // 構造文件路徑
            $sformat(pat_path, "./hex/hex%0d.dat", i);
            $sformat(golden_path, "./hash/hash%0d.dat", i);

            // 打開測試數據文件
            pat_file = $fopen(pat_path, "r");
            if (pat_file == 0) begin
                $display("Error: Cannot open pattern file %s", pat_path);
                $finish;
            end

            // 打開正確答案文件
            golden_file = $fopen(golden_path, "r");
            if (golden_file == 0) begin
                $display("Error: Cannot open golden file %s", golden_path);
                $finish;
            end

            // 讀取總行數
            pat_r = $fscanf(pat_file, "%d %d\n", lines, last_len);
            // $display("lines: %d, last_len: %d", lines, last_len);

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


            // 讀取正確答案
            j = 0;
            while (!$feof(golden_file)) begin
                golden_r = $fscanf(golden_file, "%8h\n", golden_hash[j]);
                j = j + 1;
            end
            $fclose(golden_file);

            // 模擬數據輸入
            for (j = 0; j < lines; j = j + 1) begin
                tdata = pat_data[j];
                tdata_len = pat_data_len[j];
               
                tlast = (j == lines - 1) ? 1 : 0;
                while (!tready) @(posedge clk);
                tvalid = 1;
                @(posedge clk);
                
                // @(posedge clk);
                // $display("--------------------------------");
                // $display("tdata: %h\ntdata_len: %d\ntvalid: %d\ntlast: %d", tdata, tdata_len, tvalid, tlast);
                // $display("--------------------------------");

                // $finish;
                
                tvalid = 0;
            end

            // 比對輸出與正確答案
            j = 7;
            jump = 1;
            while (jump) begin
                @(posedge clk);
                if (sha256_valid) begin
                    if (sha256_out !== golden_hash[j]) begin
                        $display("Test failed for file %s: mismatch at word %d. Expected: %h, Got: %h",
                                 pat_path, j, golden_hash[j], sha256_out);
                        $finish;
                    end
                    if (j == 0 && sha256_last !== 1) begin
                        $display("Error: sha256_last not asserted after final word");
                        $finish;
                    end
                    $display("Pass Document %d : (%0d/8), golden_hash: %h, sha256_out: %h", i, 8-j, golden_hash[j], sha256_out);
                    j = j - 1;
                end
                if (sha256_last) begin
                    if (j != -1) begin  // SHA256 應該要輸出 5 個 32-bit 字
                        $display("Error: Incorrect number of output words. Expected: 5, Got: %d", j);
                        $finish;
                    end
                    jump = 0;
                end
            end
            $display("--------------------------------");
            $display("Test passed for file (%0d/%0d) %s", i, file_count, pat_path);
            $display("--------------------------------");
        end

        // 所有測試完成
        $display("################################");
        $display("Congratulations! All tests passed! :D");
        $display("################################");
        $finish;
    end

    // end simulation
    initial begin
        #`END_CYCLE
        $display("Simulation too long, end at %d", $time);
        $finish;
    end
endmodule
