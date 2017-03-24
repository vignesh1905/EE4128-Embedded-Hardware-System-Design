library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.aespackage.all;

entity myip2_v1_0 is
	port 
	(
		-- DO NOT EDIT BELOW THIS LINE ---------------------
		-- Bus protocol ports, do not add or delete. 
		ACLK	: in	std_logic;
		ARESETN	: in	std_logic;
		S_AXIS_TREADY	: out	std_logic;
		S_AXIS_TDATA	: in	std_logic_vector(0 to 31);
		S_AXIS_TLAST	: in	std_logic;
		S_AXIS_TVALID	: in	std_logic;
		M_AXIS_TVALID	: out	std_logic;
		M_AXIS_TDATA	: out	std_logic_vector(0 to 31);
		M_AXIS_TLAST	: out	std_logic;
		M_AXIS_TREADY	: in	std_logic
		-- DO NOT EDIT ABOVE THIS LINE ---------------------
	);

attribute SIGIS : string; 
attribute SIGIS of ACLK : signal is "Clk"; 
end myip2_v1_0;

architecture EXAMPLE of myip2_v1_0 is

   -- Total number of input data.
 constant NUMBER_OF_INPUT_WORDS  : natural := 4;

 -- Total number of output data
 constant NUMBER_OF_OUTPUT_WORDS : natural := 4;

 type STATE_TYPE is (Idle, Read_Data, Read_Key, Read_Buffer, KeyExp, decrypt, write_output);
 type INNER_STATE_TYPE is (Addrk, inverse_shiftrow, inverse_subbyte, inverse_mixcol);
 
 signal state        : STATE_TYPE;

 -- Accumulator to hold sum of inputs read at any point in time
  signal output          : std_logic_vector(0 to 31);
  signal input          : std_logic_vector(0 to 127);
  signal key128         : std_logic_vector(0 to 127);
  signal KeyArray      : std_logic_vector(0 to 1279) := (others => '0');
  signal round          : natural range 1 to 11;
  signal innerround     : natural range 1 to 11;
  signal temp           : natural range 1 to 11;
  signal inner_state    : INNER_STATE_TYPE;

 -- Counters to store the number inputs read & outputs written
 signal nr_of_reads  : natural range 0 to NUMBER_OF_INPUT_WORDS - 1;
 signal nr_of_writes : natural range 0 to NUMBER_OF_OUTPUT_WORDS - 1;
 signal got_key : natural range 0 to 1;

begin

 S_AXIS_TREADY  <= '1'  when state = Read_Key or state = Read_Data  else '0';
 M_AXIS_TVALID <= '1' when state = write_output else '0';
 M_AXIS_TLAST <= '1' when (state = write_output and nr_of_writes = 0) else '0';
--     M_AXIS_TDATA <= output;
M_AXIS_TDATA <= input (0 to 31) when (state = write_output and nr_of_writes = 3 ) 
				else input(32 to 63) when (state = write_output and nr_of_writes = 2 ) 
				else input(64 to 95) when (state = write_output and nr_of_writes = 1 )
				else input(96 to 127) when (state = write_output and nr_of_writes = 0 );

 The_SW_accelerator : process (ACLK) is
  
