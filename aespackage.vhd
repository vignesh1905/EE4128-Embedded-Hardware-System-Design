----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/27/2016 02:18:48 AM
-- Design Name: 
-- Module Name: aespackage - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

package aespackage is

 
 	FUNCTION Keyexpand( RoundKey : std_logic_vector(0 to 127); round: natural range 0 to 11) RETURN std_logic_vector;
--	FUNCTION SBoxInvGet (data8: std_logic_vector(0 to 7)) RETURN std_logic_vector;
--	FUNCTION SBoxGet (data8:std_logic_vector(0 to 7)) RETURN std_logic_vector;
	FUNCTION subbytes ( input: std_logic_vector(0 to 127) ) RETURN std_logic_vector;
	FUNCTION shiftrows ( input: std_logic_vector(0 to 127) ) RETURN std_logic_vector; 
	FUNCTION mixcols ( input: std_logic_vector(0 to 127) ) RETURN std_logic_vector;
--	FUNCTION mult ( a: std_logic_vector(0 to 7); b: std_logic_vector(0 to 7) ) RETURN std_logic_vector;
	FUNCTION Addrk ( RoundKey: std_logic_vector(0 to 127); input: std_logic_vector(0 to 127) ) RETURN std_logic_vector;
	
end aespackage;

package body aespackage is

Function Keyexpand(RoundKey : std_logic_vector(0 to 127); round :natural range 0 to 11) Return std_logic_vector is 
             variable nextRound : std_logic_vector(0 to 127) := (others => '0');
type sbox1 is array (integer range 0 to 15, integer range 0 to 15) of std_logic_vector(7 downto 0);
    constant SBOX: sbox1 := ( ( x"63" , x"7c" , x"77" , x"7b" , x"f2" , x"6b" , x"6f" , x"c5" , x"30" , x"01" , x"67" , x"2b" , x"fe" , x"d7", x"ab" , x"76") ,
                                 ( x"ca" , x"82" , x"c9" , x"7d" , x"fa" , x"59" , x"47" , x"f0" , x"ad" , x"d4" , x"a2" , x"af" , x"9c" , x"a4", x"72" , x"c0") ,
                                 ( x"b7" , x"fd" , x"93" , x"26" , x"36" , x"3f" , x"f7" , x"cc" , x"34" , x"a5" , x"e5" , x"f1" , x"71" , x"d8", x"31" , x"15") ,
                                 ( x"04" , x"c7" , x"23" , x"c3" , x"18" , x"96" , x"05" , x"9a" , x"07" , x"12" , x"80" , x"e2" , x"eb" , x"27", x"b2" , x"75") ,
                                 ( x"09" , x"83" , x"2c" , x"1a" , x"1b" , x"6e" , x"5a" , x"a0" , x"52" , x"3b" , x"d6" , x"b3" , x"29" , x"e3", x"2f" , x"84") ,
                                 ( x"53" , x"d1" , x"00" , x"ed" , x"20" , x"fc" , x"b1" , x"5b" , x"6a" , x"cb" , x"be" , x"39" , x"4a" , x"4c", x"58" , x"cf") ,
                                 ( x"d0" , x"ef" , x"aa" , x"fb" , x"43" , x"4d" , x"33" , x"85" , x"45" , x"f9" , x"02" , x"7f" , x"50" , x"3c", x"9f" , x"a8") ,
                                 ( x"51" , x"a3" , x"40" , x"8f" , x"92" , x"9d" , x"38" , x"f5" , x"bc" , x"b6" , x"da" , x"21" , x"10" , x"ff", x"f3" , x"d2") ,
                                 ( x"cd" , x"0c" , x"13" , x"ec" , x"5f" , x"97" , x"44" , x"17" , x"c4" , x"a7" , x"7e" , x"3d" , x"64" , x"5d", x"19" , x"73") ,
                                 ( x"60" , x"81" , x"4f" , x"dc" , x"22" , x"2a" , x"90" , x"88" , x"46" , x"ee" , x"b8" , x"14" , x"de" , x"5e", x"0b" , x"db") ,
                                 ( x"e0" , x"32" , x"3a" , x"0a" , x"49" , x"06" , x"24" , x"5c" , x"c2" , x"d3" , x"ac" , x"62" , x"91" , x"95", x"e4" , x"79") ,
                                 ( x"e7" , x"c8" , x"37" , x"6d" , x"8d" , x"d5" , x"4e" , x"a9" , x"6c" , x"56" , x"f4" , x"ea" , x"65" , x"7a", x"ae" , x"08") ,
                                 ( x"ba" , x"78" , x"25" , x"2e" , x"1c" , x"a6" , x"b4" , x"c6" , x"e8" , x"dd" , x"74" , x"1f" , x"4b" , x"bd", x"8b" , x"8a") ,
                                 ( x"70" , x"3e" , x"b5" , x"66" , x"48" , x"03" , x"f6" , x"0e" , x"61" , x"35" , x"57" , x"b9" , x"86" , x"c1", x"1d" , x"9e") ,
                                 ( x"e1" , x"f8" , x"98" , x"11" , x"69" , x"d9" , x"8e" , x"94" , x"9b" , x"1e" , x"87" , x"e9" , x"ce" , x"55", x"28" , x"df") ,
                                 ( x"8c" , x"a1" , x"89" , x"0d" , x"bf" , x"e6" , x"42" , x"68" , x"41" , x"99" , x"2d" , x"0f" , x"b0" , x"54", x"bb" , x"16")); 
