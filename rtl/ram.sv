module ram #(
  parameter int unsigned DATA_WIDTH = 32,
  parameter int unsigned DEPTH      = 1024,
  parameter int unsigned ADDR_WIDTH = (DEPTH <= 1) ? 1 : $clog2(DEPTH)
)(
  input logic clk,
  input logic w_en,
  input logic [ADDR_WIDTH - 1 : 0] addr,
  input logic [DATA_WIDTH - 1 : 0] data_in,
  output logic [DATA_WIDTH - 1 : 0] data_out
);

  logic [DATA_WIDTH - 1 : 0] mem [DEPTH];

  always_ff @(posedge clk) begin
    if (w_en) begin
      mem[addr] <= data_in;
    end
    data_out <= mem[addr];
  end
endmodule
