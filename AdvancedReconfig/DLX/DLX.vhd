library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DLX is
	port (
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		MAX10_CLK2_50 : in std_logic;
        HEX0 : out std_logic_vector(7 downto 0) := (others => '1');
		HEX1 : out std_logic_vector(7 downto 0) := (others => '1');
		HEX2 : out std_logic_vector(7 downto 0) := (others => '1');
		HEX3 : out std_logic_vector(7 downto 0) := (others => '1');
		HEX4 : out std_logic_vector(7 downto 0) := (others => '1');
		HEX5 : out std_logic_vector(7 downto 0) := (others => '1');
        KEY : in std_logic_vector(1 downto 0);
        RX : in std_logic;  --pin AB2 (pin 39) (green)
        TX : out std_logic  --pin AA2 (pin 40) (white)
	);                      --ground pin is 30
end DLX;

architecture rtl of DLX is

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
            reg_1 : out std_logic_vector(31 downto 0);
            --branch_taken
            branch_taken : in std_logic
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
            reg_1_out : out std_logic_vector(31 downto 0);
            --forwarded data
            for_reg_prev0 : in std_logic_vector(31 downto 0); --from output of ALU (output of execute stage, this stage)
            for_reg_prev1 : in std_logic_vector(31 downto 0);  --from output of ALU (output of memory stage, next stage)
            for_reg_prev1_mem : in std_logic_vector(31 downto 0)    --from output of Memory (output of memory stage, next stage)
        );
    end component execute_stage;

    component memory_stage is
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
    end component memory_stage;

    component write_back_stage is
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
    end component write_back_stage;

    component uart_pll
        PORT
        (
            areset		: IN STD_LOGIC  := '0';
            inclk0		: IN STD_LOGIC  := '0';
            c0		: OUT STD_LOGIC ;
            c1		: OUT STD_LOGIC ;
            locked		: OUT STD_LOGIC 
        );
    end component;

    component tx_fifo
        PORT
        (
            aclr		: IN STD_LOGIC  := '0';
            data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            rdclk		: IN STD_LOGIC ;
            rdreq		: IN STD_LOGIC ;
            wrclk		: IN STD_LOGIC ;
            wrreq		: IN STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            rdempty		: OUT STD_LOGIC ;
            rdusedw		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            wrfull		: OUT STD_LOGIC 
        );
    end component;

    component uart_tx
        port (
            clk : in std_logic;
            rst : in std_logic;
            valid_in : in std_logic;
            data_in : in std_logic_vector(7 downto 0);
            rd : out std_logic;
            tx_wire : out std_logic
        );
    end component;
    

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

    --outputs for memory
    signal mem_out_ALU_out : std_logic_vector(31 downto 0);
    signal mem_out_mem_data : std_logic_vector(31 downto 0);
    signal mem_out_instruct : std_logic_vector(31 downto 0);

    --write_back outputs
    signal reg_write_address : std_logic_vector(4 downto 0);
    signal reg_write_value : std_logic_vector(31 downto 0);
    signal reg_wr_en : std_logic;

    signal clk : std_logic;
    signal rst : std_logic;

    --tx
    signal tx_rd : std_logic;
    signal tx_data : std_logic_vector(7 downto 0);
    signal tx_data_valid : std_logic;

    --tx fifo
    signal tx_fifo_full : std_logic;
    signal tx_fifo_out : std_logic_vector(7 downto 0);
    signal tx_fifo_empty : std_logic;
    signal tx_fifo_write : std_logic;

    --display the ascii value
    signal hex_0 : integer := 0;
	signal hex_1 : integer := 0;

    type MY_MEM is array (0 to 15) of std_logic_vector(7 downto 0);
	constant table : MY_MEM := (X"C0", X"F9", X"A4", X"B0", X"99", X"92", X"82", X"F8", X"80", X"90", X"88", X"83", X"A7", X"A1", X"86", X"8E");

    --pll signals
    signal tx_clk : std_logic;
    signal rx_clk : std_logic;
    signal pll_reset : std_logic;
    signal pll_locked : std_logic;

begin

    --clk set to 50 MHz
    clk <= MAX10_CLK1_50;

    --pll for uart
    pll_for_uart : uart_pll
    port map (
        areset => pll_reset,
        inclk0 => ADC_CLK_10,
        c0 => tx_clk,
        c1 => rx_clk,
        locked => pll_locked
    );

    pll_reset <= not(key(1));
    
    rst <= not(pll_locked);

    fifo_tx : tx_fifo
    port map (
        aclr => rst,
        data => tx_data,
        rdclk => tx_clk,
        rdreq => tx_rd,
        wrclk => MAX10_CLK1_50,
        wrreq => tx_fifo_write,
        q => tx_fifo_out,
        rdempty => tx_fifo_empty,
        wrfull => tx_fifo_full
    );

    tx_data_valid <= not(tx_fifo_empty);

    tx_side : uart_tx
    port map (
        clk => tx_clk,
        rst => rst,
        valid_in => tx_data_valid,
        data_in => tx_fifo_out,
        rd => tx_rd,
        tx_wire => TX
    );

    hex_0 <= to_integer(unsigned(tx_data(3 downto 0)));
    hex_1 <= to_integer(unsigned(tx_data(7 downto 4)));
    hex0 <= table(hex_0);
	hex1 <= table(hex_1);
	hex2 <= X"FF";
	hex3 <= X"FF";
	hex4 <= X"FF";
	hex5 <= X"FF";


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
        reg_1 => rg_1,
        branch_taken => mux_sel_from_mem
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
        reg_1_out => exec_out_reg_1,
        --forwarded data
        for_reg_prev0 => ALU_out,
        for_reg_prev1 => mem_out_ALU_out, --from output of ALU (output of memory stage, next stage)
        for_reg_prev1_mem => mem_out_mem_data   --from output of Memory (output of memory stage, next stage)
    );

    remember : memory_stage
    port map (
        clk => clk,
        rst => rst,
        --inputs from execute
        ALU_out => ALU_out,
        instruct => exec_out_reg_instruct,
        reg_1 => exec_out_reg_1,
        --outputs
        ALU_out_regged => mem_out_ALU_out,
        mem_data_out => mem_out_mem_data,
        regged_instruct => mem_out_instruct
    );

    writer : write_back_stage
    port map (
        clk => clk,
        rst => rst,
        --inputs from memory
        ALU_out => mem_out_ALU_out,
        mem_data_out => mem_out_mem_data,
        instruct => mem_out_instruct,
        --outputs
        reg_wr_address => reg_write_address,
        reg_wr_data => reg_write_value,
        reg_wr_en => reg_wr_en
    );


end rtl;