begin
                            
	    case round is
	       when 1 =>
	    
		-- ROTWORD
		nextRound(0 to 23) := RoundKey(104 to 127);
		nextRound(24 to 31) := RoundKey(96 to 103);
		
		-- SUBBYTE (SBOX)
		nextRound(0 to 7) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(0 to 3))),to_integer(unsigned(nextRound(4 to 7)))));
		nextRound(8 to 15) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(8 to 11))),to_integer(unsigned(nextRound(12 to 15)))));
		nextRound(16 to 23) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(16 to 19))),to_integer(unsigned(nextRound(20 to 23)))));
		nextRound(24 to 31) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(24 to 27))),to_integer(unsigned(nextRound(28 to 31)))));
		
		-- XOR
		nextRound(0 to 7) :=  nextRound(0 to 7) xor RoundKey(0 to 7) xor "00000001";
		nextRound(8 to 15) := nextRound(8 to 15) xor RoundKey(8 to 15);
		nextRound(16 to 23) := nextRound(16 to 23) xor RoundKey(16 to 23);
		nextRound(24 to 31) := nextRound(24 to 31) xor RoundKey(24 to 31);
		nextRound(32 to 63) := nextRound(0 to 31) xor RoundKey(32 to 63);
		nextRound(64 to 95) := nextRound(32 to 63) xor RoundKey(64 to 95);
		nextRound(96 to 127) := nextRound(64 to 95) xor RoundKey(96 to 127); 
		
		when 2 =>
                
        -- ROTWORD
        nextRound(0 to 23) := RoundKey(104 to 127);
        nextRound(24 to 31) := RoundKey(96 to 103);
                
        -- SUBBYTE (SBOX)
        nextRound(0 to 7) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(0 to 3))),to_integer(unsigned(nextRound(4 to 7)))));
        nextRound(8 to 15) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(8 to 11))),to_integer(unsigned(nextRound(12 to 15)))));
        nextRound(16 to 23) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(16 to 19))),to_integer(unsigned(nextRound(20 to 23)))));
        nextRound(24 to 31) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(24 to 27))),to_integer(unsigned(nextRound(28 to 31)))));
                
        -- XOR
        nextRound(0 to 7) :=  nextRound(0 to 7) xor RoundKey(0 to 7) xor "00000010";
        nextRound(8 to 15) := nextRound(8 to 15) xor RoundKey(8 to 15);
        nextRound(16 to 23) := nextRound(16 to 23) xor RoundKey(16 to 23);
        nextRound(24 to 31) := nextRound(24 to 31) xor RoundKey(24 to 31);
        nextRound(32 to 63) := nextRound(0 to 31) xor RoundKey(32 to 63);
        nextRound(64 to 95) := nextRound(32 to 63) xor RoundKey(64 to 95);
        nextRound(96 to 127) := nextRound(64 to 95) xor RoundKey(96 to 127); 
        
        when 3 =>
                
        -- ROTWORD
        nextRound(0 to 23) := RoundKey(104 to 127);
        nextRound(24 to 31) := RoundKey(96 to 103);
                
        -- SUBBYTE (SBOX)
        nextRound(0 to 7) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(0 to 3))),to_integer(unsigned(nextRound(4 to 7)))));
        nextRound(8 to 15) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(8 to 11))),to_integer(unsigned(nextRound(12 to 15)))));
        nextRound(16 to 23) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(16 to 19))),to_integer(unsigned(nextRound(20 to 23)))));
        nextRound(24 to 31) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(24 to 27))),to_integer(unsigned(nextRound(28 to 31)))));
                
        -- XOR
        nextRound(0 to 7) :=  nextRound(0 to 7) xor RoundKey(0 to 7) xor "00000100";
        nextRound(8 to 15) := nextRound(8 to 15) xor RoundKey(8 to 15);
        nextRound(16 to 23) := nextRound(16 to 23) xor RoundKey(16 to 23);
        nextRound(24 to 31) := nextRound(24 to 31) xor RoundKey(24 to 31);
        nextRound(32 to 63) := nextRound(0 to 31) xor RoundKey(32 to 63);
        nextRound(64 to 95) := nextRound(32 to 63) xor RoundKey(64 to 95);
        nextRound(96 to 127) := nextRound(64 to 95) xor RoundKey(96 to 127); 

        when 4 =>
	    
		-- ROTWORD
		nextRound(0 to 23) := RoundKey(104 to 127);
		nextRound(24 to 31) := RoundKey(96 to 103);
		
		-- SUBBYTE (SBOX)
		nextRound(0 to 7) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(0 to 3))),to_integer(unsigned(nextRound(4 to 7)))));
		nextRound(8 to 15) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(8 to 11))),to_integer(unsigned(nextRound(12 to 15)))));
		nextRound(16 to 23) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(16 to 19))),to_integer(unsigned(nextRound(20 to 23)))));
		nextRound(24 to 31) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(24 to 27))),to_integer(unsigned(nextRound(28 to 31)))));
		
		-- XOR
		nextRound(0 to 7) :=  nextRound(0 to 7) xor RoundKey(0 to 7) xor "00001000";
		nextRound(8 to 15) := nextRound(8 to 15) xor RoundKey(8 to 15);
		nextRound(16 to 23) := nextRound(16 to 23) xor RoundKey(16 to 23);
		nextRound(24 to 31) := nextRound(24 to 31) xor RoundKey(24 to 31);
		nextRound(32 to 63) := nextRound(0 to 31) xor RoundKey(32 to 63);
		nextRound(64 to 95) := nextRound(32 to 63) xor RoundKey(64 to 95);
		nextRound(96 to 127) := nextRound(64 to 95) xor RoundKey(96 to 127);
        
        when 5 =>
	    
		-- ROTWORD
		nextRound(0 to 23) := RoundKey(104 to 127);
		nextRound(24 to 31) := RoundKey(96 to 103);
		
		-- SUBBYTE (SBOX)
		nextRound(0 to 7) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(0 to 3))),to_integer(unsigned(nextRound(4 to 7)))));
		nextRound(8 to 15) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(8 to 11))),to_integer(unsigned(nextRound(12 to 15)))));
		nextRound(16 to 23) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(16 to 19))),to_integer(unsigned(nextRound(20 to 23)))));
		nextRound(24 to 31) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(24 to 27))),to_integer(unsigned(nextRound(28 to 31)))));
		
		-- XOR
		nextRound(0 to 7) :=  nextRound(0 to 7) xor RoundKey(0 to 7) xor "00010000";
		nextRound(8 to 15) := nextRound(8 to 15) xor RoundKey(8 to 15);
		nextRound(16 to 23) := nextRound(16 to 23) xor RoundKey(16 to 23);
		nextRound(24 to 31) := nextRound(24 to 31) xor RoundKey(24 to 31);
		nextRound(32 to 63) := nextRound(0 to 31) xor RoundKey(32 to 63);
		nextRound(64 to 95) := nextRound(32 to 63) xor RoundKey(64 to 95);
		nextRound(96 to 127) := nextRound(64 to 95) xor RoundKey(96 to 127);

        when 6 =>
	    
		-- ROTWORD
		nextRound(0 to 23) := RoundKey(104 to 127);
		nextRound(24 to 31) := RoundKey(96 to 103);
		
		-- SUBBYTE (SBOX)
		nextRound(0 to 7) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(0 to 3))),to_integer(unsigned(nextRound(4 to 7)))));
		nextRound(8 to 15) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(8 to 11))),to_integer(unsigned(nextRound(12 to 15)))));
		nextRound(16 to 23) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(16 to 19))),to_integer(unsigned(nextRound(20 to 23)))));
		nextRound(24 to 31) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(24 to 27))),to_integer(unsigned(nextRound(28 to 31)))));
		
		-- XOR
		nextRound(0 to 7) :=  nextRound(0 to 7) xor RoundKey(0 to 7) xor "00100000";
		nextRound(8 to 15) := nextRound(8 to 15) xor RoundKey(8 to 15);
		nextRound(16 to 23) := nextRound(16 to 23) xor RoundKey(16 to 23);
		nextRound(24 to 31) := nextRound(24 to 31) xor RoundKey(24 to 31);
		nextRound(32 to 63) := nextRound(0 to 31) xor RoundKey(32 to 63);
		nextRound(64 to 95) := nextRound(32 to 63) xor RoundKey(64 to 95);
		nextRound(96 to 127) := nextRound(64 to 95) xor RoundKey(96 to 127);
		
        when 7 =>
	    
		-- ROTWORD
		nextRound(0 to 23) := RoundKey(104 to 127);
		nextRound(24 to 31) := RoundKey(96 to 103);
		
		-- SUBBYTE (SBOX)
		nextRound(0 to 7) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(0 to 3))),to_integer(unsigned(nextRound(4 to 7)))));
		nextRound(8 to 15) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(8 to 11))),to_integer(unsigned(nextRound(12 to 15)))));
		nextRound(16 to 23) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(16 to 19))),to_integer(unsigned(nextRound(20 to 23)))));
		nextRound(24 to 31) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(24 to 27))),to_integer(unsigned(nextRound(28 to 31)))));
		
		-- XOR
		nextRound(0 to 7) :=  nextRound(0 to 7) xor RoundKey(0 to 7) xor "01000000";
		nextRound(8 to 15) := nextRound(8 to 15) xor RoundKey(8 to 15);
		nextRound(16 to 23) := nextRound(16 to 23) xor RoundKey(16 to 23);
		nextRound(24 to 31) := nextRound(24 to 31) xor RoundKey(24 to 31);
		nextRound(32 to 63) := nextRound(0 to 31) xor RoundKey(32 to 63);
		nextRound(64 to 95) := nextRound(32 to 63) xor RoundKey(64 to 95);
		nextRound(96 to 127) := nextRound(64 to 95) xor RoundKey(96 to 127);

        when 8 =>
	    
		-- ROTWORD
		nextRound(0 to 23) := RoundKey(104 to 127);
		nextRound(24 to 31) := RoundKey(96 to 103);
		
		-- SUBBYTE (SBOX)
		nextRound(0 to 7) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(0 to 3))),to_integer(unsigned(nextRound(4 to 7)))));
		nextRound(8 to 15) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(8 to 11))),to_integer(unsigned(nextRound(12 to 15)))));
		nextRound(16 to 23) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(16 to 19))),to_integer(unsigned(nextRound(20 to 23)))));
		nextRound(24 to 31) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(24 to 27))),to_integer(unsigned(nextRound(28 to 31)))));
		
		-- XOR
		nextRound(0 to 7) :=  nextRound(0 to 7) xor RoundKey(0 to 7) xor "10000000";
		nextRound(8 to 15) := nextRound(8 to 15) xor RoundKey(8 to 15);
		nextRound(16 to 23) := nextRound(16 to 23) xor RoundKey(16 to 23);
		nextRound(24 to 31) := nextRound(24 to 31) xor RoundKey(24 to 31);
		nextRound(32 to 63) := nextRound(0 to 31) xor RoundKey(32 to 63);
		nextRound(64 to 95) := nextRound(32 to 63) xor RoundKey(64 to 95);
		nextRound(96 to 127) := nextRound(64 to 95) xor RoundKey(96 to 127);
		
        when 9 =>
	    
		-- ROTWORD
		nextRound(0 to 23) := RoundKey(104 to 127);
		nextRound(24 to 31) := RoundKey(96 to 103);
		
		-- SUBBYTE (SBOX)
		nextRound(0 to 7) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(0 to 3))),to_integer(unsigned(nextRound(4 to 7)))));
		nextRound(8 to 15) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(8 to 11))),to_integer(unsigned(nextRound(12 to 15)))));
		nextRound(16 to 23) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(16 to 19))),to_integer(unsigned(nextRound(20 to 23)))));
		nextRound(24 to 31) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(24 to 27))),to_integer(unsigned(nextRound(28 to 31)))));
		
		-- XOR
		nextRound(0 to 7) :=  nextRound(0 to 7) xor RoundKey(0 to 7) xor "00011011";
		nextRound(8 to 15) := nextRound(8 to 15) xor RoundKey(8 to 15);
		nextRound(16 to 23) := nextRound(16 to 23) xor RoundKey(16 to 23);
		nextRound(24 to 31) := nextRound(24 to 31) xor RoundKey(24 to 31);
		nextRound(32 to 63) := nextRound(0 to 31) xor RoundKey(32 to 63);
		nextRound(64 to 95) := nextRound(32 to 63) xor RoundKey(64 to 95);
		nextRound(96 to 127) := nextRound(64 to 95) xor RoundKey(96 to 127);
		
        when 10 =>
	    
		-- ROTWORD
		nextRound(0 to 23) := RoundKey(104 to 127);
		nextRound(24 to 31) := RoundKey(96 to 103);
		
		-- SUBBYTE (SBOX)
		nextRound(0 to 7) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(0 to 3))),to_integer(unsigned(nextRound(4 to 7)))));
		nextRound(8 to 15) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(8 to 11))),to_integer(unsigned(nextRound(12 to 15)))));
		nextRound(16 to 23) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(16 to 19))),to_integer(unsigned(nextRound(20 to 23)))));
		nextRound(24 to 31) := std_logic_vector(SBOX(to_integer(unsigned(nextRound(24 to 27))),to_integer(unsigned(nextRound(28 to 31)))));
		
		-- XOR
		nextRound(0 to 7) :=  nextRound(0 to 7) xor RoundKey(0 to 7) xor "00110110";
		nextRound(8 to 15) := nextRound(8 to 15) xor RoundKey(8 to 15);
		nextRound(16 to 23) := nextRound(16 to 23) xor RoundKey(16 to 23);
		nextRound(24 to 31) := nextRound(24 to 31) xor RoundKey(24 to 31);
		nextRound(32 to 63) := nextRound(0 to 31) xor RoundKey(32 to 63);
		nextRound(64 to 95) := nextRound(32 to 63) xor RoundKey(64 to 95);
		nextRound(96 to 127) := nextRound(64 to 95) xor RoundKey(96 to 127);
				
		when others => null;
		
        end case;
        
        --output
        return nextRound;
														                                
