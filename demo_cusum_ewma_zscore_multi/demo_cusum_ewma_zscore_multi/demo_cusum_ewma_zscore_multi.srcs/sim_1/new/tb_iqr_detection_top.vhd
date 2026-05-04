library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_iqr_detection_top is
end tb_iqr_detection_top;

architecture tb_iqr_detection_top_arch of tb_iqr_detection_top is

    signal aclk: std_logic := '0';
    signal aresetn: std_logic := '0';

    signal Q1_tvalid: std_logic := '0';
    signal Q1_tdata: std_logic_vector(31 downto 0) := (others => '0');
    signal Q1_tready: std_logic;

    signal Q3_tvalid: std_logic := '0';
    signal Q3_tdata: std_logic_vector(31 downto 0) := (others => '0');
    signal Q3_tready: std_logic;

    signal Value_tvalid: std_logic := '0';
    signal Value_tdata: std_logic_vector(31 downto 0) := (others => '0');
    signal Value_tready: std_logic;

    signal outlier_detection: std_logic;
    signal normal_detection: std_logic;
    signal detection_tvalid: std_logic;
    
    constant clk_period: time := 10 ns;

    constant Q1_VALUE: std_logic_vector(31 downto 0) := x"40000000"; -- 2.0
    constant Q3_VALUE: std_logic_vector(31 downto 0) := x"41000000"; -- 8.0

    type vector_array is array(natural range <>) of std_logic_vector(31 downto 0);
    constant VALUE_NORMALS  : vector_array := (
        x"40A00000", x"41175c29", x"4141c28f", x"4121eb85", x"41871eb8" -- 5.0, 9.46, 12.11, 10.12, 16.89
    );
    constant VALUE_OUTLIERS : vector_array := (
        x"c293570a", x"c0e051ec", x"419b999a", x"41890a3d", x"41990ce7" -- -73.67, -7.01, 19.45, 17.13, 19.1313
    );

begin

    uut: entity work.iqr_detection_top
        port map (
            aclk => aclk,
            aresetn => aresetn,
            Q1_tvalid => Q1_tvalid,
            Q1_tdata  => Q1_tdata,
            Q1_tready => Q1_tready,
            Q3_tvalid => Q3_tvalid,
            Q3_tdata  => Q3_tdata,
            Q3_tready => Q3_tready,
            Value_tvalid => Value_tvalid,
            Value_tdata  => Value_tdata,
            Value_tready => Value_tready,
            outlier_detection => outlier_detection,
            normal_detection => normal_detection,
            detection_tvalid => detection_tvalid
        );

clk_process: process
begin
    aclk <= '0';
    wait for clk_period / 2;
    aclk <= '1';
    wait for clk_period / 2;
end process;


sim_process: process
begin
    aresetn <= '0';
    wait for 20 ns;
    aresetn <= '1';
    wait for 20 ns;

    for i in VALUE_NORMALS'range loop
        wait until rising_edge(aclk) and Q1_tready = '1' and Q3_tready = '1' and Value_tready = '1';
        Q1_tdata <= Q1_VALUE;
        Q3_tdata <= Q3_VALUE;
        Q1_tvalid <= '1';
        Q3_tvalid <= '1';
        Value_tdata <= VALUE_NORMALS(i);
        Value_tvalid <= '1';

        wait for clk_period;

        Q1_tvalid <= '0';
        Q3_tvalid <= '0';
        Value_tvalid <= '0';

        wait for 10 ns;
    end loop;

    for i in VALUE_OUTLIERS'range loop
        wait until rising_edge(aclk) and Q1_tready = '1' and Q3_tready = '1' and Value_tready = '1';
        Q1_tdata <= Q1_VALUE;
        Q3_tdata <= Q3_VALUE;
        Q1_tvalid <= '1';
        Q3_tvalid <= '1';
        Value_tdata <= VALUE_OUTLIERS(i);
        Value_tvalid <= '1';

        wait for clk_period;

        Q1_tvalid <= '0';
        Q3_tvalid <= '0';
        Value_tvalid <= '0';

        wait for 10 ns;
    end loop;

    wait;
end process;


end architecture;
