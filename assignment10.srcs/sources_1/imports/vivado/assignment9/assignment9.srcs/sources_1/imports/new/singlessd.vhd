----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/29/2022 10:38:12 AM
-- Design Name: 
-- Module Name: singlessd - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity singlessd is
--  Port ( );
port(
    i1: in std_logic;
    i2: in std_logic;
	i3: in std_logic;
	i4: in std_logic;
	o0: out std_logic;
	o1: out std_logic;
	o2: out std_logic;
	o3: out std_logic;
	o4: out std_logic;
	o5: out std_logic;
    o6: out std_logic);
end singlessd;

architecture Behavioral of singlessd is

begin

process (i1, i2, i3, i4) is
begin
    if ((i1 and (i2 or i3)) = '1') then
       o0 <= not ((not i2 and i3 and not i4) or (i2 and i3));
       o1 <= not ((not i2 and i3 and not i4) or (i2 and (i3 xor i4)));
       o2 <= not ((not i2 and i3) or (i2 and not i3 and i4));
       o3 <= (not i2 and i3 and not i4) or (i2 and i3 and i4);
       o4 <= '0';
       o5 <= (i2 and not i3);
       o6 <= '0';  
    else
	   o0 <= not (not ((not i1 and not i2 and not i3 and i4) or (not i1 and i2 and not i3 and not i4)));
	   o1 <= not (not (not i1 and i2 and (i3 xor i4)));
	   o2 <= not (not (not i1 and not i2 and i3 and not i4));
	   o3 <= not (not ((not i1 and not i2 and not i3 and i4) or (not i1 and i2 and not i3 and not i4) or (not i1 and i2 and i3 and i4)));
	   o4 <= not ((not i4) and not (not i1 and i2 and not i3));
	   o5 <= not (not ((not i1 and not i2 and (i3 or i4)) or (not i1 and i2 and i3 and i4)));
	   o6 <= not (not ((not i1 and not i2 and not i3) or (not i1 and i2 and i3 and i4)));
	end if;
end process;

end Behavioral;
