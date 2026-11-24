`timescale 1ns/1ps
`define END_CYCLE 10000000

module tb_mod_mul;

    // 模擬時鐘和重置信號
    reg clk;
    reg rst_n;

    // 測試輸入
    reg [255:0] a_in;
    reg [255:0] b_in;
    reg [255:0] p_in;
    reg mul_start;

    // 模組輸出
    wire mul_done;
    wire mul_busy;
    wire mul_ready;
    wire [255:0] mod_mul_result;

    // 檔案操作相關變數
    integer a_file, b_file, results_file;
    integer i, t;
    reg [255:0] golden_result;

    // 用於儲存從檔案讀入的 a、b 和對應正確結果
    reg [255:0] a_values_mem [0:1023];
    reg [255:0] b_values_mem [0:1023];
    reg [255:0] golden_results_mem [0:1023];

    integer num_pairs;

    // 待測模組實例化
    mod_mul uut (
        .clk(clk),
        .rst_n(rst_n),
        .mul_start(mul_start),
        .a(a_in),
        .b(b_in),
        .m(p_in),
        .mul_done(mul_done),
        .mul_busy(mul_busy),
        .mul_ready(mul_ready),
        .mul_result(mod_mul_result)
    );

    // ********************************** Waveform ***********************************
    // Not neccessary 
    // Dump waveform if you need it
    initial begin
        $fsdbDumpfile("mod_mul.fsdb");
        $fsdbDumpvars("+mda");
    end
    // *******************************************************************************

    // 時鐘生成
    always #5 clk = ~clk;

    // 初始化
    initial begin
        clk = 0;
        rst_n = 0;
        mul_start = 0;
        a_in = 0;
        b_in = 0;
        p_in = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F; // 假設 p 為此固定值

        // 重置信號
        #20 rst_n = 1;
    end

    // 檔案讀取流程
    initial begin
        // 從 pat/a.txt 中讀取 a 值
        a_file = $fopen("pat/a.txt", "r");
        if (a_file == 0) begin
            $display("Error: Cannot open a.txt");
            $finish;
        end
        
        // 從 pat/b.txt 中讀取 b 值
        b_file = $fopen("pat/b.txt", "r");
        if (b_file == 0) begin
            $display("Error: Cannot open b.txt");
            $finish;
        end

        // 從 golden/results.txt 中讀取對應正確結果
        results_file = $fopen("golden/results.txt", "r");
        if (results_file == 0) begin
            $display("Error: Cannot open results.txt");
            $finish;
        end

        // 將整個 a, b 列表與結果數據讀取至暫存陣列
        i = 0;
        while (!$feof(a_file)) begin
            t = $fscanf(a_file, "%h\n", a_values_mem[i]);
            t = $fscanf(b_file, "%h\n", b_values_mem[i]);
            t = $fscanf(results_file, "%h\n", golden_results_mem[i]);
            i = i + 1;
        end
        num_pairs = i;
        $fclose(a_file);
        $fclose(b_file);
        $fclose(results_file);

        wait(rst_n);
        @(posedge clk); // wait for reset

        // 輸入 a 和 b 至模組並比對計算結果
        for (i = 0; i < num_pairs; i = i + 1) begin
            a_in = a_values_mem[i];
            b_in = b_values_mem[i];
            while (mul_busy) @(posedge clk);
            mul_start = 1;
            @(posedge clk);
            mul_start = 0;

            while (!mul_done) @(posedge clk);
            // 比對 mod_mul_result
            if (mod_mul_result !== golden_results_mem[i]) begin
                $display("Test failed at index %0d: Expected: %h, Got: %h",
                         i, golden_results_mem[i], mod_mul_result);
                $finish;
            end else begin
                $display("Pass index %0d: Result: %h == %h",
                         i, mod_mul_result, golden_results_mem[i]);
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