--  variable temp  : std_logic_vector(0 to 127);
 
  begin 
  if ACLK'event and ACLK = '1' then     
    if ARESETN  = '0' then              
      -- CAUTION: make sure your reset polarity is consistent with the
      -- system reset polarity
      state        <= Idle;
      inner_state <= Addrk;
      nr_of_reads  <= 0;
      nr_of_writes <= 0;
      got_key <= 0;
    else
     case state is
        when Idle =>
          if (S_AXIS_TVALID = '1') then
            if (got_key = 0)then 
                state <= Read_Key;
            else
                state <= Read_Data;
            end if;
                nr_of_reads <= NUMBER_OF_INPUT_WORDS - 1;
          end if;
              
           when Read_Key =>
              if (S_AXIS_TVALID = '1') then
                  if(nr_of_reads = 3) then
                      key128(0 to 31) <= S_AXIS_TDATA;
                      state <= Read_Key;
                      nr_of_reads <= nr_of_reads - 1;
                  elsif(nr_of_reads = 2) then
                      key128(32 to 63) <= S_AXIS_TDATA;
                      nr_of_reads <= nr_of_reads - 1;
                      state <= Read_Key;
                  elsif(nr_of_reads = 1) then
                      key128(64 to 95) <= S_AXIS_TDATA;
                      nr_of_reads <= nr_of_reads - 1;
                      state <= Read_Key;
                  elsif(nr_of_reads = 0) then
                      key128(96 to 127) <= S_AXIS_TDATA;
                      nr_of_reads <= NUMBER_OF_INPUT_WORDS - 1;
                      state <= Read_Data;
                  else
                       state <= Read_Key;
                  end if;    
              end if;
              
           when Read_Data =>
              if (S_AXIS_TVALID = '1') then
                  if(nr_of_reads = 3) then
                      input(0 to 31) <= S_AXIS_TDATA;
                      nr_of_reads <= nr_of_reads - 1;
                      state <= Read_Data;
                  elsif(nr_of_reads = 2) then
                      input(32 to 63) <= S_AXIS_TDATA;
                      nr_of_reads <= nr_of_reads - 1;
                      state <= Read_Data;
                  elsif(nr_of_reads = 1) then
                      input(64 to 95) <= S_AXIS_TDATA;
                      nr_of_reads <= nr_of_reads - 1;
                      state <= Read_Data;
                  elsif(nr_of_reads = 0) then
                      input(96 to 127) <= S_AXIS_TDATA;
                      state <= Read_buffer;
                else
                      state <=Read_Data;
                  end if;
              end if;
          
           when Read_Buffer =>
              	round <= 1;
              	innerround <=1;
              	if (got_key=0) then
				 state <= KeyExp;
				else
				 state <= decrypt;
				end if;
				got_key <= 1;
				inner_state <= Addrk;
				nr_of_writes <= NUMBER_OF_OUTPUT_WORDS - 1;
              
           when KeyExp =>
                if(round = 1) then 
                    KeyArray(((round-1)*128) to (((round-1)*128)+127)) <= Keyexpand(key128,round);
                    state <= KeyExp;
                    round <= round+1 ;
                    temp <= 1 ;
                elsif(round = 11) then
                    round <= 1;
                    state <= decrypt;
                else
                    KeyArray(((round-1)*128) to (((round-1)*128)+127)) <= Keyexpand(KeyArray(((temp-1)*128) to (((temp-1)*128)+127)), round);
                    round <= round + 1;
                    temp <= temp +1 ;
                end if;
               
           when decrypt =>
               case inner_state is
                  when Addrk =>
                    if(innerround = 1) then
                        input(0 to 127) <= Addrk(KeyArray(((10-innerround)*128) to (((10-innerround)*128)+127)), input);
                        inner_state <= inverse_shiftrow;
                        innerround <= innerround + 1 ;
                     elsif(innerround = 11) then
                        input(0 to 127) <= Addrk(key128,input);
                        innerround <= 1;
                        state <= write_output;
                     else 
                        input(0 to 127) <= Addrk(KeyArray(((10-innerround)*128) to ((10-innerround)*128)+127), input);
                        inner_state <= inverse_mixcol;
                    end if;
              
                  when inverse_shiftrow =>
                        inner_state <= inverse_subbyte;
                        input(0 to 127) <= shiftrows(input(0 to 127));
             
                  when inverse_subbyte =>
                        inner_state <= Addrk;
                        input(0 to 127) <= subbytes(input(0 to 127));
                  
                  when inverse_mixcol =>
                        inner_state <= inverse_shiftrow;
                        input(0 to 127) <= mixcols(input(0 to 127));
                        innerround <= innerround + 1;      
                end case;
         
          when write_output =>
                if (M_AXIS_TREADY = '1') then                          
					if (nr_of_writes = 0) then
						state <= Idle;                
					else
						nr_of_writes <= nr_of_writes - 1;
					end if;
				end if;
         when others =>
                state <= Idle;
       end case;
    end if;
  end if;
 end process The_SW_accelerator;
end EXAMPLE;