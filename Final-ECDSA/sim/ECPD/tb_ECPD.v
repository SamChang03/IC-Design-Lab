`timescale 1ns/1ps
`define END_CYCLE 100000000

module tb_ECPD;

    // 模擬時鐘和重置信號
    reg clk;
    reg rst_n;

    // 測試輸入
    reg [255:0] m_in;
    reg [255:0] X1_in;
    reg [255:0] Y1_in;
    reg [255:0] Z1_in;
    reg double_start;

    // 模組輸出
    wire double_done;
    wire [255:0] X3_out;
    wire [255:0] Y3_out;
    wire [255:0] Z3_out;

    // 檔案操作相關變數
    integer pat_X1_file, pat_Y1_file, pat_Z1_file, golden_X3_file, golden_Y3_file, golden_Z3_file;
    integer i, t;

    // 用於儲存從檔案讀入的 a、b 和對應正確結果
    reg [255:0] pat_X1_mem [0:1023];
    reg [255:0] pat_Y1_mem [0:1023];
    reg [255:0] pat_Z1_mem [0:1023];
    reg [255:0] golden_X3_mem [0:1023];
    reg [255:0] golden_Y3_mem [0:1023];
    reg [255:0] golden_Z3_mem [0:1023];

    integer num_pairs;

    // // 待測模組實例化
    ECPD uut (
        .clk(clk),
        .rst_n(rst_n),
        .m(m_in),
        .double_start(double_start),
        .X1(X1_in),
        .Y1(Y1_in),
        .Z1(Z1_in),
        .double_done(double_done),
        .X3(X3_out),
        .Y3(Y3_out),
        .Z3(Z3_out)
    );

    // ********************************** Waveform ***********************************
    // Not neccessary 
    // Dump waveform if you need it
    initial begin
        $fsdbDumpfile("ECPD.fsdb");
        $fsdbDumpvars("+mda");
    end
    // *******************************************************************************

    // 時鐘生成
    always #5 clk = ~clk;

    // 初始化
    initial begin
        clk = 0;
        rst_n = 0;
        double_start = 0;
        X1_in = 0;
        Y1_in = 0;
        Z1_in = 0;
        m_in = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F; // 假設 p 為此固定值

        // 重置信號
        #20 rst_n = 1;
    end

    // 檔案讀取流程
    initial begin
        wait(rst_n == 1);
        // 從 pat/a.txt 中讀取 a 值
        pat_X1_file = $fopen("pat/points_x.txt", "r");
        if (pat_X1_file == 0) begin
            $display("Error: Cannot open points_x.txt");
            $finish;
        end

        pat_Y1_file = $fopen("pat/points_y.txt", "r");
        if (pat_Y1_file == 0) begin
            $display("Error: Cannot open points_y.txt");
            $finish;
        end

        pat_Z1_file = $fopen("pat/points_z.txt", "r");
        if (pat_Z1_file == 0) begin
            $display("Error: Cannot open points_z.txt");
            $finish;
        end

        // 從 golden/results.txt 中讀取對應正確結果
        golden_X3_file = $fopen("golden/doubles_x.txt", "r");
        if (golden_X3_file == 0) begin
            $display("Error: Cannot open doubles_x.txt");
            $finish;
        end

        golden_Y3_file = $fopen("golden/doubles_y.txt", "r");
        if (golden_Y3_file == 0) begin
            $display("Error: Cannot open doubles_y.txt");
            $finish;
        end

        golden_Z3_file = $fopen("golden/doubles_z.txt", "r");
        if (golden_Z3_file == 0) begin
            $display("Error: Cannot open doubles_z.txt");
            $finish;
        end
        // 將整個 a, b 列表與結果數據讀取至暫存陣列
        i = 0;
        while (!$feof(pat_X1_file)) begin
            t = $fscanf(pat_X1_file, "%h\n", pat_X1_mem[i]);
            t = $fscanf(pat_Y1_file, "%h\n", pat_Y1_mem[i]);
            t = $fscanf(pat_Z1_file, "%h\n", pat_Z1_mem[i]);
            t = $fscanf(golden_X3_file, "%h\n", golden_X3_mem[i]);
            t = $fscanf(golden_Y3_file, "%h\n", golden_Y3_mem[i]);
            t = $fscanf(golden_Z3_file, "%h\n", golden_Z3_mem[i]);
            // $display("Read index %0d: X1: %h, Y1: %h, Z1: %h", i, pat_X1_mem[i], pat_Y1_mem[i], pat_Z1_mem[i]);
            // $display("Read index %0d: X3: %h, Y3: %h, Z3: %h", i, golden_X3_mem[i], golden_Y3_mem[i], golden_Z3_mem[i]);
            i = i + 1;
        end
        num_pairs = i;
        $fclose(pat_X1_file);
        $fclose(pat_Y1_file);
        $fclose(pat_Z1_file);
        $fclose(golden_X3_file);
        $fclose(golden_Y3_file);
        $fclose(golden_Z3_file);

        // delay 1 clk for reset
        @(posedge clk);

        // 輸入 a 和 b 至模組並比對計算結果
        for (i = 0; i < num_pairs; i = i + 1) begin
            X1_in = pat_X1_mem[i];
            Y1_in = pat_Y1_mem[i];
            Z1_in = pat_Z1_mem[i];
            // while(double_busy) @(posedge clk);
            double_start = 1;
            @(posedge clk);
            double_start = 0;

            while(double_done == 0) @(posedge clk); 

            // 比對 mod_add_result
            if (X3_out !== golden_X3_mem[i] || Y3_out !== golden_Y3_mem[i] || Z3_out !== golden_Z3_mem[i]) begin
                if(X3_out !== golden_X3_mem[i]) begin
                    $display("Test failed at index %0d: Expected X3: %h, Got: %h",
                         i, golden_X3_mem[i], X3_out);
                end
                if(Y3_out !== golden_Y3_mem[i]) begin
                    $display("Test failed at index %0d: Expected Y3: %h, Got: %h",
                         i, golden_Y3_mem[i], Y3_out);
                end
                if(Z3_out !== golden_Z3_mem[i]) begin
                    $display("Test failed at index %0d: Expected Z3: %h, Got: %h",
                         i, golden_Z3_mem[i], Z3_out);
                end
                $finish;
            end else begin
                $display("Pass index %0d: Result:\n X3: %h == %h,\n Y3: %h == %h,\n Z3: %h == %h",
                         i, X3_out, golden_X3_mem[i], Y3_out, golden_Y3_mem[i], Z3_out, golden_Z3_mem[i]);
            end
        end

        $display("################################");
        $display("Congraduation! ALL Pattern Pass!!! :D");
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
