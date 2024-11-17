# Create port_slicer
cell pavel-demin:user:port_slicer slice_0 {
  DIN_WIDTH 8 DIN_FROM 0 DIN_TO 0
}

for {set i 0} {$i <= 7} {incr i} {

  # Create port_slicer
  cell pavel-demin:user:port_slicer slice_[expr $i + 1] {
    DIN_WIDTH 288 DIN_FROM [expr $i] DIN_TO [expr $i]
  }

  # Create port_selector
  cell pavel-demin:user:port_selector selector_$i {
    DOUT_WIDTH 16
  } {
    cfg slice_[expr $i + 1]/dout
    din /adc_0/m_axis_tdata
  }

  # Create port_slicer
  cell pavel-demin:user:port_slicer slice_[expr $i + 9] {
    DIN_WIDTH 288 DIN_FROM [expr 32 * $i + 63] DIN_TO [expr 32 * $i + 32]
  }

  # Create axis_constant
  cell pavel-demin:user:axis_constant phase_$i {
    AXIS_TDATA_WIDTH 32
  } {
    cfg_data slice_[expr $i + 9]/dout
    aclk /pll_0/clk_out1
  }

  # Create dds_compiler
  cell xilinx.com:ip:dds_compiler dds_$i {
    DDS_CLOCK_RATE 122.88
    SPURIOUS_FREE_DYNAMIC_RANGE 138
    FREQUENCY_RESOLUTION 0.2
    PHASE_INCREMENT Streaming
    HAS_PHASE_OUT false
    PHASE_WIDTH 30
    OUTPUT_WIDTH 24
    DSP48_USE Minimal
    NEGATIVE_SINE true
  } {
    S_AXIS_PHASE phase_$i/M_AXIS
    aclk /pll_0/clk_out1
  }

}

# Create xlconstant
cell xilinx.com:ip:xlconstant const_0