end Keyexpand;

Function subbytes (input: std_logic_vector(0 to 127)) return std_logic_vector is 

variable output: std_logic_vector(0 to 127) := (others => '0');
type sbox is array
	 (integer range 0 to 15, integer range 0 to 15) of std_logic_vector(7 downto 0);
constant INVSBOX: sbox := (     ( x"52" , x"09" , x"6a" , x"d5" , x"30" , x"36" , x"a5" , x"38" , x"bf" , x"40" , x"a3" , x"9e" , x"81" , x"f3" , x"d7", x"fb" ) ,
                                ( x"7c" , x"e3" , x"39" , x"82" , x"9b" , x"2f" , x"ff" , x"87" , x"34" , x"8e" , x"43" , x"44" , x"c4" , x"de" , x"e9", x"cb" ) ,
                                ( x"54" , x"7b" , x"94" , x"32" , x"a6" , x"c2" , x"23" , x"3d" , x"ee" , x"4c" , x"95" , x"0b" , x"42" , x"fa" , x"c3", x"4e" ) ,
                                ( x"08" , x"2e" , x"a1" , x"66" , x"28" , x"d9" , x"24" , x"b2" , x"76" , x"5b" , x"a2" , x"49" , x"6d" , x"8b" , x"d1", x"25" ) ,
                                ( x"72" , x"f8" , x"f6" , x"64" , x"86" , x"68" , x"98" , x"16" , x"d4" , x"a4" , x"5c" , x"cc" , x"5d" , x"65" , x"b6", x"92" ) ,
                                ( x"6c" , x"70" , x"48" , x"50" , x"fd" , x"ed" , x"b9" , x"da" , x"5e" , x"15" , x"46" , x"57" , x"a7" , x"8d" , x"9d", x"84" ) ,
                                ( x"90" , x"d8" , x"ab" , x"00" , x"8c" , x"bc" , x"d3" , x"0a" , x"f7" , x"e4" , x"58" , x"05" , x"b8" , x"b3" , x"45", x"06" ) ,
                                ( x"d0" , x"2c" , x"1e" , x"8f" , x"ca" , x"3f" , x"0f" , x"02" , x"c1" , x"af" , x"bd" , x"03" , x"01" , x"13" , x"8a", x"6b" ) ,
                                ( x"3a" , x"91" , x"11" , x"41" , x"4f" , x"67" , x"dc" , x"ea" , x"97" , x"f2" , x"cf" , x"ce" , x"f0" , x"b4" , x"e6", x"73" ) ,
                                ( x"96" , x"ac" , x"74" , x"22" , x"e7" , x"ad" , x"35" , x"85" , x"e2" , x"f9" , x"37" , x"e8" , x"1c" , x"75" , x"df", x"6e" ) ,
                                ( x"47" , x"f1" , x"1a" , x"71" , x"1d" , x"29" , x"c5" , x"89" , x"6f" , x"b7" , x"62" , x"0e" , x"aa" , x"18" , x"be", x"1b" ) ,
                                ( x"fc" , x"56" , x"3e" , x"4b" , x"c6" , x"d2" , x"79" , x"20" , x"9a" , x"db" , x"c0" , x"fe" , x"78" , x"cd" , x"5a", x"f4" ) ,
                                ( x"1f" , x"dd" , x"a8" , x"33" , x"88" , x"07" , x"c7" , x"31" , x"b1" , x"12" , x"10" , x"59" , x"27" , x"80" , x"ec", x"5f" ) ,
                                ( x"60" , x"51" , x"7f" , x"a9" , x"19" , x"b5" , x"4a" , x"0d" , x"2d" , x"e5" , x"7a" , x"9f" , x"93" , x"c9" , x"9c", x"ef" ) ,
                                ( x"a0" , x"e0" , x"3b" , x"4d" , x"ae" , x"2a" , x"f5" , x"b0" , x"c8" , x"eb" , x"bb" , x"3c" , x"83" , x"53" , x"99", x"61" ) ,
                               ( x"17" , x"2b" , x"04" , x"7e" , x"ba" , x"77" , x"d6" , x"26" , x"e1" , x"69" , x"14" , x"63" , x"55" , x"21" , x"0c", x"7d" ));
