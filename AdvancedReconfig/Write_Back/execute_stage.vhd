library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

library work;
use work.dlx_pkg.all;

entity execute_stage is
	port (
		clk : in std_logic;
        rst : in std_logic;
        --inputs from decode
        nxt_pc : in std_logic_vector(9 downto 0);
        instruct : in std_logic_vector(31 downto 0);
        sign_extend_immediate : in std_logic_vector(31 downto 0);
        reg_0 : in std_logic_vector(31 downto 0);
        reg_1 : in std_logic_vector(31 downto 0);
        --outputs
        take_branch : out std_logic := '0';
        jmp_address : out std_logic_vector(31 downto 0);
        ALU_out : out std_logic_vector(31 downto 0);
        regged_instruct : out std_logic_vector(31 downto 0);
        reg_1_out : out std_logic_vector(31 downto 0)
	);
end execute_stage;

architecture rtl of execute_stage is

signal ALU_in_0 : std_logic_vector(31 downto 0);
signal ALU_in_1 : std_logic_vector(31 downto 0);
signal op_code : std_logic_vector(5 downto 0);

begin

    --opcode
    op_code <= instruct(31 downto 26) when rst = '0' else "00" & X"0";

    --zero? block
    zero_blck : process(clk)
    begin
        if (rising_edge(clk)) then
            case op_code is
                when c_BEQZ =>
                    if (reg_0 = X"00000000") then
                        take_branch <= '1';
                        jmp_address <= sign_extend_immediate;
                    else
                        take_branch <= '0';
                    end if;
                when c_BNEZ =>
                    if (reg_0 /= X"00000000") then
                        take_branch <= '1';
                        jmp_address <= sign_extend_immediate;
                    else
                        take_branch <= '0';
                    end if;
                when c_J =>
                    take_branch <= '1';
                    jmp_address <= sign_extend_immediate;
                when c_JR =>
                    take_branch <= '1';
                    jmp_address <= reg_0;
                when c_JAL =>
                    take_branch <= '1';
                    jmp_address <= sign_extend_immediate;
                when c_JALR =>
                    take_branch <= '1';
                    jmp_address <= reg_0;
                when others =>
                    take_branch <= '0';
            end case;
        end if;
    end process;

    --MUX 0
    ALU_in_0 <= "00" & X"00000" & nxt_pc when (op_code = c_JAL or op_code = c_JALR) else reg_0;  --figure out when this is used (from op code somehow)

    --MUX 1
    ALU_in_1 <= sign_extend_immediate when (op_code = c_SW or op_code = c_LW or op_code = c_ADDI or op_code = c_ADDUI or op_code = c_SUBI or op_code = c_SUBUI
        or op_code = c_ANDI or op_code = c_ORI or op_code = c_XORI or op_code = c_SLLI or op_code = c_SRLI
        or op_code = c_SRAI or op_code = c_SLTI or op_code = c_SLTUI or op_code = c_SGTI or op_code = c_SGTUI
        or op_code = c_SLEI or op_code = c_SLEUI or op_code = c_SGEI or op_code = c_SGEUI or op_code = c_SEQI 
        or op_code = c_SNEI or op_code = c_BEQZ or op_code = c_BNEZ or op_code = c_J or op_code = c_JAL) else reg_1;

    --ALU
    ALU : process (clk)
    begin
        if (rising_edge(clk)) then
            case op_code is
                when c_LW =>
                    ALU_out <= std_logic_vector(unsigned(ALU_in_0) + unsigned(ALU_in_1));
                when c_SW =>
                    ALU_out <= std_logic_vector(unsigned(ALU_in_0) + unsigned(ALU_in_1));
                when c_ADD =>
                    ALU_out <= std_logic_vector(signed(ALU_in_0) + signed(ALU_in_1));
                when c_ADDI =>
                    ALU_out <= std_logic_vector(signed(ALU_in_0) + signed(ALU_in_1));
                when c_ADDU =>
                    ALU_out <= std_logic_vector(unsigned(ALU_in_0) + unsigned(ALU_in_1));
                when c_ADDUI =>
                    ALU_out <= std_logic_vector(unsigned(ALU_in_0) + unsigned(ALU_in_1));
                when c_SUB =>
                    ALU_out <= std_logic_vector(signed(ALU_in_0) - signed(ALU_in_1));
                when c_SUBI =>
                    ALU_out <= std_logic_vector(signed(ALU_in_0) - signed(ALU_in_1));
                when c_SUBU =>
                    ALU_out <= std_logic_vector(unsigned(ALU_in_0) - unsigned(ALU_in_1));
                when c_SUBUI =>
                    ALU_out <= std_logic_vector(unsigned(ALU_in_0) - unsigned(ALU_in_1));
                when c_AND =>
                    ALU_out <= ALU_in_0 and ALU_in_1;
                when c_ANDI =>
                    ALU_out <= ALU_in_0 and ALU_in_1;
                when c_OR =>
                    ALU_out <= ALU_in_0 or ALU_in_1;
                when c_ORI =>
                    ALU_out <= ALU_in_0 or ALU_in_1;
                when c_XOR =>
                    ALU_out <= ALU_in_0 xor ALU_in_1;
                when c_XORI =>
                    ALU_out <= ALU_in_0 xor ALU_in_1;
                when c_SLL =>
                    ALU_out <= std_logic_vector(shift_left(signed(ALU_in_0), to_integer(unsigned(ALU_in_1))));
                when c_SLLI =>
                    ALU_out <= std_logic_vector(shift_left(unsigned(ALU_in_0), to_integer(unsigned(ALU_in_1))));
                when c_SRL =>
                    ALU_out <= std_logic_vector(shift_right(unsigned(ALU_in_0), to_integer(unsigned(ALU_in_1))));
                when c_SRLI =>
                    ALU_out <= std_logic_vector(shift_right(unsigned(ALU_in_0), to_integer(unsigned(ALU_in_1))));
                when c_SRA =>
                    ALU_out <= std_logic_vector(shift_right(signed(ALU_in_0), to_integer(unsigned(ALU_in_1))));
                when c_SRAI =>
                    ALU_out <= std_logic_vector(shift_right(signed(ALU_in_0), to_integer(unsigned(ALU_in_1))));
                when c_SLT =>
                    if (signed(ALU_in_0) < signed(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SLTI =>
                    if (signed(ALU_in_0) < signed(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SLTU =>
                    if (unsigned(ALU_in_0) < unsigned(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SLTUI =>
                    if (unsigned(ALU_in_0) < unsigned(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SGT =>
                    if (signed(ALU_in_0) > signed(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SGTI =>
                    if (signed(ALU_in_0) > signed(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SGTU =>
                    if (unsigned(ALU_in_0) > unsigned(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SGTUI =>
                    if (unsigned(ALU_in_0) > unsigned(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SLE =>
                    if (signed(ALU_in_0) <= signed(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SLEI =>
                    if (signed(ALU_in_0) <= signed(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SLEU =>
                    if (unsigned(ALU_in_0) <= unsigned(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SLEUI =>
                    if (unsigned(ALU_in_0) <= unsigned(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SGE =>
                    if (signed(ALU_in_0) >= signed(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SGEI =>
                    if (signed(ALU_in_0) >= signed(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SGEU =>
                    if (unsigned(ALU_in_0) >= unsigned(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SGEUI =>
                    if (unsigned(ALU_in_0) >= unsigned(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SEQ =>
                    if (unsigned(ALU_in_0) = unsigned(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SEQI =>
                    if (unsigned(ALU_in_0) = unsigned(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SNE =>
                    if (unsigned(ALU_in_0) /= unsigned(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_SNEI =>
                    if (unsigned(ALU_in_0) /= unsigned(ALU_in_1)) then
                        ALU_out <= X"00000001";
                    else
                        ALU_out <= X"00000000";
                    end if;
                when c_BEQZ =>
                    ALU_out <= ALU_in_0;
                when c_BNEZ =>
                    ALU_out <= ALU_in_0;
                when c_J =>
                    ALU_out <= ALU_in_0;
                when c_JR =>
                    ALU_out <= ALU_in_0;
                when c_JAL =>
                    ALU_out <= ALU_in_0;
                when c_JALR =>
                    ALU_out <= ALU_in_0;
                when others =>
                    ALU_out <= (others => 'X');
            end case;
        end if;
    end process;

    reg_values : process(clk)
    begin
        if (rising_edge(clk)) then
            regged_instruct <= instruct;
            reg_1_out <= reg_1;
        end if;
    end process;

end rtl;