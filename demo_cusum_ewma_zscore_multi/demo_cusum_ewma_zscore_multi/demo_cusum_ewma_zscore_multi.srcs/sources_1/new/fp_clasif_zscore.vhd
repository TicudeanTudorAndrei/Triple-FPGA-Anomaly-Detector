library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fp_clasif_zscore is
port ( aclk: in STD_LOGIC;
s_axis_tvalid: in STD_LOGIC;
s_axis_tready: out STD_LOGIC;
s_axis_tdata: in STD_LOGIC_VECTOR(31 downto 0);

m_axis_tvalid: out STD_LOGIC;
m_axis_tready: in STD_LOGIC;
m_axis_tdata : out STD_LOGIC_VECTOR(7 downto 0));
end entity;

architecture fp_clasif_zscore_arch of fp_clasif_zscore is

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

signal abs_tvalid: STD_LOGIC := '0';
signal abs_tready: STD_LOGIC := '0';
signal abs_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

signal comp_b_tready: STD_LOGIC := '0';

begin

fp_abs_inst: fp_abs
port map ( s_axis_a_tvalid => s_axis_tvalid,
s_axis_a_tready => s_axis_tready,
s_axis_a_tdata => s_axis_tdata,
m_axis_result_tvalid => abs_tvalid,
m_axis_result_tready => abs_tready,
m_axis_result_tdata  => abs_tdata);

fp_comp_inst: fp_comp
port map ( aclk => aclk,
s_axis_a_tvalid => abs_tvalid,
s_axis_a_tready => abs_tready,
s_axis_a_tdata => abs_tdata,
s_axis_b_tvalid => '1',
s_axis_b_tready => comp_b_tready,
s_axis_b_tdata => x"40400000", -- 3
m_axis_result_tvalid => m_axis_tvalid,
m_axis_result_tready => m_axis_tready,
m_axis_result_tdata  => m_axis_tdata);

end architecture;
