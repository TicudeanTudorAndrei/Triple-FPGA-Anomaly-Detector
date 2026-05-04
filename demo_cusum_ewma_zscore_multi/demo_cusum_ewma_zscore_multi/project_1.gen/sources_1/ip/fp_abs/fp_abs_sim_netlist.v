// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Tue Feb 17 18:45:45 2026
// Host        : DESKTOP-LU6EQ9E running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               e:/VivadoProjects/demo_cusum_ewma_zscore_multi/demo_cusum_ewma_zscore_multi/project_1.gen/sources_1/ip/fp_abs/fp_abs_sim_netlist.v
// Design      : fp_abs
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "fp_abs,floating_point_v7_1_15,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "floating_point_v7_1_15,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module fp_abs
   (s_axis_a_tvalid,
    s_axis_a_tready,
    s_axis_a_tdata,
    m_axis_result_tvalid,
    m_axis_result_tready,
    m_axis_result_tdata);
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_A TVALID" *) input s_axis_a_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_A TREADY" *) output s_axis_a_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_A TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS_A, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) input [31:0]s_axis_a_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_RESULT TVALID" *) output m_axis_result_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_RESULT TREADY" *) input m_axis_result_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS_RESULT TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS_RESULT, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, LAYERED_METADATA undef, INSERT_VIP 0" *) output [31:0]m_axis_result_tdata;

  wire \<const0> ;
  wire [30:0]\^m_axis_result_tdata ;
  wire m_axis_result_tready;
  wire m_axis_result_tvalid;
  wire [31:0]s_axis_a_tdata;
  wire s_axis_a_tready;
  wire s_axis_a_tvalid;
  wire NLW_inst_m_axis_result_tlast_UNCONNECTED;
  wire NLW_inst_s_axis_b_tready_UNCONNECTED;
  wire NLW_inst_s_axis_c_tready_UNCONNECTED;
  wire NLW_inst_s_axis_operation_tready_UNCONNECTED;
  wire [31:31]NLW_inst_m_axis_result_tdata_UNCONNECTED;
  wire [0:0]NLW_inst_m_axis_result_tuser_UNCONNECTED;

  assign m_axis_result_tdata[31] = \<const0> ;
  assign m_axis_result_tdata[30:0] = \^m_axis_result_tdata [30:0];
  GND GND
       (.G(\<const0> ));
  (* C_ACCUM_INPUT_MSB = "32" *) 
  (* C_ACCUM_LSB = "-31" *) 
  (* C_ACCUM_MSB = "32" *) 
  (* C_A_FRACTION_WIDTH = "24" *) 
  (* C_A_TDATA_WIDTH = "32" *) 
  (* C_A_TUSER_WIDTH = "1" *) 
  (* C_A_WIDTH = "32" *) 
  (* C_BRAM_USAGE = "0" *) 
  (* C_B_FRACTION_WIDTH = "24" *) 
  (* C_B_TDATA_WIDTH = "32" *) 
  (* C_B_TUSER_WIDTH = "1" *) 
  (* C_B_WIDTH = "32" *) 
  (* C_COMPARE_OPERATION = "8" *) 
  (* C_C_FRACTION_WIDTH = "24" *) 
  (* C_C_TDATA_WIDTH = "32" *) 
  (* C_C_TUSER_WIDTH = "1" *) 
  (* C_C_WIDTH = "32" *) 
  (* C_FIXED_DATA_UNSIGNED = "0" *) 
  (* C_HAS_ABSOLUTE = "1" *) 
  (* C_HAS_ACCUMULATOR_A = "0" *) 
  (* C_HAS_ACCUMULATOR_PRIMITIVE_A = "0" *) 
  (* C_HAS_ACCUMULATOR_PRIMITIVE_S = "0" *) 
  (* C_HAS_ACCUMULATOR_S = "0" *) 
  (* C_HAS_ACCUM_INPUT_OVERFLOW = "0" *) 
  (* C_HAS_ACCUM_OVERFLOW = "0" *) 
  (* C_HAS_ACLKEN = "0" *) 
  (* C_HAS_ADD = "0" *) 
  (* C_HAS_ARESETN = "0" *) 
  (* C_HAS_A_TLAST = "0" *) 
  (* C_HAS_A_TUSER = "0" *) 
  (* C_HAS_B = "0" *) 
  (* C_HAS_B_TLAST = "0" *) 
  (* C_HAS_B_TUSER = "0" *) 
  (* C_HAS_C = "0" *) 
  (* C_HAS_COMPARE = "0" *) 
  (* C_HAS_C_TLAST = "0" *) 
  (* C_HAS_C_TUSER = "0" *) 
  (* C_HAS_DIVIDE = "0" *) 
  (* C_HAS_DIVIDE_BY_ZERO = "0" *) 
  (* C_HAS_EXPONENTIAL = "0" *) 
  (* C_HAS_FIX_TO_FLT = "0" *) 
  (* C_HAS_FLT_TO_FIX = "0" *) 
  (* C_HAS_FLT_TO_FLT = "0" *) 
  (* C_HAS_FMA = "0" *) 
  (* C_HAS_FMS = "0" *) 
  (* C_HAS_INVALID_OP = "0" *) 
  (* C_HAS_LOGARITHM = "0" *) 
  (* C_HAS_MULTIPLY = "0" *) 
  (* C_HAS_OPERATION = "0" *) 
  (* C_HAS_OPERATION_TLAST = "0" *) 
  (* C_HAS_OPERATION_TUSER = "0" *) 
  (* C_HAS_OVERFLOW = "0" *) 
  (* C_HAS_RECIP = "0" *) 
  (* C_HAS_RECIP_SQRT = "0" *) 
  (* C_HAS_RESULT_TLAST = "0" *) 
  (* C_HAS_RESULT_TUSER = "0" *) 
  (* C_HAS_SQRT = "0" *) 
  (* C_HAS_SUBTRACT = "0" *) 
  (* C_HAS_UNDERFLOW = "0" *) 
  (* C_HAS_UNFUSED_MULTIPLY_ACCUMULATOR_A = "0" *) 
  (* C_HAS_UNFUSED_MULTIPLY_ACCUMULATOR_S = "0" *) 
  (* C_HAS_UNFUSED_MULTIPLY_ADD = "0" *) 
  (* C_HAS_UNFUSED_MULTIPLY_SUB = "0" *) 
  (* C_LATENCY = "0" *) 
  (* C_MULT_USAGE = "0" *) 
  (* C_OPERATION_TDATA_WIDTH = "8" *) 
  (* C_OPERATION_TUSER_WIDTH = "1" *) 
  (* C_OPTIMIZATION = "1" *) 
  (* C_PART = "xc7a100tcsg324-1" *) 
  (* C_RATE = "1" *) 
  (* C_RESULT_FRACTION_WIDTH = "24" *) 
  (* C_RESULT_TDATA_WIDTH = "32" *) 
  (* C_RESULT_TUSER_WIDTH = "1" *) 
  (* C_RESULT_WIDTH = "32" *) 
  (* C_THROTTLE_SCHEME = "1" *) 
  (* C_TLAST_RESOLUTION = "0" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* KEEP_HIERARCHY = "soft" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  fp_abs_floating_point_v7_1_15 inst
       (.aclk(1'b0),
        .aclken(1'b1),
        .aresetn(1'b1),
        .m_axis_result_tdata({NLW_inst_m_axis_result_tdata_UNCONNECTED[31],\^m_axis_result_tdata }),
        .m_axis_result_tlast(NLW_inst_m_axis_result_tlast_UNCONNECTED),
        .m_axis_result_tready(m_axis_result_tready),
        .m_axis_result_tuser(NLW_inst_m_axis_result_tuser_UNCONNECTED[0]),
        .m_axis_result_tvalid(m_axis_result_tvalid),
        .s_axis_a_tdata({1'b0,s_axis_a_tdata[30:0]}),
        .s_axis_a_tlast(1'b0),
        .s_axis_a_tready(s_axis_a_tready),
        .s_axis_a_tuser(1'b0),
        .s_axis_a_tvalid(s_axis_a_tvalid),
        .s_axis_b_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_b_tlast(1'b0),
        .s_axis_b_tready(NLW_inst_s_axis_b_tready_UNCONNECTED),
        .s_axis_b_tuser(1'b0),
        .s_axis_b_tvalid(1'b0),
        .s_axis_c_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_c_tlast(1'b0),
        .s_axis_c_tready(NLW_inst_s_axis_c_tready_UNCONNECTED),
        .s_axis_c_tuser(1'b0),
        .s_axis_c_tvalid(1'b0),
        .s_axis_operation_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_operation_tlast(1'b0),
        .s_axis_operation_tready(NLW_inst_s_axis_operation_tready_UNCONNECTED),
        .s_axis_operation_tuser(1'b0),
        .s_axis_operation_tvalid(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2022.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
mmOvRnJo0hx7+PqMGu3YoWxrEBYAxAdZi1zk+yzEFiZIJMjePV38Oa31uE0BaogpqUs7AS9njISN
GZXX2Xcd9eCF9tXyfpnThXpwLDha12v0ZRAsGKJHWGpBuDMZg6FXSDy2oeRxKIQMa0luoKI0vLk0
yZbC4dlqmTYczcsfIuQ=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
fc8cpYYv5vI/H3z7pnHmVqePZADreJdu3RKVQcBi8nZYms7mT9oN5x0NgM+DUuXRd1Z7x8HYKYeE
kFyxlHaCo/HIJiqVA+2bOXqsng8BbIFNN+FiN3UgJaewkE9dTJVd/ROEVhqxJON57Tx6IVhV0WmJ
cWPYhMeEYFid4FpJ0H3xsk+KcoW4L+xz+/UK9Z+xiowEJep7aUN038Ga9jglCTb40A35B8+G1HZS
h9D3sOXIpp8/2ejcwVIcjIhUkppN+xHEnunW6OkL9vh91/NWQS/u+lphwOKOX+WDuHIngd1xnvKt
+i5AmVHnptjvzDMKlW6nFgNnkugxOVQma/k9HQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
DUm+EfBkI7e/sY7EMLDsRVZLuEfIgjt3sfz7ShHtswxkS45dBAv5l/yiKPu9/6DM/iz80pGT45/K
2/hjeTM9CVgsalBokhtLjhdSW6RJFxVp6ZKD9jR7RvDnnrEaAJd+02jPK9YzTdRbTzm0sMHn5mLU
ztqja0MbixEZImt/93U=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
L0pKmZTGbWTdrIwcHYZ2dWbmD42xIJQXnGlG8XhayhBFtlOYgMREvK9vlHyPS4Isiz6mTW2yh6Qv
OPeDuapEOxbUo7SjK03RgNomPPKnMz5ZpZ4FfhJ56GCAA426m/cAckB5Ni0EugOisw15S0O3/HKb
qWmEcBkcQksqvkCitstRfS8T9LvOXQXTpDNIeo+gEPlQmIe7mfCp8xAJ5TzZDXLLRsK7lSeDj6qp
FCzCOerPsmRxTazCLJBRiRlMrDyjDjq2SYXmTSicf939s/rv31mpdYo4WdsKpJp1c9z8BxTjK1/x
pFKn1uL9i5TBnnp2PTTzxJgbND1J9nSw36/6CQ==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
4qHn9m5I5jLdIM/fNCqj608HG58k8mMnLL06oke1tI/TPvZ4Kl/RtSd3S+PLIQKxCTyojQBz/kAO
QIzZweo20v/r7iTHLCrsHEXDtFvI78WHwMbz9lg9BDszKLVO+U7VGTdmQrQC9aeYX/M0r/2qDSi1
WycGOpmo3WneDM6hA+pcMjs+byYGYKKNcRISNPkEblobug+u53AdSy7+DOQmJrXef1lUjI6L7/HK
hUtNHd3Qx/d5CwEC58xLAeM2kn57vUXKlTSUsUjVVEol3T7lv84kKHb5yrrcb8lHxV2IojdMO2o1
n9v7EbOJK/7G3Osc9osF+JcJad6wPIsa46INFw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_07", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
ETbRXS7YQk/Ygxv+Qi9wEi7T+hk+MEMZI95u/c2eFw/pb27fXDUGP48hiMfCyAWlfuwwUH3fQPbz
khlm0LIUo6Xael/yAbJaAcaV66Am02ja53+YiCngXT9RVFQyefaIP/7YcAcFRYW3SxQK5rpXQeBK
Mj9avK2LlvOh+LjIUDQUUQnoZ0qftB72dPfopDt7GDpONMtf8aFY7I2aMTiQLt6NDkPJ5avK+R1b
rLXyWH898NyGxmRWkl0zw0637JVrYNxDIRPMv0uA3ujUDE5JX4TnBweHtgPk6MyO2/pikczw2iP3
l9uU2u8K1wHGqYv32+CcE2yLLNDxLF+4zBT/8g==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
DGTJq6GIxpJpCyrcF3lPti11wrEojytsyrjbNsuQDbI/UwSi2ip7dvKR7MkXC8HGDqQ5vPbQSOuR
UY3Xniav28PBFc2qZMK07SKE02Z5QhaTju1tIy6ACa8GVuTGGquCC58NNupc4u/zPB+HeQTXDlrW
r3YrSeCS3VSSwjICQ8HL9+z9e4LSbJtq65BiAlS8V7qn/ENrhwkPWY5FPdBs9Y+C3UdMV/xI5IAA
a8hqPWQswv9vZDRxH/dXI+eklyMbwzbwRZCV1KTx5P5t5VUhFXDehns8OcYJoO7M8kmK7MIpsw2P
2diAjrDolQU/urY1X7gEiYnz3/3fdkLF9ARawQ==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
MqYYWpi5cUKxeqegUOZ/FE71PbGIeBKRaebYLZrsAQMHxp7rX2HLBfghj8DkaLpBvFZsRe3QHQKz
7J1EMjkJRnAZ99lDMCh1BUBj9yoG3aflK5SgQS3f8wlsLqzxJQbBRYVv77/LYvZT2OjIBhwl+6FU
aRzgPT7kw+CouWg5nRmaPHQpuF7RDIGYw3iAEgHi5JqIhbys9ADrgHdVkby+d1nfJ1QzimhoiEDF
nR2tfpELYmQO6yMjac1NMKwqamfGQ7sv7BCChIwYRvW9l2fN2Yp+2i05nuVSfAyEHC9Z7nSdSPmO
kwN5VI8z8fnBCE/0cAwavWW8BKo3rvlv6KOQXDuNYHOmb8oArzgg3a5htizGcx9BfdyK/+3Pd7u5
iNn4SGpLSWsRwMYQcGbNHsXPsWpEiVtHxs06Tc1S9Arn09eWIggn++2/3CDDG+nYQrcSlMaKtTmX
rbG7zsJpirzPDalNQh3HiAK+ZU+lVyaiMY86sPq6VhY43uq9Z78kF01R

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
j8OUn7H0onPT0+ubA7jLFo+cW7C6hcKI39ZZ2/bHcowL1pbZqDp3KOJxwRqSNOB7aXQ3QKJvcel+
COdVz2X4+AsoLGzifagtsIFiRDNQ2ivmE7jUyJmsfO8F1cLTi2Ezd8szMAP9Q4wvU8Vazm4bGNLk
NceiyiGaMhtt4pPVY4RvuoRdCt3Ic9/usyfgfyjZSgIqc+oT36/FtQPznhXEiWcoc3P3rILT1LfZ
lFz11X3JH70rU3hNTPjhbmy4OtvUpx0hqViwWvMIOHoDuS1aqZegrgD/qnOb+XPD4U3gzoaEu1oj
KOFl4N48DoB8AvG8tlxSJLWw7OYcwucfAsGsGw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Nk67071xqauILwugiwP8EtIKmKWHvYj1MR2AAnCjpnoRvkcRpKoso6SZQJe/MBzGjRaF6JnEdx3D
zaBXg6T9pMoRvlTyJR8JGrI5MwMHn1BsSLFGSUnZo+vOjtgU2UmctbauYEd+hofhRHKZM6armgDg
T8614MfvdDMIXjQlBjDMSwvXTKVwvuDOA47XvpQGx3NyjNx900eNRtq4GdRlwMxMQpqhV+L4e8aV
6b8x6RKhrzAhIBOnygBJiN3HrAVnde8w3grEnkSl03TbvDq51PZbkbNBL/9tcRgIcfx/31zipPm0
gG/lqiXJPRJki+W4hrODH7awStUMEAlG1xtxgQ==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
geQE6ns3MrHF9tAB3kuKO2D49GoelMuAz0FQA8BKh0H344HueuGGJWf7spPbWh89mhxQ1wRkxJ9X
iWYm5h7vsQ8YUPBVVHRiPAhCMlYNcjwD7oKSfJMYQqjd06lGJipgxXJiXHSJr1tBMlr/ruIQHrB/
tE6bvbMCF5ly70jJphAMCuXhKJ8bSwNlfhZlX1+bM26LzzoRGxaFTeAgLoo5I5hVvHZrED+gPQaK
DdLRuy7bIZZSGs5Viz8APoRuo2/EKw26WEf9qdlqovwpwxh/R4AZD+Q7jP6a+Gn5OU2jkFYcuu1z
r1TA9D3pC6pzvICy95FfUiM0Fha8OBVVTZs0ng==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 13712)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
