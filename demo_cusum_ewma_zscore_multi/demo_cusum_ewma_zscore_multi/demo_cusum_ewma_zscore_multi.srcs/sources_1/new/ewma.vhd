library IEEE;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity ewma is
generic ( NUM_STREAMS: integer := 2);
port ( aclk: in STD_LOGIC;
aresetn: in STD_LOGIC;

alpha_data: in STD_LOGIC_VECTOR(NUM_STREAMS*32-1 downto 0);
p_data:     in STD_LOGIC_VECTOR(NUM_STREAMS*32-1 downto 0);
s0_data:    in STD_LOGIC_VECTOR(NUM_STREAMS*32-1 downto 0);

x_tvalid: in STD_LOGIC;
x_tdata: in STD_LOGIC_VECTOR(31 downto 0);
x_tready: out STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0);
x_id: in STD_LOGIC_VECTOR(15 downto 0);

anomaly_tvalid: out STD_LOGIC;
anomaly_tdata: out STD_LOGIC_VECTOR(7 downto 0);
anomaly_tready: in STD_LOGIC;
anomaly_id: out STD_LOGIC_VECTOR(15 downto 0));
end ewma;

architecture ewma_arh of ewma is

component fp_clasif is
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
end component;

component fifo32xN_buffering is
port ( s_axis_aresetn: in STD_LOGIC;
s_axis_aclk: in STD_LOGIC;

s_axis_tvalid: in STD_LOGIC;
s_axis_tready: out STD_LOGIC;
s_axis_tdata: in STD_LOGIC_VECTOR(31 downto 0);

m_axis_tvalid: out STD_LOGIC;
m_axis_tready: in STD_LOGIC;
m_axis_tdata: out STD_LOGIC_VECTOR(31 downto 0));
end component;

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

component fp_sub is
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

component fp_add is
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

component fp_mul is
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

component fp_broadcaster is
port ( aclk: in std_logic;
aresetn: in std_logic;
s_axis_tvalid: in std_logic;
s_axis_tready: out std_logic;
s_axis_tdata: in std_logic_vector(31 downto 0);
m_axis_tvalid: out std_logic_vector(1 downto 0);
m_axis_tready: in std_logic_vector(1 downto 0);
m_axis_tdata: out std_logic_vector(63 downto 0));
end component;

component fp_broadcast_3 is
port ( aclk: in std_logic;
aresetn: in std_logic;
s_axis_tvalid: in std_logic;
s_axis_tready: out std_logic;
s_axis_tdata: in std_logic_vector(31 downto 0);
m_axis_tvalid: out std_logic_vector(2 downto 0);
m_axis_tready: in std_logic_vector(2 downto 0);
m_axis_tdata: out std_logic_vector(95 downto 0));
end component;

component fifo32x16_self_init_buffering is
port ( s_axis_aresetn: in STD_LOGIC;
s_axis_aclk: in STD_LOGIC;

s0_data: in STD_LOGIC_VECTOR(31 downto 0);

s_axis_tvalid: in STD_LOGIC;
s_axis_tready: out STD_LOGIC;
s_axis_tdata: in STD_LOGIC_VECTOR(31 downto 0);

m_axis_tvalid: out STD_LOGIC;
m_axis_tready: in STD_LOGIC;
m_axis_tdata: out STD_LOGIC_VECTOR(31 downto 0));
end component;

signal St_1_fifo_tready: STD_LOGIC := '0';
signal St_1_fifo_tvalid: STD_LOGIC := '0';
signal St_1_fifo_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

signal St_1_tready: STD_LOGIC := '0';
signal St_1_tvalid: STD_LOGIC := '0';
signal St_1_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

signal broadcaster_x_tdata: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal broadcaster_x_tvalid: STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
signal broadcaster_x_tready: STD_LOGIC_VECTOR(1 downto 0) := (others => '0');

signal broadcaster_St_1_tdata: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal broadcaster_St_1_tvalid: STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
signal broadcaster_St_1_tready: STD_LOGIC_VECTOR(1 downto 0) := (others => '0');

