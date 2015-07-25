----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/11/2014 12:18:10 AM
-- Design Name: 
-- Module Name: test - Behavioral
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

entity test is
    Port ( color : out STD_LOGIC_VECTOR (7 downto 0);
           hsync : out STD_LOGIC;
           vsync : out STD_LOGIC;
           CCLK : in STD_LOGIC;
           ce : out STD_LOGIC;
           oe : out STD_LOGIC;
           we : out STD_LOGIC;
           crdata : inout STD_LOGIC_VECTOR (15 downto 0);
           craddr : out STD_LOGIC_VECTOR (25 downto 0);
           lb :out std_logic;
           cre : out std_logic;
           adv : out std_logic;
           ub : out std_logic;
           crclk : out std_logic;
           crwait : in std_logic;
           btn : in std_logic_vector (4 downto 0);
           switches : in std_logic_vector(7 downto 0);
           NESlatch : out std_logic:='0';
           NESpulse : out std_logic:='0';
           NESdata : in std_logic;
--           PS2KeyboardData : inout std_logic;
--           PS2KeyboardClk : inout std_logic;
           led : out std_logic_vector(7 downto 0)
           );
end test;

architecture Behavioral of test is

component vga_gen is
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
end component;

component ramcontroller is
	Port ( wraddr : in STD_LOGIC_VECTOR (18 downto 0);
		   wrdata : in STD_LOGIC_VECTOR (7 downto 0);
		   xaddr : in std_logic_vector (9 downto 0);
		   yaddr : in std_logic_vector(8 downto 0);
		   rddata : out STD_LOGIC_VECTOR(7 downto 0);
		   crdata : inout STD_LOGIC_VECTOR (15 downto 0);--:="000000000000000";
		   craddr : out STD_LOGIC_VECTOR (25 downto 0);--:="00000000000000000000000000";
		   ce : out STD_LOGIC:='1';
		   oe : out STD_LOGIC:='1';
		   we : out STD_LOGIC:='1';
		   adv : out std_logic:='1';
		   cre : out std_logic:='0';
		   clk : in std_logic;
		   crwait : in std_logic;
		   crclk : out std_logic;
			wrcmd : in std_logic;
			stahp : out std_logic;
			ub : out std_logic;
			lb : out std_logic;
            			offset : in std_logic_vector(7 downto 0)
			);
end component;

component nes_fsm is
    port (
	  clk: in std_logic;
	  latch: in std_logic;
	  pulse: in std_logic;
	  data: in std_logic;
	  button: out std_logic_vector(7 downto 0)
	  );
end component;

component marioPosition is
    port (clk: in std_logic;
      vsync: in STD_LOGIC;
      writemode: in STD_LOGIC;
      button: in std_logic_vector(7 downto 0);
      color: in std_logic_vector(7 downto 0);
      vgaX : in STD_LOGIC_VECTOR (9 downto 0);   
      vgaY : in STD_LOGIC_VECTOR (8 downto 0);
      posX: out std_logic_vector(9 downto 0);
      posY: out std_logic_vector(8 downto 0)
      );
end component;

--component ps2interface is
--    port(
--      ps2_clk  : inout std_logic;
--      ps2_data : inout std_logic;

--      clk      : in std_logic;
--      rst      : in std_logic;

--      tx_data  : in std_logic_vector(7 downto 0);
--      write    : in std_logic;
   
--      rx_data  : out std_logic_vector(7 downto 0);
--      read     : out std_logic;
--      busy     : out std_logic;
--      err      : out std_logic
--      );
--end component;

--component SerialController is
--Port ( iClk:       IN std_logic;
--       clkEn:      IN std_logic;
--       ClkEnRun:   out std_logic;
--       iScan:      IN std_logic_vector(7 DOWNTO 0);
--       iReset:     IN std_logic;
--       RX:         OUT std_logic);
--end component;

--component TopLevel is
--    Port ( 
--        adc_digital             : in STD_LOGIC_VECTOR (7 downto 0);
--        SystemClock_IN          : in STD_LOGIC;
--		EOC_IN			        : in STD_LOGIC;
--        address_A_OUT           : out STD_LOGIC;
--        address_B_OUT           : out STD_LOGIC:= '0';
--        address_C_OUT           : out STD_LOGIC:= '0';
--        ALE_OUT                 : out STD_LOGIC;
--        Start                   : out STD_LOGIC;
--        adc_clock               : out STD_LOGIC:= '0';
--        adc_data1_OUT           : out STD_LOGIC_VECTOR(7 downto 0);
--        adc_data2_OUT           : out STD_LOGIC_VECTOR(7 downto 0));
--end component;

