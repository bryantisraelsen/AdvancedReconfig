library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity uart_tx is
	port (
		clk : in std_logic;
		rst : in std_logic;
        valid_in : in std_logic;
        data_in : in std_logic_vector(7 downto 0);
        rd : out std_logic := '0';
        tx_wire : out std_logic := '1'
	);
end uart_tx;

architecture rtl of uart_tx is
    --state machine
    type t_TX_STATE is (IDLE, READ_FIFO, STORE_DATA, SEND_BIT, ERR); --make states for reading from rx
    signal tx_state : t_TX_STATE := IDLE;

    signal iter_cnt : integer := 0;
    signal data_stored : std_logic_vector(7 downto 0);
begin

    tx_state_machine : process(clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                tx_state <= IDLE;
            else
                case tx_state is
                    when IDLE =>
                        iter_cnt <= 0;
                        if (valid_in = '1') then
                            tx_state <= READ_FIFO;
                        end if;

                    when READ_FIFO =>
                        tx_state <= STORE_DATA;
                        

                    when STORE_DATA =>
                        data_stored <= data_in;
                        tx_state <= SEND_BIT;

                    when SEND_BIT =>
                        iter_cnt <= iter_cnt + 1;
                        if (iter_cnt = 0) then
                            tx_wire <= '0';
                        elsif (iter_cnt < 9) then
                            tx_wire <= data_stored(0);
                            data_stored <= '0' & data_stored(7 downto 1);
                        elsif (iter_cnt = 9) then
                            tx_wire <= '1';
                            tx_state <= IDLE;
                        else
                            tx_state <= ERR;
                        end if;

                    when ERR =>
                        if (rst = '1') then
                            tx_state <= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process;

    rd <= '1' when tx_state = READ_FIFO else '0';

end rtl;