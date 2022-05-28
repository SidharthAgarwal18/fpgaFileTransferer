----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/20/2022 10:15:19 AM
-- Design Name: 
-- Module Name: trans - Behavioral
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

entity trans is
Port ( 
    clk: in std_logic;
    reset: in std_logic;
    send_flag: in std_logic;
    data_in: in std_logic_vector(7 downto 0);
    data_out: out std_logic;
    sent_flag : out std_logic
);
end trans;

architecture Behavioral of trans is
signal counter: std_logic_vector(15 downto 0) := (others => '0');
signal baud_lim: std_logic_vector(15 downto 0) := x"28b0";
signal baud: std_logic := '0';

type states is (IDLE, START, SEND, FIN);
signal state : states := IDLE;

begin

process(clk)
begin
    if rising_edge(clk) then
        if counter = baud_lim then
            counter <= (others => '0');
        else
            -- counter is set to count the time period for baud rate (9600 Hz) from the clock (100 MHz)
            counter <= counter + 1;
        end if;
    end if;
end process;

-- set 1 when one baud passes
baud <= '1' when counter = baud_lim else '0';

process(clk)
variable bits: integer := 0;
begin
    if rising_edge(clk) then
        -- reset button (btnC) sets ongoing Tx back to idle whichever state it is in
        if reset = '1' then
            data_out <= '1';
            sent_flag <= '0';
            bits := 0;
            state <= IDLE;
        elsif baud = '1' then
            case state is
                when IDLE =>
                    -- wait till send_flag from mgr is 1 ( till then send '1' on line)
                    data_out <= '1';
                    sent_flag <= '0';
                    bits := 0;
                    if send_flag = '1' then
                        state <= START;
                    end if;
                when START =>
                    -- send start bit initially before sending the bits
                    data_out <= '0';
                    state <= SEND;
                when SEND =>
                    -- send 8 bits at every baud and then switch to final state
                    data_out <= data_in(bits);
                    if bits = 7 then
                        state <= FIN;
                    else
                        bits := bits + 1;
                    end if;
                when FIN =>
                    -- send stop bit and sent_flag to 1 and then switch back to IDLE
                    data_out <= '1';
                    sent_flag <= '1';
                    state <= IDLE;
            end case;
        end if;
    end if;
end process;

end Behavioral;
