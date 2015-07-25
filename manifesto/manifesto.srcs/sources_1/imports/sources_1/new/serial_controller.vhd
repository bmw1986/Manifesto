LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

ENTITY serial_controller IS
    Port ( iClk:       IN std_logic;
           clkEn:      IN std_logic;
           ClkEnRun:   out std_logic;
           iScan:      IN std_logic_vector(7 DOWNTO 0);
           iReset:     IN std_logic;
           RX:         OUT std_logic);         
END serial_controller;

ARCHITECTURE Behavioral of serial_controller IS
    SIGNAL DIV:             unsigned (15 DOWNTO 0) := X"0000"; 
    SIGNAL LUT_ADDRESS, Count:     integer range 0 to 5 := 0;
    SIGNAL state, NewData:   integer range 0 to 11 :=  0;
    SIGNAL LUT_DATA:        std_logic_vector (7  DOWNTO 0);
    SIGNAL Scan, LScan:     std_logic_vector (7 DOWNTO 0):=x"00";
    SIGNAL BAUD:            std_logic:= '0';
    SIGNAL newDatasig:      std_logic:= '1';
    signal q1, q2, q3, break, edge: std_logic;
    signal resetNewDataSig: std_logic:= '0';
    signal Enable, En, EnS: std_logic:= '0';
    signal Ledge, Ledge2:  std_logic:='0';
    
  
        
--    function asciiTable( bitChar: std_logic_vector(3 downto 0)) return std_logic_vector is
--    begin
--    	case bitChar is    	
--    		when x"0" =>
--    			return x"30";
--    		when x"1" => 
--    			return x"31";
--    		when x"2" =>
--    			return x"32";
--    		when x"3" => 
--    			return x"33";
--    		when x"4" =>
--    			return x"34";
--    		when x"5" => 
--    			return x"35";
--    		when x"6" =>
--    			return x"36";
--    		when x"7" => 
--    			return x"37";
--    		when x"8" =>
--    			return x"38";
--    		when x"9" => 
--    			return x"39";
--    		when x"A" =>
--    			return x"41";
--    		when x"B" => 
--    			return x"42";
--    		when x"C" =>
--    			return x"43";
--    		when x"D" => 
--    			return x"44";
--    		when x"E" =>
--    			return x"45";
--    		when x"F" => 
--    			return x"46";
--    		when others =>
--    			return x"3F";
--    		end case;
--    end asciiTable;	
function KeyboardToASCII(QWERTY : std_logic_vector(7 downto 0)) return std_logic_vector is
begin
case QWERTY is
	when x"15" => return  x"51"; --Q
	when x"1D" => return  x"57"; --W
	when x"24" => return  x"45"; --E
	when x"2D" => return  x"52"; --R
	when x"2C" => return  x"54"; --T
	when x"35" => return  x"59"; --Y
	when x"3C" => return  x"55"; --U
	when x"43" => return  x"49"; --I
	when x"44" => return  x"4F"; --O
	when x"4D" => return  x"50"; --P
	when x"1C" => return  x"41"; --A
	when x"1B" => return  x"53"; --S
	when x"23" => return  x"44"; --D
	when x"2B" => return  x"46"; --F
	when x"34" => return  x"47"; --G
	when x"33" => return  x"48"; --H
	when x"3B" => return  x"4A"; --J
	when x"42" => return  x"4B"; --K
	when x"4B" => return  x"4C"; --L
	when x"1A" => return  x"5A"; --Z
	when x"22" => return  x"58"; --X
	when x"21" => return  x"43"; --C
	when x"2A" => return  x"56"; --V
	when x"32" => return  x"42"; --B
	when x"31" => return  x"4E"; --N
	when x"3A" => return  x"4D"; --M
	when x"16" => return  x"31"; --1
    when x"1E" => return  x"32"; --2
    when x"26" => return  x"33"; --3
    when x"25" => return  x"34"; --4
    when x"2E" => return  x"35"; --5
    when x"36" => return  x"36"; --6
    when x"3D" => return  x"37"; --7
    when x"3E" => return  x"38"; --8
    when x"46" => return  x"39"; --9
	when others => return X"1B";
