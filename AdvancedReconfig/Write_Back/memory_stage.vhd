library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library work;
use work.dlx_pkg.all;

entity memory_stage is
	port (
		clk : in std_logic;
        rst : in std_logic;
        --inputs from execute
        ALU_out : in std_logic_vector(31 downto 0);
        instruct : in std_logic_vector(31 downto 0);
        reg_1 : in std_logic_vector(31 downto 0);
        --outputs
        ALU_out_regged : out std_logic_vector(31 downto 0);
        mem_data_out : out std_logic_vector(31 downto 0);
        regged_instruct : out std_logic_vector(31 downto 0)
	);
end memory_stage;

architecture rtl of memory_stage is

signal op_code : std_logic_vector(5 downto 0);
signal mem_wr_en : std_logic;

component data_mem
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
end component;

begin

    --opcode
    op_code <= instruct(31 downto 26) when rst = '0' else "00" & X"0";

    data_mem_inst : data_mem 
    PORT MAP (
		address	 => ALU_out(9 downto 0),
		clock	 => clk,
		data	 => reg_1,
		wren	 => mem_wr_en,
		q	 => mem_data_out
	);
    mem_wr_en <= '1' when op_code = c_SW else '0';

    reg_values : process(clk)
    begin
        if (rising_edge(clk)) then
            regged_instruct <= instruct;
            ALU_out_regged <= ALU_out;
        end if;
    end process;

end rtl;