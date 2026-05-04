library IEEE;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity zscore is
generic ( NUM_STREAMS: integer := 2;
SAMPLE_SIZE_INT : integer := 64;
SAMPLE_SIZE_HEX: STD_LOGIC_VECTOR(31 downto 0) := x"42800000");
port ( aclk: in STD_LOGIC;
aresetn: in STD_LOGIC;
        
x_tvalid: in STD_LOGIC;
x_tdata: in STD_LOGIC_VECTOR(31 downto 0);
x_tready: out STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0);
x_id: in STD_LOGIC_VECTOR(15 downto 0); 
 
anomaly_tvalid: out STD_LOGIC;
anomaly_tdata: out STD_LOGIC_VECTOR(7 downto 0);
anomaly_tready: in STD_LOGIC;       
anomaly_id: out STD_LOGIC_VECTOR(15 downto 0); 

init_complete: out STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0));
end entity;

architecture zscore_arh of zscore is

component mean is
generic ( NUM_STREAMS: integer := 2; 
SAMPLE_SIZE_INT: integer := 64;
SAMPLE_SIZE_HEX: STD_LOGIC_VECTOR(31 downto 0) := x"42800000");
port ( aclk: in STD_LOGIC;
aresetn: in STD_LOGIC;

x_tvalid: in STD_LOGIC;
x_tready: out STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0);
x_tdata: in STD_LOGIC_VECTOR(31 downto 0);
x_id: in STD_LOGIC_VECTOR(15 downto 0);

mean_tvalid: out STD_LOGIC;
mean_tready: in STD_LOGIC;
mean_tdata: out STD_LOGIC_VECTOR(31 downto 0);
mean_id: out STD_LOGIC_VECTOR(15 downto 0);
init_complete: out STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0));
end component;

component std_dev is
generic ( NUM_STREAMS: integer := 2;
SAMPLE_SIZE_INT : integer := 64;
SAMPLE_SIZE_HEX: STD_LOGIC_VECTOR(31 downto 0) := x"42800000");
port ( aclk: in STD_LOGIC;
aresetn: in STD_LOGIC;
        
x_tvalid: in STD_LOGIC;
x_tdata: in STD_LOGIC_VECTOR(31 downto 0);
x_tready: out STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0);
x_id: in STD_LOGIC_VECTOR(15 downto 0);
        
mean_tvalid: in STD_LOGIC;
mean_tdata: in STD_LOGIC_VECTOR(31 downto 0);
mean_tready: out STD_LOGIC;
mean_id: in STD_LOGIC_VECTOR(15 downto 0);
  
std_dev_tvalid: out STD_LOGIC;
std_dev_tdata: out STD_LOGIC_VECTOR(31 downto 0);
std_dev_tready: in STD_LOGIC;
std_dev_id: out STD_LOGIC_VECTOR(15 downto 0);

x_minus_mean_tvalid: out STD_LOGIC;
x_minus_mean_tdata: out STD_LOGIC_VECTOR(31 downto 0);
x_minus_mean_tready: in STD_LOGIC;
x_minus_mean_id: out STD_LOGIC_VECTOR(15 downto 0);

mean_init_comp: in STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0);
init_complete: out STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0));
end component;

component fp_div_buffering is
port ( aclk: in STD_LOGIC;
aresetn: in STD_LOGIC;

s_axis_a_tvalid: in STD_LOGIC;
s_axis_a_tready: out STD_LOGIC;
s_axis_a_tdata: in STD_LOGIC_VECTOR(31 downto 0);

s_axis_b_tvalid: in STD_LOGIC;
s_axis_b_tready: out STD_LOGIC;
s_axis_b_tdata: in STD_LOGIC_VECTOR(31 downto 0);

m_axis_result_tvalid: out STD_LOGIC;
m_axis_result_tready: in STD_LOGIC;
m_axis_result_tdata: out STD_LOGIC_VECTOR(31 downto 0));
end component;

component fp_clasif_zscore is
port ( aclk: in STD_LOGIC;
s_axis_tvalid: in STD_LOGIC;
s_axis_tready: out STD_LOGIC;
s_axis_tdata: in STD_LOGIC_VECTOR(31 downto 0);

m_axis_tvalid: out STD_LOGIC;
m_axis_tready: in STD_LOGIC;
m_axis_tdata : out STD_LOGIC_VECTOR(7 downto 0));
end component;

signal std_dev_tvalid: STD_LOGIC := '0';
signal std_dev_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal std_dev_init_complete: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0);
signal std_dev_id_signal: STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); 

signal div_a_tready: STD_LOGIC := '0';
signal div_b_tready: STD_LOGIC := '0';
signal clasif_tready: STD_LOGIC := '0';

signal mean_tready: STD_LOGIC := '0';
signal mean_id: STD_LOGIC_VECTOR(15 downto 0); 
signal mean_tvalid_signal: STD_LOGIC := '0';
signal mean_tvalid: STD_LOGIC := '0';
signal mean_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal mean_init_complete: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0);
signal mean_tready_signals: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');

signal x_minus_mean_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal x_minus_mean_tvalid: STD_LOGIC := '0';
signal x_minus_mean_id_signal: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

signal x_tready_mean: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal x_tready_std: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');

