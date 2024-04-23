library ieee;
use ieee.std_logic_1164.all;
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
        reg_1_out : out std_logic_vector(31 downto 0);
        --write to tx fifo
        tx_fifo_valid : out std_logic := '0';
        --write to unsigned state machine
        unsigned_valid : out std_logic := '0';
        --write to signed state machine
        signed_valid : out std_logic := '0';
        --stall when full but writing to fifo
        state_machine_stall : in std_logic;
        state_machine_finished : in std_logic;
        stall : out std_logic := '0';
        --forwarded data
        for_reg_prev0 : in std_logic_vector(31 downto 0); --from output of ALU (output of execute stage, this stage)
        for_reg_prev1 : in std_logic_vector(31 downto 0);  --from output of ALU (output of memory stage, next stage)
        for_reg_prev1_mem : in std_logic_vector(31 downto 0)    --from output of Memory (output of memory stage, next stage)
	);
end execute_stage;

architecture rtl of execute_stage is

signal ALU_in_0 : std_logic_vector(31 downto 0);
signal ALU_in_1 : std_logic_vector(31 downto 0);
signal op_code : std_logic_vector(5 downto 0);
signal dest_reg : std_logic_vector(4 downto 0);

--regging previous registers addresses being written to
signal dest_reg_prev0 : std_logic_vector(4 downto 0);
signal dest_reg_prev1 : std_logic_vector(4 downto 0);

--source registers
signal rs0 : std_logic_vector(4 downto 0);
signal rs1 : std_logic_vector(4 downto 0);

--reg_0/1 replacements
signal reg_0_replace : std_logic_vector(31 downto 0);
signal reg_1_replace : std_logic_vector(31 downto 0);

--prev op_code
signal prev_op_code0 : std_logic_vector(5 downto 0);
signal prev_op_code1 : std_logic_vector(5 downto 0);

