library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.dlx_pkg.all;

entity Fetch_stage is
	port (
		clk : in std_logic;
        rst : in std_logic;
        mux_sel_from_mem : in std_logic;
        address_from_mem : in std_logic_vector(9 downto 0);
        regged_address : out std_logic_vector(9 downto 0);
        regged_instruct : out std_logic_vector(31 downto 0);
        --stall
        stall : in std_logic
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
    signal prev_op_code : std_logic_vector(5 downto 0);
    signal prev_dest_reg : std_logic_vector(4 downto 0);
    signal curr_rd : std_logic_vector(4 downto 0);
    signal curr_rs0 : std_logic_vector(4 downto 0);
    signal curr_rs1 : std_logic_vector(4 downto 0);
    signal ROM_out : std_logic_vector(31 downto 0);
    signal op_code : std_logic_vector(5 downto 0);
    signal instruct_storred : std_logic_vector(31 downto 0);
    signal stopped : std_logic := '0';
    signal replace : std_logic := '0';
    signal reg_branch_sel : std_logic := '0';
    signal conflict : std_logic;

begin

    instruct : instructions_ROM PORT MAP (
		address	 => pc,
		clock	 => clk,
		q	    => ROM_out
	);

    op_code <= ROM_out(31 downto 26);

    --registers for ROM_out
    curr_rd <= ROM_out(25 downto 21);
    curr_rs0 <= ROM_out(4 downto 0) when op_code = c_JR or op_code = c_JALR or op_code = c_PCH or op_code = c_PD or op_code = c_PDU else ROM_out(20 downto 16) when op_code = c_LW or op_code = c_SW else ROM_out(25 downto 21) when op_code = c_BEQZ or op_code = c_BNEZ else ROM_out(20 downto 16);
    curr_rs1 <= ROM_out(25 downto 21) when op_code = c_SW else ROM_out(15 downto 11);

    regged_instruct <= (others => '0') when mux_sel_from_mem = '1' or reg_branch_sel = '1' or conflict = '1' else regged_instruct when stall = '1' else instruct_storred when stopped = '1' else ROM_out;

    conflict <= '1' when (prev_op_code = c_LW and rst = '0' and prev_dest_reg /= 0 and (prev_dest_reg = curr_rs1 or prev_dest_reg = curr_rs0)) else '0';

    --update address
    address_incremented <= address_from_mem + 1 when mux_sel_from_mem = '1' or reg_branch_sel = '1' else pc when (conflict = '1' or stall = '1') else pc + 1;

    --storred RAM_out
    storeRAMout : process(clk)
    begin
        if (rising_edge(clk)) then
            if ((conflict = '1' or stall = '1') and stopped = '0') then
                instruct_storred <= ROM_out;
                stopped <= '1';
            elsif (conflict = '0' and stall = '0') then
                stopped <= '0';
            end if;
        end if;
    end process;

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

    --reg destination register
    prevDestReg : process(clk)
    begin
        if (rising_edge(clk)) then
            reg_branch_sel <= mux_sel_from_mem;
            prev_op_code <= op_code;
            if (stall = '1' or conflict = '1') then
                prev_dest_reg <= (others => '0');
            else
                prev_dest_reg <= curr_rd;
            end if;
        end if;
    end process;

end rtl;