begin 

           output(0 to 7) := std_logic_vector(INVSBOX(to_integer(unsigned(input(0 to 3))),to_integer(unsigned(input(4 to 7)))));
           output(8 to 15) := std_logic_vector(INVSBOX(to_integer(unsigned(input(8 to 11))),to_integer(unsigned(input(12 to 15)))));
           output(16 to 23) := std_logic_vector(INVSBOX(to_integer(unsigned(input(16 to 19))),to_integer(unsigned(input(20 to 23)))));
           output(24 to 31) := std_logic_vector(INVSBOX(to_integer(unsigned(input(24 to 27))),to_integer(unsigned(input(28 to 31)))));
           output(32 to 39) := std_logic_vector(INVSBOX(to_integer(unsigned(input(32 to 35))),to_integer(unsigned(input(36 to 39)))));
           output(40 to 47) := std_logic_vector(INVSBOX(to_integer(unsigned(input(40 to 43))),to_integer(unsigned(input(44 to 47)))));
           output(48 to 55) := std_logic_vector(INVSBOX(to_integer(unsigned(input(48 to 51))),to_integer(unsigned(input(52 to 55)))));
           output(56 to 63) := std_logic_vector(INVSBOX(to_integer(unsigned(input(56 to 59))),to_integer(unsigned(input(60 to 63)))));
           output(64 to 71) := std_logic_vector(INVSBOX(to_integer(unsigned(input(64 to 67))),to_integer(unsigned(input(68 to 71)))));
           output(72 to 79) := std_logic_vector(INVSBOX(to_integer(unsigned(input(72 to 75))),to_integer(unsigned(input(76 to 79)))));
           output(80 to 87) := std_logic_vector(INVSBOX(to_integer(unsigned(input(80 to 83))),to_integer(unsigned(input(84 to 87)))));
           output(88 to 95) := std_logic_vector(INVSBOX(to_integer(unsigned(input(88 to 91))),to_integer(unsigned(input(92 to 95)))));
           output(96 to 103) := std_logic_vector(INVSBOX(to_integer(unsigned(input(96 to 99))),to_integer(unsigned(input(100 to 103)))));
           output(104 to 111) := std_logic_vector(INVSBOX(to_integer(unsigned(input(104 to 107))),to_integer(unsigned(input(108 to 111)))));
           output(112 to 119) := std_logic_vector(INVSBOX(to_integer(unsigned(input(112 to 115))),to_integer(unsigned(input(116 to 119)))));
           output(120 to 127) := std_logic_vector(INVSBOX(to_integer(unsigned(input(120 to 123))),to_integer(unsigned(input(124 to 127)))));

    return output;
