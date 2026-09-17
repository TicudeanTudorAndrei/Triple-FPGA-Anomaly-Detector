library IEEE;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity top_level_proj is
port ( clk: in STD_LOGIC;
btn: in STD_LOGIC_VECTOR(4 downto 0);
sw: in STD_LOGIC_VECTOR(15 downto 0);       
led: out STD_LOGIC_VECTOR(15 downto 0);       
an: out STD_LOGIC_VECTOR(7 downto 0);        
cat: out STD_LOGIC_VECTOR(6 downto 0);
uart_cts: in STD_LOGIC; -- Clear to Send
uart_rts: out STD_LOGIC; -- Request to Send
uart_rxd_out: out STD_LOGIC; -- Receive Data - FPGA output
uart_txd_in: in STD_LOGIC);  -- Transmit Data - FPGA input
end top_level_proj;

architecture top_level_proj_arh of top_level_proj is

constant NUM_STREAMS: integer := 4;
constant ZSCORE_SAMPLE_SIZE_INTEGER: integer := 64;                                      -- SELECT SAMPLE SIZE HERE, MAX IS 64
constant ZSCORE_SAMPLE_SIZE_HEXADECIMAL: STD_LOGIC_VECTOR(31 downto 0) := x"42800000";   -- WRITE THE IEEE 754 HEXADECIMAL REPRESENTATION: https://www.h-schmidt.net/FloatConverter/IEEE754.html?

-- sw(0), sw(1) and sw(2) are used for reset (for no reset set them on '1' - up position)

component mpg is
port ( btn: in STD_LOGIC;
clk: in STD_LOGIC;
enable: out STD_LOGIC);
end component;

component ssd is
port ( digits: in STD_LOGIC_VECTOR(31 downto 0); 
clk: in STD_LOGIC;
an: out STD_LOGIC_VECTOR(7 downto 0);
cat: out STD_LOGIC_VECTOR(6 downto 0));
end component;

component ewma is
generic ( NUM_STREAMS : integer := 2);
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
end component;

