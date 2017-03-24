----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:25:59 23/08/2016 
-- Design Name: 
-- Module Name:    Four_Bit_Counter - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

entity Four_Bit_Counter is
Port ( clk          : in STD_LOGIC;
       UP_DOWN      : in STD_LOGIC;
       LOAD         : in STD_LOGIC;
       AUTO_MANUAL  : in STD_LOGIC;
       TICK         : in STD_LOGIC;
       Value        : in STD_LOGIC_VECTOR(3 downto 0);
       Port_Counter : out STD_LOGIC_VECTOR(3 downto 0));
	
end Four_Bit_Counter;

architecture Behavioral of Four_Bit_Counter is
-- to store counter before assigning to Port_counter
signal temp: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

signal clk_enable: STD_LOGIC := '0';
signal counter_enable: STD_LOGIC := '0';

--for TICK pushbutton
signal sync_r: STD_LOGIC := '0';
signal old_state_r: STD_LOGIC := '0';

signal count : unsigned(26 downto 0) := (others => '0');

begin
    
	-- Counter Process
    process(clk, LOAD, Value) begin
             
        if (LOAD = '1') then
        --LOAD asynchronously into Port_counter
            temp <= value;
            
        elsif rising_edge(clk) then

            if clk_enable = '1' then   
                --enabled at 1Hz rate without using another downscaled clock
                if (AUTO_MANUAL = '1') then 
                    --Auto-counting                               
                    if UP_DOWN = '1' then
                        if temp < "1111" then
                            temp <= STD_LOGIC_VECTOR(unsigned(temp) + "0001");
                        else
                            temp <= "1111";
                        end if;           
                    else
                        if temp > "0000" then
                            temp <= STD_LOGIC_VECTOR(unsigned(temp) - "0001");
                        else
                            temp <= "0000";
                        end if;   
                    end if; 
                    
                else 
                    --Manual Counting
                    if counter_enable = '1' then
                        if UP_DOWN = '1' then
                            if temp < "1111" then
                                temp <= STD_LOGIC_VECTOR(unsigned(temp) + "0001");
                            else
                                temp <= "1111";
                            end if;           
                        else
                            if temp > "0000" then
                                temp <= STD_LOGIC_VECTOR(unsigned(temp) - "0001");
                            else
                                temp <= "0000";
                            end if;   
                        end if;                                 
                    end if;
                    --here "sync_r" is the name i gave to the first register (it does metastability (debounce) synchronization) 
                    --and old_state_r is the name of the second register (for storing the previous state of the signal 
                    --to detect edges)
                    sync_r <= TICK; 
                    old_state_r <= sync_r;                         
                end if;    
            end if;   
        end if;       
    end process;
    
    counter_enable <= sync_r and (not old_state_r);    
    Port_Counter <= temp;
    
    --clock_enable process
    process(clk)
     begin   
       if rising_edge(clk) then
           clk_enable <= '0';
           count <= count + 1;
           if count = 100000000/1 then --clock_freq/desired_freq
              clk_enable <= '1';
              count <= (others => '0');
           end if;
        end if;
    end process;

end Behavioral;
