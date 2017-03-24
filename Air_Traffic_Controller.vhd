----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/28/2016 08:42:23 PM
-- Design Name: 
-- Module Name: Air_Traffic_Controller - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AirTraffic is
Port 
(  
    Port_Req : in  STD_LOGIC;
    Port_Clk : in  STD_LOGIC;
    Port_TypeNumber : in  STD_LOGIC_VECTOR (2 downto 0);
    Port_Denied : out  STD_LOGIC;
    Port_Granted : out  STD_LOGIC
);
		
constant LIGHT : std_logic := '0';
constant HEAVY : std_logic := '1';

end AirTraffic;

architecture Behavioral of AirTraffic is

signal clk_enable: STD_LOGIC := '0';
signal count : unsigned(26 downto 0) := (others => '0');

signal Timer: unsigned(1 downto 0) := "00"; -- 3 seconds timer
signal Timer2: unsigned(3 downto 0) := "0000"; -- 10 seconds timer
signal Timer_start: STD_LOGIC := '0'; -- 3 second timer start/stop signal
signal Timer2_start: STD_LOGIC := '0'; -- 10 second timer start/stop signal

signal AirplaneTypeCurr : std_logic := '0';
signal AirplaneTypePrev : std_logic := '0';

signal req_enable: STD_LOGIC := '0';

--for REQ pushbutton
signal sync_r: STD_LOGIC := '0';
signal old_state_r: STD_LOGIC := '0';

type state_type is (WAITING,GRANTED,DENIED);  --type of state machine.
signal current_state,next_state: state_type;  --current and next state declaration.

