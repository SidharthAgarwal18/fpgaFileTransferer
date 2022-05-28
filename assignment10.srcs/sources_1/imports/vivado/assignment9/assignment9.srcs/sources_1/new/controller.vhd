----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/24/2022 11:59:01 AM
-- Design Name: 
-- Module Name: controller - Behavioral
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

entity controller is
  Port (
    clk: in std_logic;
    i: in std_logic_vector(15 downto 0);
    btnL: in std_logic;
    btnR: in std_logic;
    led: out std_logic_vector(15 downto 0);
    c: out std_logic_vector(6 downto 0);
    a: out std_logic_vector(3 downto 0)
   );
end controller;

architecture Behavioral of controller is
type states is (IDLE, READ, WRITE);
signal state: states := IDLE;

signal b: std_logic_vector(7 downto 0) := (others => '1'); 
signal display_i: std_logic_vector(15 downto 0) := (others => '0');

signal bram_read_value: std_logic_vector(15 downto 0):= (others => '0');
signal bram_read_flag: std_logic := '0';
signal bram_read_done: std_logic := '0';
signal bram_write_value: std_logic_vector(15 downto 0):= (others => '0');
signal bram_write_flag: std_logic := '0';
signal bram_write_done: std_logic := '0';

signal debounced_btnL: std_logic := '0';
signal debounced_btnR: std_logic := '0';

begin

get_display: entity work.display(Behavioral)
port map (clk, display_i, b, c, a);

get_bram: entity work.fifo(Behavioral)
port map (clk, bram_read_value, bram_read_flag, bram_read_done, bram_write_value, bram_write_flag, bram_write_done, led);

get_btnL: entity work.btn_debouncer(Behavioral)
port map (clk, btnL, debounced_btnL);

get_btnR: entity work.btn_debouncer(Behavioral)
port map (clk, btnR, debounced_btnR);

process(clk)
begin
    if rising_edge(clk) then
    -- default state; goes to READ state on debounced_btnL is pressed and returns
    -- when bram_read_done = 1. Similarly for WRITE state is sensitive to debounced_btnR and returns
    -- when bram_write_done = 1.
        if state = IDLE then
            if debounced_btnL = '1' then
                state <= READ;
                bram_read_value <= i;
                bram_read_flag <= '1';
            elsif debounced_btnR = '1' then
                state <= WRITE;
                bram_write_flag <= '1';
            end if;
        elsif state = READ then
            bram_read_flag <= '0';
            if bram_read_done = '1' then
                state <= IDLE;
            end if;
        elsif state = WRITE then
            bram_write_flag <= '0';
            if bram_write_done = '1' then
                display_i <= bram_write_value;
                state <= IDLE;
            end if;
        end if;
    end if;
end process;

end Behavioral;
