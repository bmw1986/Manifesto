library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

entity clk_enabler is
    Port  (
        iClk        : in std_logic;
        pulse       : inout std_logic := '0';
        latch       : out std_logic
    );
end clk_enabler;

architecture Behavioral of clk_enabler is
   
    signal div          : integer range 0 to 1666666:=0;

begin

process(iClk)
    begin
    if rising_edge(iClk) then
        div <= div + 1;
        if div < 1200 then
            latch <= '1';
        else
            latch <= '0';
            if div >= 1800 and div < 11400 and ((div mod 600) = 0) then
                pulse <= not pulse;
            end if;
        end if;
    end if;    
end process;

end Behavioral;