signal broadcaster_St_tdata: STD_LOGIC_VECTOR(95 downto 0) := (others => '0');
signal broadcaster_St_tvalid: STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
signal broadcaster_St_tready: STD_LOGIC_VECTOR(2 downto 0) := (others => '0');

signal x_fifo_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal x_fifo_tvalid: STD_LOGIC := '0';
signal x_fifo_tready: STD_LOGIC := '0';

signal x_fifo_inp_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal x_fifo_inp_tvalid: STD_LOGIC := '0';
signal x_fifo_inp_tready: STD_LOGIC := '0';

signal x_St_1_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal x_St_1_tvalid: STD_LOGIC := '0';
signal x_St_1_tready: STD_LOGIC := '0';

signal mul_alpha_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal mul_alpha_tvalid: STD_LOGIC := '0';
signal mul_alpha_tready: STD_LOGIC := '0';

signal alpha_tready: STD_LOGIC := '0';
signal p_tready: STD_LOGIC := '0';

signal St_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal St_tvalid: STD_LOGIC := '0';
signal St_tready: STD_LOGIC := '0';

signal x_St_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal x_St_tvalid: STD_LOGIC := '0';
signal x_St_tready: STD_LOGIC := '0';

signal p_St_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal p_St_tvalid: STD_LOGIC := '0';
signal p_St_tready: STD_LOGIC := '0';

type streamtype is array (0 to NUM_STREAMS-1) of STD_LOGIC_VECTOR(31 downto 0);

signal x_tdata_streams: streamtype := (others => (others => '0'));
signal x_tvalid_streams: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal x_tready_streams: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');

signal fifo_x_m_tdata: streamtype := (others => (others => '0'));
signal fifo_x_m_tvalid: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal fifo_x_m_tready: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');

signal st_tdata_streams: streamtype := (others => (others => '0'));
signal st_tvalid_streams: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal st_tready_streams: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');

signal fifo_st_m_tdata: streamtype := (others => (others => '0'));
signal fifo_st_m_tvalid: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal fifo_st_m_tready: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');

signal fifo_x_select     : integer range 0 to NUM_STREAMS-1 := 0;
signal fifo_x_ready_pulse : std_logic_vector(NUM_STREAMS-1 downto 0) := (others => '0');
signal fifo_st_ready_pulse: std_logic_vector(NUM_STREAMS-1 downto 0) := (others => '0');

signal anomaly_tvalid_signal: STD_LOGIC := '0';
signal anomaly_id_signal: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

-- Plain array FIFOs for stream ID tracking through the pipeline.
-- ewma_id_fifo: pushed when x is consumed, popped when St broadcaster fires.
-- anom_id_fifo: pushed when St broadcaster fires, popped when anomaly fires.
-- Both are read combinatorially so the correct ID is available the same clock.
constant ID_FIFO_DEPTH : integer := 64;
type id_fifo_t is array(0 to ID_FIFO_DEPTH-1) of integer range 0 to NUM_STREAMS-1;

signal ewma_id_fifo : id_fifo_t := (others => 0);
signal ewma_id_wr   : integer range 0 to ID_FIFO_DEPTH-1 := 0;
signal ewma_id_rd   : integer range 0 to ID_FIFO_DEPTH-1 := 0;

signal anom_id_fifo : id_fifo_t := (others => 0);
signal anom_id_wr   : integer range 0 to ID_FIFO_DEPTH-1 := 0;
signal anom_id_rd   : integer range 0 to ID_FIFO_DEPTH-1 := 0;

-- alpha_id_fifo: pushed with ewma_id_fifo when x is consumed, popped when St result fires
signal alpha_id_fifo : id_fifo_t := (others => 0);
signal alpha_id_wr   : integer range 0 to ID_FIFO_DEPTH-1 := 0;
signal alpha_id_rd   : integer range 0 to ID_FIFO_DEPTH-1 := 0;

-- per-stream selected scalars
signal alpha_selected : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal p_selected     : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

begin

