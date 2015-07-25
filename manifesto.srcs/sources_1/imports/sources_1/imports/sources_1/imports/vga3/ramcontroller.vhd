library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ramcontroller is
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
end ramcontroller;

architecture Behavioral of ramcontroller is

COMPONENT linebuffer
  PORT (
	clka : IN STD_LOGIC;
	wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	addra : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
	dina : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	clkb : IN STD_LOGIC;
	addrb : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
	doutb : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END COMPONENT;

COMPONENT writequeue
  PORT (
    clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(35 DOWNTO 0);
    clkb : IN STD_LOGIC;
    addrb : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(35 DOWNTO 0)
  );
END COMPONENT;

signal mode: integer range 0 to 2;
signal writestate: integer range 0 to 8;
signal init: integer range 0 to 10003:=0;
signal rw: std_logic:='0';
signal lineptr: unsigned(8 downto 0):="000000000";
signal linebufen: std_logic_vector (0 downto 0);
signal twopixel: std_logic_vector (15 downto 0);
signal lineaddr: std_logic_vector(8 downto 0);
signal wea: std_logic_vector(0 downto 0);
signal waitdelay,writedone: std_logic;
signal slowclock: std_logic:='1';
signal inptr: unsigned (9 downto 0):="0000000001";
signal outptr: unsigned (9 downto 0);
signal wrbaddr: std_logic_vector (17 downto 0);
signal wrbdata: std_logic_vector (15 downto 0);
signal writecache,queue, prequeue: std_logic_vector(35 downto 0);
signal qwea: std_logic_vector(0 downto 0);
signal writewaiting, readhold: std_logic;
signal prevaddr: unsigned(17 downto 0);

begin

ROW: linebuffer
  PORT MAP (
	clka => slowclock,
	wea => wea,
	addra => std_logic_vector(lineptr),
	dina => crdata,--not (xaddr (7 downto 0) & xaddr (7 downto 0)),--crdata,
	clkb => clk,
	addrb => xaddr(9 downto 1),
	doutb => twopixel
  );
  
INPUT_BUFFER : writequeue
  PORT MAP (
    clka => clk,
    wea => qwea,
    addra => std_logic_vector(inptr),
    dina => queue,--wrdata & wraddr,
    clkb => slowclock,
    addrb => std_logic_vector(outptr),
    doutb => writecache
  );
wea(0) <= rw and crwait;

process (twopixel, xaddr)
begin
rddata <= xaddr(7 downto 0) xor yaddr(7 downto 0);
if xaddr(0) = '1' then
	rddata <= twopixel(15 downto 8);
else
	rddata <= twopixel(7 downto 0);
end if;
end process;

process(clk)
begin
if rising_edge(clk) then
	slowclock <= not slowclock;
	if init = 8 then
	   crclk <= not slowclock;
   end if;
    qwea(0) <= wrcmd;
	if wrcmd = '1' then
        	  
        	          	  queue(17 downto 0) <= wraddr(18 downto 1);
              if wraddr(0) = '1' then
                  queue(33 downto 26) <= wrdata;
                  queue(35) <= '0';
                  if queue(17 downto 0) /= wraddr(18 downto 1) then
                      queue(34) <= '1';
                  end if;
              else
                  queue(25 downto 18) <= wrdata;
                  queue(34) <= '0';
                  if queue(17 downto 0) /= wraddr(18 downto 1) then
                      queue(35) <= '1';
                  end if;    
              end if;
        	  
		if queue(17 downto 0) /= wraddr(18 downto 1) or inptr = outptr then
		  inptr <= inptr+1;
        end if;
	end if;
	if rw = '0' then
		if xaddr = "1001111111" and readhold /= yaddr(0) and writedone = '0' then
                        readhold <= yaddr(0);
    					writedone <= '1';
    				end if;
        else
            writedone <= '0';
        end if;
end if;
end process;

process(inptr)
begin
if inptr+3 = outptr or inptr+2 = outptr or inptr+1 = outptr  then
	stahp <= '1';
else
	stahp <= '0';
end if;
end process;

process(slowclock)
begin
if rising_edge(slowclock) then
    waitdelay <= crwait;
	case init is
		when 0 =>
			craddr(22 downto 0) <= "000" & "10" & "00" & '0' & '1' & "011" & '0' & '0' & '0' & '0' & '0' & "01" & '1' & "111";
			cre <= '1';
			ce <= '0';
			init <= 1;
		when 1 =>
				adv <= '0';
				init <= 2;
		when 2 =>
				ce <= '0';
				init <= 3;
		when 4 =>
				we <= '0';
				init <= 5;
		when 6 =>
				adv <= '1';
				we <= '1';
				cre <= '0';
				ce <= '1';
				init <= 7;
			   craddr(25 downto 18) <= "00000000";
           when 7 =>
           init <= 8;
			    rw <= '1'; 
		when 8 =>
			if rw = '1' then -- read mode
				case mode is
					when 0 =>
						craddr(17 downto 0) <= yaddr & "000000000";
							lb <= '0';
							ub <= '0';
						crdata <= "ZZZZZZZZZZZZZZZZ";
						ce <= '0';
						adv <= '0';
						mode <= 1;
					when 1 =>
						adv <= '1';
						oe <= '0';
						mode <= 2;
					when 2 =>
						if crwait = '1' then --crwait
							if lineptr = "100111111" then
								lineptr <= "000000000";
								mode <= 0;
								rw <= '0';
								adv <= '0';
								oe <= '1';
								ce <= '1';
								we <= '0';
								--writedone <= '0';
							else
								lineptr <= lineptr + 1;
							end if;
						end if;
					when others =>
				end case;
			else -- write mode
			     case writestate is
			         when 0 =>
                         if writedone = '1' then
                             rw <= '1';
                             we <= '1';
                         elsif inptr /=outptr then
                             ce <= '0';
                             adv <= '0';
                             writestate <= 1;
                             craddr(17 downto 0) <= writecache(17 downto 0);
                             crdata(15 downto 0) <= writecache(33 downto 18);
                             outptr <= outptr + 1;
                             prevaddr <= unsigned(writecache(17 downto 0));
                             							ub <= writecache(35);
                             							lb <= writecache(34);
                         end if;
                     when 1 =>
                        adv <= '1';
                        if crwait = '1' then
                            if unsigned(writecache(17 downto 0)) /=  prevaddr + 1 or writedone = '1' or inptr = outptr or writecache(6 downto 0) = "0000000" then
                                ce <= '1';
                                writestate <= 0;
                                if writedone = '1' then
                                                                writestate <= 0;
                                    rw <= '1';
                                    we <= '1';
                                end if;
                            else
                                prevaddr <= unsigned(writecache(17 downto 0));
                                crdata(15 downto 0) <= writecache(33 downto 18);
                                							ub <= writecache(35);
                                							lb <= writecache(34);
                                outptr <= outptr + 1;
                            end if;
                        end if;
			         when others =>
                 end case;
			end if;
		when others =>
			init <= init+1;
	end case;
end if;

if init = 8 then
    craddr(25 downto 18) <= offset;
end if;
end process;

end Behavioral;
