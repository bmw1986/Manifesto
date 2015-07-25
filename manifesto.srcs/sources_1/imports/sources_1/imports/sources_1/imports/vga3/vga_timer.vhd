----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/10/2014 04:25:14 PM
-- Design Name: 
-- Module Name: vga_timer - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_timer is
    Port ( clk : in STD_LOGIC;
           xaddr : out STD_LOGIC_VECTOR (9 downto 0);
           yaddr : out STD_LOGIC_VECTOR (8 downto 0);
           hsync : out STD_LOGIC;
           vsync : out STD_LOGIC;
           blank : out STD_LOGIC);
end vga_timer;

architecture Behavioral of vga_timer is

signal hcnt:integer range 0 to 799:=735;
signal vcnt:integer range 0 to 521:=481;
signal hen,ven:std_logic;

begin
process(clk)
begin
if rising_edge(clk) then
    if hcnt = 799 then
        hcnt <= 0;
    else
        hcnt <= hcnt + 1;
    end if;
    
    case hcnt is
        when 639 => -- end of image data
            hen <= '0';
        when 655 => -- after front porch
            if vcnt = 521 then
                vcnt <= 0;
					 ven <= '1';
            else
                vcnt <= vcnt + 1;
            end if;
				if vcnt = 479 then
					ven <= '0';
				end if;
            hsync <= '0'; -- or not ven;
        when 751 => -- after pulse
            hsync <= '1';
        when 799 => -- after back porch
            hen <= '1';
        when others =>
    end case;
    
    case vcnt is
--        when 480 => -- end of image data
--            ven <= '0';
        when 489 => -- after front porch
            vsync <= '0';
        when 491 => -- after pulse
            vsync <= '1';
--        when 0 => -- after back porch
--				ven <= '1';
        when others =>
    end case;
        
    blank <= not (hen and ven);
        if hen = '1' then
            xaddr <= std_logic_vector(to_unsigned(hcnt,10));
        end if;
        
        if ven = '1' then
            yaddr <= std_logic_vector(to_unsigned(vcnt,9));
        end if; 
end if;
end process;
--process(hcnt,vcnt)
--begin
--        if hen = '1' then
--            xaddr <= std_logic_vector(to_unsigned(hcnt,10));
--        end if;
--        
--        if ven = '1' then
--            yaddr <= std_logic_vector(to_unsigned(vcnt,9));
--        end if;
--end process;

end Behavioral;