--component screen_text is
--Port ( clk 		: in STD_LOGIC;
--		 pixel_x	: in STD_LOGIC_VECTOR(9 downto 0);
--		 pixel_y	: in STD_LOGIC_VECTOR(8 downto 0);
--		 ASCII  	: in STD_LOGIC_VECTOR(7 downto 0);
--		 text_rgb	: out STD_LOGIC_VECTOR(7 downto 0);
--		 text_on		: out STD_LOGIC_VECTOR(1 downto 0));
--end component;

signal colors: std_logic_vector(7 downto 0);
signal xaddrs: std_logic_vector(9 downto 0);
signal yaddrs: std_logic_vector(8 downto 0);
signal mode: std_logic;
signal raminit: integer range 0 to 14:=0;
signal slowclk: std_logic;
signal sccnt: integer range 0 to 9;
signal trash1: STD_LOGIC_VECTOR (18 downto 0);
signal trash2: STD_LOGIC_VECTOR (7 downto 0);
signal trash3: STD_LOGIC;
signal trash4: STD_LOGIC;
signal por:std_logic:='1';
signal xinit: unsigned(9 downto 0):="0000000000";
signal yinit: unsigned(8 downto 0):="000000000";
signal vsyncs: std_logic;
signal xptr, xpos, xlatch: unsigned(9 downto 0):="0100000000";
signal yptr, ypos, ylatch: unsigned(8 downto 0):="010000000";
signal width: unsigned(7 downto 0);
signal x8bit, y8bit : std_logic_vector(7 downto 0);
signal btndeb: std_logic;
signal ASCII: STD_LOGIC_VECTOR(7 downto 0);
signal rx_data: STD_LOGIC_VECTOR (7 downto 0);
signal text_rgb: STD_LOGIC_VECTOR(7 downto 0);
signal text_on: std_logic_vector(1 downto 0);
signal rgb_reg, rgb_next: std_logic_vector(7 downto 0);
signal rddata: STD_LOGIC_VECTOR(7 downto 0);
--signal trash5: STD_LOGIC;
--signal trash6: STD_LOGIC;
signal buttonsPushed : std_logic_vector(7 downto 0);
signal posXs : std_logic_vector(9 downto 0);
signal posYs : std_logic_vector(8 downto 0);
signal writemode, writepre : std_logic:='1';
signal buttonfilt : std_logic_vector(3 downto 0);
signal ramoffset : std_logic_vector(7 downto 0);
signal btnpre :  std_logic_vector(7 downto 0);
signal erase : std_logic;
--signal resetD, read, busy, err	: std_logic;
--signal letters : std_logic_vector(7 downto 0);
signal latch, pulse : std_logic:='0';
signal NEScounter : integer range 0 to 1666667:=0;


begin

VGA_ADAPTER: vga_gen
    Port map(CCLK => CCLK, -- : in STD_LOGIC;
           hsync => hsync, -- : out STD_LOGIC;
           vsync => vsyncs, -- : out STD_LOGIC;
           colorout => color, -- : out STD_LOGIC_VECTOR (7 downto 0);
           colorin => colors, --: in STD_LOGIC_VECTOR (7 downto 0);
           xaddr => xaddrs, -- : out STD_LOGIC_VECTOR (9 downto 0);
           yaddr => yaddrs, --: out STD_LOGIC_VECTOR (8 downto 0)
           posX => posXs,
           posY => posYs,
           cursorx => std_logic_vector(xpos),
           cursory => std_logic_vector(ypos),
           writemode => writemode
           );           

RAM: ramcontroller
    Port map( wraddr => trash1, -- : in STD_LOGIC_VECTOR (18 downto 0);
           wrdata => trash2, -- : in STD_LOGIC_VECTOR (7 downto 0);
--           wrcmd => trash3, -- : in STD_LOGIC;
           xaddr => xaddrs,
           yaddr => yaddrs,
--           rdaddr => xaddrs & yaddrs, -- : in STD_LOGIC_VECTOR (18 downto 0);
           rddata => colors, --rddata, -- : out STD_LOGIC;
           crdata => crdata, -- : inout STD_LOGIC_VECTOR (15 downto 0);
           craddr => craddr, -- : in STD_LOGIC_VECTOR (25 downto 0);
--           rw => trash4, -- : in STD_LOGIC;
--           read => trash5, --: out std_logic; -- past tense
--           written => trash6, -- : out std_logic;
           ce => ce, -- : out STD_LOGIC;
           oe => oe, -- : out STD_LOGIC;
           adv => adv,
           cre => cre,
           we => we, -- : out STD_LOGIC;
           clk => CCLK, -- : in std_logic
           crwait => crwait,
           crclk => crclk,
			  wrcmd => trash3,
			  stahp => trash4,
			  ub => ub,
			  lb => lb,
		  offset => ramoffset
           );

