----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/22/2014 02:12:22 PM
-- Design Name: 
-- Module Name: boundary_setter - Behavioral
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

entity boundary_setter is
    Port ( clk : in STD_LOGIC;
           vsync : in STD_LOGIC;
           color : in STD_LOGIC_VECTOR (7 downto 0):="000000000";
           mxpos : in STD_LOGIC_VECTOR (9 downto 0):="000000000";
           mypos : in STD_LOGIC_VECTOR (8 downto 0):="000000000";
           vxpos : in STD_LOGIC_VECTOR (9 downto 0):="000000000";
           vypos : in STD_LOGIC_VECTOR (8 downto 0):="000000000";
           lb : out STD_LOGIC_VECTOR (9 downto 0):="0000001000";
           rb : out STD_LOGIC_VECTOR (9 downto 0):="1001011111";
           ub : out STD_LOGIC_VECTOR (8 downto 0):="000001000";
           db : out STD_LOGIC_VECTOR (8 downto 0):="110111111");
end boundary_setter;

architecture Behavioral of boundary_setter is

signal r1,r2,r3,r4,presync: std_logic;
signal lbs: unsigned(9 downto 0):="0000001000";
signal rbs: unsigned(9 downto 0):="1001110111";
signal ubs: unsigned(8 downto 0):="000001000";
signal dbs: unsigned(8 downto 0):="111010111";

begin

process(vxpos,vypos)
begin
if unsigned(vxpos) >= unsigned(mxpos) and unsigned(vxpos) <= unsigned(mxpos) + 15 and unsigned(vypos) < unsigned(mypos) then
    r1 <= '1';
else
    r1 <= '0';
end if;
if unsigned(vypos) >= unsigned(mypos) and unsigned(vypos) <= unsigned(mypos) + 15 and unsigned(vxpos) < unsigned(mxpos) then
    r2 <= '1';
else
    r2 <= '0';
end if;
if unsigned(vypos) >= unsigned(mypos) and unsigned(vypos) <= unsigned(mypos) + 15 and unsigned(vxpos) > unsigned(mxpos) + 15 then
    r3 <= '1';
else
    r3 <= '0';
end if;
if unsigned(vxpos) >= unsigned(mxpos) and unsigned(vxpos) <= unsigned(mxpos) + 15 and unsigned(vypos) > unsigned(mypos) + 15 then
    r4 <= '1';
else
    r4 <= '0';
end if;
end process;

process(clk)
begin
if rising_edge(clk) then
    presync <= vsync;
    if presync = '0' and vsync = '1' then
        lbs <= "0000001000";
        rbs <= "1001110111";
        ubs <= "000001000";
        dbs <= "111010111";
    else
        if r1 = '1' and color /="11111111" and unsigned(vypos) > ubs then
            ubs <= unsigned(vypos);
        end if;
        if r2 = '1' and color /="11111111" and unsigned(vxpos) > lbs then
            lbs <= unsigned(vxpos);
        end if;
        if r3 = '1' and color /="11111111" and unsigned(vxpos) < rbs then
            rbs <= unsigned(vxpos);
        end if;
        if r4 = '1' and color /="11111111" and unsigned(vypos) < dbs then
            dbs <= unsigned(vypos);
        end if;
    end if;
end if;
end process;           

lb <= std_logic_vector(lbs);
rb <= std_logic_vector(rbs);
ub <= std_logic_vector(ubs);
db <= std_logic_vector(dbs);

end Behavioral;