for {set i 0} {$i <= 15} {incr i} {

  # Create port_slicer
  cell pavel-demin:user:port_slicer dds_slice_$i {
    DIN_WIDTH 48 DIN_FROM [expr 24 * ($i % 2) + 23] DIN_TO [expr 24 * ($i % 2)]
  } {
    din dds_[expr $i / 2]/m_axis_data_tdata
  }

  # Create dsp48
  cell pavel-demin:user:dsp48 mult_$i {
    A_WIDTH 24
    B_WIDTH 16
    P_WIDTH 24
  } {
    A dds_slice_$i/dout
    B selector_[expr $i / 2]/dout
    CLK /pll_0/clk_out1
  }

  # Create cic_compiler
  cell xilinx.com:ip:cic_compiler cic_$i {
    INPUT_DATA_WIDTH.VALUE_SRC USER
    FILTER_TYPE Decimation
    NUMBER_OF_STAGES 6
    SAMPLE_RATE_CHANGES Fixed
    FIXED_OR_INITIAL_RATE 128
    INPUT_SAMPLE_FREQUENCY 122.88
    CLOCK_FREQUENCY 122.88
    INPUT_DATA_WIDTH 24
    QUANTIZATION Truncation
    OUTPUT_DATA_WIDTH 32
    USE_XTREME_DSP_SLICE false
    HAS_DOUT_TREADY true
    HAS_ARESETN true
  } {
    s_axis_data_tdata mult_$i/P
    s_axis_data_tvalid const_0/dout
    aclk /pll_0/clk_out1
    aresetn /rst_0/peripheral_aresetn
  }

}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
  NUM_SI 16
} {
  S00_AXIS cic_0/M_AXIS_DATA
  S01_AXIS cic_1/M_AXIS_DATA
  S02_AXIS cic_2/M_AXIS_DATA
  S03_AXIS cic_3/M_AXIS_DATA
  S04_AXIS cic_4/M_AXIS_DATA
  S05_AXIS cic_5/M_AXIS_DATA
  S06_AXIS cic_6/M_AXIS_DATA
  S07_AXIS cic_7/M_AXIS_DATA
  S08_AXIS cic_8/M_AXIS_DATA
  S09_AXIS cic_9/M_AXIS_DATA
  S10_AXIS cic_10/M_AXIS_DATA
  S11_AXIS cic_11/M_AXIS_DATA
  S12_AXIS cic_12/M_AXIS_DATA
  S13_AXIS cic_13/M_AXIS_DATA
  S14_AXIS cic_14/M_AXIS_DATA
  S15_AXIS cic_15/M_AXIS_DATA
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 64
  M_TDATA_NUM_BYTES 4
} {
  S_AXIS comb_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler cic_16 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Fixed
  FIXED_OR_INITIAL_RATE 120
  INPUT_SAMPLE_FREQUENCY 0.96
  CLOCK_FREQUENCY 122.88
  NUMBER_OF_CHANNELS 16
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_DOUT_TREADY true
  HAS_ARESETN true
} {
  S_AXIS_DATA conv_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create fir_compiler
cell xilinx.com:ip:fir_compiler fir_0 {
  DATA_WIDTH.VALUE_SRC USER
  DATA_WIDTH 32
  COEFFICIENTVECTOR {-1.6476029924e-08, -4.7317663921e-08, -7.9297086919e-10, 3.0931068251e-08, 1.8624899184e-08, 3.2745275438e-08, -6.2983102205e-09, -1.5226461510e-07, -8.3037993196e-08, 3.1450399608e-07, 3.0559647999e-07, -4.7412518790e-07, -7.1342412421e-07, 5.4726906080e-07, 1.3344889422e-06, -4.1409901942e-07, -2.1502957535e-06, -6.7734780426e-08, 3.0751582226e-06, 1.0369197451e-06, -3.9439705591e-06, -2.5916552851e-06, 4.5149247871e-06, 4.7473529367e-06, -4.4923942508e-06, -7.3975088222e-06, 3.5718066668e-06, 1.0288505945e-05, -1.5036699926e-06, -1.3019569206e-05, -1.8318952561e-06, 1.5076655211e-05, 6.3540146763e-06, -1.5904108520e-05, -1.1731311774e-05, 1.5009519800e-05, 1.7370248710e-05, -1.2093149493e-05, -2.2464642138e-05, 7.1690327594e-06, 2.6100666080e-05, -6.6351550041e-07, -2.7426546211e-05, -6.5499631942e-06, 2.5861779804e-05, 1.3202990848e-05, -2.1314918913e-05, -1.7788233187e-05, 1.4364979354e-05, 1.8817765049e-05, -6.3570758109e-06, -1.5160950101e-05, -6.3446650653e-07, 6.4151039934e-06, 4.0073694377e-06, 6.7569265413e-06, -1.0052571209e-06, -2.2400780694e-05, -1.0761580775e-05, 3.7229655526e-05, 3.2697577872e-05, -4.6855822711e-05, -6.4646230690e-05, 4.6255347932e-05, 1.0439146560e-04, -3.0537318086e-05, -1.4744250814e-04, -4.1197597426e-06, 1.8716724719e-04, 5.9466388336e-05, -2.1535343798e-04, -1.3428871227e-04, 2.2320188691e-04, 2.2381300637e-04, -2.0268042569e-04, -3.1959186896e-04, 1.4808143459e-04, 4.1000950243e-04, -5.7554045117e-05, -4.8146700521e-04, -6.5669757798e-05, 5.2019915257e-04, 2.1264294432e-04, -5.1456744773e-04, -3.6896902805e-04, 4.5742183724e-04, 5.1592218707e-04, -3.4844328132e-04, -6.3281816345e-04, 1.9563040584e-04, 7.0011894344e-04, -1.5797846449e-05, -7.0313532236e-04, -1.6635993250e-04, 6.3578061968e-04, 3.2080008143e-04, -5.0376101407e-04, -4.1621362769e-04, 3.2653766960e-04, 4.2534929843e-04, -1.3745356625e-04, -3.3101221784e-04, -1.8430012550e-05, 1.3193968343e-04, 8.8982050994e-05, 1.5239118041e-04, -2.2003278613e-05, -4.7906135871e-04, -2.2613687582e-04, 7.8151784851e-04, 6.8026889589e-04, -9.7374401905e-04, -1.3372978829e-03, 9.5740939718e-04, 2.1580230247e-03, -6.3299474197e-04, -3.0620906209e-03, -8.6269449756e-05, 3.9271007758e-03, 1.2587759927e-03, -4.5927432956e-03, -2.8987761545e-03, 4.8703230916e-03, 4.9622222115e-03, -4.5574266467e-03, -7.3359412491e-03, 3.4568188251e-03, 9.8315561210e-03, -1.3980539406e-03, -1.2184949179e-02, -1.7401694020e-03, 1.4060881305e-02, 6.0079369926e-03, -1.5064074389e-02, -1.1369007075e-02, 1.4746889392e-02, 1.7685463058e-02, -1.2617271454e-02, -2.4710701135e-02, 8.1300985728e-03, 3.2083272920e-02, -6.4509548985e-04, -3.9313133290e-02, -1.0691329576e-02, 4.5732093991e-02, 2.7247437703e-02, -5.0316476483e-02, -5.1710664547e-02, 5.1014540684e-02, 9.0561853039e-02, -4.1604548308e-02, -1.6373166526e-01, -1.0797747008e-02, 3.5635721746e-01, 5.5476729348e-01, 3.5635721746e-01, -1.0797747008e-02, -1.6373166526e-01, -4.1604548308e-02, 9.0561853039e-02, 5.1014540684e-02, -5.1710664547e-02, -5.0316476483e-02, 2.7247437703e-02, 4.5732093991e-02, -1.0691329576e-02, -3.9313133290e-02, -6.4509548985e-04, 3.2083272920e-02, 8.1300985728e-03, -2.4710701135e-02, -1.2617271454e-02, 1.7685463058e-02, 1.4746889392e-02, -1.1369007075e-02, -1.5064074389e-02, 6.0079369926e-03, 1.4060881305e-02, -1.7401694020e-03, -1.2184949179e-02, -1.3980539406e-03, 9.8315561210e-03, 3.4568188251e-03, -7.3359412491e-03, -4.5574266467e-03, 4.9622222115e-03, 4.8703230916e-03, -2.8987761545e-03, -4.5927432956e-03, 1.2587759927e-03, 3.9271007758e-03, -8.6269449756e-05, -3.0620906209e-03, -6.3299474197e-04, 2.1580230247e-03, 9.5740939718e-04, -1.3372978829e-03, -9.7374401905e-04, 6.8026889589e-04, 7.8151784851e-04, -2.2613687582e-04, -4.7906135871e-04, -2.2003278613e-05, 1.5239118041e-04, 8.8982050994e-05, 1.3193968343e-04, -1.8430012550e-05, -3.3101221784e-04, -1.3745356625e-04, 4.2534929843e-04, 3.2653766960e-04, -4.1621362769e-04, -5.0376101407e-04, 3.2080008143e-04, 6.3578061968e-04, -1.6635993250e-04, -7.0313532236e-04, -1.5797846449e-05, 7.0011894344e-04, 1.9563040584e-04, -6.3281816345e-04, -3.4844328132e-04, 5.1592218707e-04, 4.5742183724e-04, -3.6896902805e-04, -5.1456744773e-04, 2.1264294432e-04, 5.2019915257e-04, -6.5669757798e-05, -4.8146700521e-04, -5.7554045117e-05, 4.1000950243e-04, 1.4808143459e-04, -3.1959186896e-04, -2.0268042569e-04, 2.2381300637e-04, 2.2320188691e-04, -1.3428871227e-04, -2.1535343798e-04, 5.9466388336e-05, 1.8716724719e-04, -4.1197597426e-06, -1.4744250814e-04, -3.0537318086e-05, 1.0439146560e-04, 4.6255347932e-05, -6.4646230690e-05, -4.6855822711e-05, 3.2697577872e-05, 3.7229655526e-05, -1.0761580775e-05, -2.2400780694e-05, -1.0052571209e-06, 6.7569265413e-06, 4.0073694377e-06, 6.4151039934e-06, -6.3446650653e-07, -1.5160950101e-05, -6.3570758109e-06, 1.8817765049e-05, 1.4364979354e-05, -1.7788233187e-05, -2.1314918913e-05, 1.3202990848e-05, 2.5861779804e-05, -6.5499631942e-06, -2.7426546211e-05, -6.6351550041e-07, 2.6100666080e-05, 7.1690327594e-06, -2.2464642138e-05, -1.2093149493e-05, 1.7370248710e-05, 1.5009519800e-05, -1.1731311774e-05, -1.5904108520e-05, 6.3540146763e-06, 1.5076655211e-05, -1.8318952561e-06, -1.3019569206e-05, -1.5036699926e-06, 1.0288505945e-05, 3.5718066668e-06, -7.3975088222e-06, -4.4923942508e-06, 4.7473529367e-06, 4.5149247871e-06, -2.5916552851e-06, -3.9439705591e-06, 1.0369197451e-06, 3.0751582226e-06, -6.7734780426e-08, -2.1502957535e-06, -4.1409901942e-07, 1.3344889422e-06, 5.4726906080e-07, -7.1342412421e-07, -4.7412518790e-07, 3.0559647999e-07, 3.1450399608e-07, -8.3037993196e-08, -1.5226461510e-07, -6.2983102205e-09, 3.2745275438e-08, 1.8624899184e-08, 3.0931068251e-08, -7.9297086919e-10, -4.7317663921e-08, -1.6476029924e-08}
  COEFFICIENT_WIDTH 32
  QUANTIZATION Quantize_Only
  BESTPRECISION true
  FILTER_TYPE Decimation
  DECIMATION_RATE 2
  NUMBER_CHANNELS 16
  NUMBER_PATHS 1
  SAMPLE_FREQUENCY 0.008
  CLOCK_FREQUENCY 122.88
  OUTPUT_ROUNDING_MODE Convergent_Rounding_to_Even
  OUTPUT_WIDTH 33
  M_DATA_HAS_TREADY true
  HAS_ARESETN true
} {
  S_AXIS_DATA cic_16/M_AXIS_DATA
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_subset_converter
cell xilinx.com:ip:axis_subset_converter subset_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 5
  M_TDATA_NUM_BYTES 4
  TDATA_REMAP {tdata[31:0]}
} {
  S_AXIS fir_0/M_AXIS_DATA
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create floating_point
cell xilinx.com:ip:floating_point fp_0 {
  OPERATION_TYPE Fixed_to_float
  A_PRECISION_TYPE.VALUE_SRC USER
  C_A_EXPONENT_WIDTH.VALUE_SRC USER
  C_A_FRACTION_WIDTH.VALUE_SRC USER
  A_PRECISION_TYPE Custom
  C_A_EXPONENT_WIDTH 2
  C_A_FRACTION_WIDTH 30
  RESULT_PRECISION_TYPE Single
  HAS_ARESETN true
} {
  S_AXIS_A subset_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_1 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 64
} {
  S_AXIS fp_0/M_AXIS_RESULT
  aclk /pll_0/clk_out1
  aresetn /rst_0/peripheral_aresetn
}

# Create axis_fifo
cell pavel-demin:user:axis_fifo fifo_0 {
  S_AXIS_TDATA_WIDTH 512
  M_AXIS_TDATA_WIDTH 512
  WRITE_DEPTH 1024
  ALWAYS_READY TRUE
} {
  S_AXIS conv_1/M_AXIS
  aclk /pll_0/clk_out1
  aresetn slice_0/dout
}

# Create axis_dwidth_converter
cell xilinx.com:ip:axis_dwidth_converter conv_2 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 64
  M_TDATA_NUM_BYTES 4
} {
  S_AXIS fifo_0/M_AXIS
  aclk /pll_0/clk_out1
  aresetn slice_0/dout
}
