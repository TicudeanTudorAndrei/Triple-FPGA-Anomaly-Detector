library IEEE;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_misc.all;

entity sqrd_dev is
generic ( NUM_STREAMS: integer := 2;
SAMPLE_SIZE : integer := 64);
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
        
sqrd_dev_tvalid: out STD_LOGIC;
sqrd_dev_tdata: out STD_LOGIC_VECTOR(31 downto 0);
sqrd_dev_tready: in STD_LOGIC;
sqrd_dev_id: out STD_LOGIC_VECTOR(15 downto 0);

x_minus_mean_tvalid: out STD_LOGIC;
x_minus_mean_tdata: out STD_LOGIC_VECTOR(31 downto 0);
x_minus_mean_tready: in STD_LOGIC;
x_minus_mean_id: out STD_LOGIC_VECTOR(15 downto 0);

mean_init_comp: in STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0);
init_complete: out STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0));
end entity;

architecture sqrd_dev_arch of sqrd_dev is

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

component sum_buffering_small is
generic ( SAMPLE_SIZE : integer := 64);
port ( aclk: in STD_LOGIC;
aresetn: in STD_LOGIC;

x_tvalid: in STD_LOGIC;
x_tready: out STD_LOGIC;
x_tdata: in STD_LOGIC_VECTOR(31 downto 0);

sum_tvalid: out STD_LOGIC;
sum_tready: in STD_LOGIC;
sum_tdata: out STD_LOGIC_VECTOR(31 downto 0);
init_complete: out STD_LOGIC);
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

type streamtype is array (0 to NUM_STREAMS-1) of STD_LOGIC_VECTOR(31 downto 0);

signal x_tdata_streams: streamtype := (others => (others => '0'));
signal x_tvalid_streams: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal x_tready_streams: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');

signal fifo_x_m_tvalid: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal fifo_x_m_tready: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal fifo_x_m_tdata: streamtype := (others => (others => '0'));
signal fifo_x_select : integer range 0 to NUM_STREAMS-1 := 0;
signal fifo_x_ready_pulse : STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');

signal x_fifo_tvalid: STD_LOGIC := '0';
signal x_fifo_tready: STD_LOGIC := '0';
signal x_fifo_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

-- Per-stream mean FIFOs
signal fifo_mean_m_tvalid_streams: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal fifo_mean_m_tready_streams: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal fifo_mean_m_tdata_streams: streamtype := (others => (others => '0'));
signal fifo_mean_ready_pulse: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal mean_route_tvalid_streams: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal mean_route_tdata_streams: streamtype := (others => (others => '0'));
signal mean_route_tready_streams: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');

signal mean_fifo_tvalid: STD_LOGIC := '0';
signal mean_fifo_tready: STD_LOGIC := '0';
signal mean_fifo_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

signal mul_tdata_streams: streamtype := (others => (others => '0'));
signal mul_tvalid_streams: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal mul_tready_streams: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');

signal sum_tready_streams: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal sum_tvalid_streams: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal sum_tdata_streams: streamtype := (others => (others => '0'));

signal sqrd_dev_tready_streams: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal sqrd_dev_tvalid_streams: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal sqrd_dev_tdata_streams: streamtype := (others => (others => '0'));
signal sqrd_dev_select : integer range 0 to NUM_STREAMS-1 := 0;
signal sqrd_dev_ready_pulse: std_logic_vector(NUM_STREAMS-1 downto 0) := (others => '0');

signal init_complete_streams: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');

signal sub_tvalid: STD_LOGIC := '0';
signal sub_tready: STD_LOGIC := '0';
signal sub_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

signal mul_tvalid: STD_LOGIC := '0';
signal mul_tready: STD_LOGIC := '0';
signal mul_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

signal mux_a_tvalid: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');

signal mul_a_tready: STD_LOGIC := '0';
signal mul_b_tready: STD_LOGIC := '0';

signal sqrd_dev_tvalid_signal: STD_LOGIC := '0';
signal sqrd_dev_id_signal: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

constant NSTR_NSAMPL: integer := SAMPLE_SIZE * NUM_STREAMS;

type int_array is array (0 to NUM_STREAMS-1) of integer range 0 to SAMPLE_SIZE;
signal count_x: int_array := (others => 0);
signal send_x: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');