x_tready <= x_tready_streams;
anomaly_tvalid <= anomaly_tvalid_signal;
anomaly_id <= anomaly_id_signal;

alpha_selected <= alpha_data(alpha_id_fifo(alpha_id_rd)*32+31 downto alpha_id_fifo(alpha_id_rd)*32);
p_selected     <= p_data(ewma_id_fifo(ewma_id_rd)*32+31 downto ewma_id_fifo(ewma_id_rd)*32);

-- take inputs
process(aclk)
begin
if rising_edge(aclk) then
    x_tvalid_streams <= (others => '0');
    x_tvalid_streams(conv_integer(x_id)) <= x_tvalid;

    x_tdata_streams <= (others => (others => '0'));
    x_tdata_streams(conv_integer(x_id)) <= x_tdata;
end if;
end process;

-- input x fifos (N size)
fifo_input_instances: for i in 0 to NUM_STREAMS-1
generate fifo_input_inst_i: fifo32xN_buffering
    port map ( s_axis_aresetn => aresetn,
    s_axis_aclk => aclk,

    s_axis_tvalid => x_tvalid_streams(i),
    s_axis_tready => x_tready_streams(i),
    s_axis_tdata => x_tdata_streams(i),

    m_axis_tvalid => fifo_x_m_tvalid(i),
    m_axis_tready => fifo_x_m_tready(i),
    m_axis_tdata => fifo_x_m_tdata(i));
end generate;

-- Selector for x and St-1
process(aclk)
begin
    if rising_edge(aclk) then
        if aresetn = '0' then
            fifo_x_select      <= 0;
            fifo_x_ready_pulse  <= (others => '0');
            fifo_st_ready_pulse <= (others => '0');
            ewma_id_wr         <= 0;
        else
            fifo_x_ready_pulse  <= (others => '0');
            fifo_st_ready_pulse <= (others => '0');

            if fifo_x_m_tvalid(fifo_x_select) = '1' and x_fifo_inp_tready = '1' then
                fifo_x_ready_pulse(fifo_x_select)  <= '1';
                fifo_st_ready_pulse(fifo_x_select) <= '1';
                ewma_id_fifo(ewma_id_wr)   <= fifo_x_select;
                alpha_id_fifo(alpha_id_wr) <= fifo_x_select;
                if ewma_id_wr = ID_FIFO_DEPTH - 1 then ewma_id_wr <= 0;
                else ewma_id_wr <= ewma_id_wr + 1; end if;
                if alpha_id_wr = ID_FIFO_DEPTH - 1 then alpha_id_wr <= 0;
                else alpha_id_wr <= alpha_id_wr + 1; end if;
            end if;

            -- Always advance
            if fifo_x_select = NUM_STREAMS - 1 then
                fifo_x_select <= 0;
            else
                fifo_x_select <= fifo_x_select + 1;
            end if;
        end if;
    end if;
end process;

fifo_x_m_tready <= fifo_x_ready_pulse;

x_fifo_inp_tvalid <= fifo_x_m_tvalid(fifo_x_select);
x_fifo_inp_tdata  <= fifo_x_m_tdata(fifo_x_select);

fp_broadcast_x_inst: fp_broadcaster
port map ( aclk => aclk,
aresetn => aresetn,
s_axis_tvalid => x_fifo_inp_tvalid,
s_axis_tready => x_fifo_inp_tready,
s_axis_tdata => x_fifo_inp_tdata,
m_axis_tvalid => broadcaster_x_tvalid,
m_axis_tready => broadcaster_x_tready,
m_axis_tdata => broadcaster_x_tdata);

fifo_x_inst: fifo32x16_buffering
port map ( s_axis_aresetn => aresetn,
s_axis_aclk => aclk,

s_axis_tvalid => broadcaster_x_tvalid(1),
s_axis_tready => broadcaster_x_tready(1),
s_axis_tdata => broadcaster_x_tdata(63 downto 32),

m_axis_tvalid => x_fifo_tvalid,
m_axis_tready => x_fifo_tready,
m_axis_tdata => x_fifo_tdata);

