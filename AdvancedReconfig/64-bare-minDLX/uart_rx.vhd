library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity uart_rx is
	port (
		clk : in std_logic;
		rst : in std_logic;
        rx_wire : in std_logic;
        fifo_ready : in std_logic;  --does nothing currently
        write_out : out std_logic := '0';
        data_out : out std_logic_vector(7 downto 0)
	);
end uart_rx;

architecture rtl of uart_rx is
    --state machine
    type t_RX_STATE is (IDLE, READ_BIT, ERR); --make states for reading from rx
    signal rx_state : t_RX_STATE := IDLE;

    signal sample_cnt : integer := 0;
    signal bit_cnt : integer := 0;
    signal shift : std_logic_vector(7 downto 0) := (others => '0');

    signal sample_data : std_logic_vector(2 downto 0) := (others => '0');

begin

    rx_state_machine : process (clk)
    begin
        if (rising_edge(clk)) then
            if (rst = '1') then
                rx_state <= IDLE;
            else
                case rx_state is 
                    when IDLE =>
                    write_out <= '0';
                        if (rx_wire = '0') then --start signal
                            rx_state <= READ_BIT;
                            sample_cnt <= sample_cnt + 1;
                        else
                            sample_cnt <= 0;
                            bit_cnt <= 0;
                        end if;

                    when READ_BIT =>
                        if (sample_cnt < 7) then --update sample cnt
                            sample_cnt <= sample_cnt + 1;
                        else
                            sample_cnt <= 0;
                        end if;
                        if (sample_cnt > 2 and sample_cnt < 6) then --update sample data and actual data_out
                            sample_data <= rx_wire & sample_data(2 downto 1);
                        elsif (sample_cnt = 7) then
                            if ((sample_data(0) = '1' and sample_data(1) = '1') or (sample_data(0) = '1' and sample_data(2) = '1') or (sample_data(1) = '1' and sample_data(2) = '1')) then --received a '1'
                                if (bit_cnt = 0) then
                                    rx_state <= IDLE;  --false read of '0' for start
                                elsif (bit_cnt > 0 and bit_cnt < 9) then
                                    data_out <= '1' & shift(7 downto 1);
                                    shift <= '1' & shift(7 downto 1);
                                else        --go back to IDLE to get next read
                                    rx_state <= IDLE;
                                    write_out <= '1';
                                end if;
                            else                            --received a '0'
                                if (bit_cnt > 0 and bit_cnt < 9) then
                                    data_out <= '0' & shift(7 downto 1);
                                    shift <= '0' & shift(7 downto 1);
                                elsif (bit_cnt = 9) then  --didn't get stop where expected
                                    rx_state <= ERR;
                                end if;
                            end if;
                            if (bit_cnt < 9) then --update bit_cnt
                                bit_cnt <= bit_cnt + 1;
                            else
                                bit_cnt <= 0;
                            end if;
                        end if;

                    when ERR =>
                        if (rst = '1') then
                            rx_state <= IDLE;
                        end if;
                end case;
            end if;
        end if;
    end process;


end rtl;