Controller:nes_fsm
       port map(
      clk => CCLK,
      latch => latch,
      pulse => pulse,
      data => NESdata,   
      button => buttonsPushed
      );
      
Position:marioPosition
        port map(
       clk => CCLK,
       vsync => vsyncs,
       button => buttonsPushed, --btn
       color => colors,
       vgaX => xaddrs,
       vgaY => yaddrs,
       posX => posXs,
       posY => posYs,
       writemode => writemode
       );    
          
--Inst_ps2interface: ps2interface
--        port map(ps2_clk => PS2KeyboardClk,
--       ps2_data => PS2KeyboardData,
   
--       clk => CCLK,
--       rst => resetD,
   
--       tx_data => x"00",
--       write => '0',
      
--       rx_data => letters,
--       read => read,
--       busy => busy,
--       err => err
--       );         
           	  
--Inst_SerialController: SerialController
--        port map(iClk          => iClk, 
--       clkEn         => Read,
--       clkEnRun      => run1,        
--       iScan         => TestLetter,
--       iReset        => RingCounterreset, 
--       RX            => RsRx
--       );
           	  
--ADC_CONTROLLER:TopLevel
--               Port map ( 
--                   adc_digital => adc_digital,--            : in STD_LOGIC_VECTOR (7 downto 0);
--                   SystemClock_IN  => CCLK,--        : in STD_LOGIC;
--           		   EOC_IN => EOC_IN,--			        : in STD_LOGIC;
--                   address_A_OUT => address_A_OUT,  --         : out STD_LOGIC;
--                   address_B_OUT => address_B_OUT,  --         : out STD_LOGIC:= '0';
--                   address_C_OUT => address_C_OUT,  --         : out STD_LOGIC:= '0';
--                   ALE_OUT => ALE_OUT, --                : out STD_LOGIC;
--                   Start => Start, --                 : out STD_LOGIC;
--                   adc_clock => adc_clock, --             : out STD_LOGIC:= '0';
--                   adc_data1_OUT => x8bit, --         : out STD_LOGIC_VECTOR(7 downto 0);
--                   adc_data2_OUT => y8bit --ata1_OUT --         : out STD_LOGIC_VECTOR(7 downto 0)
--                   );
----width <= x"7";

----------------------------------------------------------------------------------
---- Text Display

--TEXT_A: screen_text
--	Port map( clk 			=> CCLK,
--				 pixel_x 	=> xaddrs,
--				 pixel_y 	=> yaddrs,
--				 ASCII		=> ASCII,
--				 text_rgb	=> text_rgb,
--				 text_on    => text_on
--				 );

----------------------------------------------------------------------------------
---- rgb multiplexing circuit

--process(text_on,text_rgb,rddata)
--begin
--   if (text_on(1)='1') then
--    	colors <= text_rgb;
--	elsif(text_on(0)='1') then
--		colors <= text_rgb;
--	else
--		colors <= rddata;
--   end if;
--end process;

------------------------------------------------------------------------------------ 
vsync <= vsyncs;


process(CCLK, por, vsyncs, btn, buttonsPushed) --power on reset
begin
    if rising_edge(CCLK) then
    btnpre <= buttonsPushed;
--    btnpre <= btn;
        
