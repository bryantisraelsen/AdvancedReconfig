library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity decode_tb is
end decode_tb;

architecture behavioral of decode_tb  is
	component dlx is
        port (
            clk : in std_logic;
            rst : in std_logic;
            reg_write_address : in std_logic_vector(4 downto 0);
            reg_write_value : in std_logic_vector(31 downto 0);
            reg_wr_en : in std_logic
        );
    end component dlx;
	
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
	
	dlx_er : dlx
	port map (
		clk => clk_50,
        rst => rst,
        reg_write_address => reg_write_address,
        reg_write_value => reg_write_value,
        reg_wr_en => reg_wr_en
	);

    reg_write_args : process(clk_50)
    begin
        if (rising_edge(clk_50)) then
            -- if (fast_forward = '1') then
            --     if (timer = X"41") then
            --         reg_write_address <= "0" & X"A";
            --         reg_write_value <= X"00000004";
            --         reg_wr_en <= '1';
            --     elsif (timer = X"42") then
            --         reg_write_address <= "0" & X"2";
            --         reg_write_value <= X"00000002";
            --         reg_wr_en <= '1';
            --     elsif (timer = X"43") then
            --         reg_write_address <= "0" & X"A";
            --         reg_write_value <= X"0000000A";
            --         reg_wr_en <= '1';
            --     elsif (timer = X"44") then
            --         reg_write_address <= "0" & X"1";
            --         reg_write_value <= X"00000001";
            --         reg_wr_en <= '1';
            --     elsif (timer = X"45") then
            --         reg_write_address <= "0" & X"6";
            --         reg_write_value <= X"00000006";
            --         reg_wr_en <= '1';
            --     else
            --         reg_wr_en <= '0';
            --     end if;
            if (take_your_time = '1') then
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