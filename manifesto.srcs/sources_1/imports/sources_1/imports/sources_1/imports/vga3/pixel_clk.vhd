----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/10/2014 04:34:53 PM
-- Design Name: 
-- Module Name: pixel_clk - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pixel_clk is
    Port ( CCLK : in STD_LOGIC;
           pclk : out STD_LOGIC);
end pixel_clk;

architecture Behavioral of pixel_clk is

signal counter: integer range 0 to 3;

begin

process(CCLK)
begin
if rising_edge(CCLK) then
    if counter = 3 then
        counter <= 0;
        pclk <= '1';
    else
        pclk <= '0';
        counter <= counter+1;
    end if;
end if;
end process;

end Behavioral;
