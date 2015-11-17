-------------------------------------------------------------------------------
--
-- Title       : progetto_Mini_Router
-- Design      : miniRouter
-- Author      : 
-- Company     : 
--
-------------------------------------------------------------------------------
--
-- File        : c:\My_Designs\miniRouter\miniRouter\src\progetto_Mini_Router.vhd
-- Generated   : Fri Dec 12 17:04:57 2014
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {progetto_Mini_Router} architecture {progetto_Mini_Router}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity progetto_Mini_Router is 
		
generic (N : INTEGER:=10);
port(  	  
		clk        : in  std_logic;
		reset      : in  std_logic;	  		 
		------- LINK 1-------
		data1        : in  std_logic_VECTOR (N-1 downto 0);	 
		req1         : in  std_logic;						 --request1
		grant1       : out  std_logic :='0'; 				 
		------- LINK 2-------
		data2        : in  std_logic_vector(N-1 downto 0);
		req2         : in  std_logic;						 --request2
		grant2       : out  std_logic :='0'; 
		-------OUTPUT a valle-------
		valid     	 : out  std_logic :='0'; 
		data_out	 : out std_logic_vector(N-3 downto 0)); --not have bit of priority
	
end progetto_Mini_Router;

architecture progetto_Mini_Router of progetto_Mini_Router is

 SIGNAL   	g1   : std_logic:='0';					 --return grant1 to input 
 SIGNAL   	g2  : std_logic:='0';					 --return grant2 to input
 SIGNAL  	confronto : std_logic_vector(1 downto 0);--output of combinational network confronto
 SIGNAL 	R1_valid : std_logic:='0';	 			 --output of AND between r1 and grant1
 SIGNAL 	R2_valid : std_logic:='0';				 --output of AND between r2 and grant2
 SIGNAL		Multiplexer1_2:	std_logic; 				 --second input of variable control of multiplexer2
 SIGNAL		Multiplexer2_3:	std_logic; 				 --input of variable control of multiplexer3
 SIGNAL 	RoundRobin : std_logic:='0'; 
 SIGNAL 	M1 : std_logic_vector(1 downto 0);  	 --output multiplexer1
 SIGNAL 	M2 : std_logic_vector(1 downto 0); 	   	 --output multiplexer2
 SIGNAL 	M3 : std_logic_vector(1 downto 0); 		 --output multiplexer3
 BEGIN
 grant1<=g1;	  									 --connect g1 to grant1
 grant2<=g2;										 --connect g2 to grant2
 confronto <=	"00" when data1(9 downto 8) > data2(9 downto 8) else	-- check priority 
				"01" when data1(9 downto 8) = data2(9 downto 8) else
	 			"11" ;
 R1_valid <=	(NOT g1) AND req1; 					--the request1 is valid when req1=1 e grant1=0
 R2_valid <= (NOT g2) AND req2; 					--the request2 is valid when req2=1 e grant2=0
 Multiplexer2_3 <= R1_valid AND R2_valid;			-- control variable of a multiplexer3
 Multiplexer1_2 <= Multiplexer2_3 and (confronto(0) XOR confronto(1)); 	 -- control variable of a multiplexer2
 M1 <=	"01" WHEN RoundRobin='0' else "10"	;	   					--output multiplexer1
 M2 <=	"01" WHEN (Multiplexer1_2 & confronto)= "000" ELSE    		--output multiplexer2
		"10" WHEN(Multiplexer1_2 & confronto)="011" ELSE M1;    			
 M3 <=	M2   WHEN Multiplexer2_3 ='1' else  R2_valid & R1_valid;    --output multiplexer3  	
	start:PROCESS(clk)	 
	BEGIN 
	 IF (clk'EVENT AND clk='1') THEN
        IF (reset='1') then			    --RESET
			g1 <= '0';
			g2<='0';  
			valid<='0';	 
			data_out<="00000000";		
		ELSE   
			CASE M3 IS
				WHEN "00" =>		 				     --case not have new input, all outputs 0
					g1 <= '0';
					g2<='0';  
					valid<='0';
				WHEN "01" =>							--case data1 is connect to output
					data_out <= data1(7 downto 0);		--connect data_out with data1
					g1<= '1';							--update grant1
					g2<='0'; 							--in case the previous clock was served link2
					valid<='1';	   						--data_out is valid
				WHEN "10"	=>							-- case data2 is connect to output
					data_out <= data2(7 downto 0);   	--connect data_out with data2
					g1 <= '0';							--in case the previous clock was served link1
					g2<='1'; 							--update grant1
					valid<='1';	 					    --data_out is valid
				WHEN others => null; 
			END CASE; 
			if(((CONFRONTO(0) XOR CONFRONTO(1))= '1')AND R1_valid='1' AND R2_valid='1')	 then	--update control variable of round robin 
					roundrobin <= not roundrobin;												--when have two request with equal priority												   
			END IF;
		END IF;
	END IF;	 
	end process start;
end progetto_Mini_Router;			 