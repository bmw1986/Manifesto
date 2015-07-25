-- nes_fsm.vhd
library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

entity marioPosition is
    port (
      clk: in std_logic;
      vsync: in STD_LOGIC;
      button: in std_logic_vector(7 downto 0);
      color: in std_logic_vector(7 downto 0);
      vgaX : in STD_LOGIC_VECTOR (9 downto 0);   
      vgaY : in STD_LOGIC_VECTOR (8 downto 0);
      posX: out std_logic_vector(9 downto 0);
      posY: out std_logic_vector(8 downto 0);
      writemode: in STD_LOGIC);
end marioPosition;
architecture arch of marioPosition is

    component boundary_setter
    Port ( clk : in STD_LOGIC;
           vsync : in STD_LOGIC;
           color : in std_logic_vector(7 downto 0);
           mxpos : in STD_LOGIC_VECTOR (9 downto 0);
           mypos : in STD_LOGIC_VECTOR (8 downto 0);
           vxpos : in STD_LOGIC_VECTOR (9 downto 0);
           vypos : in STD_LOGIC_VECTOR (8 downto 0);
           lb : inout STD_LOGIC_VECTOR (9 downto 0);
           rb : inout STD_LOGIC_VECTOR (9 downto 0);
           ub : inout STD_LOGIC_VECTOR (8 downto 0);
           db : inout STD_LOGIC_VECTOR (8 downto 0));
    end component;

    signal pX : integer range 0 to 639:=319;
    signal pY : integer range 0 to 479:=279;
    signal pXs : integer range 0 to 639:=319;
    signal pYs : integer range 0 to 479:=279; 
    signal vX: integer range -15 to 15:=0;
    signal vY: integer range -25 to 25:=0;
    signal vmax: integer range 0 to 15:= 6;
    signal jump: integer range 0 to 15:= 0;
    signal jumpMax: integer range 0 to 15:= 15;
    signal jumpPeak: std_logic:= '0';
    signal lb: integer range 0 to 639:=10;
    signal rb: integer range 0 to 639:=629;
    signal ub: integer range 0 to 479:=10;
    signal db: integer range 0 to 479:=479;
    signal size: integer range 0 to 100:=16;
    signal lbs,rbs: std_logic_vector(9 downto 0);
    signal ubs,dbs: std_logic_vector(8 downto 0);

begin  -- arch

Boundaries:boundary_setter
       port map(
      clk => clk,
      vsync => vsync,
      color => color,
      mxpos => std_logic_vector(to_unsigned(pX,10)),
      mypos => std_logic_vector(to_unsigned(pY,9)),
      vxpos => vgaX,
      vypos => vgaY,
      lb => lbs,
      rb => rbs,
      ub => ubs,
      db => dbs
      );
      lb <= to_integer(unsigned(lbs));
      rb <= to_integer(unsigned(rbs));
      ub <= to_integer(unsigned(ubs));
      db <= to_integer(unsigned(dbs));
    fsm:process(vsync)
    begin
    pXs <= (pX*2 + Vx)/2;
    pYs <= (pY*2 + Vy)/2;
   
    
    if falling_edge(vsync) then
        if Vx > 0 then
            Vx <= Vx - 1;
        end if;
        if Vx < 0 then
            Vx <= Vx + 1;
        end if;
--        if Vy > 0 then
--            Vy <= Vy - 1;
--        end if;
        if Vy /= 25 then
            Vy <= Vy + 1;
        end if;
        
        if writemode = '0' then
            px <= pxs;
            py <= pys;
        end if;
        
        if pXs <= lb then
            pX <= lb+1;
            Vx <= 0;
        end if;
        if pXs >= rb - 15 then
            pX <= rb-16;
            Vx <= 0;
        end if;
        if pYs >= db - 15 then
            py <= db-16;
            Vy <= 0;
        end if;
        if pYs <= ub then
            py <= ub+1;
            Vy <= 0;
        end if;
        
                
        if button(6) = '1' then
            vmax <= 15;
        else
            vmax <= 6;
        end if;
        
        if button(7) = '1' and py = (db-16) then
            if button(6) = '1' and vx /= 0 then
                Vy <= -18;
            else
                Vy <= -13;
            end if;
        end if;
        
        if button(0) = '1' then
            if Vx < vmax then
                vx <= vx + 1;
            end if;
        end if;
        if button(1) = '1' then
            if Vx > -vmax then
                vx <= vx - 1;
            end if;
        end if;
--        if button(2) = '1' then
--            if Vy < vmax then
--                vy <= vy + 1;
--            end if;
--        end if;
--        if button(3) = '1' then
--            if Vy > -vmax then
--                vy <= vy - 1;
--            end if;
--        end if;        
    end if;
    end process fsm;

posX <= std_logic_vector(to_unsigned(pX,10));
posY <= std_logic_vector(to_unsigned(pY,9));

end arch;
    