end subbytes;

Function shiftrows ( input : std_logic_vector(0 to 127)) return std_logic_vector is 
variable output : std_logic_vector (0 to 127) := (others => '0');
begin
            output(0 to 7) := input(0 to 7);
            output(8 to 15) := input(104 to 111);
            output(16 to 23) := input(80 to 87);
            output(24 to 31) := input(56 to 63);
            
            output(32 to 39) := input(32 to 39);
            output(40 to 47) := input(8 to 15);
            output(48 to 55) := input(112 to 119);
            output(56 to 63) := input(88 to 95);
            
            output(64 to 71) := input(64 to 71);
            output(72 to 79) := input(40 to 47);
            output(80 to 87) := input(16 to 23);
            output(88 to 95) := input(120 to 127);
            
            output(96 to 103) := input(96 to 103);
            output(104 to 111) := input(72 to 79);
            output(112 to 119) := input(48 to 55);
            output(120 to 127) := input(24 to 31);
            
            return output;
end shiftrows;

Function mixcols( input : std_logic_vector(0 to 127)) return std_logic_vector is 
    variable temp: std_logic_vector(0 to 127);
    
variable b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15: std_logic_vector(0 to 7);
  
type MultiplyLUT is array(0 to 255) of std_logic_vector(7 downto 0);
	
	constant mult9 : MultiplyLUT :=
	(	x"00",x"09",x"12",x"1b",x"24",x"2d",x"36",x"3f",x"48",x"41",x"5a",x"53",x"6c",x"65",x"7e",x"77",
		x"90",x"99",x"82",x"8b",x"b4",x"bd",x"a6",x"af",x"d8",x"d1",x"ca",x"c3",x"fc",x"f5",x"ee",x"e7",
		x"3b",x"32",x"29",x"20",x"1f",x"16",x"0d",x"04",x"73",x"7a",x"61",x"68",x"57",x"5e",x"45",x"4c",
		x"ab",x"a2",x"b9",x"b0",x"8f",x"86",x"9d",x"94",x"e3",x"ea",x"f1",x"f8",x"c7",x"ce",x"d5",x"dc",
		x"76",x"7f",x"64",x"6d",x"52",x"5b",x"40",x"49",x"3e",x"37",x"2c",x"25",x"1a",x"13",x"08",x"01",
		x"e6",x"ef",x"f4",x"fd",x"c2",x"cb",x"d0",x"d9",x"ae",x"a7",x"bc",x"b5",x"8a",x"83",x"98",x"91",
		x"4d",x"44",x"5f",x"56",x"69",x"60",x"7b",x"72",x"05",x"0c",x"17",x"1e",x"21",x"28",x"33",x"3a",
		x"dd",x"d4",x"cf",x"c6",x"f9",x"f0",x"eb",x"e2",x"95",x"9c",x"87",x"8e",x"b1",x"b8",x"a3",x"aa",
		x"ec",x"e5",x"fe",x"f7",x"c8",x"c1",x"da",x"d3",x"a4",x"ad",x"b6",x"bf",x"80",x"89",x"92",x"9b",
		x"7c",x"75",x"6e",x"67",x"58",x"51",x"4a",x"43",x"34",x"3d",x"26",x"2f",x"10",x"19",x"02",x"0b",
		x"d7",x"de",x"c5",x"cc",x"f3",x"fa",x"e1",x"e8",x"9f",x"96",x"8d",x"84",x"bb",x"b2",x"a9",x"a0",
		x"47",x"4e",x"55",x"5c",x"63",x"6a",x"71",x"78",x"0f",x"06",x"1d",x"14",x"2b",x"22",x"39",x"30",
		x"9a",x"93",x"88",x"81",x"be",x"b7",x"ac",x"a5",x"d2",x"db",x"c0",x"c9",x"f6",x"ff",x"e4",x"ed",
		x"0a",x"03",x"18",x"11",x"2e",x"27",x"3c",x"35",x"42",x"4b",x"50",x"59",x"66",x"6f",x"74",x"7d",
		x"a1",x"a8",x"b3",x"ba",x"85",x"8c",x"97",x"9e",x"e9",x"e0",x"fb",x"f2",x"cd",x"c4",x"df",x"d6",
		x"31",x"38",x"23",x"2a",x"15",x"1c",x"07",x"0e",x"79",x"70",x"6b",x"62",x"5d",x"54",x"4f",x"46", others => (others => '0')); 

	constant mult11 : MultiplyLUT :=
	(	x"00",x"0b",x"16",x"1d",x"2c",x"27",x"3a",x"31",x"58",x"53",x"4e",x"45",x"74",x"7f",x"62",x"69",
		x"b0",x"bb",x"a6",x"ad",x"9c",x"97",x"8a",x"81",x"e8",x"e3",x"fe",x"f5",x"c4",x"cf",x"d2",x"d9",
		x"7b",x"70",x"6d",x"66",x"57",x"5c",x"41",x"4a",x"23",x"28",x"35",x"3e",x"0f",x"04",x"19",x"12",
		x"cb",x"c0",x"dd",x"d6",x"e7",x"ec",x"f1",x"fa",x"93",x"98",x"85",x"8e",x"bf",x"b4",x"a9",x"a2",
		x"f6",x"fd",x"e0",x"eb",x"da",x"d1",x"cc",x"c7",x"ae",x"a5",x"b8",x"b3",x"82",x"89",x"94",x"9f",
		x"46",x"4d",x"50",x"5b",x"6a",x"61",x"7c",x"77",x"1e",x"15",x"08",x"03",x"32",x"39",x"24",x"2f",
		x"8d",x"86",x"9b",x"90",x"a1",x"aa",x"b7",x"bc",x"d5",x"de",x"c3",x"c8",x"f9",x"f2",x"ef",x"e4",
		x"3d",x"36",x"2b",x"20",x"11",x"1a",x"07",x"0c",x"65",x"6e",x"73",x"78",x"49",x"42",x"5f",x"54",
		x"f7",x"fc",x"e1",x"ea",x"db",x"d0",x"cd",x"c6",x"af",x"a4",x"b9",x"b2",x"83",x"88",x"95",x"9e",
		x"47",x"4c",x"51",x"5a",x"6b",x"60",x"7d",x"76",x"1f",x"14",x"09",x"02",x"33",x"38",x"25",x"2e",
		x"8c",x"87",x"9a",x"91",x"a0",x"ab",x"b6",x"bd",x"d4",x"df",x"c2",x"c9",x"f8",x"f3",x"ee",x"e5",
		x"3c",x"37",x"2a",x"21",x"10",x"1b",x"06",x"0d",x"64",x"6f",x"72",x"79",x"48",x"43",x"5e",x"55",
		x"01",x"0a",x"17",x"1c",x"2d",x"26",x"3b",x"30",x"59",x"52",x"4f",x"44",x"75",x"7e",x"63",x"68",
		x"b1",x"ba",x"a7",x"ac",x"9d",x"96",x"8b",x"80",x"e9",x"e2",x"ff",x"f4",x"c5",x"ce",x"d3",x"d8",
		x"7a",x"71",x"6c",x"67",x"56",x"5d",x"40",x"4b",x"22",x"29",x"34",x"3f",x"0e",x"05",x"18",x"13",
		x"ca",x"c1",x"dc",x"d7",x"e6",x"ed",x"f0",x"fb",x"92",x"99",x"84",x"8f",x"be",x"b5",x"a8",x"a3", others => (others => '0')); 

	constant mult13 : MultiplyLUT :=	
	(	x"00",x"0d",x"1a",x"17",x"34",x"39",x"2e",x"23",x"68",x"65",x"72",x"7f",x"5c",x"51",x"46",x"4b",
		x"d0",x"dd",x"ca",x"c7",x"e4",x"e9",x"fe",x"f3",x"b8",x"b5",x"a2",x"af",x"8c",x"81",x"96",x"9b",
		x"bb",x"b6",x"a1",x"ac",x"8f",x"82",x"95",x"98",x"d3",x"de",x"c9",x"c4",x"e7",x"ea",x"fd",x"f0",
		x"6b",x"66",x"71",x"7c",x"5f",x"52",x"45",x"48",x"03",x"0e",x"19",x"14",x"37",x"3a",x"2d",x"20",
		x"6d",x"60",x"77",x"7a",x"59",x"54",x"43",x"4e",x"05",x"08",x"1f",x"12",x"31",x"3c",x"2b",x"26",
		x"bd",x"b0",x"a7",x"aa",x"89",x"84",x"93",x"9e",x"d5",x"d8",x"cf",x"c2",x"e1",x"ec",x"fb",x"f6",
		x"d6",x"db",x"cc",x"c1",x"e2",x"ef",x"f8",x"f5",x"be",x"b3",x"a4",x"a9",x"8a",x"87",x"90",x"9d",
		x"06",x"0b",x"1c",x"11",x"32",x"3f",x"28",x"25",x"6e",x"63",x"74",x"79",x"5a",x"57",x"40",x"4d",
		x"da",x"d7",x"c0",x"cd",x"ee",x"e3",x"f4",x"f9",x"b2",x"bf",x"a8",x"a5",x"86",x"8b",x"9c",x"91",
		x"0a",x"07",x"10",x"1d",x"3e",x"33",x"24",x"29",x"62",x"6f",x"78",x"75",x"56",x"5b",x"4c",x"41",
		x"61",x"6c",x"7b",x"76",x"55",x"58",x"4f",x"42",x"09",x"04",x"13",x"1e",x"3d",x"30",x"27",x"2a",
		x"b1",x"bc",x"ab",x"a6",x"85",x"88",x"9f",x"92",x"d9",x"d4",x"c3",x"ce",x"ed",x"e0",x"f7",x"fa",
		x"b7",x"ba",x"ad",x"a0",x"83",x"8e",x"99",x"94",x"df",x"d2",x"c5",x"c8",x"eb",x"e6",x"f1",x"fc",
		x"67",x"6a",x"7d",x"70",x"53",x"5e",x"49",x"44",x"0f",x"02",x"15",x"18",x"3b",x"36",x"21",x"2c",
		x"0c",x"01",x"16",x"1b",x"38",x"35",x"22",x"2f",x"64",x"69",x"7e",x"73",x"50",x"5d",x"4a",x"47",
		x"dc",x"d1",x"c6",x"cb",x"e8",x"e5",x"f2",x"ff",x"b4",x"b9",x"ae",x"a3",x"80",x"8d",x"9a",x"97", others => (others => '0')); 

	constant mult14 : MultiplyLUT :=	
	(	x"00",x"0e",x"1c",x"12",x"38",x"36",x"24",x"2a",x"70",x"7e",x"6c",x"62",x"48",x"46",x"54",x"5a",
		x"e0",x"ee",x"fc",x"f2",x"d8",x"d6",x"c4",x"ca",x"90",x"9e",x"8c",x"82",x"a8",x"a6",x"b4",x"ba",
		x"db",x"d5",x"c7",x"c9",x"e3",x"ed",x"ff",x"f1",x"ab",x"a5",x"b7",x"b9",x"93",x"9d",x"8f",x"81",
		x"3b",x"35",x"27",x"29",x"03",x"0d",x"1f",x"11",x"4b",x"45",x"57",x"59",x"73",x"7d",x"6f",x"61",
		x"ad",x"a3",x"b1",x"bf",x"95",x"9b",x"89",x"87",x"dd",x"d3",x"c1",x"cf",x"e5",x"eb",x"f9",x"f7",
		x"4d",x"43",x"51",x"5f",x"75",x"7b",x"69",x"67",x"3d",x"33",x"21",x"2f",x"05",x"0b",x"19",x"17",
		x"76",x"78",x"6a",x"64",x"4e",x"40",x"52",x"5c",x"06",x"08",x"1a",x"14",x"3e",x"30",x"22",x"2c",
		x"96",x"98",x"8a",x"84",x"ae",x"a0",x"b2",x"bc",x"e6",x"e8",x"fa",x"f4",x"de",x"d0",x"c2",x"cc",
		x"41",x"4f",x"5d",x"53",x"79",x"77",x"65",x"6b",x"31",x"3f",x"2d",x"23",x"09",x"07",x"15",x"1b",
		x"a1",x"af",x"bd",x"b3",x"99",x"97",x"85",x"8b",x"d1",x"df",x"cd",x"c3",x"e9",x"e7",x"f5",x"fb",
		x"9a",x"94",x"86",x"88",x"a2",x"ac",x"be",x"b0",x"ea",x"e4",x"f6",x"f8",x"d2",x"dc",x"ce",x"c0",
		x"7a",x"74",x"66",x"68",x"42",x"4c",x"5e",x"50",x"0a",x"04",x"16",x"18",x"32",x"3c",x"2e",x"20",
		x"ec",x"e2",x"f0",x"fe",x"d4",x"da",x"c8",x"c6",x"9c",x"92",x"80",x"8e",x"a4",x"aa",x"b8",x"b6",
		x"0c",x"02",x"10",x"1e",x"34",x"3a",x"28",x"26",x"7c",x"72",x"60",x"6e",x"44",x"4a",x"58",x"56",
		x"37",x"39",x"2b",x"25",x"0f",x"01",x"13",x"1d",x"47",x"49",x"5b",x"55",x"7f",x"71",x"63",x"6d",
		x"d7",x"d9",x"cb",x"c5",x"ef",x"e1",x"f3",x"fd",x"a7",x"a9",x"bb",x"b5",x"9f",x"91",x"83",x"8d", others => (others => '0')); 
