----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/24/2022 01:32:36 PM
-- Design Name: 
-- Module Name: btn_debouncer - Behavioral
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
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity btn_debouncer is
  Port (
    clk: in std_logic;
    btn: in std_logic;
    dbtn: out std_logic
  );
end btn_debouncer;

architecture Behavioral of btn_debouncer is
signal counter : std_logic_vector(19 downto 0) := (others => '0');
signal counter_check: std_logic_vector(19 downto 0) := "11110100001001000000";
signal check: std_logic;

signal calc: integer := 0;
begin
-- Used for debouncing the button

process(clk)
begin
    if rising_edge(clk) then
        if counter = counter_check then
            counter <= (others =>'0');
        else
            counter <= counter +1;
        end if;
    end if;
end process;

check <= '1' when counter = counter_check else '0';

-- every 10 msec check btn=1
-- if btn=1 for 4 times then debouncing btn(dbtn) becomes 1
-- else dbtn = 0
process(clk)
begin
    if rising_edge(clk) then
        if check = '1' then
            if btn = '1' then
                if calc = 7 then
                    calc <= 0;
                    dbtn <= '1';
                else
                    calc <= calc + 1;
                end if;
            else
                calc <= 0;
            end if;
        else
            dbtn <= '0';
        end if;
    end if;
end process;

end Behavioral;
