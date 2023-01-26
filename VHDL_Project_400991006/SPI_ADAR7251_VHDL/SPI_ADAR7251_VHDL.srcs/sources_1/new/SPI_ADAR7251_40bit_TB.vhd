library ieee;
use ieee.std_logic_1164.all;

entity tb_SPI_ADAR7251_40bit is
end tb_SPI_ADAR7251_40bit;

architecture tb of tb_SPI_ADAR7251_40bit is

    component SPI_ADAR7251_40bit
        port (o_SPI_SDO    : out std_logic;
              i_SPI_SDI    : in std_logic;
              o_SPI_SCLK   : out std_logic;
              o_SPI_CSB    : out std_logic;
              o_SPI_DIR    : out std_logic;
              i_clk        : in std_logic;
              i_reset      : in std_logic;
              i_enable     : in std_logic;
              i_reg_rd_wrb : in std_logic;
              i_reg_addr   : in std_logic_vector (15 downto 0);
              i_reg_data   : in std_logic_vector (15 downto 0);
              o_reg_data   : out std_logic_vector (15 downto 0);
              o_busy       : out std_logic;
              o_finish     : out std_logic);
    end component;

    signal o_SPI_SDO    : std_logic;
    signal i_SPI_SDI    : std_logic;
    signal o_SPI_SCLK   : std_logic;
    signal o_SPI_CSB    : std_logic;
    signal o_SPI_DIR    : std_logic;
    signal i_clk        : std_logic;
    signal i_reset      : std_logic;
    signal i_enable     : std_logic;
    signal i_reg_rd_wrb : std_logic;
    signal i_reg_addr   : std_logic_vector (15 downto 0);
    signal i_reg_data   : std_logic_vector (15 downto 0);
    signal o_reg_data   : std_logic_vector (15 downto 0);
    signal o_busy       : std_logic;
    signal o_finish     : std_logic;

    constant TbPeriod : time := 10 ns; 
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : SPI_ADAR7251_40bit
    port map (o_SPI_SDO    => o_SPI_SDO,
              i_SPI_SDI    => i_SPI_SDI,
              o_SPI_SCLK   => o_SPI_SCLK,
              o_SPI_CSB    => o_SPI_CSB,
              o_SPI_DIR    => o_SPI_DIR,
              i_clk        => i_clk,
              i_reset      => i_reset,
              i_enable     => i_enable,
              i_reg_rd_wrb => i_reg_rd_wrb,
              i_reg_addr   => i_reg_addr,
              i_reg_data   => i_reg_data,
              o_reg_data   => o_reg_data,
              o_busy       => o_busy,
              o_finish     => o_finish);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    i_clk <= TbClock;

    stimuli : process
    begin
        i_SPI_SDI <= '0';
        i_enable <= '1';
        i_reg_rd_wrb <= '1';
        i_reg_addr <= "1010000010100000"; -- A0A0
        i_reg_data <= "0000101000001010"; -- 0A0A

        -- Reset generation
        i_reset <= '1';
        wait for 100 ns;
        i_reset <= '0';
        wait for 100 ns;
        i_enable <= '0';
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