--    if btnpre(3) = '0' and btn(3) = '1' and btn(1) = '1' then
--        erase <= '1';
--    end if;
--    if btnpre(1) = '0' and btn(3) = '1' and btn(1) = '1' then
--        erase <= '0';
--    end if;                
    
    if writemode = '0' then
        ramoffset <= switches;
    elsif writemode = '1' then
        if buttonsPushed(6) = '1' then
            erase <= '1';
        else
            erase <= '0';
        end if;
    end if;
    
    if btnpre(5) = '0' and buttonsPushed(5) = '1' and writemode = '0' then
        writemode <= '1';
    end if;
    if btnpre(5) = '0' and buttonsPushed(5) = '1' and writemode = '1' then
        writemode <= '0';
    end if;
    if buttonsPushed(4) = '1' and writemode = '1' then
        por <= '1';
    end if;

    if por = '1' then
		if trash4 = '0' then
			trash1 <= std_logic_vector(yinit) & std_logic_vector(xinit); --std_logic_vector(yinit) & std_logic_vector(xinit);
		      trash2 <= "11111111";
                if xinit = 639 then
                    xinit <= "0000000000";
                    if yinit = 480 then
                        por <= '0';
                        yinit <= "000000000";
                    else
                        yinit <= yinit + 1;
                    end if;
                else
                    xinit <= xinit + 1;
                end if;
			trash3 <= '1';
            else
			    trash3 <= '0';
            end if;
		
            ylatch <= ypos;
            yptr <= ypos;
            xlatch <= xpos;
            xptr <= xpos;
            width <= x"00";
            
        else
            if trash4= '0' then
                trash1 <= std_logic_vector(yptr) & std_logic_vector(xptr);
                trash3 <= buttonsPushed(7) and writemode;
                if xptr = xlatch + width then
                    if yptr = ylatch + width then
                        ylatch <= ypos;
                        yptr <= ypos;
                        xlatch <= xpos;
                        xptr <= xpos;
                        if erase = '1' then
                            width <= x"0f";
                            trash2 <= x"ff";
                        else
                            trash2 <= switches;
                            width <= x"00";
                        end if;
                    else
                        xptr <= xlatch;
                        yptr <= yptr + 1;
                    end if;
                else
                    xptr <= xptr + 1;
                end if;
            else
                trash3 <= '0';
            end if;
        end if;
    end if;
	if rising_edge(vsyncs) and writemode = '1' then
		if buttonsPushed(3) = '1' then
			ypos <= ypos - 1;
		end if;
		if buttonsPushed(0) = '1' then
			xpos <= xpos + 1;
		end if;
		if buttonsPushed(2) = '1' then
			ypos <= ypos + 1;
		end if;
		if buttonsPushed(1) = '1' then
			xpos <= xpos - 1;
		end if;
	end if;
end process;

process(CCLK)
begin
    if rising_edge(CCLK) then
        if NEScounter < 1666666 then
            if NEScounter >= 0 and NEScounter < 1200 then
                NESlatch <= '1';
                latch <= '1';
            elsif NEScounter >= 1200 and NEScounter < 1800 then
                NESlatch <= '0';
                latch <= '0';
            elsif NEScounter >= 1800 and NEScounter < 2400 then
                NESpulse <= '1';
                pulse <= '1';
            elsif NEScounter >= 2400 and NEScounter < 3000 then
                NESpulse <= '0';
                pulse <= '0';
            elsif NEScounter >= 3000 and NEScounter < 3600 then
                NESpulse <= '1';
                pulse <= '1';
            elsif NEScounter >= 3600 and NEScounter < 4200 then
                NESpulse <= '0';   
                pulse <= '0';                                     
            elsif NEScounter >= 4200 and NEScounter < 4800 then
                NESpulse <= '1';
                pulse <= '1';
            elsif NEScounter >= 4800 and NEScounter < 5400 then
                NESpulse <= '0';
                pulse <= '0';
            elsif NEScounter >= 5400 and NEScounter < 6000 then
                NESpulse <= '1';
                pulse <= '1';
            elsif NEScounter >= 6000 and NEScounter < 6600 then
                NESpulse <= '0';    
                pulse <= '0';                    
            elsif NEScounter >= 6600 and NEScounter < 7200 then
                NESpulse <= '1';
                pulse <= '1';
            elsif NEScounter >= 7200 and NEScounter < 7800 then
                NESpulse <= '0';    
                pulse <= '0';             
            elsif NEScounter >= 7800 and NEScounter < 8400 then
                NESpulse <= '1';
                pulse <= '1';
            elsif NEScounter >= 8400 and NEScounter < 9000 then
                NESpulse <= '0';      
                pulse <= '0';        
            elsif NEScounter >= 9000 and NEScounter < 9600 then
                NESpulse <= '1';
                pulse <= '1';
            elsif NEScounter >= 9600 and NEScounter < 10200 then
                NESpulse <= '0';      
                pulse <= '0';    
            elsif NEScounter >= 10200 and NEScounter < 10800 then
                NESpulse <= '1';
                pulse <= '1';
            elsif NEScounter >= 10800 and NEScounter < 11400 then
                NESpulse <= '0';      
                pulse <= '0'; 
            else
                NESlatch <= '0'; 
                NESpulse <= '0'; 
                latch <= '0'; 
                pulse <= '0'; 
            end if;
        else    
            NEScounter <= 0;
            NESlatch <= '0';
            NESpulse <= '0';
            latch <= '0';
            pulse <= '0';
        end if; 
        NEScounter <= NEScounter + 1;
        led <= buttonsPushed(7 downto 0);
    end if;
end process;

end Behavioral;