begin
	
	process(Port_Clk)
	begin
	   if rising_edge(Port_Clk) then
	       if clk_enable = '1' then

                if (current_state = WAITING and next_state = GRANTED) then                
                    AirplaneTypePrev <= AirplaneTypeCurr;
                end if;

               current_state <= next_state;
    
                if Port_Req = '1' then
                   if Port_TypeNumber = "001" or Port_TypeNumber = "011" or Port_TypeNumber = "111" then
                       AirplaneTypeCurr <= HEAVY;
                   else
                       AirplaneTypeCurr <= LIGHT;    
                   end if;
                end if;
                
                --here "sync_r" is the name i gave to the first register (it does metastability (debounce) synchronization) 
                --and old_state_r is the name of the second register (for storing the previous state of the signal 
                --to detect edges)
                sync_r <= Port_Req; 
                old_state_r <= sync_r; 
               
               if Timer_start = '1' then -- start timer
                   if Timer < "10" then
                       Timer <= Timer + 1;
                   else
                       Timer <= "10";
                   end if; 
               else -- reset and stop timer
                   Timer <= "00";
               end if;
    
               if Timer2_start = '1' then -- start timer2
                   if Timer2 < "1010" then
                       Timer2 <= Timer2 + 1;
                   else
                       Timer2 <= "1010";
                   end if; 
               else -- reset and stop timer2
                   Timer2 <= "0000";
               end if;
            end if;
        end if;
	end process;
	
	req_enable <= sync_r and (not old_state_r);  
	
	-- next state generation process
	process(current_state, req_enable, Port_TypeNumber, AirplaneTypeCurr, AirplaneTypePrev, Timer, Timer2)
	
	begin					           
                    
        -- The CASE statement checks the value of the State variable,
        -- and based on the value and any other control signals, changes
        -- to a new state.
        CASE current_state IS
     
            -- If the current state satisfies , 
                --a) REQ ='1', Curr.Plane='H' 
                --b) REQ ='1', Curr.Plane='L', Prev.Plane='L' 
                --c) REQ ='1', Curr.Plane='L', Prev.Plane='H', timer2 >= 10s
            -- then the next state is GRANTED
            --Led off
            --Reset and stop timer1
                        
            WHEN WAITING =>                                              
                             
                IF req_enable = '1' THEN   

                     if (AirplaneTypeCurr = HEAVY and AirplaneTypePrev = HEAVY) then --restart timer2
                        Timer2_start <= '0';
                    elsif (AirplaneTypeCurr = LIGHT and AirplaneTypePrev = HEAVY) then --continue timer2
                        Timer2_start <= '1';
                    elsif (AirplaneTypeCurr = HEAVY and AirplaneTypePrev = LIGHT) then --start timer2
                        Timer2_start <= '1';
                    else
                        Timer2_start <= '0';
                    end if;  
                                                                     
                    if AirplaneTypeCurr = HEAVY or (AirplaneTypeCurr = LIGHT and AirplaneTypePrev = LIGHT) or 
                      (AirplaneTypeCurr = LIGHT and AirplaneTypePrev = HEAVY and Timer2 = "1010") then

                        Port_Granted <= '1';
                        Port_Denied <= '0';
                        Timer_start <= '0';
                        next_state <= GRANTED; 
                        
                    else
                        Port_Granted <= '0';
                        Port_Denied <= '1';
                        Timer_start <= '0';
                        next_state <= DENIED;
                    end if;
                    
                else
                   if (AirplaneTypeCurr = HEAVY and AirplaneTypePrev = HEAVY) then --continue timer2
                       Timer2_start <= '1';
                   elsif (AirplaneTypeCurr = LIGHT and AirplaneTypePrev = HEAVY) then --continue timer2
                       Timer2_start <= '1';
                   elsif (AirplaneTypeCurr = HEAVY and AirplaneTypePrev = LIGHT) then --start timer2
                       Timer2_start <= '1';
                   else
                       Timer2_start <= '0';
                   end if;   
                    
                    Port_Granted <= '0';
                    Port_Denied <= '0';
                    Timer_start <= '0';
                    next_state <= WAITING;
                END IF;                                        


   
     
            -- If the current state is GRANTED and timer reaches 3, then the
            -- next state is WAITING
            -- Start timer1
            -- Reset and stop timer2 for (c)
            -- Start timer2 for (a)
            -- Led_Granted on for 3s
            -- Change previous plane type
            -- Ignore REQ
                
            WHEN GRANTED => 

                if (AirplaneTypeCurr = HEAVY and AirplaneTypePrev = HEAVY) then --restart timer2
                    Timer2_start <= '1';
                elsif (AirplaneTypeCurr = LIGHT and AirplaneTypePrev = HEAVY) then --continue timer2
                    Timer2_start <= '1';
                elsif (AirplaneTypeCurr = HEAVY and AirplaneTypePrev = LIGHT) then --start timer2
                    Timer2_start <= '1';
                else
                    Timer2_start <= '0';
                end if; 
         
                if Timer = "10" then     
                    Port_Granted <= '0'; 
                    Port_Denied <= '0';
                    Timer_start <= '0';               
                    next_state <= WAITING;
                    
                else
                    Port_Granted <= '1';
                    Port_Denied <= '0';
                    Timer_start <= '1';
                    next_state <= GRANTED;
                end if; 
           
           
            
            -- If the current state is DENIED and timer reaches 3, then the
            -- next state is WAITING  
            -- Start timer1
            -- Led_Denied on for 3s
            -- Ignore REQ
                   
            WHEN DENIED =>               
                          
                if Timer = "10" then 
                    Port_Granted <= '0'; 
                    Port_Denied <= '0';   
                    Timer_start <= '0';   
                    Timer2_start <= '1';         
                    next_state <= WAITING; 
                else
                    Port_Granted <= '0'; 
                    Port_Denied <= '1';
                    Timer_start <= '1';
                    Timer2_start <= '1';
                    next_state <= DENIED;
                end if; 
                
                
            WHEN others =>
                Port_Granted <= '0'; 
                Port_Denied <= '0';   
                Timer_start <= '0';  
                Timer2_start <= '0';
                next_state <= WAITING;
        END CASE; 
	end process;

	
    --clock_enable process
    process(Port_clk)
     begin
    
       if rising_edge(Port_clk) then
           clk_enable <= '0';
           count <= count + 1;
           if count = 100000000/1 then --clock_freq/desired_freq
              clk_enable <= '1';
              count <= (others => '0');
           end if;
        end if;
    end process;
	
end Behavioral;
