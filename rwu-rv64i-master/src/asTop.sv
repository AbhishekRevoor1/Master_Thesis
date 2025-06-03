`timescale 1ns/1ps

import as_pack::*;

module as_top (input  logic                       clk_i,
               input  logic                       rst_i,
               input  logic                       tck_i,      // Test Clock
               input  logic                       trst_i,     // TAPC reset
               input  logic                       tms_i,      // Test Mode Select
               input  logic                       tdi_i,      // Test Data In
               output logic                       tdo_o,      // Test Data Out
               output logic [nr_gpios-1:0]        gpio_o,     // data of data bus (write to dmem)
               output logic [gpio_addr_width-1:0] gpioAddr_o, // addr of data bus
               output logic                       cs_o
              );

  // data bus
  logic [reg_width-1:0]   dBusDataRd_s; // data out from dmem
  logic [reg_width-1:0]   dBusDataWr_s; // data in to dmem
  logic [daddr_width-1:0] dBusAddr_s;   // address for dmem
  logic			  dMemRd_s;     // read enable for dmem
  logic			  dMemWr_s;     // write enable for dmem
  logic			  dMemWrMx_s;   // write enable for dmem after CS Mux
  
  // instruction bus
  logic [instr_width-1:0] iBusDataRd_s; // data out from imem
  logic [instr_width-1:0] iBusDataWr_s; // data in to imem            -- not connected
  logic [iaddr_width-1:0] iBusAddr_s;   // address for imem
  logic			  iMemRd_s;     // read enable for imem       -- not connected
  logic			  iMemWr_s;     // write enable for imem      -- not connected

  // Umbau
  logic aluSrcA_s,aluSrcB_s,regWr_s,jump_s,zero_s,PCsrc_s;
  logic [dmuxsel_width-1:0]  resultSrc_s;
  logic [immsrc_width-1:0]   immSrc_s;
  logic [aluselrv_width-1:0] aluSel_s;

  // PC
  logic [iaddr_width-1:0] PCnext_s; // next PC
  logic [iaddr_width-1:0] PCp4_s;   // linear code
  logic [iaddr_width-1:0] PCbr_s;   // branch target; PCTarget
  logic	[iaddr_width-1:0] PCorRS1_s;

  // Immediate extention
  logic [reg_width-1:0] immExt_s;
  // Register file
  logic [reg_width-1:0] srcA_s, regA_s;
  logic [reg_width-1:0] srcB_s;

  // D-Mem
  logic [reg_width-1:0] result_s;
  // ALU
  logic                 nega_s,carry_s,overflow_s;

  // chip selects
  logic [cs_width-1:0]        cs_s;
  logic [cs_width-1:0]        csReg_s;
  logic [nr_gpios-1:0]        gpio_s;
  logic [nr_gpios-1:0]        gpioReg_s;
  logic [gpio_addr_width-1:0] gpioAddr_s;
  logic [gpio_addr_width-1:0] gpioAddrReg_s;

  // JTAG
  logic tap_rst_s;
  logic	sc01_tdo_s, sc01_tdi_s, sc01_shift_s, sc01_clock_s;
  logic im_tdo_s, im_tdi_s, im_shift_s, im_clock_s, im_upd_s, im_mode_s;
  logic bs_tdo_s, bs_tdi_s, bs_shift_s, bs_clock_s, bs_upd_s, bs_mode_s;
  logic	clk_mux_s;
  // JTAG: Artificial scan chain
  logic	and_in01_s, and_in02_s, and_out_s;
  logic	sc01_01_s, sc01_02_s, sc01_03_s;
  logic	to_some_pin1_s, to_some_pin2_s; 
  // JTAG: I-Mem scan chain
  logic [im_scan_length-1:0] im_datai_s, im_datao_s;
  // JTAG: I-Mem Address MUX
  logic [iaddr_width-1:0] iBusAddr2_s;   // address for imem
  logic [iaddr_width-1:0] im_addr_s;   // address for imem from chain
  logic			  mux_sel_s;

  assign gpio_o      = gpioReg_s;
  assign gpioAddr_o  = gpioAddrReg_s;
  assign cs_o        = csReg_s[1];

  
  //--------------------------------------------
  // design an DMem address decoder with chip selects for peripherals
  //--------------------------------------------
  // from h00000000_00000000 to h00000000_0000FFFF : variables, 65536 Bytes, 8192 double words
  // from h00000000_00010000 to h00000000_0001000F : external peripherals, 16 Bytes, 2 double words
  always_comb 
  begin
    case (dBusAddr_s) inside
      [64'h00000000_00000000:64'h00000000_000000FF]: begin cs_s = 2'b01; end // 0 -> 255: interner Speicherbereich
      [64'h00000000_00000100:64'h00000000_0000010F]: begin cs_s = 2'b10; end // 256 -> (256+15): externer (GPIO) Speicherbereich
      default:                                       begin cs_s = 2'b00; end
    endcase
  end

  always_comb
  begin
    case (cs_s)
      2'b10 :   begin 
                  gpio_s     = dBusDataWr_s[nr_gpios-1:0];
                  gpioAddr_s = dBusAddr_s[gpio_addr_width-1:0];
                  dMemWrMx_s = 0;
                end
      default : begin 
                  gpio_s     = {nr_gpios{1'b0}};
                  gpioAddr_s = {gpio_addr_width{1'b0}};
                  dMemWrMx_s = dMemWr_s;
                end
    endcase
  end // always_comb

  //--------------------------------------------
  // register gpio
  //--------------------------------------------
  always_ff @(posedge clk_i, posedge rst_i)
  begin
    if(rst_i == 1)
    begin
      gpioReg_s     <= 0;
      gpioAddrReg_s <= 0;
      csReg_s       <= 0;
    end
    else
    begin
      if (cs_s[1] == 1)
      begin
        gpioReg_s     <= gpio_s;
        gpioAddrReg_s <= gpioAddr_s;
        csReg_s       <= cs_s;
      end
      else
        csReg_s       <= 0;
    end
  end // always_ff @ (posedge clk_i, posedge rst_i)

  //--------------------------------------------
  // PC, Program Counter
  //--------------------------------------------
  as_pc pc (.clk_i(clk_i),
            .rst_i(rst_i),
            .PCnext_i(PCnext_s),
            .PC_o(iBusAddr_s) // PC
           );

  //--------------------------------------------
  // Adder +4 for the address of the next instruction
  //--------------------------------------------
  as_adder add4 (.a_i(iBusAddr_s), // PC
                 .b_i(64'd4),
                 .sum_o(PCp4_s)
                ); // replace 64 by constant !!!!!!!!!!

  //--------------------------------------------
  // Mux for jumps of jalr instruction or normal branches.
  //         - pc_o   : jalr
  //         - regA_s : normal branch
  //--------------------------------------------
  as_mux2 jalrmux(.d0_i(iBusAddr_s), // PC
                  .d1_i(regA_s),
                  .sel_i(jump_s),
                  .y_o(PCorRS1_s)
                 );

  //--------------------------------------------
  // Adder for the branch targets
  //--------------------------------------------
  as_adder addbranch (.a_i(PCorRS1_s),
                      .b_i(immExt_s),
                      .sum_o(PCbr_s)
                     );

  //--------------------------------------------
  // Mux for the PC, either +4 or branch target
  //--------------------------------------------
  as_mux2 pcmux (.d0_i(PCp4_s),
                 .d1_i(PCbr_s),
                 .sel_i(PCsrc_s),
                 .y_o(PCnext_s)
                );

  //--------------------------------------------
  // Register file
  //--------------------------------------------
  as_regfile regfile (.clk_i(clk_i),
                      .rst_i(rst_i),
                      .we_i(regWr_s),
                      .raddr01_i(iBusDataRd_s[19:15]),
                      .raddr02_i(iBusDataRd_s[24:20]),
                      .waddr01_i(iBusDataRd_s[11:7]),
                      .wdata01_i(result_s),
                      .rdata01_o(regA_s),
                      .rdata02_o(dBusDataWr_s)
                     );

  //--------------------------------------------
  // Immediate generation
  //--------------------------------------------
  as_immgen extend (.instr_i(iBusDataRd_s[instr_width-1:7]),
                    .sel_i(immSrc_s),
                    .imm_o(immExt_s)
                   );

  //--------------------------------------------
  // ALU: input mux for regB or immediate
  //--------------------------------------------
  as_mux2 alumuxB (.d0_i(dBusDataWr_s),
                   .d1_i(immExt_s),
                   .sel_i(aluSrcB_s),
                   .y_o(srcB_s)
                  );

  //--------------------------------------------
  // ALU: input mux for regA or PC
  //--------------------------------------------
  as_mux2 alumuxA (.d0_i(regA_s),
                   .d1_i(iBusAddr_s), // PC
                   .sel_i(aluSrcA_s),
                   .y_o(srcA_s)
                  );

  //--------------------------------------------
  // ALU
  //--------------------------------------------
  as_alurv alu (.data01_i(srcA_s),
                .data02_i(srcB_s),
                .aluSel_i(aluSel_s),
                .aluZero_o(zero_s),
                .aluNega_o(nega_s),
                .aluCarr_o(carry_s),
                .aluOver_o(overflow_s),
                .aluResult_o(dBusAddr_s)
               );

  //--------------------------------------------
  // Mux for aluResult, dmem or PC+4 to register file
  //--------------------------------------------
  as_mux3 dmmux (.d0_i(dBusAddr_s),
                 .d1_i(dBusDataRd_s),
                 .d2_i(PCp4_s),
                 .sel_i(resultSrc_s),
                 .y_o(result_s)
                );

  //--------------------------------------------
  // Instruction decoder
  //--------------------------------------------
  as_controlall control (.opcode_i(iBusDataRd_s[6:0]),
                      .func3_i(iBusDataRd_s[14:12]),
                      .func7b5_i(iBusDataRd_s[30]),
                      .zero_i(zero_s),
                      .resultSrc_o(resultSrc_s),
                      .dMemWr_o(dMemWr_s),
                      .dMemRd_o(dMemRd_s),
                      .PCSrc_o(PCsrc_s),
                      .aluSrcB_o(aluSrcB_s),
                      .aluSrcA_o(aluSrcA_s),
                      .regWr_o(regWr_s),
                      .jump_o(jump_s),
                      .immSrc_o(immSrc_s),
                      .aluSel_o(aluSel_s)
                      );

  //--------------------------------------------
  // instruction memory
  //--------------------------------------------
  assign im_addr_s    = im_datao_s[im_scan_length-1:instr_width+1];
  assign iMemWr_s     = im_datao_s[0] & (~im_clock_s);
  assign iBusDataWr_s = im_datao_s[instr_width:1];
  assign mux_sel_s    = im_datao_s[0] & (~im_clock_s);
  assign iBusAddr2_s = (mux_sel_s == 0) ? iBusAddr_s[imem_addr_width-1:0] : im_addr_s;
  as_imem imem (.clk_i(clk_i),
                .addr_i(iBusAddr2_s[imem_addr_width-1:0]),
                .data_i(iBusDataWr_s),
                .wr_i(iMemWr_s),
                .data_o(iBusDataRd_s)
               );

  //--------------------------------------------
  // data memory
  //--------------------------------------------
  as_dmem dmem (.clk_i(clk_i),
                .addr_i(dBusAddr_s[dmem_addr_width-1:0]),
                .wrEn_i(dMemWrMx_s),
                .rdEn_i(dMemRd_s),
                .opcode_i(iBusDataRd_s[6:0]),
                .func3_i(iBusDataRd_s[14:12]),
                .data_i(dBusDataWr_s),
                .data_o(dBusDataRd_s)
               );

  //--------------------------------------------
  // JTAG
  //--------------------------------------------
  jtag as_jtag (.tck_i(tck_i),
                .trst_i(trst_i),
                .tms_i(tms_i),
                .tdi_i(tdi_i),
                .tdo_o(tdo_o),
                .tap_rst_o(tap_rst_s),
                .sc01_tdo_i(sc01_tdo_s),
                .sc01_tdi_o(sc01_tdi_s),
                .sc01_shift_o(sc01_shift_s),
                .sc01_clock_o(sc01_clock_s),
                .im_tdo_i(im_tdo_s),
                .im_tdi_o(im_tdi_s),
                .im_shift_o(im_shift_s),
                .im_clock_o(im_clock_s),
                .im_upd_o(im_upd_s),
                .im_mode_o(im_mode_s),
                .bs_tdo_i(bs_tdo_s),
                .bs_tdi_o(bs_tdi_s),
                .bs_shift_o(bs_shift_s),
                .bs_clock_o(bs_clock_s),
                .bs_upd_o(bs_upd_s),
                .bs_mode_o(bs_mode_s)
               );

  //--------------------------------------------
  // Test Scan Chain
  //--------------------------------------------
  assign clk_mux_s = (sc01_clock_s == 1) ? tck_i : clk_i;
  scan_cell sc01 (clk_mux_s, tap_rst_s, sc01_shift_s, 1'b0, sc01_tdi_s, and_in01_s, sc01_01_s);
  scan_cell sc02 (clk_mux_s, tap_rst_s, sc01_shift_s, 1'b0, sc01_01_s, and_in02_s, sc01_02_s);
  assign and_out_s = and_in01_s & and_in02_s;
  scan_cell sc03 (clk_mux_s, tap_rst_s, sc01_shift_s, and_out_s, sc01_02_s, to_some_pin1_s, sc01_03_s);
  scan_cell sc04 (clk_mux_s, tap_rst_s, sc01_shift_s, 1'b0, sc01_03_s, to_some_pin2_s, sc01_tdo_s);

  //--------------------------------------------
  // Scan chain for I-Mem
  //--------------------------------------------
  assign im_datai_s  = {im_scan_length{1'b0}}; // paralell load
  dr_reg #(.dr_width(im_scan_length)) imem_load (.tck_i(tck_i),
                  .trst_i(tap_rst_s),
                  .mode_i(im_mode_s),
                  .dr_shift_i(im_shift_s),
                  .dr_clock_i(im_clock_s),
                  .dr_upd_i(im_upd_s),
                  .data_i(im_datai_s),// parallel in to chain
                  .ser_i(im_tdi_s),
                  .data_o(im_datao_s),// to I-Mem
                  .ser_o(im_tdo_s)
		 );
 
endmodule : as_top