sub_x_St_1_inst: fp_sub
port map ( aclk => aclk,
aresetn => aresetn,

s_axis_a_tvalid => broadcaster_x_tvalid(0),
s_axis_a_tdata => broadcaster_x_tdata(31 downto 0),
s_axis_a_tready => broadcaster_x_tready(0),

s_axis_b_tvalid => broadcaster_St_1_tvalid(0),
s_axis_b_tdata => broadcaster_St_1_tdata(31 downto 0),
s_axis_b_tready => broadcaster_St_1_tready(0),

m_axis_result_tvalid => x_St_1_tvalid,
m_axis_result_tdata => x_St_1_tdata,
m_axis_result_tready => x_St_1_tready);

fifo_St_1_inst: fifo32x16_buffering
port map ( s_axis_aresetn => aresetn,
s_axis_aclk => aclk,

s_axis_tvalid =>  broadcaster_St_1_tvalid(1),
s_axis_tready => broadcaster_St_1_tready(1),
s_axis_tdata => broadcaster_St_1_tdata(63 downto 32),

m_axis_tvalid => St_1_fifo_tvalid,
m_axis_tready => St_1_fifo_tready,
m_axis_tdata => St_1_fifo_tdata);

mul_x_St_1_alpha_inst: fp_mul
port map ( aclk => aclk,
aresetn => aresetn,

s_axis_a_tvalid => x_St_1_tvalid,
s_axis_a_tdata => x_St_1_tdata,
s_axis_a_tready => x_St_1_tready,

s_axis_b_tvalid => x_St_1_tvalid,
s_axis_b_tdata => alpha_selected,
s_axis_b_tready => alpha_tready,

m_axis_result_tvalid => mul_alpha_tvalid,
m_axis_result_tdata => mul_alpha_tdata,
m_axis_result_tready => mul_alpha_tready);

add_St_inst: fp_add
port map ( aclk => aclk,
aresetn => aresetn,

s_axis_a_tvalid => mul_alpha_tvalid,
s_axis_a_tdata => mul_alpha_tdata,
s_axis_a_tready => mul_alpha_tready,

s_axis_b_tvalid => St_1_fifo_tvalid,
s_axis_b_tdata => St_1_fifo_tdata,
s_axis_b_tready => St_1_fifo_tready,

m_axis_result_tvalid => St_tvalid,
m_axis_result_tdata => St_tdata,
m_axis_result_tready => St_tready);

fp_broadcast_St_inst: fp_broadcast_3
port map ( aclk => aclk,
aresetn => aresetn,
s_axis_tvalid => St_tvalid,
s_axis_tready => St_tready,
s_axis_tdata => St_tdata,
m_axis_tvalid => broadcaster_St_tvalid,
m_axis_tready => broadcaster_St_tready,
m_axis_tdata => broadcaster_St_tdata);

sub_x_St_inst: fp_sub
port map ( aclk => aclk,
aresetn => aresetn,

s_axis_a_tvalid => x_fifo_tvalid,
s_axis_a_tdata => x_fifo_tdata,
s_axis_a_tready => x_fifo_tready,

s_axis_b_tvalid => broadcaster_St_tvalid(0),
s_axis_b_tdata => broadcaster_St_tdata(31 downto 0),
s_axis_b_tready => broadcaster_St_tready(0),

m_axis_result_tvalid => x_St_tvalid,
m_axis_result_tdata => x_St_tdata,
m_axis_result_tready => x_St_tready);

mul_p_St_inst: fp_mul
port map ( aclk => aclk,
aresetn => aresetn,

s_axis_a_tvalid => broadcaster_St_tvalid(1),
s_axis_a_tdata => p_selected,
s_axis_a_tready => p_tready,

s_axis_b_tvalid => broadcaster_St_tvalid(1),
s_axis_b_tdata => broadcaster_St_tdata(63 downto 32),
s_axis_b_tready => broadcaster_St_tready(1),

m_axis_result_tvalid => p_St_tvalid,
m_axis_result_tdata => p_St_tdata,
m_axis_result_tready => p_St_tready);

