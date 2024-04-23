library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity decode_tb is
end decode_tb;

architecture behavioral of decode_tb  is
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
	
	signal clk_50 : std_logic := '0';
    signal rst : std_logic := '1';
	signal mux_sel_from_mem : std_logic := '0';
    signal timer : std_logic_vector(31 downto 0) := (others => '0');
    signal address_from_mem : std_logic_vector(9 downto 0) := (others => '0');
    signal regged_address : std_logic_vector(9 downto 0);
    signal regged_instruct : std_logic_vector(31 downto 0);
    signal rg_0 : std_logic_vector(31 downto 0);
    signal rg_1 : std_logic_vector(31 downto 0);
    signal sgn_extnd_imm : std_logic_vector(31 downto 0);
    signal decode_out_instruct : std_logic_vector(31 downto 0);
    signal decode_out_pc : std_logic_vector(9 downto 0);

    --input from write_back
    signal reg_write_address : std_logic_vector(4 downto 0) := (others => '0');
    signal reg_write_value : std_logic_vector(31 downto 0) := (others => '0');
    signal reg_wr_en : std_logic := '0';

    --which test to do
    signal fast_forward : std_logic := '1';
    signal take_your_time : std_logic := '0';
	
begin
	
	fetcher : Fetch_stage
	port map (
		clk => clk_50,
        rst => rst,
        mux_sel_from_mem => mux_sel_from_mem,
        address_from_mem => address_from_mem,
        regged_address => regged_address,
        regged_instruct => regged_instruct
	);

    decoder : decode_stage
    port map (
        clk => clk_50,
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

    write_back_args : process(clk_50)
    begin
        if (rising_edge(clk_50)) then
            if (fast_forward = '1') then
                if (timer = X"41") then
                    reg_write_address <= "0" & X"A";
                    reg_write_value <= X"00000004";
                    reg_wr_en <= '1';
                elsif (timer = X"42") then
                    reg_write_address <= "0" & X"2";
                    reg_write_value <= X"00000002";
                    reg_wr_en <= '1';
                elsif (timer = X"43") then
                    reg_write_address <= "0" & X"A";
                    reg_write_value <= X"0000000A";
                    reg_wr_en <= '1';
                elsif (timer = X"44") then
                    reg_write_address <= "0" & X"1";
                    reg_write_value <= X"00000001";
                    reg_wr_en <= '1';
                elsif (timer = X"45") then
                    reg_write_address <= "0" & X"6";
                    reg_write_value <= X"00000006";
                    reg_wr_en <= '1';
                else
                    reg_wr_en <= '0';
                end if;
            elsif (take_your_time = '1') then
                if (timer = X"44") then
                    reg_write_address <= "0" & X"A";
                    reg_write_value <= X"00000004";
                    reg_wr_en <= '1';
                elsif (timer = X"45") then
                    reg_write_address <= "0" & X"1";
                    reg_write_value <= X"00000004";
                    reg_wr_en <= '1';
                elsif (timer = X"46") then
                    reg_write_address <= "0" & X"2";
                    reg_write_value <= X"00000003";
                    reg_wr_en <= '1';
                elsif (timer = X"47") then
                    reg_write_address <= "0" & X"B";
                    reg_write_value <= X"00000000";
                    reg_wr_en <= '1';
                else
                    reg_wr_en <= '0';
                end if;
            end if;
        end if;
    end process;
	
	--clk_10 <= not(clk_10) after 50 ns; --10 MHz
    clk_50 <= not(clk_50) after 10 ns; --50 MHz
	
	inputs_mod : process (clk_50)
	begin
		if (rising_edge(clk_50)) then
			timer <= timer + 1;
            if (timer = X"40") then
                rst             <= '0';
            elsif (timer = X"48") then
                mux_sel_from_mem <= '1';
                address_from_mem <= '0' & '0' & X"0B";
            elsif (timer = X"49") then
                mux_sel_from_mem <= '0';
            elsif (timer = X"53") then
                mux_sel_from_mem <= '1';
                address_from_mem <= '0' & '0' & X"0E";
            elsif (timer = X"54") then
                mux_sel_from_mem <= '0';
            elsif (timer = X"5B") then
                mux_sel_from_mem <= '1';
                address_from_mem <= '0' & '0' & X"0E";
            elsif (timer = X"5C") then
                mux_sel_from_mem <= '0';
            elsif (timer = X"63") then
                mux_sel_from_mem <= '1';
                address_from_mem <= '0' & '0' & X"0E";
            elsif (timer = X"64") then
                mux_sel_from_mem <= '0';
            elsif (timer = X"68") then
                mux_sel_from_mem <= '1';
                address_from_mem <= '0' & '0' & X"13";
            elsif (timer = X"69") then
                mux_sel_from_mem <= '0';
            elsif (timer = X"6C") then
                mux_sel_from_mem <= '1';
                address_from_mem <= '0' & '0' & X"06";
            elsif (timer = X"6D") then
                mux_sel_from_mem <= '0';
            elsif (timer = X"300") then
                mux_sel_from_mem <= '1';
            end if;			
		end if;
	end process;
	

end architecture behavioral;