library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.dlx_pkg.all;

entity write_back_stage is
	port (
		clk : in std_logic;
        rst : in std_logic;
        --inputs from memory
        ALU_out : in std_logic_vector(31 downto 0);
        mem_data_out : in std_logic_vector(31 downto 0);
        instruct : in std_logic_vector(31 downto 0);
        --outputs
        reg_wr_address : out std_logic_vector(4 downto 0);
        reg_wr_data : out std_logic_vector(31 downto 0);
        reg_wr_en : out std_logic
	);
end write_back_stage;

architecture rtl of write_back_stage is

signal op_code : std_logic_vector(5 downto 0);

begin

    --opcode
    op_code <= instruct(31 downto 26) when rst = '0' else "00" & X"0";

    reg_wr_data <= mem_data_out when op_code = c_LW else ALU_out;
    reg_wr_address <= '1' & X"F" when op_code = c_JAL or op_code = c_JALR else instruct(25 downto 21);   --make sure this is always true
    
    reg_wr_en <= '1' when rst = '0' and (op_code = c_LW or op_code = c_ADD or op_code = c_ADDX or op_code = c_ADDY or op_code = c_ADDI or op_code = c_ADDU or op_code = c_ADDUI or op_code = c_SUB 
                                    or op_code = c_SUBI or op_code = c_SUBU or op_code = c_SUBUI or op_code = c_AND or op_code = c_ANDI or op_code = c_OR
                                    or op_code = c_ORI or op_code = c_XOR or op_code = c_XORI or op_code = c_SLL or op_code = c_SLLI or op_code = c_SRL
                                    or op_code = c_SRLI or op_code = c_SRA or op_code = c_SRAI or op_code = c_SLT or op_code = c_SLTI or op_code = c_SLTU
                                    or op_code = c_SLTUI or op_code = c_SGT or op_code = c_SGTI or op_code = c_SGTU or op_code = c_SGTUI or op_code = c_SLE
                                    or op_code = c_SLEI or op_code = c_SLEU or op_code = c_SLEUI or op_code = c_SGE or op_code = c_SGEI or op_code = c_SGEU
                                    or op_code = c_SGEUI or op_code = c_SEQ or op_code = c_SEQI or op_code = c_SNE or op_code = c_SNEI or op_code = c_JAL 
                                    or op_code = c_JALR or op_code = c_GD or op_code = c_GDU) else '0';

end rtl;