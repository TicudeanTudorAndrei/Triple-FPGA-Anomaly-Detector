library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fp_clasif is
port ( aclk: in STD_LOGIC;
s_axis_tvalid: in STD_LOGIC;
s_axis_tready: out STD_LOGIC;
s_axis_tdata: in STD_LOGIC_VECTOR(31 downto 0);

pS_axis_tvalid: in STD_LOGIC;
pS_axis_tready: out STD_LOGIC;
pS_axis_tdata: in STD_LOGIC_VECTOR(31 downto 0);

m_axis_tvalid: out STD_LOGIC;
m_axis_tready: in STD_LOGIC;
m_axis_tdata : out STD_LOGIC_VECTOR(7 downto 0));
end entity;

architecture fp_clasif_arch of fp_clasif is

component fp_abs
port ( s_axis_a_tvalid: in STD_LOGIC;
s_axis_a_tready: out STD_LOGIC;
s_axis_a_tdata: in STD_LOGIC_VECTOR(31 downto 0);
m_axis_result_tvalid: out STD_LOGIC;
m_axis_result_tready: in STD_LOGIC;
m_axis_result_tdata : out STD_LOGIC_VECTOR(31 downto 0));
end component;

component fp_comp
port ( aclk: in STD_LOGIC;
s_axis_a_tvalid: in STD_LOGIC;
s_axis_a_tready: out STD_LOGIC;
s_axis_a_tdata: in STD_LOGIC_VECTOR(31 downto 0);
s_axis_b_tvalid: in STD_LOGIC;
s_axis_b_tready: out STD_LOGIC;
s_axis_b_tdata: in STD_LOGIC_VECTOR(31 downto 0);
m_axis_result_tvalid: out STD_LOGIC;
m_axis_result_tready: in STD_LOGIC;
m_axis_result_tdata : out STD_LOGIC_VECTOR(7 downto 0));
end component;

signal abs1_tvalid: STD_LOGIC := '0';
signal abs1_tready: STD_LOGIC := '0';
signal abs1_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

signal abs2_tvalid: STD_LOGIC := '0';
signal abs2_tready: STD_LOGIC := '0';
signal abs2_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

begin

fp_abs_inst_1: fp_abs
port map ( s_axis_a_tvalid => s_axis_tvalid,
s_axis_a_tready => s_axis_tready,
s_axis_a_tdata => s_axis_tdata,
m_axis_result_tvalid => abs1_tvalid,
m_axis_result_tready => abs1_tready,
m_axis_result_tdata  => abs1_tdata);

fp_abs_inst_2: fp_abs
port map ( s_axis_a_tvalid => pS_axis_tvalid,
s_axis_a_tready => pS_axis_tready,
s_axis_a_tdata => pS_axis_tdata,
m_axis_result_tvalid => abs2_tvalid,
m_axis_result_tready => abs2_tready,
m_axis_result_tdata  => abs2_tdata);

fp_comp_inst: fp_comp
port map ( aclk => aclk,
s_axis_a_tvalid => abs1_tvalid,
s_axis_a_tready => abs1_tready,
s_axis_a_tdata => abs1_tdata,
s_axis_b_tvalid => abs2_tvalid,
s_axis_b_tready => abs2_tready,
s_axis_b_tdata => abs2_tdata,
m_axis_result_tvalid => m_axis_tvalid,
m_axis_result_tready => m_axis_tready,
m_axis_result_tdata  => m_axis_tdata);

end architecture;