signal count_sub: integer range 0 to NSTR_NSAMPL-1;
signal send_x_minus_mean: STD_LOGIC := '0';

signal x_minus_mean_id_signal: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

-- ID FIFOs
constant SQ_ID_DEPTH : integer := 64;
type sq_id_fifo_t is array(0 to SQ_ID_DEPTH-1) of integer range 0 to NUM_STREAMS-1;
signal sub_id_fifo    : sq_id_fifo_t := (others => 0);
signal sub_id_wr      : integer range 0 to SQ_ID_DEPTH-1 := 0;
signal sub_id_rd      : integer range 0 to SQ_ID_DEPTH-1 := 0;
signal mul_id_fifo_arr: sq_id_fifo_t := (others => 0);
signal mul_id_wr      : integer range 0 to SQ_ID_DEPTH-1 := 0;
signal mul_id_rd      : integer range 0 to SQ_ID_DEPTH-1 := 0;

begin

x_tready <= x_tready_streams;
mean_tready <= '1';

mul_tready <= '1';
init_complete <= init_complete_streams;

x_minus_mean_tdata <= sub_tdata;
x_minus_mean_id <= x_minus_mean_id_signal;
                
sqrd_dev_tvalid <= sqrd_dev_tvalid_signal;
sqrd_dev_id <= sqrd_dev_id_signal;

-- direct x inputs to correct fifo, count inputs to eliminate initialization inputs
process(aclk)
begin
if rising_edge(aclk) then    
    if aresetn = '0' then
        count_x <= (others => 0);
        send_x <= (others => '0');
        x_tvalid_streams <= (others => '0');
        x_tdata_streams <= (others => (others => '0'));
    else
        x_tvalid_streams <= (others => '0');
        x_tvalid_streams(conv_integer(x_id)) <= mux_a_tvalid(conv_integer(x_id));
    
        x_tdata_streams <= (others => (others => '0'));
        x_tdata_streams(conv_integer(x_id)) <= x_tdata;
        
        if x_tvalid = '1' and count_x(conv_integer(x_id)) < SAMPLE_SIZE - 1 and send_x(conv_integer(x_id)) = '0' then -- if not yet finished initialization, just count
            count_x(conv_integer(x_id)) <= count_x(conv_integer(x_id)) + 1;
            send_x(conv_integer(x_id)) <= '0';
        elsif x_tvalid = '1' and count_x(conv_integer(x_id)) = SAMPLE_SIZE - 1 and send_x(conv_integer(x_id)) = '0' then -- when last number in initialization state is finally processed
            send_x(conv_integer(x_id)) <= '1'; -- assert send_x
        end if;
    end if;
end if;
end process;

-- Route incoming mean to the per-stream FIFO, mean_id.
process(aclk)
begin
if rising_edge(aclk) then
    if aresetn = '0' then
        mean_route_tvalid_streams <= (others => '0');
        mean_route_tdata_streams  <= (others => (others => '0'));
    else
        mean_route_tvalid_streams <= (others => '0');
        mean_route_tvalid_streams(conv_integer(mean_id)) <= mean_tvalid;
        mean_route_tdata_streams  <= (others => (others => '0'));
        mean_route_tdata_streams(conv_integer(mean_id))  <= mean_tdata;
    end if;
end if;
end process;

-- Selector for x FIFOs to fp_sub.
process(aclk)
begin
    if rising_edge(aclk) then
        if aresetn = '0' then
            fifo_x_select      <= 0;
            fifo_x_ready_pulse  <= (others => '0');
            fifo_mean_ready_pulse <= (others => '0');
            sub_id_wr          <= 0;
        else
            fifo_x_ready_pulse   <= (others => '0');
            fifo_mean_ready_pulse <= (others => '0');

            if fifo_x_m_tvalid(fifo_x_select) = '1' and
               fifo_mean_m_tvalid_streams(fifo_x_select) = '1' and
               x_fifo_tready = '1' then
                fifo_x_ready_pulse(fifo_x_select)   <= '1';
                fifo_mean_ready_pulse(fifo_x_select) <= '1';
                sub_id_fifo(sub_id_wr) <= fifo_x_select;
                if sub_id_wr = SQ_ID_DEPTH - 1 then sub_id_wr <= 0;
                else sub_id_wr <= sub_id_wr + 1; end if;
            end if;

            if fifo_x_select = NUM_STREAMS - 1 then
                fifo_x_select <= 0;
            else
                fifo_x_select <= fifo_x_select + 1;
            end if;
        end if;
    end if;
