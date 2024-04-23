library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dlx is
	port (
		clk : in std_logic;
        rst : in std_logic;
        reg_write_address : in std_logic_vector(4 downto 0);
        reg_write_value : in std_logic_vector(31 downto 0);
        reg_wr_en : in std_logic
	);
end dlx;

architecture rtl of dlx is

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

    component decode_stage is
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
    end component decode_stage;

    component execute_stage is
        port (
            clk : in std_logic;
            rst : in std_logic;
            --from decode inputs
            nxt_pc : in std_logic_vector(9 downto 0);
            instruct : in std_logic_vector(31 downto 0);
            sign_extend_immediate : in std_logic_vector(31 downto 0);
            reg_0 : in std_logic_vector(31 downto 0);
            reg_1 : in std_logic_vector(31 downto 0);
            --outputs
            take_branch : out std_logic;
            jmp_address : out std_logic_vector(31 downto 0);
            ALU_out : out std_logic_vector(31 downto 0);
            regged_instruct : out std_logic_vector(31 downto 0);
            reg_1_out : out std_logic_vector(31 downto 0)
        );
    end component execute_stage;

    signal mux_sel_from_mem : std_logic := '0';
    signal address_from_mem : std_logic_vector(31 downto 0) := (others => '0');
    --outputs from fetch
    signal regged_address : std_logic_vector(9 downto 0);
    signal regged_instruct : std_logic_vector(31 downto 0);
    --outputs for decode
    signal rg_0 : std_logic_vector(31 downto 0);
    signal rg_1 : std_logic_vector(31 downto 0);
    signal sgn_extnd_imm : std_logic_vector(31 downto 0);
    signal decode_out_instruct : std_logic_vector(31 downto 0);
    signal decode_out_pc : std_logic_vector(9 downto 0);
    --outputs for execute
    signal ALU_out : std_logic_vector(31 downto 0);
    signal exec_out_reg_instruct : std_logic_vector(31 downto 0);
    signal exec_out_reg_1 : std_logic_vector(31 downto 0);

begin

    fetcher : Fetch_stage
	port map (
		clk => clk,
        rst => rst,
        mux_sel_from_mem => mux_sel_from_mem,
        address_from_mem => address_from_mem(9 downto 0),
        regged_address => regged_address,
        regged_instruct => regged_instruct
	);

    decoder : decode_stage
    port map (
        clk => clk,
        rst => rst,
        --inputs from fetch stage
        fetch_next_pc_address => regged_address,
        fetch_instruct => regged_instruct,
        --inputs from write_back stage
        reg_write_address => reg_write_address,
        reg_write_value => reg_write_value,
        reg_wr_en => reg_wr_en,
        --outputs
        regged_nxt_pc => decode_out_pc,
        regged_instruct => decode_out_instruct,
        sign_extnd_immediate => sgn_extnd_imm,
        reg_0 => rg_0,
        reg_1 => rg_1
    );


    execute_order_66 : execute_stage
    port map (
        clk => clk,
        rst => rst,
        --from decode inputs
        nxt_pc => decode_out_pc,
        instruct => decode_out_instruct,
        sign_extend_immediate => sgn_extnd_imm,
        reg_0 => rg_0,
        reg_1 => rg_1,
        --outputs
        take_branch => mux_sel_from_mem,
        jmp_address => address_from_mem,
        ALU_out => ALU_out,
        regged_instruct => exec_out_reg_instruct,
        reg_1_out => exec_out_reg_1
    );


end rtl;