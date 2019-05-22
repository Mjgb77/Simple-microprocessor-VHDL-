----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:36:51 07/27/2018 
-- Design Name: 
-- Module Name:    ControlUnit - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ControlUnit is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           S_IN : in  STD_LOGIC_VECTOR (15 downto 0);
           S_WR : out  STD_LOGIC;
           S_OUT : out  STD_LOGIC_VECTOR (15 downto 0));
end ControlUnit;

architecture Behavioral of ControlUnit is

component RAM is
    Port ( data_in : in  STD_LOGIC_VECTOR (15 downto 0);
           address : in  STD_LOGIC_VECTOR (15 downto 0);
           WR : in  STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR (15 downto 0) := (others => '0'));
end component;

component ALU is
    Port ( A : in  STD_LOGIC_VECTOR (15 downto 0);
           B : in  STD_LOGIC_VECTOR (15 downto 0);
           S : in  STD_LOGIC_VECTOR (3 downto 0);
           R : buffer  STD_LOGIC_VECTOR (15 downto 0);
           Z : out  STD_LOGIC);
end component;


type RF_array is array(0 to 7) of std_logic_vector(15 downto 0);
signal RF: RF_array := (others => (others=>'0'));

signal PC : integer range 0 to 255 := 0;
signal SP : integer range 0 to 255 := 0;

signal IR: std_logic_vector(15 downto 0);

signal RA: std_logic_vector(2 downto 0) := (others => '0');
signal RB: std_logic_vector(2 downto 0) := (others => '0');
signal RD: std_logic_vector(2 downto 0) := (others => '0');

signal terminate : std_logic := '0';

signal opcode: std_logic_vector (6 downto 0) := (others => '0');

signal ramAddr : std_logic_vector(15 downto 0);
signal ramWData : std_logic_vector(15 downto 0) := (others => '0');
signal ramRData : std_logic_vector(15 downto 0) := (others => '0');
signal ramWR : std_logic;

signal aluA : std_logic_vector (15 downto 0) := (others => '0');
signal aluB : std_logic_vector (15 downto 0) := (others => '0');
signal aluS : std_logic_vector (3 downto 0) := (others => '0');
signal aluR : std_logic_vector (15 downto 0) := (others => '0');
signal aluZ : std_logic := '0';

type state_type is (	reset_PC, fetch, decode, decode1, execute_ldi, execute_ldi1, execute_movr,
							execute_movmr, execute_movmr1, execute_movmr2, execute_movrm, execute_movrm1, execute_movrm2,
							execute_inc, execute_inc1, execute_dec, execute_dec1, execute_adi, execute_adi1, execute_adi2,
							execute_add, execute_add1, execute_addc, execute_addc1, execute_sub, execute_sub1,
							execute_jmp, execute_jmp1, execute_jz, execute_jz1, execute_jnz, execute_jnz1,
							execute_and, execute_and1, execute_or, execute_or1, execute_in, execute_out, execute_ev,
							execute_call, execute_call_1, execute_ret, execute_ret1, execute_halt);
signal state : state_type;

