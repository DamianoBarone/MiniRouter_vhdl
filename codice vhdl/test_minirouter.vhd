-------------------------------------------------------------------------------
--
-- Title       : test_minirouter
-- Design      : miniRouter
-- Author      : 
-- Company     : 
--
-------------------------------------------------------------------------------
--
-- File        : c:\My_Designs\miniRouter\miniRouter\src\test_minirouter.vhd
-- Generated   : Thu Dec 11 23:03:00 2014
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
--{entity {test_minirouter} architecture {test_minirouter}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use STD.textio.all;	
use IEEE.numeric_std.all;
USE ieee.std_logic_arith.ALL; 
use ieee.std_logic_unsigned.all;
entity test_minirouter is
end test_minirouter; 
architecture test_minirouter of test_minirouter is	 

   COMPONENT progetto_Mini_Router

   generic (N : INTEGER:=10);

   port(clk        : in  std_logic;
		reset      : in  std_logic;	  
		-------INPUT LINK 1-------
		data1        : in  std_logic_VECTOR (N-1 downto 0);	 
		req1         : in  std_logic;
		grant1       : out  std_logic :='0'; 	
		-------INPUT LINK 2-------
		data2        : in  std_logic_vector(N-1 downto 0);
		req2         : in  std_logic;
		grant2       : out  std_logic :='0'; 
		-------OUTPUT-------
		valid     	 : out  std_logic :='0'; 
		data_out	 : out std_logic_vector(N-3 downto 0)); 

   END COMPONENT;
   ----------------------------------------------------------------------------
	CONSTANT N       :  INTEGER  := 10;       -- Bus Width
	CONSTANT MckPer  :  TIME     := 200 ns;  -- Master Clk period
	CONSTANT TestLen :  INTEGER  := 50;      -- No. of Count (MckPer/2) for test
	
	SIGNAL clk  : std_logic := '0';
	SIGNAL reset: std_logic := '0';
	SIGNAL req1 :std_logic_vector(0 downto 0);		
	SIGNAL req2 :std_logic_vector(0 downto 0);							 				 
	SIGNAL data1:std_logic_vector(N-1 downto 0);	
	SIGNAL data2:std_logic_vector(N-1 downto 0);
	
	-----signal output-----
	SIGNAL grant1 :std_logic;
	SIGNAL grant2 : std_logic;
	SIGNAL valid :std_logic;
	SIGNAL data_out: std_logic_vector(N-3 downto 0);  
	SIGNAL clk_cycle : INTEGER;
    SIGNAL Testing: Boolean := True;

	BEGIN

   I : Progetto_Mini_Router GENERIC MAP(N=>10)																					  
             PORT MAP(clk,reset,data1,req1(0),grant1,data2,req2(0),grant2,valid,data_out);
 	-- Generates clk											
	clk     <= NOT clk AFTER MckPer/2 WHEN Testing ELSE '0'; 
	Test_Proc: process(clk)  
	variable temp : integer;  

	variable buf_in,buf_out: LINE;		--buffers used to read and write on file
 	VARIABLE count: INTEGER:= 0;   
	file test_vectors1 : text open read_mode is "C:/My_Designs/miniRouter/read1.txt";  --oper read1.txt
	file test_vectors2 : text open read_mode is "C:/My_Designs/miniRouter/read2.txt";  --oper read2.txt
	file file_pointer : text open write_mode is "C:/My_Designs/miniRouter/write.txt";  --create write.txt
	begin				
	IF (clk'EVENT AND clk='1') THEN 	  
    	clk_cycle <= (count+1)/2;
		case count is
			when 0 => reset <= '1';	 
			when 1 => reset <= '0';
			when (TestLen -1) => Testing <= FALSE;
			when others => 	 
			if ((not(endfile(test_vectors1)))and  (not (endfile(test_vectors2)))) then	 
			--link1
			readline(test_vectors1, buf_in);				--read line of read1.text
			read(buf_in, temp);								--read req1
			req1 <=std_logic_vector(to_signed(temp,1));    
			read(buf_in, temp);								--read data1
			data1<=std_logic_vector(to_signed(temp,10));   	
			--link2
			readline(test_vectors2, buf_in);				--read line of read2.text
			read(buf_in, temp);								--read req2
			req2 <=std_logic_vector(to_signed(temp,1));    	   
			read(buf_in, temp);								--read data2
			data2<=std_logic_vector(to_signed(temp,10));
			write(buf_out,"valid: ");						--write valid
		 	write(buf_out,conv_integer(valid));	
		 	write(buf_out," data_out: ");	 
	   	  	write(buf_out,conv_integer(data_out));			--write data_out
			write(buf_out," grant1: ");  
			write(buf_out,conv_integer(grant1));			--write grant1
		 	write(buf_out," grant2: ");
		    write(buf_out,conv_integer(grant2)); 			--write grant2
		    writeline(file_pointer,buf_out) ;	   
		  end if;
		end case;
		count:= count + 1;		
	end if;
	end PROCESS Test_Proc;
end test_minirouter;