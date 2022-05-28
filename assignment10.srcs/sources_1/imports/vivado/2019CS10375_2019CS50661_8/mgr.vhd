----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.05.2022 16:19:49
-- Design Name: 
-- Module Name: mgr - Behavioral
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

entity mgr is
  Port ( 
    clk: in std_logic;
    RsRx: in std_logic;
    RsTx: out std_logic;
    btnC: in std_logic;
    a: out std_logic_vector(3 downto 0);
    c: out std_logic_vector(6 downto 0)
  );
end mgr;

architecture Behavioral of mgr is

signal display_input: std_logic_vector(7 downto 0):= (others => '0');
signal display_brightness: std_logic_vector(7 downto 0) := x"ff";

signal recv_data_in: std_logic := '1';
signal recv_data_out: std_logic_vector(7 downto 0):= (others => '0');
signal recv_flag : std_logic := '0';

signal sent_flag : std_logic := '0';
signal send_flag : std_logic := '0';
signal send_data_in: std_logic_vector(7 downto 0) := (others => '0');
signal send_data_out: std_logic := '0';

type states is (GET, SEND);
signal state : states := GET;

begin

-- parallely diplaying on 7 segment display
get_display: entity work.display(Behavioral)
port map (clk, display_input, display_brightness, c, a);

--parallely receiving input
get_data: entity work.rec(Behavioral)
port map (clk, btnC, RsRx, recv_data_out, recv_flag);

-- parellely sending the output
send_data: entity work.trans(Behavioral)
port map (clk, btnC, send_flag, send_data_in, RsTx, sent_flag);

process(clk)
begin
    if rising_edge(clk) then
    -- when reciving is complete then GET transits to SEND and sending completes it transits to GET
        case state is
            when GET =>
                -- once data recieved by the Rx we switch to send state
                send_flag <= '0'; 
                if recv_flag = '1' then
                    state <= SEND;
                end if;
            when SEND =>
                -- send revieced input from rx back to the tx and the display units
                -- once sent, we switch back to the get state and wait for input
                display_input <= recv_data_out;
                send_data_in <= recv_data_out;
                send_flag <= '1';
                if sent_flag = '1' then
                    state <= GET;
                end if;
        end case;
    end if;
end process;

end Behavioral;
