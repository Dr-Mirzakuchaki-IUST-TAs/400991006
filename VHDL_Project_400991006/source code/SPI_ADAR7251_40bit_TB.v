`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////

module TB_SPI_40;

	// Inputs
	reg i_SPI_SDI;
	reg i_clk;
	reg i_reset;
	reg i_enable;
	reg i_reg_rd_wrb;
	reg [15:0] i_reg_addr;
	reg [15:0] i_reg_data;

	// Outputs
	wire o_SPI_SDO;
	wire o_SPI_SCLK;
	wire o_SPI_CSB;
	wire o_SPI_DIR;
	wire [15:0] o_reg_data;
	wire o_busy;
	wire o_finish;

	// Instantiate the Unit Under Test (UUT)
	SPI_ADAR7251_40bit uut (
		.o_SPI_SDO(o_SPI_SDO), 
		.i_SPI_SDI(i_SPI_SDI), 
		.o_SPI_SCLK(o_SPI_SCLK), 
		.o_SPI_CSB(o_SPI_CSB), 
		.o_SPI_DIR(o_SPI_DIR), 
		.i_clk(i_clk), 
		.i_reset(i_reset), 
		.i_enable(i_enable), 
		.i_reg_rd_wrb(i_reg_rd_wrb), 
		.i_reg_addr(i_reg_addr), 
		.i_reg_data(i_reg_data), 
		.o_reg_data(o_reg_data), 
		.o_busy(o_busy), 
		.o_finish(o_finish)
	);

	initial begin
		// Initialize Inputs
		i_SPI_SDI = 0;
		i_clk = 1;
		i_reset = 1;
		i_enable = 0;
		i_reg_rd_wrb = 1;
		i_reg_addr = 16'h0505;;
		i_reg_data = 16'haaaa;

		// Wait 100 ns for global reset to finish
		#101;
        i_reset = 0;
		#50;
		i_enable =1;
		#10;
		i_enable =0;
		// Add stimulus here

	end
 always #5 i_clk = ~i_clk;    
endmodule

