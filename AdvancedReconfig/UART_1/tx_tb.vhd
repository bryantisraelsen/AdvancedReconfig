library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity tx_tb is
end tx_tb;

architecture behavioral of tx_tb  is
	component uart_tx is
        port (
            clk : in std_logic;
            rst : in std_logic;
            valid_in : in std_logic;
            data_in : in std_logic_vector(7 downto 0);
            rd : out std_logic := '0';
            tx_wire : out std_logic := '1'
        );
    end component uart_tx;

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
	
	signal clk : std_logic := '0';
    signal rst : std_logic := '1';
	signal valid_in : std_logic := '1';
    signal tx_wire : std_logic := '1';
    signal rd : std_logic;
    signal data_in : std_logic_vector(7 downto 0);
    signal timer : std_logic_vector(31 downto 0) := (others => '0');
    signal fifo_data_in : std_logic_vector(7 downto 0) := (others => '0');
    signal rdempty : std_logic;
    signal fifo_wr : std_logic := '0';
	
begin
	
	uut : uart_tx
	port map (
		clk => clk,
		rst => rst,
        valid_in => valid_in,
        tx_wire => tx_wire,
        rd => rd,
        data_in => data_in
	);
	
	clk <= not(clk) after 52.0833 us; --19.2 kHz
    rst <= '0' after 50 us;
	
    fifo : tx_fifo
    port map (
        aclr => rst,
        data => fifo_data_in,
        rdclk => clk,
        rdreq => rd,
        wrclk => clk,
        wrreq => fifo_wr,
        q => data_in,
        rdempty => rdempty,
        rdusedw => open,
        wrfull => open
    );

    valid_in <= not(rdempty);

	inputs_mod : process (clk)
	begin
		if (rising_edge(clk)) then
			timer <= timer + 1;
            if (fifo_wr = '1') then
                fifo_wr <= '0';
			elsif (timer = 0) then
				fifo_data_in <= X"4D";
                fifo_wr <= '1';
			elsif(timer = 70) then
				fifo_data_in <= X"01";
                fifo_wr <= '1';
            elsif(timer = 121) then
                fifo_data_in <= X"23";
                fifo_wr <= '1';
			elsif(timer = 208) then
				fifo_data_in <= X"BC";
                fifo_wr <= '1';
			-- elsif(timer = 36) then
			-- 	rx_wire <= '0';
			-- elsif(timer = 44) then
			-- 	rx_wire <= '0';
			-- elsif(timer = 52) then
			-- 	rx_wire <= '1';
			-- elsif(timer = 60) then
			-- 	rx_wire <= '1';
            -- elsif(timer = 68) then
            --     rx_wire <= '0';
            -- elsif(timer = 76) then
            --     rx_wire <= '1';
            -- elsif(timer = 84) then
            --     rx_wire <= '0';
            -- elsif(timer = 92) then
            --     rx_wire <= '1';
			end if;
		end if;
	end process;
	

end architecture behavioral;