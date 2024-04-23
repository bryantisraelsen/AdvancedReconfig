library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity rx_tb is
end rx_tb;

architecture behavioral of rx_tb  is
	component uart_rx is
        port (
            clk : in std_logic;
            rst : in std_logic;
            rx_wire : in std_logic;
            fifo_ready : in std_logic;
            write_out : out std_logic;
            data_out : inout std_logic_vector(7 downto 0)
        );
    end component uart_rx;
	
	signal clk : std_logic := '0';
    signal rst : std_logic := '1';
	signal rx_wire : std_logic := '1';
    signal fifo_ready : std_logic := '1';
    signal write_out : std_logic;
    signal data_out : std_logic_vector(7 downto 0);
    signal timer : std_logic_vector(31 downto 0) := (others => '0');
	
begin
	
	uut : uart_rx
	port map (
		clk => clk,
		rst => rst,
        rx_wire => rx_wire,
        fifo_ready => '1',
        write_out => write_out,
        data_out => data_out
	);
	
	clk <= not(clk) after 6.5104 us; --153.6 kHz
    rst <= '0' after 50 us;
	
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