end process;

fifo_x_m_tready           <= fifo_x_ready_pulse;
fifo_mean_m_tready_streams <= fifo_mean_ready_pulse;

x_fifo_tvalid <= fifo_x_m_tvalid(fifo_x_select) and fifo_mean_m_tvalid_streams(fifo_x_select);
x_fifo_tdata  <= fifo_x_m_tdata(fifo_x_select);

mean_fifo_tvalid <= fifo_mean_m_tvalid_streams(fifo_x_select);
mean_fifo_tdata  <= fifo_mean_m_tdata_streams(fifo_x_select);

-- count sub results to eliminate initialization results
process(aclk)
begin
if rising_edge(aclk) then    
    if aresetn = '0' then
        count_sub <= 0;
        send_x_minus_mean <= '0';
    else
        if sub_tvalid = '1' and count_sub < NSTR_NSAMPL-1 and send_x_minus_mean = '0' then -- if not yet finished initialization, just count
            count_sub <= count_sub + 1;
            send_x_minus_mean <= '0';
        elsif sub_tvalid = '1' and count_sub = NSTR_NSAMPL-1 and send_x_minus_mean = '0' then -- when last number in initialization state is finally processed
            send_x_minus_mean <= '1'; -- assert send_x_minus_mean
        end if;
    end if;
end if;
end process;

-- ID propagation
process(aclk)
begin
    if rising_edge(aclk) then
        if aresetn = '0' then
            sub_id_rd <= 0;
            mul_id_wr <= 0;
            mul_id_rd <= 0;
        else
            if sub_tvalid = '1' then
                mul_id_fifo_arr(mul_id_wr) <= sub_id_fifo(sub_id_rd);
                if mul_id_wr = SQ_ID_DEPTH - 1 then mul_id_wr <= 0;
                else mul_id_wr <= mul_id_wr + 1; end if;
                if sub_id_rd = SQ_ID_DEPTH - 1 then sub_id_rd <= 0;
                else sub_id_rd <= sub_id_rd + 1; end if;
            end if;
            if mul_tvalid = '1' then
                if mul_id_rd = SQ_ID_DEPTH - 1 then mul_id_rd <= 0;
                else mul_id_rd <= mul_id_rd + 1; end if;
            end if;
        end if;
    end if;
end process;

x_minus_mean_id_signal <= std_logic_vector(to_unsigned(sub_id_fifo(sub_id_rd), 16));

-- Send mul result to the correct per-stream sum_buffering
process(aclk)
begin
if rising_edge(aclk) then
    mul_tvalid_streams <= (others => '0');
    mul_tvalid_streams(mul_id_fifo_arr(mul_id_rd)) <= mul_tvalid;
    mul_tdata_streams  <= (others => (others => '0'));
    mul_tdata_streams(mul_id_fifo_arr(mul_id_rd))  <= mul_tdata;
end if;
end process;    

-- Selector for squared-deviation sum FIFO
process(aclk)
begin
if rising_edge(aclk) then
    if aresetn = '0' then
        sqrd_dev_select      <= 0;
        sqrd_dev_ready_pulse <= (others => '0');
    else
        sqrd_dev_ready_pulse <= (others => '0');

        if sqrd_dev_tvalid_streams(sqrd_dev_select) = '1' and sqrd_dev_tready = '1' then
            sqrd_dev_ready_pulse(sqrd_dev_select) <= '1';
        end if;

        if sqrd_dev_select = NUM_STREAMS - 1 then
            sqrd_dev_select <= 0;
        else
            sqrd_dev_select <= sqrd_dev_select + 1;
        end if;
    end if;
end if;
end process;

sqrd_dev_tready_streams <= sqrd_dev_ready_pulse;

sqrd_dev_tvalid_signal <= sqrd_dev_tvalid_streams(sqrd_dev_select);
sqrd_dev_tdata          <= sqrd_dev_tdata_streams(sqrd_dev_select);
sqrd_dev_id_signal      <= std_logic_vector(to_unsigned(sqrd_dev_select, 16));

