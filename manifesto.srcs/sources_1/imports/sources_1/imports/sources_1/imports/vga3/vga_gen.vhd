----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/10/2014 04:32:07 PM
-- Design Name: 
-- Module Name: vga_gen - Behavioral
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga_gen is
    Port ( CCLK : in STD_LOGIC;
           hsync : out STD_LOGIC;
           vsync : out STD_LOGIC;
           colorout : out STD_LOGIC_VECTOR (7 downto 0);
           colorin : in STD_LOGIC_VECTOR (7 downto 0);
           xaddr : out STD_LOGIC_VECTOR (9 downto 0);
           yaddr : out STD_LOGIC_VECTOR (8 downto 0);
           posX: in std_logic_vector(9 downto 0);
           posY: in std_logic_vector(8 downto 0);
           cursorx: std_logic_vector(9 downto 0);
           cursory: std_logic_vector(8 downto 0);
           writemode: std_logic);
end vga_gen;

architecture Behavioral of vga_gen is

component vga_timer is
    Port ( clk : in STD_LOGIC;
           xaddr : out STD_LOGIC_VECTOR (9 downto 0);
           yaddr : out STD_LOGIC_VECTOR (8 downto 0);
           hsync : out STD_LOGIC;
           vsync : out STD_LOGIC;
           blank : out STD_LOGIC);
end component;

component pixel_clk is
    Port ( CCLK : in STD_LOGIC;
           pclk : out STD_LOGIC);
end component;

signal blanks,hsyncs,vsyncs,pclk: std_logic;
signal xaddrs: std_logic_vector(9 downto 0);
signal yaddrs: std_logic_vector(8 downto 0);

begin

TIMING_GENERATOR: vga_timer
    Port map( clk => pclk, -- : in STD_LOGIC;
           xaddr => xaddrs, -- : out STD_LOGIC_VECTOR (9 downto 0);
           yaddr => yaddrs, -- : out STD_LOGIC_VECTOR (8 downto 0);
           hsync => hsyncs, -- : out STD_LOGIC;
           vsync => vsyncs, -- : in STD_LOGIC;
           blank => blanks -- : out STD_LOGIC
           );

CLOCKING: pixel_clk
    Port map( CCLK => CCLK, -- : in STD_LOGIC;
           pclk => pclk -- : out STD_LOGIC
           );

	 xaddr <= xaddrs;
	 yaddr <= yaddrs;
process(CCLK)
begin
if rising_edge(pclk) then
    hsync <= hsyncs;
    vsync <= vsyncs; 
    if blanks = '1' then	 
        colorout <= "00000000";
    elsif xaddrs = cursorx and yaddrs = cursory and writemode = '1' then
        colorout <= "11100000";
    elsif (xaddrs>=posX and xaddrs<=std_logic_vector(unsigned(posX)+"1111")) and (yaddrs>=posY and yaddrs<=std_logic_vector(unsigned(posY)+"1111")) then
        colorout <= "10010010"; -- character
    else -- show stuff...
        colorout <= colorin;
    end if;
end if;
end process;
end Behavioral;
