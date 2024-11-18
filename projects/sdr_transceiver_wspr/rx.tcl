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
    FIXED_OR_INITIAL_RATE 256
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
  S00_AXIS cic_1/M_AXIS_DATA
  S01_AXIS cic_0/M_AXIS_DATA
  S02_AXIS cic_3/M_AXIS_DATA
  S03_AXIS cic_2/M_AXIS_DATA
  S04_AXIS cic_5/M_AXIS_DATA
  S05_AXIS cic_4/M_AXIS_DATA
  S06_AXIS cic_7/M_AXIS_DATA
  S07_AXIS cic_6/M_AXIS_DATA
  S08_AXIS cic_9/M_AXIS_DATA
  S09_AXIS cic_8/M_AXIS_DATA
  S10_AXIS cic_11/M_AXIS_DATA
  S11_AXIS cic_10/M_AXIS_DATA
  S12_AXIS cic_13/M_AXIS_DATA
  S13_AXIS cic_12/M_AXIS_DATA
  S14_AXIS cic_15/M_AXIS_DATA
  S15_AXIS cic_14/M_AXIS_DATA
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
  FIXED_OR_INITIAL_RATE 640
  INPUT_SAMPLE_FREQUENCY 0.48
  CLOCK_FREQUENCY 122.88
  NUMBER_OF_CHANNELS 32
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
  COEFFICIENTVECTOR {-1.6476201324e-08, -4.7319529752e-08, -7.9378833862e-10, 3.0932259829e-08, 1.8626836798e-08, 3.2746632870e-08, -6.3003569993e-09, -1.5227076402e-07, -8.3038600809e-08, 3.1451674607e-07, 3.0560461875e-07, -4.7414472197e-07, -7.1344664652e-07, 5.4729249767e-07, 1.3345337879e-06, -4.1411908024e-07, -2.1503702379e-06, -6.7730609307e-08, 3.0752665553e-06, 1.0369490768e-06, -3.9441109092e-06, -2.5917393272e-06, 4.5150864549e-06, 4.7475134143e-06, -4.4925556992e-06, -7.3977634513e-06, 3.5719352305e-06, 1.0288862980e-05, -1.5037239774e-06, -1.3020021999e-05, -1.8319616982e-06, 1.5077178061e-05, 6.3542440290e-06, -1.5904655197e-05, -1.1731733788e-05, 1.5010025995e-05, 1.7370870576e-05, -1.2093540222e-05, -2.2465440684e-05, 7.1692341181e-06, 2.6101583793e-05, -6.6347017736e-07, -2.7427493645e-05, -6.5502791137e-06, 2.5862645853e-05, 1.3203553056e-05, -2.1315589230e-05, -1.7788960192e-05, 1.4365361562e-05, 1.8818518886e-05, -6.3571282800e-06, -1.5161549697e-05, -6.3470726280e-07, 6.4153523800e-06, 4.0077688832e-06, 6.7572023830e-06, -1.0055767748e-06, -2.2401681497e-05, -1.0761669742e-05, 3.7231159861e-05, 3.2698457678e-05, -4.6857746394e-05, -6.4648279447e-05, 4.6257319784e-05, 1.0439498041e-04, -3.0538784936e-05, -1.4744762041e-04, -4.1194931019e-06, 1.8717384318e-04, 5.9468081925e-05, -2.1536110034e-04, -1.3429308052e-04, 2.2320987347e-04, 2.2382058571e-04, -2.0268769877e-04, -3.1960288138e-04, 1.4808674848e-04, 4.1002373826e-04, -5.7556090677e-05, -4.8148375053e-04, -6.5672162942e-05, 5.2021718499e-04, 2.1265064271e-04, -5.1458511810e-04, -3.6898232088e-04, 4.5743723694e-04, 5.1594067106e-04, -3.4845450147e-04, -6.3284066065e-04, 1.9563584933e-04, 7.0014354671e-04, -1.5796557979e-05, -7.0315957907e-04, -1.6636797173e-04, 6.3580185584e-04, 3.2081375427e-04, -5.0377677759e-04, -4.1623063473e-04, 3.2654624631e-04, 4.2536631118e-04, -1.3745450003e-04, -3.3102525622e-04, -1.8435481587e-05, 1.3194471239e-04, 8.8990723306e-05, 1.5239747659e-04, -2.2009993060e-05, -4.7908070285e-04, -2.2613892556e-04, 7.8154948108e-04, 6.8028744618e-04, -9.7378398602e-04, -1.3373405614e-03, 9.5745009823e-04, 2.1580960047e-03, -6.3302489774e-04, -3.0621970894e-03, -8.6264304637e-05, 3.9272393751e-03, 1.2588124290e-03, -4.5929067286e-03, -2.8988711752e-03, 4.8704970947e-03, 4.9623910478e-03, -4.5575895275e-03, -7.3361947492e-03, 3.4569417287e-03, 9.8318979107e-03, -1.3981019529e-03, -1.2185372796e-02, -1.7402352577e-03, 1.4061367508e-02, 6.0081568348e-03, -1.5064588942e-02, -1.1369418643e-02, 1.4747381050e-02, 1.7686097304e-02, -1.2617670336e-02, -2.4711577150e-02, 8.1303143103e-03, 3.2084391795e-02, -6.4501410197e-04, -3.9314469608e-02, -1.0691852300e-02, 4.5733581058e-02, 2.7248590882e-02, -5.0317973069e-02, -5.1712714117e-02, 5.1015735628e-02, 9.0565201435e-02, -4.1604610826e-02, -1.6373680169e-01, -1.0801832278e-02, 3.5636029380e-01, 5.5477465298e-01, 3.5636029380e-01, -1.0801832278e-02, -1.6373680169e-01, -4.1604610826e-02, 9.0565201435e-02, 5.1015735628e-02, -5.1712714117e-02, -5.0317973069e-02, 2.7248590882e-02, 4.5733581058e-02, -1.0691852300e-02, -3.9314469608e-02, -6.4501410197e-04, 3.2084391795e-02, 8.1303143103e-03, -2.4711577150e-02, -1.2617670336e-02, 1.7686097304e-02, 1.4747381050e-02, -1.1369418643e-02, -1.5064588942e-02, 6.0081568348e-03, 1.4061367508e-02, -1.7402352577e-03, -1.2185372796e-02, -1.3981019529e-03, 9.8318979107e-03, 3.4569417287e-03, -7.3361947492e-03, -4.5575895275e-03, 4.9623910478e-03, 4.8704970947e-03, -2.8988711752e-03, -4.5929067286e-03, 1.2588124290e-03, 3.9272393751e-03, -8.6264304637e-05, -3.0621970894e-03, -6.3302489774e-04, 2.1580960047e-03, 9.5745009823e-04, -1.3373405614e-03, -9.7378398602e-04, 6.8028744618e-04, 7.8154948108e-04, -2.2613892556e-04, -4.7908070285e-04, -2.2009993060e-05, 1.5239747659e-04, 8.8990723306e-05, 1.3194471239e-04, -1.8435481587e-05, -3.3102525622e-04, -1.3745450003e-04, 4.2536631118e-04, 3.2654624631e-04, -4.1623063473e-04, -5.0377677759e-04, 3.2081375427e-04, 6.3580185584e-04, -1.6636797173e-04, -7.0315957907e-04, -1.5796557979e-05, 7.0014354671e-04, 1.9563584933e-04, -6.3284066065e-04, -3.4845450147e-04, 5.1594067106e-04, 4.5743723694e-04, -3.6898232088e-04, -5.1458511810e-04, 2.1265064271e-04, 5.2021718499e-04, -6.5672162942e-05, -4.8148375053e-04, -5.7556090677e-05, 4.1002373826e-04, 1.4808674848e-04, -3.1960288138e-04, -2.0268769877e-04, 2.2382058571e-04, 2.2320987347e-04, -1.3429308052e-04, -2.1536110034e-04, 5.9468081925e-05, 1.8717384318e-04, -4.1194931019e-06, -1.4744762041e-04, -3.0538784936e-05, 1.0439498041e-04, 4.6257319784e-05, -6.4648279447e-05, -4.6857746394e-05, 3.2698457678e-05, 3.7231159861e-05, -1.0761669742e-05, -2.2401681497e-05, -1.0055767748e-06, 6.7572023830e-06, 4.0077688832e-06, 6.4153523800e-06, -6.3470726280e-07, -1.5161549697e-05, -6.3571282800e-06, 1.8818518886e-05, 1.4365361562e-05, -1.7788960192e-05, -2.1315589230e-05, 1.3203553056e-05, 2.5862645853e-05, -6.5502791137e-06, -2.7427493645e-05, -6.6347017736e-07, 2.6101583793e-05, 7.1692341181e-06, -2.2465440684e-05, -1.2093540222e-05, 1.7370870576e-05, 1.5010025995e-05, -1.1731733788e-05, -1.5904655197e-05, 6.3542440290e-06, 1.5077178061e-05, -1.8319616982e-06, -1.3020021999e-05, -1.5037239774e-06, 1.0288862980e-05, 3.5719352305e-06, -7.3977634513e-06, -4.4925556992e-06, 4.7475134143e-06, 4.5150864549e-06, -2.5917393272e-06, -3.9441109092e-06, 1.0369490768e-06, 3.0752665553e-06, -6.7730609307e-08, -2.1503702379e-06, -4.1411908024e-07, 1.3345337879e-06, 5.4729249767e-07, -7.1344664652e-07, -4.7414472197e-07, 3.0560461875e-07, 3.1451674607e-07, -8.3038600809e-08, -1.5227076402e-07, -6.3003569993e-09, 3.2746632870e-08, 1.8626836798e-08, 3.0932259829e-08, -7.9378833862e-10, -4.7319529752e-08, -1.6476201324e-08}
  COEFFICIENT_WIDTH 32
  QUANTIZATION Maximize_Dynamic_Range
  BESTPRECISION true
  FILTER_TYPE Decimation
  DECIMATION_RATE 2
  NUMBER_CHANNELS 16
  NUMBER_PATHS 1
  SAMPLE_FREQUENCY 0.00075
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
