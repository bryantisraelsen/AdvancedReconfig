library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity UART_tb is
end UART_tb;

architecture behavioral of UART_tb  is
	component uart_1 is
        port (
            ADC_CLK_10 : in std_logic;
            MAX10_CLK1_50 : in std_logic;
            MAX10_CLK2_50 : in std_logic;
            HEX0 : out std_logic_vector(7 downto 0) := (others => '1');
            HEX1 : out std_logic_vector(7 downto 0) := (others => '1');
            HEX2 : out std_logic_vector(7 downto 0) := (others => '1');
            HEX3 : out std_logic_vector(7 downto 0) := (others => '1');
            HEX4 : out std_logic_vector(7 downto 0) := (others => '1');
            HEX5 : out std_logic_vector(7 downto 0) := (others => '1');
            KEY : in std_logic_vector(1 downto 0);
            RX : in std_logic;  --check which pin AB2 is (white)
            TX : out std_logic  --check which pin AA2 is (green)
        );                      --ground pin is 30
    end component uart_1;
	
	signal clk : std_logic := '0';
    signal clk_10 : std_logic := '0';
    signal clk_50 : std_logic := '0';
    signal key : std_logic_vector(1 downto 0) := (others => '1');
	signal rx_wire : std_logic := '1';
    signal timer : std_logic_vector(31 downto 0) := (others => '0');
    signal tx_wire : std_logic;
	
begin
	
	uut : uart_1
	port map (
		ADC_CLK_10 => clk_10,
        MAX10_CLK1_50 => clk_50,
        MAX10_CLK2_50 => clk_50,
        rx => rx_wire,
        key => key,
        tx => tx_wire
	);

    clk <= not(clk) after 3.2552 us; --153.6 kHz
	
	clk_10 <= not(clk_10) after 50 ns; --10 MHz
    clk_50 <= not(clk_50) after 10 ns; --50 MHz
	
	inputs_mod : process (clk)
	begin
		if (rising_edge(clk)) then
			timer <= timer + 1;
			if (timer = 0) then
				rx_wire <= '1';
			elsif(timer = 20) then
				rx_wire <= '0';
            elsif(timer = 21) then
                rx_wire <= '1';
			elsif(timer = 28) then
				rx_wire <= '1';
			elsif(timer = 36) then
				rx_wire <= '0';
			elsif(timer = 44) then
				rx_wire <= '0';
			elsif(timer = 52) then
				rx_wire <= '1';
			elsif(timer = 60) then
				rx_wire <= '1';
            elsif(timer = 68) then
                rx_wire <= '0';
            elsif(timer = 76) then
                rx_wire <= '1';
            elsif(timer = 84) then
                rx_wire <= '0';
            elsif(timer = 92) then
                rx_wire <= '1';
			end if;
		end if;
	end process;
	

end architecture behavioral;