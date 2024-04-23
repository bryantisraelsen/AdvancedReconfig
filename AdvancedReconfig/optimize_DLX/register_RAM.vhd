library ieee;
use ieee.std_logic_1164.all;

entity register_RAM is
	port
	(
		data_i	: in std_logic_vector(31 downto 0);
		wr_addr	: in natural range 0 to 31;
		rd_addr0 : in natural range 0 to 31;
		rd_addr1 : in natural range 0 to 31;
		we_en	: in std_logic := '1';
		clk		: in std_logic;
		reg0_q	: out std_logic_vector(31 downto 0);
		reg1_q	: out std_logic_vector(31 downto 0)
	);
	
end entity;

architecture rtl of register_RAM is

	-- Build a 2-D array type for the RAM
	subtype reg is std_logic_vector(31 downto 0);
	type memory_t is array(31 downto 0) of reg;
	
	-- Declare the RAM signal.
	signal reg_ram : memory_t;
	
	-- Register to hold the address
	signal addr_reg : natural range 0 to 63;

begin

	process(clk)
	begin
		if(rising_edge(clk)) then
			if(we_en = '1') then
				reg_ram(wr_addr) <= data_i;
			end if;

			--if register 0 always return 0 (for reg_address 0)
			if (rd_addr0 = 0) then
				reg0_q <= (others => '0');
			elsif (wr_addr = rd_addr0 and we_en = '1') then
				reg0_q <= data_i;
			else
				reg0_q <= reg_ram(rd_addr0);
			end if;
			--if register 0 always return 0 (for reg_address 1)
			if (rd_addr1 = 0) then
				reg1_q <= (others => '0');
			elsif (wr_addr = rd_addr1 and we_en = '1') then
				reg1_q <= data_i;
			else
				reg1_q <= reg_ram(rd_addr1);
			end if;
		end if;
	
	end process;
	
end rtl;
