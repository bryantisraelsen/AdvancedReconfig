library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stack is
	port (
		clk : in std_logic;
        rst : in std_logic;
        --input data
        data_i : in std_logic_vector(7 downto 0);
        wr_en : in std_logic;
        --output
        data_o : out std_logic_vector(7 downto 0);
        rd_en : in std_logic;
        --empty
        empty : out std_logic
	);
end stack;

architecture rtl of stack is

    type mem_type is array (0 to 10) of std_logic_vector(7 downto 0);
    signal stack_mem : mem_type := (others => (others => '0'));
    signal stack_pointer : integer := 0;

begin

    empty <= '1' when stack_pointer = 0 else '0';
    stacky_stack : process(clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                stack_pointer <= 0;
            elsif (wr_en = '1') then
                stack_pointer <= stack_pointer + 1;
                stack_mem(stack_pointer+1) <= data_i;
            elsif (rd_en = '1' and stack_pointer /= 0) then
                stack_pointer <= stack_pointer - 1;
                data_o <= stack_mem(stack_pointer);
            end if;
        end if;
    end process;


end rtl;