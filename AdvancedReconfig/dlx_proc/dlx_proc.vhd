library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dlx_proc is
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
end dlx_proc;

architecture rtl of dlx_proc is

    component Fetch_stage is
        port (
            clk : in std_logic;
            rst : in std_logic;
            mux_sel_from_mem : in std_logic;
            address_from_mem : in std_logic_vector(9 downto 0);
            regged_address : out std_logic_vector(9 downto 0);
            regged_instruct : out std_logic_vector(31 downto 0);
            stall : in std_logic
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
            --stall
            stall : in std_logic;
            --branch_taken
            branch_taken : in std_logic
        );
    end component decode_stage;

    component execute_stage is
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

    component divider
        PORT
        (
            clock		: IN STD_LOGIC ;
            denom		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            numer		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            quotient		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            remain		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
        );
    end component;

    component stack
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
    -- signal tx_data : std_logic_vector(7 downto 0) := (others => '0');
    signal tx_data_valid : std_logic;

    --tx fifo
    signal tx_fifo_full : std_logic;
    signal tx_fifo_out : std_logic_vector(7 downto 0);
    signal tx_fifo_empty : std_logic;
    signal tx_fifo_write : std_logic;
    signal tx_fifo_in : std_logic_vector(7 downto 0);

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

    --stall
    signal stall : std_logic;
    signal state_machine_stall : std_logic;

    --signed divider
    signal sig_div_num : std_logic_vector(31 downto 0);
    signal sig_div_remain : std_logic_vector(3 downto 0);
    signal sig_div_quot : std_logic_vector(31 downto 0);
    signal sig_div_valid : std_logic;

    --unsigned divider
    signal unsig_div_num : std_logic_vector(31 downto 0);
    signal unsig_div_remain : std_logic_vector(3 downto 0);
    signal unsig_div_quot : std_logic_vector(31 downto 0);
    signal unsig_div_valid : std_logic;

    signal char_wr : std_logic;

    --stack
    signal stack_wr : std_logic;
    signal stack_in : std_logic_vector(7 downto 0);
    signal stack_rd : std_logic;
    signal stack_out : std_logic_vector(7 downto 0);
    signal stack_empty : std_logic;
    signal div_wr_to_stack : std_logic;
    signal neg_sign_wr_stack : std_logic;


    --add this in where needed
    signal decimal_wr : std_logic := '0';

    --state machine for printing decimals
    type t_dec_state is (IDLE, S_SIGN_CONV, S_DIV, S_NEG_SIG, U_DIV, PRINT);
    signal sig_conv : std_logic_vector(31 downto 0);
    signal storred_num : std_logic_vector(31 downto 0);
    signal s_div_num_valid : std_logic := '0';
    signal u_div_num_valid : std_logic := '0';
    signal dec_state : t_dec_state := IDLE;
    signal state_machine_finished : std_logic := '0';
begin

    --clk set to 10 MHz
    clk <= ADC_CLK_10;

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

    tx_fifo_in <= ALU_out(7 downto 0) when char_wr = '1' else stack_out;

    tx_fifo_write <= char_wr or decimal_wr;

    fifo_tx : tx_fifo
    port map (
        aclr => rst,
        data => tx_fifo_in,
        rdclk => tx_clk,
        rdreq => tx_rd,
        wrclk => clk,
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

    hex_0 <= to_integer(unsigned(tx_fifo_out(3 downto 0)));
    hex_1 <= to_integer(unsigned(tx_fifo_out(7 downto 4)));
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
        regged_instruct => regged_instruct,
        stall => stall or state_machine_stall
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
        stall => stall or state_machine_stall,
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
        --write to tx fifo
        tx_fifo_valid => char_wr,
        --write to unsigned state machine
        unsigned_valid => unsig_div_valid,  --TODO: hook up these signals
        --write to signed state machine
        signed_valid => sig_div_valid,
        --stall when full but writing to fifo
        state_machine_stall => state_machine_stall or tx_fifo_full,
        state_machine_finished => state_machine_finished,
        stall => stall,
        --forwarded data
        for_reg_prev0 => ALU_out,
        for_reg_prev1 => mem_out_ALU_out, --from output of ALU (output of memory stage, next stage)
        for_reg_prev1_mem => mem_out_mem_data   --from output of Memory (output of memory stage, next stage)
    );

    unsig_div_num <= sig_conv when s_div_num_valid = '1' else storred_num when u_div_num_valid = '1' else unsig_div_quot;

    us_div : divider
    port map
    (
        clock       => clk,
        denom       => X"A",
        numer       => unsig_div_num,
        quotient    => unsig_div_quot,
        remain      => unsig_div_remain
    );

    Stacked : stack
    port map
    (
        clk => clk,
        rst => rst,
        data_i => stack_in,
        wr_en => stack_wr,
        data_o => stack_out,
        rd_en => stack_rd,
        empty => stack_empty
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

    ---------------------------
    -- Decimal State Machine --
    ---------------------------
    DecStateMachine : process(clk)
    begin
        if (rising_edge(clk)) then
            case dec_state is

                when IDLE =>
                    state_machine_finished <= '0';
                    if (sig_div_valid = '1' and state_machine_finished = '0') then
                        dec_state <= S_SIGN_CONV;
                        storred_num <= ALU_out;
                    elsif (unsig_div_valid = '1' and state_machine_finished = '0') then
                        dec_state <= U_DIV;
                        u_div_num_valid <= '1';
                        storred_num <= ALU_out;
                    end if;
                when S_SIGN_CONV =>
                    dec_state <= S_DIV;
                    sig_conv <= std_logic_vector(unsigned(storred_num xor X"FFFFFFFF")+X"00000001");
                    s_div_num_valid <= '1';

                when S_DIV =>
                    if (to_integer(unsigned(unsig_div_num)) < 10) then
                        dec_state <= S_NEG_SIG;
                    end if;
                    s_div_num_valid <= '0';

                when S_NEG_SIG =>
                    dec_state <= PRINT;

                when U_DIV =>
                    u_div_num_valid <= '0';
                    if (to_integer(unsigned(unsig_div_num)) < 10) then
                        dec_state <= PRINT;
                    end if;

                when PRINT =>
                    if (stack_empty = '1') then
                        state_machine_finished <= '1';
                        dec_state <= IDLE;
                    end if;

            end case;

            if (dec_state = S_DIV or dec_state = S_NEG_SIG or dec_state = U_DIV) then
                stack_wr <= '1';
            else
                stack_wr <= '0';
            end if;

            if (dec_state = PRINT) then
                stack_rd <= '1';
            else 
                stack_rd <= '0';
            end if;

            if (dec_state = U_DIV or dec_state = S_DIV) then
                div_wr_to_stack <= '1';
                neg_sign_wr_stack <= '0';
            elsif (dec_state = S_NEG_SIG) then
                div_wr_to_stack <= '0';
                neg_sign_wr_stack <= '1';
            else
                div_wr_to_stack <= '0';
                neg_sign_wr_stack <= '0';
            end if;

            if (stack_rd = '1' and stack_empty = '0') then
                decimal_wr <= '1';
            else
                decimal_wr <= '0';
            end if;

        end if;
    end process;

    stack_in <= (X"0" & unsig_div_remain) or (X"30") when div_wr_to_stack = '1' else X"2D" when neg_sign_wr_stack = '1' else X"00";

    state_machine_stall <= '1' when dec_state /= IDLE else '0';

end rtl;