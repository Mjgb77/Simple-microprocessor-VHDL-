----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:29:39 07/24/2018 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all; 

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( A : in  STD_LOGIC_VECTOR (15 downto 0);
           B : in  STD_LOGIC_VECTOR (15 downto 0);
           S : in  STD_LOGIC_VECTOR (3 downto 0);
           R : buffer  STD_LOGIC_VECTOR (15 downto 0);
           Z : out  STD_LOGIC);
end ALU;

architecture Behavioral of ALU is

begin

	with S select
				-- ARITH
		R <=	(A)					when "0000",
				(A + x"0001")		when "0001",
				(A + B)				when "0010",
				(A + B + x"0001")	when "0011",
				(A + (not B))		when "0100",
				(A - B)				when "0101",
				(A - x"0001")		when "0110",
				(A)					when "0111",
				-- LOGIC
				(not A)				when "1000",
				(A and B)			when "1001",
				(A or B)				when "1010",
				(A xor B)			when "1011",
				-- SHIFTER
				to_stdlogicvector(to_bitvector(A) sll 1) 			when "1100",
				to_stdlogicvector(to_bitvector(A) srl 1) 			when "1101",
				to_stdlogicvector(to_bitvector(A) rol 1)			when "1110",
				to_stdlogicvector(to_bitvector(A) ror 1)			when "1111";
	
	Z <= '1' when (R = x"0000") else '0';


end Behavioral;