begin
	uut_ram: RAM Port map (
		data_in => ramWData,
		address => ramAddr,
		WR => ramWR,
		data_out => ramRData
	);
	
	uut_alu: ALU Port map (
		A => aluA,
		B => aluB,
		S => aluS,
		R => aluR,
		Z => aluZ
	);

	process (clk, reset)
	begin
		if reset = '1' then
			terminate <= '0';
			ramWR <= '0';
			state <= reset_PC;
		elsif rising_edge(clk) and terminate = '0' then
			case state is
				when reset_PC =>
					ramAddr <= conv_std_logic_vector(PC,16);
					PC <= PC + 1;
					ramWData <= x"0000";
					state <= fetch;
					
				when fetch =>
					ramWR <= '0';
					ramAddr <= conv_std_logic_vector(PC,16);
					IR <= ramRData;
					PC <= PC +  1;
					state <= decode;
					
				when decode =>
					opcode <= IR(15 downto 9);
					RA <= IR(8 downto 6);
					RB <= IR(5 downto 3);
					RD <= IR(2 downto 0);       
					state <= decode1;
					
				when decode1 =>
					case opcode is
						when "0000001" =>
							state <= execute_ldi;
						when "0000010" =>
							state <= execute_movr;
						when "0000011" =>
							state <= execute_movmr;
						when "0000100" =>
							state <= execute_movrm;
						when "0000101" =>
							state <= execute_inc;
						when "0000110" =>
							state <= execute_dec;
						when "0000111" =>
							state <= execute_adi;
						when "0001000" =>
							state <= execute_add;
						when "0001001" =>
							state <= execute_addc;
						when "0001010" =>
							state <= execute_sub;
						when "0001011" =>
							state <= execute_jmp;
						when "0001100" =>
							state <= execute_jz;
						when "0001101" =>
							state <= execute_jnz;
						when "0001110" =>
							state <= execute_and;
						when "0001111" =>
							state <= execute_or;
						when "0010000" =>
							state <= execute_in;
						when "0010001" =>
							state <= execute_out;
						when "0010010" =>
							state <= execute_ev;
	 					when "0010011" =>
							state <= execute_call;
						when "0010100" =>
							state <= execute_ret;
						when "1111111" =>
							state <= execute_halt;
						when others =>
							state <= fetch;
					end case;
				
				when execute_ldi =>
					ramWR <= '0';
					ramAddr <= conv_std_logic_vector(PC,16);
					IR <= ramRData;
					PC <= PC + 1;
					state <= execute_ldi1;
				when execute_ldi1 =>
					RF(conv_integer(RA)) <= IR;
					state <= fetch;
					
				when execute_movr =>
					RF(conv_integer(RD)) <= RF(conv_integer(RA));
					state <= fetch;
				
				when execute_movmr =>
					ramWR <= '0';
					ramAddr <= conv_std_logic_vector(PC,16);
					IR <= ramRData;
					PC <= PC + 1;
					state <= execute_movmr1;
				when execute_movmr1 =>
					ramWR <= '0';
					ramAddr <= IR;
					RF(conv_integer(RD)) <= ramRData;
					PC <= PC + 1;
					state <= fetch;
					
				when execute_movrm =>
					ramWR <= '0';
					ramAddr <= conv_std_logic_vector(PC,16);
					IR <= ramRData;
					PC <= PC + 1;
					state <= execute_movrm1;
				when execute_movrm1 =>
					ramWR <= '1';
					ramAddr <= IR;
					ramWData <= RF(conv_integer(RA));
					PC <= PC + 1;
					state <= execute_movrm2;
				when execute_movrm2 =>
					ramWR <= '0';
					state <= fetch;
				when execute_inc =>
					aluS <= "0001";
					aluA <= RF(conv_integer(RA));
					state <= execute_inc1;
				when execute_inc1 =>
					RF(conv_integer(RA)) <= aluR;
					state <= fetch;

				when execute_dec =>
					aluS <= "0110";
					aluA <= RF(conv_integer(RA));
					state <= execute_dec1;
				when execute_dec1 =>
					RF(conv_integer(RA)) <= aluR;
					state <= fetch;
					
				when execute_adi =>
					ramWR <= '0';
					ramAddr <= conv_std_logic_vector(PC,16);
					IR <= ramRData;
					PC <= PC + 1;
					state <= execute_adi1;
				when execute_adi1 =>
					aluS <= "0010";
					aluA <= RF(conv_integer(RA));
					aluB <= IR;
					state <= execute_adi2;
				when execute_adi2 =>
					RF(conv_integer(RA)) <= aluR;
					state <= fetch;
					
				when execute_add =>
					aluS <= "0010";
					aluA <= RF(conv_integer(RA));
					aluB <= RF(conv_integer(RD));
					state <= execute_add1;
				when execute_add1 =>
					RF(conv_integer(RD)) <= aluR;
					state <= fetch;
					
				when execute_addc =>
					aluS <= "0011";
					aluA <= RF(conv_integer(RA));
					aluB <= RF(conv_integer(RD));
					state <= execute_addc1;
				when execute_addc1 =>
					RF(conv_integer(RD)) <= aluR;
					state <= fetch;

				when execute_sub =>
					aluS <= "0101";
					aluA <= RF(conv_integer(RD));
					aluB <= RF(conv_integer(RA));
					state <= execute_sub1;
				when execute_sub1 =>
					RF(conv_integer(RD)) <= aluR;
					state <= fetch;	

				when execute_jmp =>
					ramWR <= '0';
					ramAddr <= conv_std_logic_vector(PC,16);
					IR <= ramRData;
					state <= execute_jmp1;
				when execute_jmp1 =>
					PC <= conv_integer(unsigned(IR));
					state <= fetch;
					
				when execute_jz =>
					ramWR <= '0';
					ramAddr <= conv_std_logic_vector(PC,16);
					IR <= ramRData;
					state <= execute_jz1;
				when execute_jz1 =>
					if (aluZ = '1') then
						PC <= conv_integer(unsigned(IR));
					else
						PC <= PC+1;
					end if;
					state <= fetch;
					
				when execute_jnz =>
					ramWR <= '0';
					ramAddr <= conv_std_logic_vector(PC,16);
					IR <= ramRData;
					state <= execute_jnz1;
				when execute_jnz1 =>
					if (aluZ /= '1') then
						PC <= conv_integer(unsigned(IR));
					else
						PC <= PC+1;
					end if;
					state <= fetch;
				
				when execute_and =>
					aluS <= "1001";
					aluA <= RF(conv_integer(RD));
					aluB <= RF(conv_integer(RA));
					state <= execute_and1;
				when execute_and1 =>
					RF(conv_integer(RD)) <= aluR;
					state <= fetch;
				
				when execute_or =>
					aluS <= "1010";
					aluA <= RF(conv_integer(RD));
					aluB <= RF(conv_integer(RA));
					state <= execute_or1;
				when execute_or1 =>
					RF(conv_integer(RD)) <= aluR;
					state <= fetch;
				
				when execute_in =>
					RF(conv_integer(RD)) <= S_IN;
					state <= fetch;
				
				when execute_out =>
					S_OUT <= RF(conv_integer(RA));
					state <= fetch;

				when execute_ev =>
					aluS <= "0000";
					aluA <= RF(conv_integer(RA));
					state <= fetch;
					
				when execute_call =>
					ramWR <= '1';
					ramAddr <= conv_std_logic_vector(SP,16);
					ramWData <= conv_std_logic_vector(PC,16);
					state <= execute_call_1;
				when execute_call_1 =>
					SP <= SP-1;
					state <= fetch;
				
				when execute_ret =>
					if (SP /= 255) then
						ramWR <= '0';
						ramAddr <= conv_std_logic_vector(SP+1,16);
						PC <= conv_integer(ramRData);
						state <= execute_ret1;
					else
						state <= fetch;
					end if;
				when execute_ret1 =>
					SP <= SP+1;
					state <= fetch;
				
				when execute_halt =>
					terminate <= '1';
					state <= fetch;
				
				when others =>
					state <= fetch;
			end case;
		end if;
	end process;

end Behavioral;