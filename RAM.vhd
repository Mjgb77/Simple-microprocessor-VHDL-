----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:33:28 07/27/2018 
-- Design Name: 
-- Module Name:    RAM - Behavioral 
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RAM is
    Port ( data_in : in  STD_LOGIC_VECTOR (15 downto 0);
           address : in  STD_LOGIC_VECTOR (15 downto 0);
           WR : in  STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR (15 downto 0));
end RAM;

architecture Behavioral of RAM is

type RAM_ARR is array (0 to 255) of std_logic_vector (15 downto 0);

signal mem : RAM_ARR := (	0 => "0010000000000000",
									1 => "0010000000000001",
									2 => "0010010000000000",
									3 => "0001100000000000",
									4 => "0000000000001001",
									5 => "0001000001000010",
									6 => "0000110000000000",
									7 => "0001101000000000",
									8 => "0000000000000101",
									9 => "0010001010000000",
									10 => "1111111111111111",
									others => (others=>'0') );

signal data : STD_LOGIC_VECTOR (15 downto 0); 

begin
	data_out <= data when (WR = '0') else (others=>'Z');

	-- Memory Write Block
	MEM_WRITE:
	process (address, data_in, WR) begin
		if (WR = '1') then
			mem(conv_integer(address)) <= data_in;
		end if;
	end process;
	
	-- Memory Read Block
	MEM_READ:
		process (address, WR) begin
		if (WR = '0')  then
			data <= mem(conv_integer(address));
		end if;
	end process;

end Behavioral;
