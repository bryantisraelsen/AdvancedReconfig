library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.dlx_pkg.all;

entity decode_stage is
	port (
		clk : in std_logic;
        rst : in std_logic;
        --from fetch inputs
        fetch_next_pc_address : in std_logic_vector(9 downto 0);
        fetch_instruct : in std_logic_vector(31 downto 0);
        --from write_back inptus
        reg_write_address : in std_logic_vector(4 downto 0);
        reg_write_value : in std_logic_vector(31 downto 0);
        reg_wr_en : in std_logic;
        --outputs
        regged_nxt_pc : out std_logic_vector(9 downto 0);
        regged_instruct : out std_logic_vector(31 downto 0);
        sign_extnd_immediate : out std_logic_vector(31 downto 0);
        reg_0 : out std_logic_vector(31 downto 0);
        reg_1 : out std_logic_vector(31 downto 0)
	);
end decode_stage;

architecture rtl of decode_stage is

    component register_RAM
        port
        (
            data_i	: in std_logic_vector(31 downto 0);
            wr_addr	: in natural range 0 to 31;
            rd_addr0 : in natural range 0 to 31;
            rd_addr1 : in natural range 0 to 31;
            we_en	: in std_logic := '1';
            clk		: in std_logic;
            reg0_q	: out std_logic_vector(31 downto 0);
            reg1_q	: out std_logic_vector(31 downto 0)
        );
    end component;

    signal op_code : std_logic_vector(5 downto 0);
    signal reg0_addr : natural range 0 to 31;
    signal reg1_addr : natural range 0 to 31;
    signal wr_addr : natural range 0 to 31;
    signal immediate_short : std_logic_vector(15 downto 0);

begin

    immediate_short <= fetch_instruct(15 downto 0);
    op_code <= fetch_instruct(31 downto 26) when rst = '0' else "00" & X"0";

    sgn_extnd : process(clk)
    begin
        if (rising_edge(clk)) then
            if (immediate_short(15) = '1' and (op_code = c_ADDI or op_code = c_SUBI or op_code = c_ANDI or op_code = c_ORI or op_code = c_XORI or op_code = c_SLLI or op_code = c_SRLI or op_code = c_SRAI or op_code = c_SLTI or op_code = c_SGTI or op_code = c_SLEI or op_code = c_SGEI or  op_code = c_SEQI or op_code = c_SNEI)) then
                sign_extnd_immediate <= X"1111" & immediate_short;
            else
                sign_extnd_immediate <= X"0000" & immediate_short;
            end if;
        end if;
    end process;

    reg_nxt_pc_and_instr : process (clk)
	begin
		if (rising_edge(clk)) then
            regged_nxt_pc <= fetch_next_pc_address;
            regged_instruct <= fetch_instruct;
		end if;
	end process;

    registers_content : register_RAM PORT MAP (
		data_i	 => reg_write_value,
        wr_addr	=> wr_addr,
        rd_addr0 => reg0_addr,
        rd_addr1 => reg1_addr,
        we_en => reg_wr_en,
        clk => clk,
        reg0_q	=> reg_0,
        reg1_q	=> reg_1
	);

    wr_addr <= to_integer(unsigned(reg_write_address));
    --for memory instructions (SW and LW) r_offset is in reg0
    --for SW instructions r_data is in reg1
    --NOTE: when Jump to register reg0 is from bottom 5 bits
    --reg0 has register we are comparing for BEQZ and BNEZ
    reg0_addr <= to_integer(unsigned(fetch_instruct(4 downto 0))) when op_code = c_JR or op_code = c_JALR else to_integer(unsigned(fetch_instruct(20 downto 16))) when op_code = c_LW or op_code = c_SW else to_integer(unsigned(fetch_instruct(25 downto 21))) when op_code = c_BEQZ or op_code = c_BNEZ else to_integer(unsigned(fetch_instruct(20 downto 16)));
    --NOTE: when SW reg1 is from bits 25 to 21
    reg1_addr <= to_integer(unsigned(fetch_instruct(25 downto 21))) when op_code = c_SW else to_integer(unsigned(fetch_instruct(15 downto 11)));

end rtl;


