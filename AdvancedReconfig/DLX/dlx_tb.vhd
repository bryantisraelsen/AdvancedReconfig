library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity dlx_tb is
end dlx_tb;

architecture behavioral of dlx_tb  is
	component dlx is
        port (
            clk : in std_logic;
            rst : in std_logic
        );
    end component dlx;
	
	signal clk_50 : std_logic := '0';
    signal rst : std_logic := '1';
    signal timer : std_logic_vector(63 downto 0) := (others => '0');
	
begin
	
	dlx_er : dlx
	port map (
		clk => clk_50,
        rst => rst
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