signal ready_mean_select : integer range 0 to NUM_STREAMS-1 := 0;

signal anomaly_tvalid_signal: STD_LOGIC := '0';
signal anomaly_id_signal: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

constant ANOM_ID_DEPTH : integer := 64;
type anom_id_fifo_t is array(0 to ANOM_ID_DEPTH-1) of integer range 0 to NUM_STREAMS-1;
signal anom_id_fifo : anom_id_fifo_t := (others => 0);
signal anom_id_wr   : integer range 0 to ANOM_ID_DEPTH-1 := 0;
signal anom_id_rd   : integer range 0 to ANOM_ID_DEPTH-1 := 0;

signal zscore_m_tvalid: STD_LOGIC := '0';
signal zscore_m_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

begin

init_complete <= std_dev_init_complete;
anomaly_tvalid <= anomaly_tvalid_signal;

anomaly_id <= anomaly_id_signal;

mean_inst: mean
generic map ( NUM_STREAMS => NUM_STREAMS,
SAMPLE_SIZE_INT => SAMPLE_SIZE_INT,
SAMPLE_SIZE_HEX => SAMPLE_SIZE_HEX)
port map ( aclk => aclk,
aresetn => aresetn,

x_tvalid => x_tvalid,
x_tready => x_tready_mean,
x_tdata => x_tdata,
x_id => x_id,

mean_tvalid => mean_tvalid,
mean_tready => '1',
mean_tdata => mean_tdata,
mean_id => mean_id,

init_complete => mean_init_complete);

-- select tready signal for mean
-- process(aclk, mean_tvalid)
-- begin
-- if rising_edge(aclk) or mean_tvalid'event then
    -- if mean_tvalid = '1' then
        --mean_tready <= mean_tready_signals(ready_mean_select); 
        
        -- if ready_mean_select = NUM_STREAMS-1 then
            -- ready_mean_select <= 0;
        -- else
            -- ready_mean_select <= ready_mean_select + 1;
        -- end if;    
    -- end if;
-- end if;    
-- end process;

-- AND x_tready
process(x_tready_mean, x_tready_std)
begin
    for i in 0 to NUM_STREAMS-1 loop
        x_tready(i) <= x_tready_mean(i) and x_tready_std(i);      
    end loop;
end process;

std_dev_inst: std_dev
generic map ( NUM_STREAMS => NUM_STREAMS,
SAMPLE_SIZE_INT => SAMPLE_SIZE_INT,
SAMPLE_SIZE_HEX => SAMPLE_SIZE_HEX)
port map ( aclk => aclk,
aresetn => aresetn,
        
x_tvalid => x_tvalid,
x_tdata => x_tdata,
x_tready => x_tready_std,
x_id => x_id,
        
mean_tvalid => mean_tvalid,
mean_tdata => mean_tdata,
mean_tready => mean_tready,
mean_id => mean_id,
        
std_dev_tvalid => std_dev_tvalid,
std_dev_tdata => std_dev_tdata,
std_dev_tready => div_b_tready,
std_dev_id => std_dev_id_signal,

x_minus_mean_tvalid => x_minus_mean_tvalid,
x_minus_mean_tdata => x_minus_mean_tdata,
x_minus_mean_tready => div_a_tready,
x_minus_mean_id => x_minus_mean_id_signal,

mean_init_comp => mean_init_complete,
init_complete => std_dev_init_complete);

div_inst: fp_div_buffering
port map ( aclk => aclk,
aresetn => aresetn,

s_axis_a_tvalid => x_minus_mean_tvalid,
s_axis_a_tready => div_a_tready,
s_axis_a_tdata => x_minus_mean_tdata,

s_axis_b_tvalid => std_dev_tvalid,
s_axis_b_tready => div_b_tready,
s_axis_b_tdata => std_dev_tdata,

m_axis_result_tvalid => zscore_m_tvalid,
m_axis_result_tready => clasif_tready,
m_axis_result_tdata => zscore_m_tdata);

clasif_inst: fp_clasif_zscore
port map ( aclk => aclk,

s_axis_tvalid => zscore_m_tvalid,
s_axis_tready => clasif_tready,
s_axis_tdata => zscore_m_tdata,

m_axis_tvalid => anomaly_tvalid_signal,
m_axis_tready => anomaly_tready,
m_axis_tdata => anomaly_tdata);

process(aclk)
begin
    if rising_edge(aclk) then
        if aresetn = '0' then
            anom_id_wr <= 0;
            anom_id_rd <= 0;
        else
            if x_minus_mean_tvalid = '1' and div_a_tready = '1' then
                anom_id_fifo(anom_id_wr) <= conv_integer(x_minus_mean_id_signal);
                if anom_id_wr = ANOM_ID_DEPTH - 1 then anom_id_wr <= 0;
                else anom_id_wr <= anom_id_wr + 1; end if;
            end if;

            if anomaly_tvalid_signal = '1' and anomaly_tready = '1' then
                if anom_id_rd = ANOM_ID_DEPTH - 1 then anom_id_rd <= 0;
                else anom_id_rd <= anom_id_rd + 1; end if;
            end if;
        end if;
    end if;
end process;

anomaly_id_signal <= std_logic_vector(to_unsigned(anom_id_fifo(anom_id_rd), 16));

end architecture;