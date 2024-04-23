library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;

entity dlx_proc_tb is
end dlx_proc_tb;

architecture behavioral of dlx_proc_tb  is
	component DLX_test is
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
    end component DLX_test;
	
	signal clk_50 : std_logic := '0';
	signal clk_10 : std_logic := '0';
    signal rst : std_logic := '1';
    signal timer : std_logic_vector(63 downto 0) := (others => '0');

	signal hex0 : std_logic_vector(7 downto 0);
	signal hex1 : std_logic_vector(7 downto 0);
	signal hex2 : std_logic_vector(7 downto 0);
	signal hex3 : std_logic_vector(7 downto 0);
	signal hex4 : std_logic_vector(7 downto 0);
	signal hex5 : std_logic_vector(7 downto 0);

	signal tx : std_logic;
	signal rx : std_logic := '1';

	signal uart_clk : std_logic := '0';
	signal uart_timer : std_logic_vector(63 downto 0) := (others => '0');
	
begin
	
	dlx_er : DLX_test
	port map (
		ADC_CLK_10 => clk_10,
		MAX10_CLK1_50 => clk_50,
		MAX10_CLK2_50 => clk_50,
		HEX0 => hex0,
		HEX1 => hex1,
		HEX2 => hex2,
		HEX3 => hex3,
		HEX4 => hex4,
		HEX5 => hex5,
		KEY(0) => '0',
		KEY(1) => not(rst),
		RX => rx,
		TX => tx
	);
	
	clk_10 <= not(clk_10) after 50 ns; --10 MHz
    clk_50 <= not(clk_50) after 10 ns; --50 MHz
	uart_clk <= not(uart_clk) after 542.5 ns; --921600 buad
	
	inputs_mod : process (clk_50)
	begin
		if (rising_edge(clk_50)) then
			timer <= timer + 1;
            if (timer = X"5") then
                rst             <= '0';
            end if;			
		end if;
	end process;

	uart_rx : process(uart_clk)
	begin
		if (rising_edge(uart_clk)) then
			uart_timer <= uart_timer + 1;
			--7
			if (uart_timer = 3) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 4) then
				rx <= '1'; 	--bit zero (LSB)
			elsif (uart_timer = 5) then
				rx <= '1'; 	--bit one
			elsif (uart_timer = 6) then
				rx <= '1'; 	--bit two
			elsif (uart_timer = 7) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 8) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 9) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 10) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 11) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 12) then
				rx <= '1'; 	--stop bit
			--4
			elsif (uart_timer = 15) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 16) then
				rx <= '0'; 	--bit zero (LSB)
			elsif (uart_timer = 17) then
				rx <= '0'; 	--bit one
			elsif (uart_timer = 18) then
				rx <= '1'; 	--bit two
			elsif (uart_timer = 19) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 20) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 21) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 22) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 23) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 24) then
				rx <= '1'; 	--stop bit
			--2
			elsif (uart_timer = 30) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 31) then
				rx <= '0'; 	--bit zero (LSB)
			elsif (uart_timer = 32) then
				rx <= '1'; 	--bit one
			elsif (uart_timer = 33) then
				rx <= '0'; 	--bit two
			elsif (uart_timer = 34) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 35) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 36) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 37) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 38) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 39) then
				rx <= '1'; 	--stop bit
			--9
			elsif (uart_timer = 43) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 44) then
				rx <= '1'; 	--bit zero (LSB)
			elsif (uart_timer = 45) then
				rx <= '0'; 	--bit one
			elsif (uart_timer = 46) then
				rx <= '0'; 	--bit two
			elsif (uart_timer = 47) then
				rx <= '1'; 	--bit three
			elsif (uart_timer = 48) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 49) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 50) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 51) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 52) then
				rx <= '1'; 	--stop bit
			--6
			-- elsif (uart_timer = 55) then
			-- 	rx <= '0'; 	--start bit
			-- elsif (uart_timer = 56) then
			-- 	rx <= '0'; 	--bit zero (LSB)
			-- elsif (uart_timer = 57) then
			-- 	rx <= '1'; 	--bit one
			-- elsif (uart_timer = 58) then
			-- 	rx <= '1'; 	--bit two
			-- elsif (uart_timer = 59) then
			-- 	rx <= '0'; 	--bit three
			-- elsif (uart_timer = 60) then
			-- 	rx <= '1'; 	--bit four
			-- elsif (uart_timer = 61) then
			-- 	rx <= '1'; 	--bit five
			-- elsif (uart_timer = 62) then
			-- 	rx <= '0'; 	--bit six
			-- elsif (uart_timer = 63) then
			-- 	rx <= '0'; 	--bit seven
			-- elsif (uart_timer = 64) then
			-- 	rx <= '1'; 	--stop bit
			-- --5
			-- elsif (uart_timer = 67) then
			-- 	rx <= '0'; 	--start bit
			-- elsif (uart_timer = 68) then
			-- 	rx <= '1'; 	--bit zero (LSB)
			-- elsif (uart_timer = 69) then
			-- 	rx <= '0'; 	--bit one
			-- elsif (uart_timer = 70) then
			-- 	rx <= '1'; 	--bit two
			-- elsif (uart_timer = 71) then
			-- 	rx <= '0'; 	--bit three
			-- elsif (uart_timer = 72) then
			-- 	rx <= '1'; 	--bit four
			-- elsif (uart_timer = 73) then
			-- 	rx <= '1'; 	--bit five
			-- elsif (uart_timer = 74) then
			-- 	rx <= '0'; 	--bit six
			-- elsif (uart_timer = 75) then
			-- 	rx <= '0'; 	--bit seven
			-- elsif (uart_timer = 76) then
			-- 	rx <= '1'; 	--stop bit
			-- --5
			-- elsif (uart_timer = 79) then
			-- 	rx <= '0'; 	--start bit
			-- elsif (uart_timer = 80) then
			-- 	rx <= '1'; 	--bit zero (LSB)
			-- elsif (uart_timer = 81) then
			-- 	rx <= '0'; 	--bit one
			-- elsif (uart_timer = 82) then
			-- 	rx <= '1'; 	--bit two
			-- elsif (uart_timer = 83) then
			-- 	rx <= '0'; 	--bit three
			-- elsif (uart_timer = 84) then
			-- 	rx <= '1'; 	--bit four
			-- elsif (uart_timer = 85) then
			-- 	rx <= '1'; 	--bit five
			-- elsif (uart_timer = 86) then
			-- 	rx <= '0'; 	--bit six
			-- elsif (uart_timer = 87) then
			-- 	rx <= '0'; 	--bit seven
			-- elsif (uart_timer = 88) then
			-- 	rx <= '1'; 	--stop bit
			-- --7
			-- elsif (uart_timer = 91) then
			-- 	rx <= '0'; 	--start bit
			-- elsif (uart_timer = 92) then
			-- 	rx <= '1'; 	--bit zero (LSB)
			-- elsif (uart_timer = 93) then
			-- 	rx <= '1'; 	--bit one
			-- elsif (uart_timer = 94) then
			-- 	rx <= '1'; 	--bit two
			-- elsif (uart_timer = 95) then
			-- 	rx <= '0'; 	--bit three
			-- elsif (uart_timer = 96) then
			-- 	rx <= '1'; 	--bit four
			-- elsif (uart_timer = 97) then
			-- 	rx <= '1'; 	--bit five
			-- elsif (uart_timer = 98) then
			-- 	rx <= '0'; 	--bit six
			-- elsif (uart_timer = 99) then
			-- 	rx <= '0'; 	--bit seven
			-- elsif (uart_timer = 100) then
			-- 	rx <= '1'; 	--stop bit
			-- --6
			-- elsif (uart_timer = 103) then
			-- 	rx <= '0'; 	--start bit
			-- elsif (uart_timer = 104) then
			-- 	rx <= '0'; 	--bit zero (LSB)
			-- elsif (uart_timer = 105) then
			-- 	rx <= '1'; 	--bit one
			-- elsif (uart_timer = 106) then
			-- 	rx <= '1'; 	--bit two
			-- elsif (uart_timer = 107) then
			-- 	rx <= '0'; 	--bit three
			-- elsif (uart_timer = 108) then
			-- 	rx <= '1'; 	--bit four
			-- elsif (uart_timer = 109) then
			-- 	rx <= '1'; 	--bit five
			-- elsif (uart_timer = 110) then
			-- 	rx <= '0'; 	--bit six
			-- elsif (uart_timer = 111) then
			-- 	rx <= '0'; 	--bit seven
			-- elsif (uart_timer = 112) then
			-- 	rx <= '1'; 	--stop bit

			-- --6
			-- elsif (uart_timer = 115) then
			-- 	rx <= '0'; 	--start bit
			-- elsif (uart_timer = 116) then
			-- 	rx <= '0'; 	--bit zero (LSB)
			-- elsif (uart_timer = 117) then
			-- 	rx <= '1'; 	--bit one
			-- elsif (uart_timer = 118) then
			-- 	rx <= '1'; 	--bit two
			-- elsif (uart_timer = 119) then
			-- 	rx <= '0'; 	--bit three
			-- elsif (uart_timer = 120) then
			-- 	rx <= '1'; 	--bit four
			-- elsif (uart_timer = 121) then
			-- 	rx <= '1'; 	--bit five
			-- elsif (uart_timer = 122) then
			-- 	rx <= '0'; 	--bit six
			-- elsif (uart_timer = 123) then
			-- 	rx <= '0'; 	--bit seven
			-- elsif (uart_timer = 124) then
			-- 	rx <= '1'; 	--stop bit


			--enter
			elsif (uart_timer = 127) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 128) then
				rx <= '1'; 	--bit zero (LSB)
			elsif (uart_timer = 129) then
				rx <= '0'; 	--bit one
			elsif (uart_timer = 130) then
				rx <= '1'; 	--bit two
			elsif (uart_timer = 131) then
				rx <= '1'; 	--bit three
			elsif (uart_timer = 132) then
				rx <= '0'; 	--bit four
			elsif (uart_timer = 133) then
				rx <= '0'; 	--bit five
			elsif (uart_timer = 134) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 135) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 136) then
				rx <= '1'; 	--stop bit






			--6
			elsif (uart_timer = 140) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 141) then
				rx <= '0'; 	--bit zero (LSB)
			elsif (uart_timer = 142) then
				rx <= '1'; 	--bit one
			elsif (uart_timer = 143) then
				rx <= '1'; 	--bit two
			elsif (uart_timer = 144) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 145) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 146) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 147) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 148) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 149) then
				rx <= '1'; 	--stop bit
			--7
			elsif (uart_timer = 152) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 153) then
				rx <= '1'; 	--bit zero (LSB)
			elsif (uart_timer = 154) then
				rx <= '1'; 	--bit one
			elsif (uart_timer = 155) then
				rx <= '1'; 	--bit two
			elsif (uart_timer = 156) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 157) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 158) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 159) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 160) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 161) then
				rx <= '1'; 	--stop bit





			--5
			elsif (uart_timer = 164) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 165) then
				rx <= '1'; 	--bit zero (LSB)
			elsif (uart_timer = 166) then
				rx <= '0'; 	--bit one
			elsif (uart_timer = 167) then
				rx <= '1'; 	--bit two
			elsif (uart_timer = 168) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 169) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 170) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 171) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 172) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 173) then
				rx <= '1'; 	--stop bit

			
			--6
			elsif (uart_timer = 176) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 177) then
				rx <= '0'; 	--bit zero (LSB)
			elsif (uart_timer = 178) then
				rx <= '1'; 	--bit one
			elsif (uart_timer = 179) then
				rx <= '1'; 	--bit two
			elsif (uart_timer = 180) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 181) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 182) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 183) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 184) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 185) then
				rx <= '1'; 	--stop bit
			--7
			elsif (uart_timer = 188) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 189) then
				rx <= '1'; 	--bit zero (LSB)
			elsif (uart_timer = 190) then
				rx <= '1'; 	--bit one
			elsif (uart_timer = 191) then
				rx <= '1'; 	--bit two
			elsif (uart_timer = 192) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 193) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 194) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 195) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 196) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 197) then
				rx <= '1'; 	--stop bit
			--5
			elsif (uart_timer = 200) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 201) then
				rx <= '1'; 	--bit zero (LSB)
			elsif (uart_timer = 202) then
				rx <= '0'; 	--bit one
			elsif (uart_timer = 203) then
				rx <= '0'; 	--bit two
			elsif (uart_timer = 204) then
				rx <= '1'; 	--bit three
			elsif (uart_timer = 205) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 206) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 207) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 208) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 209) then
				rx <= '1'; 	--stop bit
			--3
			-- elsif (uart_timer = 212) then
			-- 	rx <= '0'; 	--start bit
			-- elsif (uart_timer = 213) then
			-- 	rx <= '1'; 	--bit zero (LSB)
			-- elsif (uart_timer = 214) then
			-- 	rx <= '1'; 	--bit one
			-- elsif (uart_timer = 215) then
			-- 	rx <= '0'; 	--bit two
			-- elsif (uart_timer = 216) then
			-- 	rx <= '0'; 	--bit three
			-- elsif (uart_timer = 217) then
			-- 	rx <= '1'; 	--bit four
			-- elsif (uart_timer = 218) then
			-- 	rx <= '1'; 	--bit five
			-- elsif (uart_timer = 219) then
			-- 	rx <= '0'; 	--bit six
			-- elsif (uart_timer = 220) then
			-- 	rx <= '0'; 	--bit seven
			-- elsif (uart_timer = 221) then
			-- 	rx <= '1'; 	--stop bit
			-- --6
			-- elsif (uart_timer = 224) then
			-- 	rx <= '0'; 	--start bit
			-- elsif (uart_timer = 225) then
			-- 	rx <= '0'; 	--bit zero (LSB)
			-- elsif (uart_timer = 226) then
			-- 	rx <= '1'; 	--bit one
			-- elsif (uart_timer = 227) then
			-- 	rx <= '1'; 	--bit two
			-- elsif (uart_timer = 228) then
			-- 	rx <= '0'; 	--bit three
			-- elsif (uart_timer = 229) then
			-- 	rx <= '1'; 	--bit four
			-- elsif (uart_timer = 230) then
			-- 	rx <= '1'; 	--bit five
			-- elsif (uart_timer = 231) then
			-- 	rx <= '0'; 	--bit six
			-- elsif (uart_timer = 232) then
			-- 	rx <= '0'; 	--bit seven
			-- elsif (uart_timer = 233) then
			-- 	rx <= '1'; 	--stop bit
			-- --4
			-- elsif (uart_timer = 236) then
			-- 	rx <= '0'; 	--start bit
			-- elsif (uart_timer = 237) then
			-- 	rx <= '0'; 	--bit zero (LSB)
			-- elsif (uart_timer = 238) then
			-- 	rx <= '0'; 	--bit one
			-- elsif (uart_timer = 239) then
			-- 	rx <= '1'; 	--bit two
			-- elsif (uart_timer = 240) then
			-- 	rx <= '0'; 	--bit three
			-- elsif (uart_timer = 241) then
			-- 	rx <= '1'; 	--bit four
			-- elsif (uart_timer = 242) then
			-- 	rx <= '1'; 	--bit five
			-- elsif (uart_timer = 243) then
			-- 	rx <= '0'; 	--bit six
			-- elsif (uart_timer = 244) then
			-- 	rx <= '0'; 	--bit seven
			-- elsif (uart_timer = 245) then
			-- 	rx <= '1'; 	--stop bit

			-- --9
			-- elsif (uart_timer = 248) then
			-- 	rx <= '0'; 	--start bit
			-- elsif (uart_timer = 249) then
			-- 	rx <= '1'; 	--bit zero (LSB)
			-- elsif (uart_timer = 250) then
			-- 	rx <= '0'; 	--bit one
			-- elsif (uart_timer = 251) then
			-- 	rx <= '0'; 	--bit two
			-- elsif (uart_timer = 252) then
			-- 	rx <= '1'; 	--bit three
			-- elsif (uart_timer = 253) then
			-- 	rx <= '1'; 	--bit four
			-- elsif (uart_timer = 254) then
			-- 	rx <= '1'; 	--bit five
			-- elsif (uart_timer = 255) then
			-- 	rx <= '0'; 	--bit six
			-- elsif (uart_timer = 256) then
			-- 	rx <= '0'; 	--bit seven
			-- elsif (uart_timer = 257) then
			-- 	rx <= '1'; 	--stop bit

			--3
			-- elsif (uart_timer = 260) then
			-- 	rx <= '0'; 	--start bit
			-- elsif (uart_timer = 261) then
			-- 	rx <= '1'; 	--bit zero (LSB)
			-- elsif (uart_timer = 262) then
			-- 	rx <= '1'; 	--bit one
			-- elsif (uart_timer = 263) then
			-- 	rx <= '0'; 	--bit two
			-- elsif (uart_timer = 264) then
			-- 	rx <= '0'; 	--bit three
			-- elsif (uart_timer = 265) then
			-- 	rx <= '1'; 	--bit four
			-- elsif (uart_timer = 266) then
			-- 	rx <= '1'; 	--bit five
			-- elsif (uart_timer = 267) then
			-- 	rx <= '0'; 	--bit six
			-- elsif (uart_timer = 268) then
			-- 	rx <= '0'; 	--bit seven
			-- elsif (uart_timer = 269) then
			-- 	rx <= '1'; 	--stop bit

			--enter
			elsif (uart_timer = 272) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 273) then
				rx <= '1'; 	--bit zero (LSB)
			elsif (uart_timer = 274) then
				rx <= '0'; 	--bit one
			elsif (uart_timer = 275) then
				rx <= '1'; 	--bit two
			elsif (uart_timer = 276) then
				rx <= '1'; 	--bit three
			elsif (uart_timer = 277) then
				rx <= '0'; 	--bit four
			elsif (uart_timer = 278) then
				rx <= '0'; 	--bit five
			elsif (uart_timer = 279) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 280) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 281) then
				rx <= '1'; 	--stop bit







			--1
			elsif (uart_timer = 284) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 285) then
				rx <= '1'; 	--bit zero (LSB)
			elsif (uart_timer = 286) then
				rx <= '0'; 	--bit one
			elsif (uart_timer = 287) then
				rx <= '0'; 	--bit two
			elsif (uart_timer = 288) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 289) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 290) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 291) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 292) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 293) then
				rx <= '1'; 	--stop bit
			--4
			elsif (uart_timer = 296) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 297) then
				rx <= '0'; 	--bit zero (LSB)
			elsif (uart_timer = 298) then
				rx <= '0'; 	--bit one
			elsif (uart_timer = 299) then
				rx <= '1'; 	--bit two
			elsif (uart_timer = 300) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 301) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 302) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 303) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 304) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 305) then
				rx <= '1'; 	--stop bit
			--3
			elsif (uart_timer = 308) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 309) then
				rx <= '1'; 	--bit zero (LSB)
			elsif (uart_timer = 310) then
				rx <= '1'; 	--bit one
			elsif (uart_timer = 311) then
				rx <= '0'; 	--bit two
			elsif (uart_timer = 312) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 313) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 314) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 315) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 316) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 317) then
				rx <= '1'; 	--stop bit
			--1
			elsif (uart_timer = 320) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 321) then
				rx <= '1'; 	--bit zero (LSB)
			elsif (uart_timer = 322) then
				rx <= '0'; 	--bit one
			elsif (uart_timer = 323) then
				rx <= '0'; 	--bit two
			elsif (uart_timer = 324) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 325) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 326) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 327) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 328) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 329) then
				rx <= '1'; 	--stop bit
			--6
			elsif (uart_timer = 332) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 333) then
				rx <= '0'; 	--bit zero (LSB)
			elsif (uart_timer = 334) then
				rx <= '1'; 	--bit one
			elsif (uart_timer = 335) then
				rx <= '1'; 	--bit two
			elsif (uart_timer = 336) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 337) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 338) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 339) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 340) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 341) then
				rx <= '1'; 	--stop bit
			--5
			elsif (uart_timer = 344) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 345) then
				rx <= '1'; 	--bit zero (LSB)
			elsif (uart_timer = 346) then
				rx <= '0'; 	--bit one
			elsif (uart_timer = 347) then
				rx <= '1'; 	--bit two
			elsif (uart_timer = 348) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 349) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 350) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 351) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 352) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 353) then
				rx <= '1'; 	--stop bit
			--5
			elsif (uart_timer = 356) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 357) then
				rx <= '1'; 	--bit zero (LSB)
			elsif (uart_timer = 358) then
				rx <= '0'; 	--bit one
			elsif (uart_timer = 359) then
				rx <= '1'; 	--bit two
			elsif (uart_timer = 360) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 361) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 362) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 363) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 364) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 365) then
				rx <= '1'; 	--stop bit
			--7
			elsif (uart_timer = 368) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 369) then
				rx <= '1'; 	--bit zero (LSB)
			elsif (uart_timer = 370) then
				rx <= '1'; 	--bit one
			elsif (uart_timer = 371) then
				rx <= '1'; 	--bit two
			elsif (uart_timer = 372) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 373) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 374) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 375) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 376) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 377) then
				rx <= '1'; 	--stop bit
			--6
			elsif (uart_timer = 380) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 381) then
				rx <= '0'; 	--bit zero (LSB)
			elsif (uart_timer = 382) then
				rx <= '1'; 	--bit one
			elsif (uart_timer = 383) then
				rx <= '1'; 	--bit two
			elsif (uart_timer = 384) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 385) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 386) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 387) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 388) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 389) then
				rx <= '1'; 	--stop bit

			--7
			elsif (uart_timer = 392) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 393) then
				rx <= '1'; 	--bit zero (LSB)
			elsif (uart_timer = 394) then
				rx <= '1'; 	--bit one
			elsif (uart_timer = 395) then
				rx <= '1'; 	--bit two
			elsif (uart_timer = 396) then
				rx <= '0'; 	--bit three
			elsif (uart_timer = 397) then
				rx <= '1'; 	--bit four
			elsif (uart_timer = 398) then
				rx <= '1'; 	--bit five
			elsif (uart_timer = 399) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 400) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 401) then
				rx <= '1'; 	--stop bit








			--enter
			elsif (uart_timer = 404) then
				rx <= '0'; 	--start bit
			elsif (uart_timer = 405) then
				rx <= '1'; 	--bit zero (LSB)
			elsif (uart_timer = 406) then
				rx <= '0'; 	--bit one
			elsif (uart_timer = 407) then
				rx <= '1'; 	--bit two
			elsif (uart_timer = 408) then
				rx <= '1'; 	--bit three
			elsif (uart_timer = 409) then
				rx <= '0'; 	--bit four
			elsif (uart_timer = 410) then
				rx <= '0'; 	--bit five
			elsif (uart_timer = 411) then
				rx <= '0'; 	--bit six
			elsif (uart_timer = 412) then
				rx <= '0'; 	--bit seven
			elsif (uart_timer = 413) then
				rx <= '1'; 	--stop bit
			end if;
		end if;
	end process;
	

end architecture behavioral;