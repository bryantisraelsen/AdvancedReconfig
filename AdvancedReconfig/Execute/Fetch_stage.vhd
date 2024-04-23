library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity Fetch_stage is
	port (
		clk : in std_logic;
        rst : in std_logic;
        mux_sel_from_mem : in std_logic;
        address_from_mem : in std_logic_vector(9 downto 0);
        regged_address : out std_logic_vector(9 downto 0);
        regged_instruct : out std_logic_vector(31 downto 0)
	);
end Fetch_stage;

architecture rtl of Fetch_stage is

    component instructions_ROM
        PORT
        (
            address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
            clock		: IN STD_LOGIC  := '1';
            q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    end component;

    signal pc : std_logic_vector(9 downto 0) := (others => '0');
    signal address_incremented : std_logic_vector(9 downto 0);

begin

    instruct : instructions_ROM PORT MAP (
		address	 => pc,
		clock	 => clk,
		q	    => regged_instruct
	);

    address_incremented <= pc + 1;
    regged_address <= pc;

    update_address : process (clk)
	begin
		if (rising_edge(clk)) then
			if (rst = '1') then
                pc <= (others => '0');
            elsif (mux_sel_from_mem = '1') then
                pc <= address_from_mem;
            else
                pc <= address_incremented;
            end if;
		end if;
	end process;

end rtl;


