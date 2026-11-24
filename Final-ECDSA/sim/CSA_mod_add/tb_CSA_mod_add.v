`timescale 1ns/1ps
`define END_CYCLE 100000

module tb_CSA_mod_add;

    // 模擬時鐘和重置信號
    reg clk;
    reg rst_n;

    // 測試輸入
    reg [255:0] a_in;
    reg [255:0] b_in;
    reg valid_in;

    // 模組輸出
    wire [255:0] result;
    wire done;

    // 檔案操作相關變數
    integer a_file, b_file, results_file;
    integer i, t;
    reg [255:0] golden_result;

    // 用於儲存從檔案讀入的 a、b 和對應正確結果
    reg [255:0] a_values_mem [0:1023];
    reg [255:0] b_values_mem [0:1023];
    reg [255:0] golden_results_mem [0:1023];

    integer num_pairs;

    // ********************************** Waveform ***********************************
    // Not neccessary 
    // Dump waveform if you need it
    initial begin
        $fsdbDumpfile("pipeline_add_sub.fsdb");
        $fsdbDumpvars("+mda");
    end
    // *******************************************************************************

    // 待測模組實例化
    CSA_mod_add uut (
        .clk(clk),
        .rst_n(rst_n),
        .add_start(valid_in),
        .a(a_in),
        .b(b_in),
        .add_done(done),
        .result(result)
    );

    // 時鐘生成
    always #5 clk = ~clk;

    // 初始化
    initial begin
        clk = 0;
        rst_n = 0;
        valid_in = 0;
        a_in = 0;
        b_in = 0;

        // 重置信號
        #20 rst_n = 1;
    end

    // 檔案讀取流程
    initial begin
        wait(rst_n == 1);
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
            // $display("a_values_mem[%d] = %h", i, a_values_mem[i]);
            // $display("b_values_mem[%d] = %h", i, b_values_mem[i]);
            // $display("golden_results_mem[%d] = %h", i, golden_results_mem[i]);
            i = i + 1;
        end
        num_pairs = i;
        $fclose(a_file);
        $fclose(b_file);
        $fclose(results_file);

        // 輸入 a 和 b 至模組並比對計算結果
        for (i = 2; i < num_pairs; i = i + 1) begin
            a_in = a_values_mem[i];
            b_in = b_values_mem[i];
            valid_in = 1;
            @(posedge clk);
            valid_in = 0;
            @(posedge clk);

            while (!done) @(posedge clk);

            // 比對 mod_add_result
            if (result !== golden_results_mem[i]) begin
                $display("Test failed at index %0d: Expected: %h, Got: %h",
                         i, golden_results_mem[i], result);
                $finish;
            end else begin
                $display("Pass index %0d: Result: %h == %h",
                         i, result, golden_results_mem[i]);
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
