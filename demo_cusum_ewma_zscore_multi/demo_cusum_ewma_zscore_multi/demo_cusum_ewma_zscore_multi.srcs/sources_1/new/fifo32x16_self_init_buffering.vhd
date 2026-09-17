library IEEE;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity fifo32x16_self_init_buffering is
port ( s_axis_aresetn: in STD_LOGIC;
s_axis_aclk: in STD_LOGIC;

s0_data: in STD_LOGIC_VECTOR(31 downto 0);

s_axis_tvalid: in STD_LOGIC;
s_axis_tready: out STD_LOGIC;
s_axis_tdata: in STD_LOGIC_VECTOR(31 downto 0);

m_axis_tvalid: out STD_LOGIC;
m_axis_tready: in STD_LOGIC;
m_axis_tdata: out STD_LOGIC_VECTOR(31 downto 0));
end fifo32x16_self_init_buffering;

architecture fifo32x16_self_init_buffering_arch of fifo32x16_self_init_buffering is

component fifo32x16_buffering is
port ( s_axis_aresetn: in STD_LOGIC;
s_axis_aclk: in STD_LOGIC;

s_axis_tvalid: in STD_LOGIC;
s_axis_tready: out STD_LOGIC;
s_axis_tdata: in STD_LOGIC_VECTOR(31 downto 0);

m_axis_tvalid: out STD_LOGIC;
m_axis_tready: in STD_LOGIC;
m_axis_tdata: out STD_LOGIC_VECTOR(31 downto 0));
end component;

signal is_first: STD_LOGIC := '1';

signal s_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal s_tvalid: STD_LOGIC := '0';
signal s_tready: STD_LOGIC := '0';

signal m_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal m_tvalid: STD_LOGIC := '0';
signal m_tready: STD_LOGIC := '0';

begin

fifo_x_inst: fifo32x16_buffering
port map ( s_axis_aresetn => s_axis_aresetn,
s_axis_aclk => s_axis_aclk,

s_axis_tvalid => s_tvalid,
s_axis_tready => s_tready,
s_axis_tdata => s_tdata,
            
m_axis_tvalid => m_tvalid,
m_axis_tready => m_tready,
m_axis_tdata => m_tdata);

m_axis_tvalid <= m_tvalid;
m_axis_tdata <= m_tdata;

with is_first select
    s_tdata <= s0_data when '1',
               s_axis_tdata when others;
               
with is_first select
    s_tvalid <= '1'when '1',
                s_axis_tvalid when others; 
                
with is_first select
    s_axis_tready <= '0' when '1',
                     s_tready when others;
                     
with is_first select
    m_tready <= '0' when '1',
                m_axis_tready when others;                                                   
    
process(s_axis_aclk)
begin
    if rising_edge(s_axis_aclk) then
        if s_axis_aresetn = '0' then
            is_first <= '1';
        else
            if is_first = '1' and s_tready = '1' then
                is_first <= '0';
            end if;
        end if;
    end if;
end process;
    
end architecture;