begin

    --opcode
    op_code <= (others => '0') when rst = '1' or stall = '1' else instruct(31 downto 26);
    --destination register
    dest_reg <= instruct(25 downto 21) when rst = '0' and op_code /= c_SW and op_code /= c_NOP and op_code /= c_J and op_code /= c_JAL and op_code /= c_JALR and op_code /= c_JR and op_code /= c_BEQZ and op_code /= c_BNEZ else "0" & X"0";
    --reg0 has register we are comparing for BEQZ and BNEZ
    rs0 <= instruct(4 downto 0) when op_code = c_JR or op_code = c_JALR or op_code = c_PCH or op_code = c_PD or op_code = c_PDU else instruct(20 downto 16) when op_code = c_LW or op_code = c_SW else instruct(25 downto 21) when op_code = c_BEQZ or op_code = c_BNEZ else instruct(20 downto 16);
    --NOTE: when SW reg1 is from bits 25 to 21
    rs1 <= instruct(25 downto 21) when op_code = c_SW else instruct(15 downto 11);

    --reg destination register
    prevDestReg : process(clk)
    begin
        if (rising_edge(clk)) then
            dest_reg_prev0 <= dest_reg;
            dest_reg_prev1 <= dest_reg_prev0;           
        end if;
    end process;

    --update the signal going into ALU when necessary
    update_reg_replacements : process(all)
    begin
        if (dest_reg_prev0 = rs0 and rs0 /= "0" & X"0") then
            reg_0_replace <= for_reg_prev0;
        elsif (dest_reg_prev1 = rs0 and rs0 /= "0" & X"0") then
            if (prev_op_code1 = c_LW) then
                reg_0_replace <= for_reg_prev1_mem;
            else
                reg_0_replace <= for_reg_prev1;
            end if;
        else
            reg_0_replace <= reg_0;
        end if;

        if (dest_reg_prev0 = rs1 and rs1 /= "0" & X"0") then
            reg_1_replace <= for_reg_prev0;
        elsif (dest_reg_prev1 = rs1 and rs1 /= "0" & X"0") then
            if (prev_op_code1 = c_LW) then
                reg_1_replace <= for_reg_prev1_mem;
            else
                reg_1_replace <= for_reg_prev1;
            end if;
        else
            reg_1_replace <= reg_1;
        end if;
    end process;

    --zero? block
    zero_blck : process(clk)
    begin
        if (rising_edge(clk)) then
            case op_code is
                when c_BEQZ =>
                    if (reg_0_replace = X"00000000" and take_branch = '0') then
                        take_branch <= '1';
                        jmp_address <= sign_extend_immediate;
                    else
                        take_branch <= '0';
                    end if;
                when c_BNEZ =>
                    if (reg_0_replace /= X"00000000" and take_branch = '0') then
                        take_branch <= '1';
                        jmp_address <= sign_extend_immediate;
                    else
                        take_branch <= '0';
                    end if;
                when c_J =>
                    if (take_branch = '0') then
                        take_branch <= '1';
                        jmp_address <= sign_extend_immediate;
                    else
                        take_branch <= '0';
                    end if;
                when c_JR =>
                    if (take_branch = '0') then
                        take_branch <= '1';
                        jmp_address <= reg_0_replace;
                    else
                        take_branch <= '0';
                    end if;
                when c_JAL =>
                    if (take_branch = '0') then
                        take_branch <= '1';
                        jmp_address <= sign_extend_immediate;
                    else
                        take_branch <= '0';
                    end if;
                when c_JALR =>
                    if (take_branch = '0') then
                        take_branch <= '1';
                        jmp_address <= reg_0_replace;
                    else
                        take_branch <= '0';
                    end if;
                when others =>
                    take_branch <= '0';
            end case;
        end if;
    end process;

    --MUX 0
    ALU_in_0 <= "00" & X"00000" & nxt_pc when (op_code = c_JAL or op_code = c_JALR) else reg_0_replace;

    --MUX 1
    ALU_in_1 <= sign_extend_immediate when (op_code = c_SW or op_code = c_LW or op_code = c_ADDI or op_code = c_ADDUI or op_code = c_SUBI or op_code = c_SUBUI
        or op_code = c_ANDI or op_code = c_ORI or op_code = c_XORI or op_code = c_SLLI or op_code = c_SRLI
        or op_code = c_SRAI or op_code = c_SLTI or op_code = c_SLTUI or op_code = c_SGTI or op_code = c_SGTUI
        or op_code = c_SLEI or op_code = c_SLEUI or op_code = c_SGEI or op_code = c_SGEUI or op_code = c_SEQI 
        or op_code = c_SNEI or op_code = c_BEQZ or op_code = c_BNEZ or op_code = c_J or op_code = c_JAL) else reg_1_replace;

    --ALU
    ALU : process (clk)
    begin
        if (rising_edge(clk)) then
            if (stall = '0') then
                case op_code is
                    when c_NOP =>
                        ALU_out <= ALU_out;
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
                    when c_PCH =>
                        ALU_out <= ALU_in_0;
                    when c_PD =>
                        ALU_out <= ALU_in_0;
                    when c_PDU =>
                        ALU_out <= ALU_in_0;
                    when others =>
                        ALU_out <= (others => 'X');
                end case;
            end if;
        end if;
    end process;

    reg_values : process(clk)
    begin
        if (rising_edge(clk)) then
            if (take_branch = '1') then
                regged_instruct <= (others => '0');
            elsif (stall = '1') then
                regged_instruct <= (others => '0');
            else
                regged_instruct <= instruct;
            end if;
            reg_1_out <= reg_1_replace;
            if (stall = '1') then
                prev_op_code0 <= (others => '0');
            else
                prev_op_code0 <= op_code;
            end if;
            prev_op_code1 <= prev_op_code0;
        end if;
    end process;

    writeToTxFIFO : process(clk)
    begin
        if (rising_edge(clk)) then
            if (state_machine_finished = '1' or take_branch = '1') then
                stall <= '0';
                tx_fifo_valid <= '0';
                signed_valid <= '0';
                unsigned_valid <= '0';
            elsif (state_machine_stall = '1') then
                tx_fifo_valid <= '0';
                signed_valid <= '0';
                unsigned_valid <= '0';
                stall <= '1';   
            elsif (op_code = c_PCH) then
                tx_fifo_valid <= '1';
                signed_valid <= '0';
                unsigned_valid <= '0';
                stall <= '0';
            elsif (op_code = c_PD) then
                signed_valid <= '1';
                tx_fifo_valid <= '0';
                unsigned_valid <= '0';
                stall <= '1';
            elsif (op_code = c_PDU) then
                unsigned_valid <= '1';
                signed_valid <= '0';
                tx_fifo_valid <= '0';
                stall <= '1';
            else
                signed_valid <= '0';
                unsigned_valid <= '0';
                tx_fifo_valid <= '0';
                stall <= '0';
            end if;
        end if;
    end process;

end rtl;