# Create clk_wiz
cell xilinx.com:ip:clk_wiz pll_0 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 122.88
  PRIM_SOURCE Differential_clock_capable_pin
  CLKOUT1_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 122.88
  CLKOUT2_USED false
  CLKOUT2_REQUESTED_OUT_FREQ 245.76
  CLKOUT2_REQUESTED_PHASE 157.5
  CLKOUT3_USED false
  CLKOUT3_REQUESTED_OUT_FREQ 245.76
  CLKOUT3_REQUESTED_PHASE 202.5
  USE_RESET false
} {
  clk_in1_p adc_clk_p_i
  clk_in1_n adc_clk_n_i
}

# Create processing_system7
cell xilinx.com:ip:processing_system7 ps_0 {
  PCW_IMPORT_BOARD_PRESET cfg/red_pitaya.xml
} {
  M_AXI_GP0_ACLK pll_0/clk_out1
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {
  make_external {FIXED_IO, DDR}
  Master Disable
  Slave Disable
} [get_bd_cells ps_0]

# Create xlconstant
cell xilinx.com:ip:xlconstant const_0

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset rst_0 {} {
  ext_reset_in const_0/dout
  dcm_locked pll_0/locked
  slowest_sync_clk pll_0/clk_out1
}

# HUB

# Create axi_hub
cell pavel-demin:user:axi_hub hub_0 {
  CFG_DATA_WIDTH 320
  STS_DATA_WIDTH 96
} {
  S_AXI ps_0/M_AXI_GP0
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}

# XADC

# Create xadc_bram
#cell pavel-demin:user:xadc_bram xadc_0 {} {
#  B_BRAM hub_0/B02_BRAM
#  Vp_Vn Vp_Vn
#  Vaux0 Vaux0
#  Vaux1 Vaux1
#  Vaux8 Vaux8
#  Vaux9 Vaux9
#}

# ADC

# Create axis_red_pitaya_adc
cell xilinx.com:ip:xlconstant const_adc_dummy_b {
  CONST_WIDTH 16
  CONST_VAL 0
}

cell pavel-demin:user:axis_red_pitaya_adc  adc_0 {
  ADC_DATA_WIDTH 16
} {
  aclk pll_0/clk_out1
  adc_dat_a adc_dat_a_i
  adc_dat_b const_adc_dummy_b/dout
}

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_0 {
  S_AXIS_TDATA_WIDTH 32
  M_AXIS_TDATA_WIDTH 32
  WRITE_DEPTH 1024
} {
  S_AXIS hub_0/M03_AXIS
  aclk pll_0/clk_out1
  aresetn rst_0/peripheral_aresetn
}


# RX 0

# Create port_slicer
cell pavel-demin:user:port_slicer rst_slice_0 {
  DIN_WIDTH 320 DIN_FROM 7 DIN_TO 0
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer rst_slice_1 {
  DIN_WIDTH 320 DIN_FROM 15 DIN_TO 8
} {
  din hub_0/cfg_data
}

# Create port_slicer
cell pavel-demin:user:port_slicer cfg_slice_0 {
  DIN_WIDTH 320 DIN_FROM 159 DIN_TO 32
} {
  din hub_0/cfg_data
}

module rx_0 {
  source projects/sdr_transceiver_hpsdr/rx.tcl
} {
  slice_0/din rst_slice_0/dout
  slice_1/din rst_slice_1/dout
  slice_2/din rst_slice_1/dout
  slice_3/din cfg_slice_0/dout
  slice_4/din cfg_slice_0/dout
  slice_5/din cfg_slice_0/dout
  slice_6/din cfg_slice_0/dout
  slice_7/din cfg_slice_0/dout
  slice_8/din cfg_slice_0/dout
  slice_9/din cfg_slice_0/dout
  slice_10/din cfg_slice_0/dout
}

# STS

# Create xlconcat
cell xilinx.com:ip:xlconcat concat_0 {
  NUM_PORTS 5
  IN0_WIDTH 16
  IN1_WIDTH 16
  IN2_WIDTH 16
  IN3_WIDTH 16
  IN4_WIDTH 4
} {
  In0 rx_0/fifo_0/read_count
  In1 const_0/dout
  In2 const_0/dout
  In3 const_0/dout
  In4 const_0/dout
  dout hub_0/sts_data
}

wire rx_0/fifo_0/M_AXIS hub_0/S00_AXIS
