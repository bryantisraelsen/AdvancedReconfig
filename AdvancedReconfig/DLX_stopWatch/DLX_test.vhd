library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DLX_test is
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
end DLX_test;

architecture rtl of DLX_test is

    component speed_up_pll
        PORT
        (
            areset		: IN STD_LOGIC  := '0';
            inclk0		: IN STD_LOGIC  := '0';
            c0		: OUT STD_LOGIC ;
            locked		: OUT STD_LOGIC 
        );
    end component;

    component Fetch_stage is
        port (
            clk : in std_logic;
            rst : in std_logic;
            mux_sel_from_mem : in std_logic;
            address_from_mem : in std_logic_vector(9 downto 0);
            regged_address : out std_logic_vector(9 downto 0);
            regged_instruct : out std_logic_vector(31 downto 0);
            basic_stall : in std_logic;
            state_machine_stall : in std_logic
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
            stall : out std_logic;
            --user received data
            received_data : in std_logic_vector(31 downto 0);
            received_data_valid : in std_logic;
            received_data_read : out std_logic;
            wait_char_stall_or_stall_cnt : out std_logic;
            --forwarded data
            for_reg_prev0 : in std_logic_vector(31 downto 0); --from output of ALU (output of execute stage, this stage)
            for_reg_prev1 : in std_logic_vector(31 downto 0);  --from output of ALU (output of memory stage, next stage)
            for_reg_prev1_mem : in std_logic_vector(31 downto 0);    --from output of Memory (output of memory stage, next stage)
            --stopwatch
            stopWatch_start : out std_logic := '0';
            stopWatch_stop : out std_logic := '0';
            stopWatch_reset : out std_logic := '0';
            --64 bit stuff
            sixty_four_valid : out std_logic := '0';
            sixty_four_upper_bits : out std_logic_vector(31 downto 0);
            storred_upper_y : out std_logic_vector(31 downto 0) := (others => '0');
            storred_upper_y_valid : out std_logic := '0'
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
            rdusedw		: OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
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

    component uart_rx
        port (
            clk : in std_logic;
            rst : in std_logic;
            rx_wire : in std_logic;
            fifo_ready : in std_logic;
            write_out : out std_logic;
            data_out : out std_logic_vector(7 downto 0)
        );
    end component;

    component rx_fifo
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
            wrfull		: OUT STD_LOGIC ;
            wrusedw		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
    end component;

    component divider
        PORT
        (
            clock		: IN STD_LOGIC ;
            denom		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            numer		: IN STD_LOGIC_VECTOR (63 DOWNTO 0);
            quotient		: OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
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

    component multiplier
        PORT
        (
            clock		: IN STD_LOGIC ;
            dataa		: IN STD_LOGIC_VECTOR (27 DOWNTO 0);
            result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    end component;

    component receive_fifo
        PORT
        (
            clock		: IN STD_LOGIC ;
            data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            rdreq		: IN STD_LOGIC ;
            sclr		: IN STD_LOGIC ;
            wrreq		: IN STD_LOGIC ;
            empty		: OUT STD_LOGIC ;
            full		: OUT STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            usedw		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
        );
    end component;

    component clk_cross_fifo
        PORT
        (
            data		: IN STD_LOGIC_VECTOR (64 DOWNTO 0);
            rdclk		: IN STD_LOGIC ;
            rdreq		: IN STD_LOGIC ;
            wrclk		: IN STD_LOGIC ;
            wrreq		: IN STD_LOGIC ;
            q		: OUT STD_LOGIC_VECTOR (64 DOWNTO 0);
            rdempty		: OUT STD_LOGIC ;
            wrfull		: OUT STD_LOGIC 
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
    signal hex_2 : integer := 0;
	signal hex_3 : integer := 0;
    signal hex_4 : integer := 0;
	signal hex_5 : integer := 0;

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
    signal unsig_div_num : std_logic_vector(63 downto 0);
    signal unsig_div_remain : std_logic_vector(3 downto 0);
    signal unsig_div_quot : std_logic_vector(63 downto 0);
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
    type t_dec_state is (IDLE, S_SIGN_CONV, S_DIV, S_WAIT, S_NEG_SIG, U_DIV, U_WAIT, BUF, PRINT);
    signal div_wait_cnt : std_logic_vector(2 downto 0) := (others => '0');
    signal sig_conv : std_logic_vector(63 downto 0);
    signal storred_num : std_logic_vector(63 downto 0);
    signal storred_char : std_logic_vector(7 downto 0);
    signal storred_char_valid : std_logic := '0';
    signal s_div_num_valid : std_logic := '0';
    signal u_div_num_valid : std_logic := '0';
    signal dec_state : t_dec_state := IDLE;
    signal state_machine_finished : std_logic := '0';

    --rx
    signal rx_fifo_ready : std_logic;
    signal rx_fifo_full : std_logic;
    signal rx_fifo_write : std_logic;
    signal rx_fifo_in : std_logic_vector(7 downto 0);
    signal rx_fifo_read : std_logic;
    signal rx_fifo_out : std_logic_vector(7 downto 0);
    signal rx_fifo_empty : std_logic;

    --RX_conv state machine
    type t_rx_conv_state is (IDLE, SET_NEG_FLAG, MULT, MULT2, ADD, CONV_VAL, WRITE_VAL);
    signal rx_conv_state : t_rx_conv_state := IDLE;
    signal rx_read_value : std_logic_vector(31 downto 0) := (others => '0');
    signal prev_rx_read_value : std_logic_vector(31 downto 0) := (others => '0');
    signal neg_sign_flag : std_logic := '0';
    
    --multiplier
    signal mult_in : std_logic_vector(27 downto 0);
    signal mult_out : std_logic_vector(31 downto 0);

    --signals for Received FIFO
    signal receive_fifo_rd : std_logic;
    signal receive_fifo_wr : std_logic;
    signal receive_fifo_empty : std_logic;
    signal receive_fifo_out : std_logic_vector(31 downto 0);

    signal char_stall : std_logic;

    --print val fifo
    signal print_val_fifo_empty : std_logic;
    signal print_val_fifo_valid : std_logic;
    signal print_val_fifo_rd : std_logic := '0';
    signal print_val_fifo_out : std_logic_vector(64 downto 0);

    --stopwatch
    signal stopWatch_start : std_logic;
    signal stopWatch_stop : std_logic;
    signal stopWatch_reset : std_logic;
    signal stopWatch_go : std_logic := '0';

    signal cnt_incr : std_logic_vector(23 downto 0) := (others => '0');
    signal incr : std_logic := '0';

    signal sixty_four_valid : std_logic;
    signal sixty_four_upper_bits : std_logic_vector(31 downto 0);
    signal upper_bits_fifo_in : std_logic_vector(31 downto 0);

    signal storred_upper_y : std_logic_vector(31 downto 0);
    signal storred_upper_y_valid : std_logic;

    signal pll_locked_1 : std_logic;

    signal filler_sig : std_logic_vector(32 downto 0);

begin

    --speed up pll
    I_am_speed : speed_up_pll
	PORT map
	(
		areset => pll_reset,
		inclk0 => MAX10_CLK1_50,
		c0 => clk,
		locked => pll_locked_1 
	);

    --pll for uart
    pll_for_uart : uart_pll
    port map (
        areset => pll_reset,
        inclk0 => ADC_CLK_10,
        c0 => tx_clk,   --has current baud rate of 921600
        c1 => rx_clk,
        locked => pll_locked
    );

    pll_reset <= not(key(1));
    
    rst <= not(pll_locked and pll_locked_1);

    rx_side : uart_rx
    port map (
        clk => rx_clk,
        rst => rst,
        fifo_ready => rx_fifo_ready,  --currently doing nothing in rx state machine
        rx_wire => RX,
        write_out => rx_fifo_write,
        data_out => rx_fifo_in
    );

    fifo_rx : rx_fifo
    port map (
        aclr => rst,
        data => rx_fifo_in,
        rdclk => MAX10_CLK1_50,   --maybe make 10MHz clk
        rdreq => rx_fifo_read,
        wrclk => rx_clk,
        wrreq => rx_fifo_write,
        q => rx_fifo_out,
        rdempty => rx_fifo_empty,
        wrfull => rx_fifo_full,
        wrusedw => open
    );
    rx_fifo_ready <= not(rx_fifo_full);

    ---------------------------
    -- RX Conv State Machine --
    ---------------------------
    RxConvStateMachine : process(MAX10_CLK1_50)
    begin
        if (rising_edge(MAX10_CLK1_50)) then
            case rx_conv_state is

                when IDLE =>
                    if (rx_fifo_empty = '0') then
                        rx_conv_state <= SET_NEG_FLAG;
                        neg_sign_flag <= '0';
                    end if;

                when SET_NEG_FLAG =>
                    if (rx_fifo_out = X"2D") then
                        neg_sign_flag <= '1';
                    else
                        neg_sign_flag <= '0';
                    end if;
                    rx_conv_state <= ADD;

                when ADD =>
                    rx_conv_state <= MULT;

                when MULT =>
                    rx_conv_state <= MULT2;

                when MULT2 =>
                    if (rx_fifo_out = X"0D") then
                        if (neg_sign_flag = '1') then
                            rx_conv_state <= CONV_VAL;
                        else
                            rx_conv_state <= WRITE_VAL;
                        end if;
                    elsif (rx_fifo_empty = '1') then
                        rx_conv_state <= IDLE;
                    else
                        rx_conv_state <= ADD;
                    end if;

                when CONV_VAL =>
                    rx_conv_state <= WRITE_VAL;

                when WRITE_VAL =>
                    rx_conv_state <= IDLE;

            end case;

            --rx_read_value
            if (rx_conv_state = WRITE_VAL) then
                rx_read_value <= (others => '0');
            elsif (rx_conv_state = ADD and rx_fifo_out >= X"30" and rx_fifo_out <= X"39") then
                rx_read_value <= std_logic_vector(unsigned(rx_read_value) + unsigned((rx_fifo_out and X"CF")));
            elsif (rx_conv_state = ADD and rx_fifo_out >= X"0D") then
                rx_read_value <= prev_rx_read_value;
            elsif (rx_conv_state = MULT2 and rx_fifo_out /= X"0D") then
                prev_rx_read_value <= rx_read_value;
                rx_read_value <= mult_out;
            end if;

            --mult_in
            if (rx_conv_state = ADD) then
                if (rx_fifo_out >= X"30" and rx_fifo_out <= X"39") then
                    mult_in <= std_logic_vector(unsigned(rx_read_value(27 downto 0)) + unsigned((rx_fifo_out and X"CF")));
                else
                    mult_in <= rx_read_value(27 downto 0);
                end if;
            else
                mult_in <= (others => '0');
            end if;

        end if;
    end process;

    receive_fifo_wr <= '1' when rx_conv_state = WRITE_VAL else '0';

    rx_fifo_read <= not(rx_fifo_empty) when rx_conv_state = IDLE else '0';
    --multiplier
    multy : multiplier
	PORT map
	(
		clock => MAX10_CLK1_50,
		dataa => mult_in,
		result => mult_out
	);

    --write to received FIFO when in WRITE_VAL state
    --received FIFO ***hook up appropriately

    receiving_cracka: clk_cross_fifo
    PORT map
    (
        data(64 downto 32) => (others => '0'),
        data(31 downto 0) => rx_read_value,
        rdclk => clk,
        rdreq => receive_fifo_rd,
        wrclk => MAX10_CLK1_50,
        wrreq => receive_fifo_wr,
        q(64 downto 32) => filler_sig,
        q(31 downto 0) => receive_fifo_out,
        rdempty => receive_fifo_empty,
        wrfull => open
    );

    -- receiving_cracka : receive_fifo
    -- PORT map
    -- (
    --     clock => clk,
    --     data => rx_read_value,
    --     rdreq => receive_fifo_rd,
    --     sclr => rst,
    --     wrreq => receive_fifo_wr,
    --     empty => receive_fifo_empty,
    --     full => open,
    --     q => receive_fifo_out,
    --     usedw => open
    -- );

    tx_fifo_in <= storred_char when storred_char_valid = '1' else stack_out;

    tx_fifo_write <= storred_char_valid or decimal_wr;

    fifo_tx : tx_fifo
    port map (
        aclr => rst,
        data => tx_fifo_in,
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

    clk_count : process(clk)
	begin
		if (rising_edge(clk)) then
            if (stopWatch_start = '1') then
                stopWatch_go <= '1';
            elsif (stopWatch_stop = '1') then
                stopWatch_go <= '0';
                cnt_incr <= (others => '0');
            end if;

            if (stopWatch_go = '1') then
                --if (cnt_incr = X"001388") then  --5000
                --if (cnt_incr = X"000200") then  --512
                if (cnt_incr = X"086470") then  --500000
                    incr <= '1';
                    cnt_incr <= (others => '0');
                else
                    incr <= '0';
                    cnt_incr <= std_logic_vector(unsigned(cnt_incr) + X"1");
                end if;
            end if;
		end if;
	end process;

    hex_update : process(clk)
	begin 
		if (rising_edge(clk)) then
			if (rst = '1' or stopWatch_reset = '1') then
				hex_0 <= 0;
				hex_1 <= 0;
				hex_2 <= 0;
				hex_3 <= 0;
				hex_4 <= 0;
				hex_5 <= 0;
			elsif (incr = '1') then
				if (hex_0 = 9) then
					hex_0 <= 0;
					if (hex_1 = 9) then
						hex_1 <= 0;
						if (hex_2 = 9) then
							hex_2 <= 0;
							if (hex_3 = 5) then
								hex_3 <= 0;
								if (hex_4 = 9) then
									hex_4 <= 0;
									if (hex_5 = 9) then
										hex_5 <= 0;
									else
										hex_5 <= hex_5 + 1;
									end if;
								else
									hex_4 <= hex_4 + 1;
								end if;
							else
								hex_3 <= hex_3 + 1;
							end if;
						else
							hex_2 <= hex_2 + 1;
						end if;
					else
						hex_1 <= hex_1 + 1;
					end if;
				else
					hex_0 <= hex_0 + 1;
				end if;
			end if;
		end if;
	end process;

    hex0 <= table(hex_0);
	hex1 <= table(hex_1);
	hex2 <= table(hex_2) and X"7F";
	hex3 <= table(hex_3);
	hex4 <= table(hex_4) and X"7F";
	hex5 <= table(hex_5);


    fetcher : Fetch_stage
	port map (
		clk => clk,
        rst => rst,
        mux_sel_from_mem => mux_sel_from_mem,
        address_from_mem => address_from_mem(9 downto 0),
        regged_address => regged_address,
        regged_instruct => regged_instruct,
        basic_stall => stall or char_stall,
        state_machine_stall => '0'
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
        stall => stall or char_stall,
        branch_taken => mux_sel_from_mem
    );
    -- David was here

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
        --stall
        stall => stall,
        --user received data
        received_data => receive_fifo_out,
        received_data_valid => not(receive_fifo_empty),
        received_data_read => receive_fifo_rd,
        wait_char_stall_or_stall_cnt => char_stall,
        --forwarded data
        for_reg_prev0 => ALU_out,
        for_reg_prev1 => mem_out_ALU_out, --from output of ALU (output of memory stage, next stage)
        for_reg_prev1_mem => mem_out_mem_data,   --from output of Memory (output of memory stage, next stage)
        stopWatch_start => stopWatch_start,
        stopWatch_stop => stopWatch_stop,
        stopWatch_reset => stopWatch_reset,
        --64 bit stuff
        sixty_four_valid => sixty_four_valid,
        sixty_four_upper_bits => sixty_four_upper_bits,
        storred_upper_y => storred_upper_y,
        storred_upper_y_valid => storred_upper_y_valid
    );

    upper_bits_fifo_in <= sixty_four_upper_bits when sixty_four_valid = '1' else storred_upper_y when storred_upper_y_valid = '1' else (others => '0');

    unsigned_fifo: clk_cross_fifo
    PORT map
    (
        data => unsig_div_valid & upper_bits_fifo_in & ALU_out,
        rdclk => MAX10_CLK1_50,
        rdreq => print_val_fifo_rd,
        wrclk => clk,
        wrreq => unsig_div_valid or char_wr,
        q => print_val_fifo_out,
        rdempty => print_val_fifo_empty,
        wrfull => open
    );

    print_val_fifo_valid <= not(print_val_fifo_empty);

    unsig_div_num <= sig_conv when s_div_num_valid = '1' else storred_num when u_div_num_valid = '1' else unsig_div_quot;

    us_div : divider
    port map
    (
        clock       => MAX10_CLK1_50,
        denom       => X"A",
        numer       => unsig_div_num,
        quotient    => unsig_div_quot,
        remain      => unsig_div_remain
    );

    Stacked : stack
    port map
    (
        clk => MAX10_CLK1_50,
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


    print_val_fifo_rd <= print_val_fifo_valid when dec_state = IDLE else '0';
    ---------------------------
    -- Decimal State Machine --
    ---------------------------
    DecStateMachine : process(MAX10_CLK1_50)
    begin
        if (rising_edge(MAX10_CLK1_50)) then
            case dec_state is

                when IDLE =>
                    state_machine_finished <= '0';
                    if (print_val_fifo_rd = '1' and print_val_fifo_out(64) = '1') then
                        dec_state <= U_WAIT;
                        u_div_num_valid <= '1';
                        storred_num <= print_val_fifo_out(63 downto 0);     --adjust storred num to be 64 bits eventually
                        storred_char_valid <= '0';
                    elsif (print_val_fifo_rd = '1' and print_val_fifo_out(64) = '0') then
                        storred_char <= print_val_fifo_out(7 downto 0);
                        storred_char_valid <= '1';
                    else
                        storred_char_valid <= '0';
                    end if;

                when S_SIGN_CONV =>
                    dec_state <= S_WAIT;
                    div_wait_cnt <= (others => '0');
                    sig_conv <= std_logic_vector(unsigned(storred_num xor X"FFFFFFFFFFFFFFFF")+X"1");
                    s_div_num_valid <= '1';

                when S_WAIT =>
                    if (div_wait_cnt = "110") then
                        div_wait_cnt <= (others => '0');
                        dec_state <= S_DIV;
                    else
                        div_wait_cnt <= std_logic_vector(unsigned(div_wait_cnt) + "001");
                    end if;

                when S_DIV =>
                    if (to_integer(unsigned(unsig_div_num)) < 10) then
                        dec_state <= S_NEG_SIG;
                    else
                        dec_state <= S_WAIT;
                    end if;
                    s_div_num_valid <= '0';

                when S_NEG_SIG =>
                    dec_state <= BUF;

                when U_WAIT =>
                    if (div_wait_cnt = "110") then
                        div_wait_cnt <= (others => '0');
                        dec_state <= U_DIV;
                    else
                        div_wait_cnt <= std_logic_vector(unsigned(div_wait_cnt) + "001");
                    end if;

                when U_DIV =>
                    u_div_num_valid <= '0';
                    if ((unsigned(unsig_div_num)) < X"000000000000000A" and unsig_div_num(63) /= '1') then
                        dec_state <= BUF;
                    else
                        dec_state <= U_WAIT;
                    end if;

                when BUF =>
                    dec_state <= PRINT;

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