begin 		
		               b0 := input(0 to 7);       b8  := input(64 to 71 ); 
                        b1 := input(8 to 15);      b9  := input( 72 to 79 ); 
                        b2 := input(16 to 23);     b10 := input( 80 to 87 );
                        b3 := input(24 to 31);    b11 := input( 88 to 95 );
                        b4 := input( 32 to 39 );   b12 := input( 96 to 103 ); 
                        b5 := input( 40 to 47 );   b13 := input( 104 to 111 ); 
                        b6 := input( 48 to 55 );   b14 := input( 112 to 119 );     
                        b7 := input( 56 to 63 );   b15 := input( 120 to 127 );
                        
                     --First Column      
                         temp( 0 to 7 )  := std_logic_vector(mult14(to_integer(unsigned(b0))) XOR mult11(to_integer(unsigned(b1))) XOR mult13(to_integer(unsigned(b2))) XOR mult9(to_integer(unsigned(b3))));
                         temp( 8 to 15 ) := std_logic_vector(mult9(to_integer(unsigned(b0))) XOR mult14(to_integer(unsigned(b1))) XOR mult11(to_integer(unsigned(b2))) XOR mult13(to_integer(unsigned(b3))));
                         temp( 16 to 23 ) := std_logic_vector(mult13(to_integer(unsigned(b0))) XOR mult9(to_integer(unsigned(b1))) XOR mult14(to_integer(unsigned(b2))) XOR mult11(to_integer(unsigned(b3))));
                         temp( 24 to 31 ) := std_logic_vector(mult11(to_integer(unsigned(b0))) XOR mult13(to_integer(unsigned(b1))) XOR mult9(to_integer(unsigned(b2))) XOR mult14(to_integer(unsigned(b3))));
                                
                     --Second Column
                         temp( 32 to 39 ) := std_logic_vector(mult14(to_integer(unsigned(b4))) XOR mult11(to_integer(unsigned(b5))) XOR mult13(to_integer(unsigned(b6))) XOR mult9(to_integer(unsigned(b7))));
                         temp( 40 to 47 ) := std_logic_vector(mult9(to_integer(unsigned(b4))) XOR mult14(to_integer(unsigned(b5))) XOR mult11(to_integer(unsigned(b6))) XOR mult13(to_integer(unsigned(b7))));
                         temp( 48 to 55 ) := std_logic_vector(mult13(to_integer(unsigned(b4))) XOR mult9(to_integer(unsigned(b5))) XOR mult14(to_integer(unsigned(b6))) XOR mult11(to_integer(unsigned(b7))));
                         temp( 56 to 63 ) := std_logic_vector(mult11(to_integer(unsigned(b4))) XOR mult13(to_integer(unsigned(b5))) XOR mult9(to_integer(unsigned(b6))) XOR mult14(to_integer(unsigned(b7))));
                                
                      --Third Column
                         temp( 64 to 71 ) := std_logic_vector(mult14(to_integer(unsigned(b8))) XOR mult11(to_integer(unsigned(b9))) XOR mult13(to_integer(unsigned(b10))) XOR mult9(to_integer(unsigned(b11))));
                         temp( 72 to 79 ) := std_logic_vector(mult9(to_integer(unsigned(b8))) XOR mult14(to_integer(unsigned(b9))) XOR mult11(to_integer(unsigned(b10))) XOR mult13(to_integer(unsigned(b11))));
                         temp( 80 to 87 ) := std_logic_vector(mult13(to_integer(unsigned(b8))) XOR mult9(to_integer(unsigned(b9))) XOR mult14(to_integer(unsigned(b10))) XOR mult11(to_integer(unsigned(b11))));
                         temp( 88 to 95 ) := std_logic_vector(mult11(to_integer(unsigned(b8))) XOR mult13(to_integer(unsigned(b9))) XOR mult9(to_integer(unsigned(b10))) XOR mult14(to_integer(unsigned(b11))));      
                        
                       --Fourth Column
                         temp( 96 to 103 )  := std_logic_vector(mult14(to_integer(unsigned(b12))) XOR mult11(to_integer(unsigned(b13))) XOR mult13(to_integer(unsigned(b14))) XOR mult9(to_integer(unsigned(b15))));
                         temp( 104 to 111 ) := std_logic_vector(mult9(to_integer(unsigned(b12))) XOR mult14(to_integer(unsigned(b13))) XOR mult11(to_integer(unsigned(b14))) XOR mult13(to_integer(unsigned(b15))));
                         temp( 112 to 119 ) := std_logic_vector(mult13(to_integer(unsigned(b12))) XOR mult9(to_integer(unsigned(b13))) XOR mult14(to_integer(unsigned(b14))) XOR mult11(to_integer(unsigned(b15))));
                         temp( 120 to 127 ) := std_logic_vector(mult11(to_integer(unsigned(b12))) XOR mult13(to_integer(unsigned(b13))) XOR mult9(to_integer(unsigned(b14))) XOR mult14(to_integer(unsigned(b15))));
                         
                         return temp;
end mixcols;

Function Addrk ( RoundKey: std_logic_vector(0 to 127); input: std_logic_vector(0 to 127) ) RETURN std_logic_vector is
	variable result	: std_logic_vector(0 to 127) := (others => '0');
	
	begin
		result := input xor RoundKey;
	return result;
	
end Addrk;

end aespackage;