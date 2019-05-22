--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:31:48 07/27/2018
-- Design Name:   
-- Module Name:   /home/ise/ise_projects/FinalPP/ACC.vhd
-- Project Name:  FinalPP
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ControlUnit
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY ACC IS
END ACC;
 
ARCHITECTURE behavior OF ACC IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ControlUnit
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         S_IN : IN  std_logic_vector(15 downto 0);
         S_WR : OUT  std_logic;
         S_OUT : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal S_IN : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal S_WR : std_logic;
   signal S_OUT : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 100 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ControlUnit PORT MAP (
          clk => clk,
          reset => reset,
          S_IN => S_IN,
          S_WR => S_WR,
          S_OUT => S_OUT
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
		reset <= '1';
		wait for clk_period;
		reset <= '0';
		wait for clk_period;
		S_IN <= std_logic_vector(to_unsigned(5, 16));
		wait for clk_period*4;
		S_IN <= std_logic_vector(to_unsigned(13, 16));
		wait for clk_period;
		wait for 100000ns;
   end process;

END;