-- MUX x_minus_mean_tvalid
with send_x_minus_mean select
x_minus_mean_tvalid <= '0' when '0',
                        sub_tvalid when others;

-- MUX s_axis_a_tvalid
process(send_x, x_tvalid)
begin
    for i in 0 to NUM_STREAMS-1 loop
        if send_x(i) = '0' then
            mux_a_tvalid(i) <= '0';
        else
            mux_a_tvalid(i) <= x_tvalid;
        end if;
    end loop;
end process;

-- OR sub_tready
sub_tready <= mul_a_tready or mul_b_tready;

fifo_instances_x: for i in 0 to NUM_STREAMS-1
generate fifo_x_inst_i: fifo32xN_buffering
    port map ( s_axis_aresetn => aresetn,
    s_axis_aclk => aclk,

    s_axis_tvalid => x_tvalid_streams(i),
    s_axis_tready => x_tready_streams(i),
    s_axis_tdata => x_tdata_streams(i),
            
    m_axis_tvalid => fifo_x_m_tvalid(i),
    m_axis_tready => fifo_x_m_tready(i),
    m_axis_tdata => fifo_x_m_tdata(i));
end generate;

fifo_mean_instances: for i in 0 to NUM_STREAMS-1
generate fifo_mean_inst_i: fifo32x16_buffering
    port map ( s_axis_aresetn => aresetn,
    s_axis_aclk => aclk,

    s_axis_tvalid => mean_route_tvalid_streams(i),
    s_axis_tready => mean_route_tready_streams(i),
    s_axis_tdata  => mean_route_tdata_streams(i),

    m_axis_tvalid => fifo_mean_m_tvalid_streams(i),
    m_axis_tready => fifo_mean_m_tready_streams(i),
    m_axis_tdata  => fifo_mean_m_tdata_streams(i));
end generate;

sub_inst: fp_sub 
port map ( aclk => aclk,
aresetn => aresetn,

s_axis_a_tvalid => x_fifo_tvalid,
s_axis_a_tdata => x_fifo_tdata,
s_axis_a_tready => x_fifo_tready,
            
s_axis_b_tvalid => mean_fifo_tvalid,
s_axis_b_tdata => mean_fifo_tdata,
s_axis_b_tready => mean_fifo_tready,

m_axis_result_tvalid => sub_tvalid,
m_axis_result_tdata => sub_tdata,
m_axis_result_tready => sub_tready);

mul_inst: fp_mul
port map ( aclk => aclk,
aresetn => aresetn,

s_axis_a_tvalid => sub_tvalid,
s_axis_a_tdata => sub_tdata,
s_axis_a_tready => mul_a_tready,
            
s_axis_b_tvalid => sub_tvalid,
s_axis_b_tdata => sub_tdata,
s_axis_b_tready => mul_b_tready,
            
m_axis_result_tvalid => mul_tvalid,
m_axis_result_tdata => mul_tdata,
m_axis_result_tready => mul_tready);

sum_buffering_instances: for i in 0 to NUM_STREAMS-1
generate sum_buffering_inst_i: sum_buffering_small
         generic map ( SAMPLE_SIZE => SAMPLE_SIZE)
         port map ( aclk => aclk,
         aresetn => aresetn,

         x_tvalid => mul_tvalid_streams(i),
         x_tready => mul_tready_streams(i),
         x_tdata => mul_tdata_streams(i),

         sum_tvalid => sum_tvalid_streams(i),
         sum_tready => sum_tready_streams(i),
         sum_tdata => sum_tdata_streams(i),
         init_complete => init_complete_streams(i));
end generate;

fifo_instances_sum: for i in 0 to NUM_STREAMS-1
generate fifo_sum_inst_i: fifo32x16_buffering
    port map ( s_axis_aresetn => aresetn,
    s_axis_aclk => aclk,

    s_axis_tvalid => sum_tvalid_streams(i),
    s_axis_tready => sum_tready_streams(i),
    s_axis_tdata => sum_tdata_streams(i),
            
    m_axis_tvalid => sqrd_dev_tvalid_streams(i),
    m_axis_tready => sqrd_dev_tready_streams(i),
    m_axis_tdata => sqrd_dev_tdata_streams(i));
end generate;

end architecture;