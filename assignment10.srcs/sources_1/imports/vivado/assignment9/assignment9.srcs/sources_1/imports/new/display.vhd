----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/10/2022 01:26:10 PM
-- Design Name: 
-- Module Name: display - Behavioral
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

entity display is
Port (
    clk: in std_logic;
    i: in std_logic_vector(7 downto 0);
    b: in std_logic_vector(7 downto 0);
    c: out std_logic_vector(6 downto 0);
    a: out std_logic_vector(3 downto 0)
 );
end display;

architecture Behavioral of display is

signal counter: std_logic_vector(17 downto 0) := "000000000000000000";
signal topbits: std_logic_vector(1 downto 0);
signal si: std_logic_vector(3 downto 0);
signal an: std_logic_vector(1 downto 0) := "00";
signal bi: std_logic_vector(7 downto 0);

begin
get_cathode : entity work.singlessd(Behavioral)
port map(si(0), si(1), si(2), si(3), c(0), c(1), c(2), c(3), c(4), c(5), c(6));

process(clk)
begin
    if rising_edge(clk) then
        if an = "00" then
            if topbits(1 downto 0) < bi(1 downto 0) then
                a <= "0111";
                si <= i(3 downto 0);
                counter <= counter + 1;
            else
                a <= "1111";
                an <= "01";
                counter <= (others => '0');
            end if;
        elsif an = "01" then
            if topbits(1 downto 0) < bi(3 downto 2) then
                a <= "1011";
                si <= i(7 downto 4);
                counter <= counter + 1;
            else
                a <= "1111";
                an <= "00";
                counter <= (others => '0');
            end if;
        end if;
    end if;
end process;
topbits <= counter(17 downto 16);
bi <= b;

end Behavioral;