broadcaster_St_tready(2) <= '1';

-- ID propagation
process(aclk)
begin
    if rising_edge(aclk) then
        if aresetn = '0' then
            ewma_id_rd  <= 0;
            anom_id_wr  <= 0;
            anom_id_rd  <= 0;
            alpha_id_rd <= 0;
        else
            -- pop alpha_id_fifo when St result is produced (add_St fires)
            if St_tvalid = '1' and St_tready = '1' then
                if alpha_id_rd = ID_FIFO_DEPTH - 1 then alpha_id_rd <= 0;
                else alpha_id_rd <= alpha_id_rd + 1; end if;
            end if;

            if broadcaster_St_tvalid(2) = '1' then
                anom_id_fifo(anom_id_wr) <= ewma_id_fifo(ewma_id_rd);
                if anom_id_wr = ID_FIFO_DEPTH - 1 then anom_id_wr <= 0;
                else anom_id_wr <= anom_id_wr + 1; end if;
                if ewma_id_rd = ID_FIFO_DEPTH - 1 then ewma_id_rd <= 0;
                else ewma_id_rd <= ewma_id_rd + 1; end if;
            end if;
            if anomaly_tvalid_signal = '1' and anomaly_tready = '1' then
                if anom_id_rd = ID_FIFO_DEPTH - 1 then anom_id_rd <= 0;
                else anom_id_rd <= anom_id_rd + 1; end if;
            end if;
        end if;
    end if;
end process;

-- Feedback write
process(aclk)
begin
if rising_edge(aclk) then
    st_tvalid_streams <= (others => '0');
    st_tvalid_streams(ewma_id_fifo(ewma_id_rd)) <= broadcaster_St_tvalid(2);

    st_tdata_streams <= (others => (others => '0'));
    st_tdata_streams(ewma_id_fifo(ewma_id_rd)) <= broadcaster_St_tdata(95 downto 64);
end if;
end process;

fifo_feedback_instances: for i in 0 to NUM_STREAMS-1
generate fifo_feedback_inst_i: fifo32x16_self_init_buffering
    port map ( s_axis_aresetn => aresetn,
    s_axis_aclk => aclk,

    s0_data => s0_data(i*32+31 downto i*32),

    s_axis_tvalid => st_tvalid_streams(i),
    s_axis_tready => st_tready_streams(i),
    s_axis_tdata => st_tdata_streams(i),

    m_axis_tvalid => fifo_st_m_tvalid(i),
    m_axis_tready => fifo_st_m_tready(i),
    m_axis_tdata => fifo_st_m_tdata(i));
end generate;

-- St-1 output uses the same selector as x
St_1_tvalid <= fifo_st_m_tvalid(fifo_x_select);
St_1_tdata  <= fifo_st_m_tdata(fifo_x_select);
fifo_st_m_tready <= fifo_st_ready_pulse;

-- broadcaster St-1
fp_broadcast_St_1_inst: fp_broadcaster
port map ( aclk => aclk,
aresetn => aresetn,
s_axis_tvalid => St_1_tvalid,
s_axis_tready => St_1_tready,
s_axis_tdata => St_1_tdata,
m_axis_tvalid => broadcaster_St_1_tvalid,
m_axis_tready => broadcaster_St_1_tready,
m_axis_tdata => broadcaster_St_1_tdata);

clasif_inst: fp_clasif
port map ( aclk => aclk,

s_axis_tvalid => x_St_tvalid,
s_axis_tready => x_St_tready,
s_axis_tdata => x_St_tdata,

pS_axis_tvalid => p_St_tvalid,
pS_axis_tready => p_St_tready,
pS_axis_tdata => p_St_tdata,

m_axis_tvalid => anomaly_tvalid_signal,
m_axis_tready => anomaly_tready,
m_axis_tdata => anomaly_tdata);

-- Anomaly ID
anomaly_id_signal <= std_logic_vector(to_unsigned(anom_id_fifo(anom_id_rd), 16));

end ewma_arh;
