library ieee;
use     ieee.std_logic_1164.all;

package dlx_pkg is
 
    constant c_NOP : std_logic_vector(5 downto 0) := (others => '0');
    constant c_LW : std_logic_vector(5 downto 0) := "00" & X"1";
    constant c_SW : std_logic_vector(5 downto 0) := "00" & X"2";
    constant c_ADD : std_logic_vector(5 downto 0) := "00" & X"3";
    constant c_ADDI : std_logic_vector(5 downto 0) := "00" & X"4";
    constant c_ADDU : std_logic_vector(5 downto 0) := "00" & X"5";
    constant c_ADDUI : std_logic_vector(5 downto 0) := "00" & X"6";

    constant c_SUB : std_logic_vector(5 downto 0) := "00" & X"7";
    constant c_SUBI : std_logic_vector(5 downto 0) := "00" & X"8";
    constant c_SUBU : std_logic_vector(5 downto 0) := "00" & X"9";
    constant c_SUBUI : std_logic_vector(5 downto 0) := "00" & X"A";

    constant c_AND : std_logic_vector(5 downto 0) := "00" & X"B";
    constant c_ANDI : std_logic_vector(5 downto 0) := "00" & X"C";

    constant c_OR : std_logic_vector(5 downto 0) := "00" & X"D";
    constant c_ORI : std_logic_vector(5 downto 0) := "00" & X"E";

    constant c_XOR : std_logic_vector(5 downto 0) := "00" & X"F";
    constant c_XORI : std_logic_vector(5 downto 0) := "01" & X"0";

    constant c_SLL : std_logic_vector(5 downto 0) := "01" & X"1";
    constant c_SLLI : std_logic_vector(5 downto 0) := "01" & X"2";
    constant c_SRL : std_logic_vector(5 downto 0) := "01" & X"3";
    constant c_SRLI : std_logic_vector(5 downto 0) := "01" & X"4";
    constant c_SRA : std_logic_vector(5 downto 0) := "01" & X"5";
    constant c_SRAI : std_logic_vector(5 downto 0) := "01" & X"6";

    constant c_SLT : std_logic_vector(5 downto 0) := "01" & X"7";
    constant c_SLTI : std_logic_vector(5 downto 0) := "01" & X"8";
    constant c_SLTU : std_logic_vector(5 downto 0) := "01" & X"9";
    constant c_SLTUI : std_logic_vector(5 downto 0) := "01" & X"A";
    constant c_SGT : std_logic_vector(5 downto 0) := "01" & X"B";
    constant c_SGTI : std_logic_vector(5 downto 0) := "01" & X"C";
    constant c_SGTU : std_logic_vector(5 downto 0) := "01" & X"D";
    constant c_SGTUI : std_logic_vector(5 downto 0) := "01" & X"E";

    constant c_SLE : std_logic_vector(5 downto 0) := "01" & X"F";
    constant c_SLEI : std_logic_vector(5 downto 0) := "10" & X"0";
    constant c_SLEU : std_logic_vector(5 downto 0) := "10" & X"1";
    constant c_SLEUI : std_logic_vector(5 downto 0) := "10" & X"2";
    constant c_SGE : std_logic_vector(5 downto 0) := "10" & X"3";
    constant c_SGEI : std_logic_vector(5 downto 0) := "10" & X"4";
    constant c_SGEU : std_logic_vector(5 downto 0) := "10" & X"5";
    constant c_SGEUI : std_logic_vector(5 downto 0) := "10" & X"6";
    constant c_SEQ : std_logic_vector(5 downto 0) := "10" & X"7";
    constant c_SEQI : std_logic_vector(5 downto 0) := "10" & X"8";
    constant c_SNE : std_logic_vector(5 downto 0) := "10" & X"9";
    constant c_SNEI : std_logic_vector(5 downto 0) := "10" & X"A";

    constant c_BEQZ : std_logic_vector(5 downto 0) := "10" & X"B";
    constant c_BNEZ : std_logic_vector(5 downto 0) := "10" & X"C";

    constant c_J : std_logic_vector(5 downto 0) := "10" & X"D";
    constant c_JR : std_logic_vector(5 downto 0) := "10" & X"E";
    constant c_JAL : std_logic_vector(5 downto 0) := "10" & X"F";
    constant c_JALR : std_logic_vector(5 downto 0) := "11" & X"0";

    constant c_PCH : std_logic_vector(5 downto 0) := "11" & X"1";
    constant c_PD : std_logic_vector(5 downto 0) := "11" & X"2";
    constant c_PDU : std_logic_vector(5 downto 0) := "11" & X"3";
    
end package dlx_pkg;