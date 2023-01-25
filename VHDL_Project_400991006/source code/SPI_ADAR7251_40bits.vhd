library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
--###########################################################################
entity SPI_ADAR7251_40bit is
	port(
		o_SPI_SDO    : out      std_logic;  --connect to SDIO        
		i_SPI_SDI    : in       std_logic;  --connect to SDIO        
		o_SPI_SCLK   : out      std_logic;  --connect to SCLK
		o_SPI_CSB    : out      std_logic;  --connect to CSB
		o_SPI_DIR    : out      std_logic;  --connect to SDO
		-- Signal from\to other blocks
		i_clk		 : in		std_logic;
		i_reset		 : in 		std_logic;
		i_enable	 : in		std_logic;		
		i_reg_rd_wrb : in		std_logic;	
		i_reg_addr	 : in       std_logic_vector(15 downto 0);
		i_reg_data	 : in       std_logic_vector(15 downto 0);	
		o_reg_data	 : out 		std_logic_vector(15 downto 0);
		o_busy		 : out 		std_logic;
		o_finish	 : out 		std_logic	
		);
end SPI_ADAR7251_40bit;
--###########################################################################
architecture Behavioral of SPI_ADAR7251_40bit is
--######################################################################
-- Constant Declerations
--######################################################################
	Constant C_ADDR15	: STD_LOGIC := '1';
--######################################################################
-- Type Decleration
--######################################################################
	type   SPIStateType is (NOP, FirstBit, RxTxData, Read_state ,LastBit);
--######################################################################
-- Signal Decleration
--###################################################################### 	
	signal SPIState    : SPIStateType;
	signal SClkSig     : std_logic;
	signal sdo_tmp     : std_logic;
	signal DataOut     : std_logic_vector(15 downto 0);
	signal data_in_reg : std_logic_vector(39 downto 0);
--###########################################################################
begin
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    o_SPI_SCLK      <= SClkSig;
    o_reg_data      <= DataOut(15 downto 0);
	o_SPI_SDO       <= sdo_tmp ;
	--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    spi_trx : process(i_clk)  
        variable Index : integer range 0 to 39;
    begin
		if rising_edge(i_clk) then
			-----------------------
			if (i_reset = '1') then
				SPIState    <= NOP;
				sdo_tmp	    <= '0';
				o_SPI_CSB	<= '1';
				SClkSig     <= '0';
				DataOut     <= (others => '0');
				Index       := 39;
				o_busy      <= '0';
				o_finish    <= '0';
				o_SPI_DIR   <= '0';
				data_in_reg <= (others => '0');
			-----------------------
			else 
				case SPIState is
					--***************************
					when NOP =>
						o_SPI_DIR <= '0';
						o_finish  <= '0';
						if (i_enable = '1') then
							SPIState    <= FirstBit;
							o_SPI_CSB   <= '0';
							SClkSig     <= '0';
							o_busy      <= '1';
							if i_reg_rd_wrb = '1' then
								data_in_reg <= "000000" & C_ADDR15 & "1" & i_reg_addr & i_reg_data;
							else
								data_in_reg <= "000000" & C_ADDR15 & "0" & i_reg_addr & i_reg_data;
							end if;
						else	
							o_SPI_CSB	<= '1';	
						end if;
					--***************************
					when FirstBit =>
						SPIState <= RxTxData;
						Index    := 39;
						sdo_tmp  <= data_in_reg(Index);
					--***************************
					when RxTxData => 
						SClkSig <= not SClkSig;
						if (SClkSig = '1') then
							if data_in_reg(32) = '0' then
								if (Index = 0) then
									SPIState <= LastBit;
								else
									Index   := Index - 1;
									sdo_tmp <= data_in_reg(Index);
								end if;
							else
								if (Index = 16) then
									SPIState  <= Read_state;
									Index     := Index - 1;
									o_SPI_DIR <= '1';
								else
									Index   := Index - 1;
									sdo_tmp <= data_in_reg(Index);
								end if;							
							end if;	
					end if; 
					--***************************
					when Read_state =>
						SClkSig <= not SClkSig;
						o_SPI_DIR 	<= '1';
						if SClkSig = '1' then
							if index = 0 then
								SPIState <= LastBit;
							end if;					
							DataOut(Index) <= i_SPI_SDI;
							Index := Index - 1;
						end if;
					--***************************
					when LastBit =>						
						o_SPI_DIR <= '0';
						SPIState <= NOP;
						o_SPI_CSB    <= '1';
						o_finish <= '1';
						o_busy   <= '0';

				end case;
			end if;
		end if;	
    end process;
--###########################################################################
end Behavioral;