component zscore is
generic ( NUM_STREAMS : integer := 2;
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
end component;

component multi_stream_cusum_anomaly_detector_top_module is
generic ( NUM_SENSORS : integer := 2);
port ( clk : in STD_LOGIC;
rst : in STD_LOGIC;
           
input_value_data : in STD_LOGIC_VECTOR (63 downto 0);
input_value_ready : out STD_LOGIC;
input_value_valid : in STD_LOGIC; 
           
threshold_data: in STD_LOGIC_VECTOR (NUM_SENSORS*32-1 downto 0);
threshold_ready: out STD_LOGIC;
threshold_valid: in STD_LOGIC;

drift_data: in STD_LOGIC_VECTOR (NUM_SENSORS*32-1 downto 0);
drift_ready: out STD_LOGIC;
drift_valid: in STD_LOGIC;
           
labeled_data : out STD_LOGIC_VECTOR (63 downto 0);
labeled_data_ready : in STD_LOGIC;
labeled_data_valid : out STD_LOGIC;
           
timestamp_data: out STD_LOGIC_VECTOR (31 downto 0);
timestamp_ready: in STD_LOGIC;
timestamp_valid: out STD_LOGIC);
end component;

component uart_tx is
generic ( g_CLKS_PER_BIT : integer := 869);
port ( i_Clk: in  STD_LOGIC;  
i_TX_DV: in  STD_LOGIC;    
i_TX_Byte: in  STD_LOGIC_VECTOR(7 downto 0);    
o_TX_Active: out STD_LOGIC;    
o_TX_Serial: out STD_LOGIC;    
o_TX_Done: out STD_LOGIC);
end component;

component uart_rx is
generic ( g_CLKS_PER_BIT : integer := 869);
port ( i_Clk: in  STD_LOGIC;
i_RX_Serial: in  STD_LOGIC;   
o_RX_DV: out STD_LOGIC;   
o_RX_Byte: out STD_LOGIC_VECTOR(7 downto 0));
end component;

signal deb_buttons: STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
signal display_data_7seg: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal display_data_7seg_filler: STD_LOGIC_VECTOR(23 downto 0) := (others => '0');

signal uart_tx_dv: STD_LOGIC := '0';
signal uart_tx_done: STD_LOGIC := '0';
signal uart_rx_dv: STD_LOGIC := '0';
signal uart_rx_byte: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal uart_tx_byte: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

signal received_data_accumulator: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal rcv_packet_count: integer range 0 to 7 := 0;

signal full_input: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal detector_select: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

signal full_float_number_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal full_float_number_tvalid: STD_LOGIC := '0';
signal full_float_number_tready: STD_LOGIC := '0';

signal zscore_anomaly_tvalid: STD_LOGIC := '0';
signal zscore_anomaly_tdata: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal zscore_anomaly_id: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal zscore_init_complete: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');

signal ewma_anomaly_tvalid: STD_LOGIC := '0';
signal ewma_anomaly_tdata: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal ewma_anomaly_id: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

signal cusum_anomaly_tvalid: STD_LOGIC := '0';
signal cusum_anomaly_tdata: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal cusum_anomaly_id: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

signal cusum_anomaly_tdata_reduced: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

signal send_valid: STD_LOGIC := '0';
signal send_data: STD_LOGIC_VECTOR(39 downto 0) := (others => '0');
signal send_active: STD_LOGIC := '0';

signal send_filler: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal input_id: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

signal send_flag_zscore: STD_LOGIC_VECTOR(6 downto 0) := "0000001";
signal send_flag_ewma: STD_LOGIC_VECTOR(6 downto 0) := "0000010";
signal send_flag_cusum: STD_LOGIC_VECTOR(6 downto 0) := "0000100";


type uart_state_type is (IDL, SB2, SB3, SB4, SB5, SELB);
signal uart_state: uart_state_type := IDL;
signal byte_count: integer range 0 to 4 := 0;

signal cusum_full_float_number_tdata: STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal cusum_full_float_number_tvalid: STD_LOGIC := '0';
signal cusum_full_float_number_tready: STD_LOGIC := '0';
signal cusum_full_float_number_id: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

signal cusum_thr_tready: STD_LOGIC := '0';
signal cusum_thr_tvalid: STD_LOGIC := '0';

signal cusum_drift_tready: STD_LOGIC := '0';
signal cusum_drift_tvalid: STD_LOGIC := '0';

signal ewma_full_float_number_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal ewma_full_float_number_tvalid: STD_LOGIC := '0';
signal ewma_full_float_number_tready: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal ewma_full_float_number_id: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

signal zscore_full_float_number_tdata: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal zscore_full_float_number_tvalid: STD_LOGIC := '0';
signal zscore_full_float_number_tready: STD_LOGIC_VECTOR(NUM_STREAMS-1 downto 0) := (others => '0');
signal zscore_full_float_number_id: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

signal timestamp_data: STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
signal timestamp_valid: STD_LOGIC := '0';

signal config_done   : STD_LOGIC := '0';

type param_array_t is array(0 to NUM_STREAMS-1) of STD_LOGIC_VECTOR(31 downto 0);
signal cusum_thr_reg  : param_array_t := (others => x"00000190"); -- 400
signal cusum_drift_reg: param_array_t := (others => x"00000064"); -- 100
signal ewma_alpha_reg : param_array_t := (others => x"3c23d70a"); -- 0.01
signal ewma_p_reg     : param_array_t := (others => x"40200000"); -- 2.5
signal ewma_s0_reg    : param_array_t := (others => x"3fc00000"); -- 1.5

-- Flattened buses for port connections (stream 0 in lowest bits)
signal cusum_thr_bus  : STD_LOGIC_VECTOR(NUM_STREAMS*32-1 downto 0) := (others => '0');
signal cusum_drift_bus: STD_LOGIC_VECTOR(NUM_STREAMS*32-1 downto 0) := (others => '0');
signal ewma_alpha_bus : STD_LOGIC_VECTOR(NUM_STREAMS*32-1 downto 0) := (others => '0');
signal ewma_p_bus     : STD_LOGIC_VECTOR(NUM_STREAMS*32-1 downto 0) := (others => '0');
signal ewma_s0_bus    : STD_LOGIC_VECTOR(NUM_STREAMS*32-1 downto 0) := (others => '0');

signal zscore_rst : STD_LOGIC := '0';
signal ewma_rst   : STD_LOGIC := '0';
signal cusum_rst  : STD_LOGIC := '0';

signal led_hold_zscore : integer range 0 to 33554431 := 0;
signal led_hold_ewma   : integer range 0 to 33554431 := 0;
signal led_hold_cusum  : integer range 0 to 33554431 := 0;

begin

zscore_rst <= sw(0) and config_done;
ewma_rst   <= sw(1) and config_done;
cusum_rst  <= sw(2) and config_done;

-- Flatten per-stream parameter arrays into contiguous buses (stream i -> bits i*32+31:i*32)
param_flatten_gen: for i in 0 to NUM_STREAMS-1 generate
    cusum_thr_bus(i*32+31 downto i*32)   <= cusum_thr_reg(i);
    cusum_drift_bus(i*32+31 downto i*32) <= cusum_drift_reg(i);
    ewma_alpha_bus(i*32+31 downto i*32)  <= ewma_alpha_reg(i);
    ewma_p_bus(i*32+31 downto i*32)      <= ewma_p_reg(i);
    ewma_s0_bus(i*32+31 downto i*32)     <= ewma_s0_reg(i);
end generate;

mpg_inst_0: mpg port map( btn => btn(0), clk => clk, enable => deb_buttons(0));
mpg_inst_1: mpg port map(btn => btn(1), clk => clk, enable => deb_buttons(1));
mpg_inst_2: mpg port map(btn => btn(2), clk => clk, enable => deb_buttons(2));
mpg_inst_3: mpg port map(btn => btn(3), clk => clk, enable => deb_buttons(3));
mpg_inst_4: mpg port map(btn => btn(4), clk => clk, enable => deb_buttons(4));
--    1
--  2 0 3 
--    4
display_inst: ssd port map(digits => display_data_7seg, clk => clk, an => an, cat => cat);

uart_trs_inst: uart_tx
generic map ( g_CLKS_PER_BIT => 869)
port map ( i_Clk => clk,      
i_TX_DV => uart_tx_dv,  
i_TX_Byte => uart_tx_byte,     
o_TX_Active => open,  
o_TX_Serial => uart_rxd_out,
o_TX_Done => uart_tx_done);

uart_rcv_inst: uart_rx
generic map ( g_CLKS_PER_BIT => 869)
port map ( i_Clk => clk,  
i_RX_Serial => uart_txd_in,     
o_RX_DV => uart_rx_dv,   
o_RX_Byte => uart_rx_byte);

z_score_inst: zscore
generic map ( NUM_STREAMS => NUM_STREAMS,
SAMPLE_SIZE_INT => ZSCORE_SAMPLE_SIZE_INTEGER,
SAMPLE_SIZE_HEX => ZSCORE_SAMPLE_SIZE_HEXADECIMAL)
port map ( aclk => clk,
aresetn => zscore_rst,

x_tvalid => zscore_full_float_number_tvalid,
x_tdata => zscore_full_float_number_tdata,
x_tready => zscore_full_float_number_tready,
x_id => zscore_full_float_number_id,

anomaly_tvalid => zscore_anomaly_tvalid,
anomaly_tdata => zscore_anomaly_tdata,
anomaly_tready => '1', -- always ready to receive output
anomaly_id => zscore_anomaly_id,

init_complete => zscore_init_complete);

cusum_inst: multi_stream_cusum_anomaly_detector_top_module
generic map ( NUM_SENSORS => NUM_STREAMS )
port map ( clk => clk,
rst => cusum_rst,

input_value_data => cusum_full_float_number_tdata,
input_value_ready => cusum_full_float_number_tready,
input_value_valid => cusum_full_float_number_tvalid,

threshold_data => cusum_thr_bus,
threshold_ready => cusum_thr_tready,
threshold_valid => cusum_thr_tvalid,

drift_data => cusum_drift_bus,
drift_ready => cusum_drift_tready,
drift_valid => cusum_drift_tvalid,
           
labeled_data => cusum_anomaly_tdata,
labeled_data_ready => '1', -- always ready to receive output
labeled_data_valid => cusum_anomaly_tvalid,
           
timestamp_data => timestamp_data,
timestamp_ready => '1',
timestamp_valid => timestamp_valid);

ewma_inst: ewma
generic map ( NUM_STREAMS => NUM_STREAMS)
port map ( aclk => clk,
aresetn => ewma_rst,

alpha_data => ewma_alpha_bus,
p_data     => ewma_p_bus,
s0_data    => ewma_s0_bus,

x_tvalid => ewma_full_float_number_tvalid,
x_tdata => ewma_full_float_number_tdata,
x_tready => ewma_full_float_number_tready,
x_id => ewma_full_float_number_id,

anomaly_tvalid => ewma_anomaly_tvalid,
anomaly_tdata => ewma_anomaly_tdata,
anomaly_tready => '1', -- always ready to receive output
anomaly_id => ewma_anomaly_id);

uart_send_proc: process(clk)
begin
    if rising_edge(clk) then
        case uart_state is
            when IDL =>
                if send_valid = '1' then
                    uart_tx_byte <= send_data(39 downto 32);
                    uart_tx_dv <= '1';
                    send_active <= '1';
                    byte_count <= 0;
                    uart_state <= SELB;
                end if;

            when SELB =>
                if uart_tx_done = '1' then
                    uart_tx_dv <= '0';
                    case byte_count is
                        when 0 =>
                            uart_tx_byte <= send_data(31 downto 24);
                            uart_state <= SB2;
                        when 1 =>
                            uart_tx_byte <= send_data(23 downto 16);
                            uart_state <= SB3;
                        when 2 =>
                            uart_tx_byte <= send_data(15 downto 8);
                            uart_state <= SB4;
                        when 3 =>
                            uart_tx_byte <= send_data(7 downto 0);
                            uart_state <= SB5;
                        when others =>
                            send_active <= '0';
                            uart_state <= IDL;
                    end case;
                    byte_count <= byte_count + 1;
                end if;

            when SB2 =>
                uart_tx_dv <= '1';
                uart_state <= SELB;

            when SB3 =>
                uart_tx_dv <= '1';
                uart_state <= SELB;

            when SB4 =>
                uart_tx_dv <= '1';
                uart_state <= SELB;
                
            when SB5 =>
                uart_tx_dv <= '1';
                uart_state <= SELB;

            when others =>
                uart_state <= IDL;
        end case;
    end if;
end process;

-- INPUT: 8 bit (unused) + 16 bit (id) + 32 bit (float number) + 8 bit (flags) => 64 total

-- flags = "00000001" - zscore
--       = "00000010" - ewma
--       = "00000100" - cusum

uart_recieve_proc: process(clk)
begin
    if rising_edge(clk) then
        full_float_number_tvalid <= '0';
        if uart_rx_dv = '1' then
            received_data_accumulator <= received_data_accumulator(55 downto 0) & uart_rx_byte;
            rcv_packet_count <= rcv_packet_count + 1;

            if rcv_packet_count = 7 then
                rcv_packet_count <= 0;

                if received_data_accumulator(55 downto 48) = x"FF" then
                    config_done <= '1';

                elsif received_data_accumulator(55 downto 48) = x"01" then
                    -- param_id = acc[47:40], stream_id = acc[39:32], value = acc[31:0]
                    case received_data_accumulator(47 downto 40) is
                        when x"01" => cusum_thr_reg(conv_integer(received_data_accumulator(39 downto 32)))  <= received_data_accumulator(31 downto 0);
                        when x"02" => cusum_drift_reg(conv_integer(received_data_accumulator(39 downto 32))) <= received_data_accumulator(31 downto 0);
                        when x"03" => ewma_alpha_reg(conv_integer(received_data_accumulator(39 downto 32)))  <= received_data_accumulator(31 downto 0);
                        when x"04" => ewma_p_reg(conv_integer(received_data_accumulator(39 downto 32)))   <= received_data_accumulator(31 downto 0);
                        when x"05" => ewma_s0_reg(conv_integer(received_data_accumulator(39 downto 32))) <= received_data_accumulator(31 downto 0);
                        when others => null;
                    end case;

                else
                    full_input <= received_data_accumulator(55 downto 0) & uart_rx_byte;
                    full_float_number_tvalid <= '1';
                end if;
            end if;
        end if;
    end if;
end process;



full_float_number_tdata <= full_input(39 downto 8);
detector_select <= full_input(7 downto 0);
input_id <= full_input(55 downto 40);

zscore_full_float_number_tdata <= full_float_number_tdata when detector_select = "00000001" else (others => '0');
ewma_full_float_number_tdata <= full_float_number_tdata when detector_select = "00000010" else (others => '0');
cusum_full_float_number_tdata(63 downto 32) <= full_float_number_tdata when detector_select = "00000100" else (others => '0');

zscore_full_float_number_tvalid <= full_float_number_tvalid when detector_select = "00000001" else '0';
ewma_full_float_number_tvalid <= full_float_number_tvalid when detector_select = "00000010" else '0';
cusum_full_float_number_tvalid <= full_float_number_tvalid when detector_select = "00000100" else '0';
cusum_drift_tvalid <= full_float_number_tvalid when detector_select = "00000100" else '0';
cusum_thr_tvalid <= full_float_number_tvalid when detector_select = "00000100" else '0';

zscore_full_float_number_id <= input_id when detector_select = "00000001" else (others => '0');
ewma_full_float_number_id <= input_id when detector_select = "00000010" else (others => '0');
cusum_full_float_number_id <= input_id when detector_select = "00000100" else (others => '0');
cusum_full_float_number_tdata(31 downto 16) <= input_id when detector_select = "00000100" else (others => '0');
cusum_full_float_number_tdata(15 downto 0) <= x"0000";


-- OUTPUT: 16 bit (unused) + 16 bit (id) + 8 bit (flags + anomaly) => 40 total

-- flags = "00000001" - zscore
-- norm  = "00000010" - ewma
--       = "00000100" - cusum

-- flags = "10000001" - zscore
-- anorm = "10000010" - ewma
--       = "10000100" - cusum

-- led(0) = anomaly cusum
-- led(1) = anomaly ewma
-- led(2) = anomaly zscore

display_result_proc: process(clk)
begin
    if rising_edge(clk) then
        send_valid <= '0';

        -- Zscore
        if zscore_anomaly_tvalid = '1' then
            display_data_7seg <= full_float_number_tdata;
            send_data <= send_filler & zscore_anomaly_id & zscore_anomaly_tdata(0) & send_flag_zscore;
            send_valid <= '1';
            if zscore_anomaly_tdata(0) = '1' then
                led_hold_zscore <= 33554431;
            end if;
        end if;

        -- EWMA
        if ewma_anomaly_tvalid = '1' then
            display_data_7seg <= full_float_number_tdata;
            send_data <= send_filler & ewma_anomaly_id & ewma_anomaly_tdata(0) & send_flag_ewma;
            send_valid <= '1';
            if ewma_anomaly_tdata(0) = '1' then
                led_hold_ewma <= 33554431;
            end if;
        end if;

        -- CUSUM
        if cusum_anomaly_tvalid = '1' then
            cusum_anomaly_tdata_reduced(0) <= cusum_anomaly_tdata(8);
            cusum_anomaly_id <= cusum_anomaly_tdata(31 downto 16);
            display_data_7seg <= full_float_number_tdata;
            send_data <= send_filler & cusum_anomaly_id & cusum_anomaly_tdata_reduced(0) & send_flag_cusum;
            send_valid <= '1';
            if cusum_anomaly_tdata(8) = '1' then
                led_hold_cusum <= 33554431;
            end if;
        end if;

        -- LED hold countdown
        if led_hold_zscore > 0 then
            led(2) <= '1';
            led_hold_zscore <= led_hold_zscore - 1;
        else
            led(2) <= '0';
        end if;

        if led_hold_ewma > 0 then
            led(1) <= '1';
            led_hold_ewma <= led_hold_ewma - 1;
        else
            led(1) <= '0';
        end if;

        if led_hold_cusum > 0 then
            led(0) <= '1';
            led_hold_cusum <= led_hold_cusum - 1;
        else
            led(0) <= '0';
        end if;

    end if;
end process;


end architecture;