end case;
end KeyboardToASCII;
    
    
BEGIN
clkEnRun <= '1';
P0: PROCESS(BAUD, State, LUT_DATA)
    BEGIN
            IF rising_edge(BAUD) and (state = 9 or state = 10) THEN
                Scan <= LScan;
            END IF;     
      END PROCESS;
      
P1: PROCESS (iClk)
    BEGIN
         IF rising_edge(iClk) THEN
            IF DIV > 100000000/9600/2 - 1 THEN
                DIV <= X"0000";
                BAUD <= NOT BAUD;
            ELSE
                DIV <= DIV + 1;
            END IF;
         END IF;
      END PROCESS;
      
P2: PROCESS(LUT_ADDRESS)
    BEGIN    
        CASE LUT_ADDRESS IS
        WHEN 0      =>  LUT_DATA <= KeyboardToASCII(LScan);
--        WHEN 1      =>  LUT_DATA <= asciiTable(iData(11  DOWNTO  8)); -- x"0"
--        WHEN 2      =>  LUT_DATA <= asciiTable(iData(7  DOWNTO  4));
--        WHEN 3      =>  LUT_DATA <= asciiTable(iData(3  DOWNTO  0));
        WHEN 1      =>  LUT_DATA <= x"0D";
        WHEN 2      =>  LUT_DATA <= x"0A";
        WHEN others =>  LUT_DATA <= x"FF";
       END CASE;
     END PROCESS;
 
P3: PROCESS(BAUD, iReset)
    BEGIN
            IF iReset = '1' THEN
            LUT_ADDRESS <= 0;
            state <= 0;
            RX <= '1';
            ELSIF RISING_EDGE(BAUD) THEN
                CASE(state) IS
                    WHEN 0      =>  state <= 1; RX <= '0'; 
                    WHEN 1      =>  state <= 2; RX <= LUT_DATA(0);
                    WHEN 2      =>  state <= 3; RX <= LUT_DATA(1);
                    WHEN 3      =>  state <= 4; RX <= LUT_DATA(2);
                    WHEN 4      =>  state <= 5; RX <= LUT_DATA(3);
                    WHEN 5      =>  state <= 6; RX <= LUT_DATA(4);
                    WHEN 6      =>  state <= 7; RX <= LUT_DATA(5);
                    WHEN 7      =>  state <= 8; RX <= LUT_DATA(6);
                    WHEN 8      =>  state <= 9; RX <= LUT_DATA(7);
                    WHEN 9      =>  state <= 10; RX <= '1'; --resetNewDataSig <= '1';
--                IF LUT_ADDRESS < 3 THEN
--                    LUT_ADDRESS <= LUT_ADDRESS + 1;
--                ELSE
                    LUT_ADDRESS <= 0; 
--                END IF;
                    WHEN 10     =>  state <= NewData;
                    WHEN others =>  state <= NewData;
            END CASE;
         END IF;
       END PROCESS; 

Process(clkEn, Baud) begin
    if clkEn = '1' then
        En <= '1';
    elsif Falling_Edge(Baud) then
        If En = '1' then
            Enable <= '1';
            En <= '0';
        else
            Enable <= '0';
        end if;
    end if;
end process;

Process(Scan, iScan, Baud)
begin  
    if rising_edge(Baud) then      
    if state = 10 and Ledge2 = '1' then
        newData <= 0;
    elsif Scan = LScan then
        newData <= 10;
    else
        newData <= 0;
    end if; end if; 
end process; 

process(iClk) begin
    if Rising_edge(iClk) then
        if iScan = X"F0" then
            LScan <= LScan;
            if state = 10 then
            Break <= '1'; end if;
        else
            LScan <= iScan;
            Break <= '0';
        end if;
        q1 <= Break;
        edge <= q1 and not Break;
    end if; 
end process; 
process(iClk) begin
    if falling_edge(iClk) then
        if state = 10 then
        if edge = '1' then 
            Count <= count + 1;
        end if;
        elsif State /= 10 then Count <= 0;
        end if;
    end if;
end process;
process(Count, Baud, Edge, iClk) begin
    if Count > 1 and edge = '1' then Ledge <= '1';
    elsif falling_edge(Baud) then
        Ledge2 <= Ledge;
        Ledge <= '0';
    end if;
end process;
END Behavioral;