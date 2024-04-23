library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity dlx_proc_tb is
end dlx_proc_tb;

architecture behavioral of dlx_proc_tb  is
	component DLX_test is
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
			RX : in std_logic;  --pin AB2 (pin 39) (green)
			TX : out std_logic  --pin AA2 (pin 40) (white)
		);                      --ground pin is 30
    end component DLX_test;
	
	signal clk_50 : std_logic := '0';
    signal rst : std_logic := '1';
    signal timer : std_logic_vector(63 downto 0) := (others => '0');

	signal hex0 : std_logic_vector(7 downto 0);
	signal hex1 : std_logic_vector(7 downto 0);
	signal hex2 : std_logic_vector(7 downto 0);
	signal hex3 : std_logic_vector(7 downto 0);
	signal hex4 : std_logic_vector(7 downto 0);
	signal hex5 : std_logic_vector(7 downto 0);

	signal tx : std_logic;
	signal rx : std_logic;
	
begin
	
	dlx_er : DLX_test
	port map (
		ADC_CLK_10 => clk_50,
		MAX10_CLK1_50 => clk_50,
		MAX10_CLK2_50 => clk_50,
		HEX0 => hex0,
		HEX1 => hex1,
		HEX2 => hex2,
		HEX3 => hex3,
		HEX4 => hex4,
		HEX5 => hex5,
		KEY(0) => '0',
		KEY(1) => not(rst),
		RX => rx,
		TX => tx
	);
	
	--clk_10 <= not(clk_10) after 50 ns; --10 MHz
    clk_50 <= not(clk_50) after 10 ns; --50 MHz
	
	inputs_mod : process (clk_50)
	begin
		if (rising_edge(clk_50)) then
			timer <= timer + 1;
            if (timer = X"5") then
                rst             <= '0';
            end if;			
		end if;
	end process;
	

end architecture behavioral;