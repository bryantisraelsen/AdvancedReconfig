library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity fetch_tb is
end fetch_tb;

architecture behavioral of fetch_tb  is
	component Fetch_stage is
        port (
            clk : in std_logic;
            rst : in std_logic;
            mux_sel_from_mem : in std_logic;
            address_from_mem : in std_logic_vector(9 downto 0);
            regged_address : out std_logic_vector(9 downto 0);
            regged_instruct : out std_logic_vector(31 downto 0)
        );
        end component Fetch_stage;
	
	signal clk_50 : std_logic := '0';
    signal rst : std_logic := '1';
	signal mux_sel_from_mem : std_logic := '0';
    signal timer : std_logic_vector(31 downto 0) := (others => '0');
    signal address_from_mem : std_logic_vector(9 downto 0) := (others => '0');
    signal regged_address : std_logic_vector(9 downto 0);
    signal regged_instruct : std_logic_vector(31 downto 0);
	
begin
	
	fetcher : Fetch_stage
	port map (
		clk => clk_50,
        rst => rst,
        mux_sel_from_mem => mux_sel_from_mem,
        address_from_mem => address_from_mem,
        regged_address => regged_address,
        regged_instruct => regged_instruct
	);

    --rst <= '0' after 10 us;
	
	--clk_10 <= not(clk_10) after 50 ns; --10 MHz
    clk_50 <= not(clk_50) after 10 ns; --50 MHz
	
	inputs_mod : process (clk_50)
	begin
		if (rising_edge(clk_50)) then
			timer <= timer + 1;
            if (timer = X"40") then
                rst             <= '0';
            elsif (timer = X"48") then
                mux_sel_from_mem <= '1';
                address_from_mem <= '0' & '0' & X"0B";
            elsif (timer = X"49") then
                mux_sel_from_mem <= '0';
            elsif (timer = X"53") then
                mux_sel_from_mem <= '1';
                address_from_mem <= '0' & '0' & X"0E";
            elsif (timer = X"54") then
                mux_sel_from_mem <= '0';
            elsif (timer = X"5B") then
                mux_sel_from_mem <= '1';
                address_from_mem <= '0' & '0' & X"0E";
            elsif (timer = X"5C") then
                mux_sel_from_mem <= '0';
            elsif (timer = X"63") then
                mux_sel_from_mem <= '1';
                address_from_mem <= '0' & '0' & X"0E";
            elsif (timer = X"64") then
                mux_sel_from_mem <= '0';
            elsif (timer = X"68") then
                mux_sel_from_mem <= '1';
                address_from_mem <= '0' & '0' & X"13";
            elsif (timer = X"69") then
                mux_sel_from_mem <= '0';
            elsif (timer = X"6C") then
                mux_sel_from_mem <= '1';
                address_from_mem <= '0' & '0' & X"06";
            elsif (timer = X"6D") then
                mux_sel_from_mem <= '0';
            elsif (timer = X"300") then
                mux_sel_from_mem <= '1';
            end if;			
		end if;
	end process;
	

end architecture behavioral;