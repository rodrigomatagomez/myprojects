module ram_tb();

  // Verible style: prefer CamelCase for localparams (per your lint rule)
  localparam int DataWidth = 32;
  localparam int Depth     = 16;
  localparam int AddrWidth = (Depth <= 1) ? 1 : $clog2(Depth);

  logic clk;
  logic w_en;
  logic [AddrWidth-1:0] addr;
  logic [DataWidth-1:0] data_in;
  logic [DataWidth-1:0] data_out;

  // DUT
  ram #(
    .DATA_WIDTH(DataWidth),
    .DEPTH(Depth),
    .ADDR_WIDTH(AddrWidth)
  ) dut (
    .clk(clk),
    .w_en(w_en),
    .addr(addr),
    .data_in(data_in),
    .data_out(data_out)
  );

  // Clock 100 MHz (10 ns)
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // Write on next posedge
  task automatic wr(input int unsigned a, input logic [DataWidth-1:0] d);
    begin
      @(negedge clk);
      w_en    = 1'b1;
      addr    = a[AddrWidth-1:0];
      data_in = d;
      @(posedge clk); // write happens here
    end
  endtask

  // Read is synchronous (1-cycle latency): value valid after a posedge with w_en=0 and addr stable
  task automatic rd_check(input int unsigned a, input logic [DataWidth-1:0] exp);
    begin
      @(negedge clk);
      w_en = 1'b0;
      addr = a[AddrWidth-1:0];

      @(posedge clk); // data_out <= mem[addr]
      #1;             // allow NBA update to settle in simulation

      if (data_out !== exp) begin
        $display("ERROR: addr=%0d data_out=%h expected=%h", a, data_out, exp);
        $finish;
      end else begin
        $display("OK: addr=%0d data_out=%h", a, data_out);
      end
    end
  endtask

  initial begin
    $dumpfile("sim/wave.vcd");
    $dumpvars(0, ram_tb);

    // init
    w_en    = 1'b0;
    addr    = '0;
    data_in = '0;

    // Tests
    wr(3, 32'hDEAD_BEEF);
    rd_check(3, 32'hDEAD_BEEF);

    wr(7, 32'h1234_5678);
    rd_check(7, 32'h1234_5678);

    wr(3, 32'hCAFE_BABE);
    rd_check(3, 32'hCAFE_BABE);

    $display("ALL TESTS PASSED");
    $finish;
  end

endmodule

