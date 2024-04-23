library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
--use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity UART_1 is
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
end UART_1;

architecture rtl of UART_1 is

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

    --pll
    signal tx_clk : std_logic;
    signal pll_locked : std_logic;
    signal rx_clk : std_logic;
    signal pll_reset : std_logic;

    --rx
    signal rx_fifo_write : std_logic;
    signal rx_fifo_in : std_logic_vector(7 downto 0);
    signal fifo_ready : std_logic;
    signal rx_rst : std_logic;
    signal wrusedw : STD_LOGIC_VECTOR (7 DOWNTO 0);

    --tx
    signal tx_rd : std_logic;
    signal tx_data : std_logic_vector(7 downto 0);
    signal tx_data_valid : std_logic;
    signal rst : std_logic;

    --rx fifo
    signal rx_fifo_full : std_logic;
    signal rx_fifo_out : std_logic_vector(7 downto 0);
    signal rx_fifo_ready : std_logic;
    signal rx_fifo_empty : std_logic;
    signal rx_fifo_read : std_logic;
    signal rx_fifo_rst : std_logic;

    --tx fifo
    signal tx_fifo_full : std_logic;
    signal tx_fifo_out : std_logic_vector(7 downto 0);
    signal tx_fifo_empty : std_logic;
    signal tx_fifo_write : std_logic;

    --send state machine
    type t_TOP_STATE is (IDLE, READ_FIFO, SEND, WAIT_ROOM, ADJUST_CASE); --make states for sending to tx
    signal top_state : t_TOP_STATE := IDLE;

    --display the ascii value
    signal hex_0 : integer := 0;
	signal hex_1 : integer := 0;

    type MY_MEM is array (0 to 15) of std_logic_vector(7 downto 0);
	constant table : MY_MEM := (X"C0", X"F9", X"A4", X"B0", X"99", X"92", X"82", X"F8", X"80", X"90", X"88", X"83", X"A7", X"A1", X"86", X"8E");

begin

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
        rdclk => MAX10_CLK1_50,
        rdreq => rx_fifo_read,
        wrclk => rx_clk,
        wrreq => rx_fifo_write,
        q => rx_fifo_out,
        rdempty => rx_fifo_empty,
        wrfull => rx_fifo_full,
        wrusedw => wrusedw --change this
    );
    rx_fifo_ready <= not(rx_fifo_full);

    top_state_machine : process (MAX10_CLK1_50)
    begin
        if (rising_edge(MAX10_CLK1_50)) then
            if (rst = '1') then
                top_state <= IDLE;
            else
                case top_state is
                    when IDLE =>
                        if (rx_fifo_empty = '0') then
                            top_state <= READ_FIFO;
                        end if;
                    
                    when READ_FIFO =>
                        top_state <= WAIT_ROOM;

                    when WAIT_ROOM =>
                        tx_data <= rx_fifo_out;
                        if (tx_fifo_full = '0') then
                            top_state <= ADJUST_CASE;
                        end if;

                    when ADJUST_CASE =>
                        top_state <= SEND;
                        if (tx_data < 65 or tx_data > 122) then --error if not a letter
                            tx_data <= X"45";
                        elsif (tx_data > 90 and tx_data < 97) then  --error if not a letter
                            tx_data <= X"45";
                        elsif (tx_data < 91) then
                            tx_data <= tx_data + 32;
                        else
                            tx_data <= tx_data - 32;
                        end if;

                        
                    --add state for changing case here

                    when SEND =>
                        top_state <= IDLE;

                end case;
            end if;
        end if;
    end process;

    rx_fifo_read <= '1' when top_state = READ_FIFO else '0';
    tx_fifo_write <= '1' when top_state = SEND else '0';

    --add in fifo for tx (will be needed for the future+)

    -- fifo_rst <= '1' when top_state = RESET else '0';
    --tx_data_valid <= '1' when top_state = SEND else '0';

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
end rtl;