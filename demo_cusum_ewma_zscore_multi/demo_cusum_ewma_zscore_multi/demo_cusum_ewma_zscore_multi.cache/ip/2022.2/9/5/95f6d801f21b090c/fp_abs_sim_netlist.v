// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (win64) Build 3671981 Fri Oct 14 05:00:03 MDT 2022
// Date        : Tue Feb 17 18:45:44 2026
// Host        : DESKTOP-LU6EQ9E running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ fp_abs_sim_netlist.v
// Design      : fp_abs
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "fp_abs,floating_point_v7_1_15,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "floating_point_v7_1_15,Vivado 2022.2" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_floating_point_v7_1_15 inst
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
X1ZmByxRTTWzncyr3apdkQ0Y6C/vyFcHerS5PsPDfVik/+VikYmOr6x4oTeQMGbR37uoHLVFTJmS
2yVwzQ3bDO96JyQVrujuvMH/I9PgpNDRj2i53JzJgIqL51UYCjz03obHKssfbIUCFzM7jPaJt60w
0w70jcy5TuuStzzsRb9trzHw2EEEL4XL9GavpdlsCIpCP6fBuORV5QH7wvAznkTQ9vLHYZjXfpXq
1Tzd57JF/wJd+ZWIxkA7e/mCs2AOopBTvQp9RwkasPDGrjl7O2tdoN3zfr0GRzrH+/b/qkyxbAEf
35epjvI8Xi9PwZbTxxnBnNo7YzJ41xnmKv2Uog==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
et9vagXiaCTjA1mIOP8uK4qeeHTe3gBVwHuUveI/y4aGBvDhCKWB08WvyvkWXdWGdxyOP9uPWmIX
+vXKIRuyxfJqpQfUEXqG2dvyFPvJj6mmVTIyF1cSgACNq+WFG9TMzdO52wYV6cXIOhXQ8M8CYIRw
57m7T3yGx08VKaKmQueea4u2BTdj+HsNAoe7rrllqhQIfQ0eAl8I1gqpAEFjYy4kcyK1OnasuMlr
RVmjcIfxzNcUQeKccozG3+ojIW7atJ479Nv7j2ok76YURfF2codOOBLm3csZK3Neeg3zfiUoU+ui
2T1PM5c042EdX8//5ylq+7sLs1AKLsImgnKEkg==

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
