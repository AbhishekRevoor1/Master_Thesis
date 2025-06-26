`timescale 1ns/1ps

module tb_instr07slli;

  logic clk = 0;
  always #5 clk = ~clk;

  logic rst = 1;
  initial #20 rst = 0;

  logic [7:0] gpio_s;

 as_top_mem dut (
  .clk_i(clk),
  .rst_i(rst),
  .gpio_o(gpio_s),
  .tck_i(1'b0),
  .tdi_i(1'b0),
  .tms_i(1'b0),
  .trst_i(1'b0),
  .tdo_o()
);


  initial begin
    $display("Running instr07slli simulation...");
  end

  always @(posedge clk) begin
    if (gpio_s !== 8'hZZ) begin
      $display("[GPIO] = 0x%0h at time %0t", gpio_s, $time);
      $finish;
    end
  end

endmodule
