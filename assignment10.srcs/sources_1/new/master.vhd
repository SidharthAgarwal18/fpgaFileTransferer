----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/27/2022 09:27:49 AM
-- Design Name: 
-- Module Name: master - Behavioral
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

entity master is
  Port (
    clk: in std_logic;
    RsRx: in std_logic;
    RsTx: out std_logic;
    btnL: in std_logic;         --reset
    btnR: in std_logic;         --tx_start
    led: out std_logic_vector(15 downto 0);
    c: out std_logic_vector(6 downto 0);
    a: out std_logic_vector(3 downto 0)
   );
end master;

architecture Behavioral of master is

signal display_input: std_logic_vector(7 downto 0):= (others => '0');
signal display_brightness: std_logic_vector(7 downto 0) := x"ff";

type states is (IDLE, RECV_IDLE, RECV, TRANS_IDLE, TRANS);
signal state : states := IDLE;

signal rx_full: std_logic := '0';
signal tx_start: std_logic := '0';

signal bram_read_value: std_logic_vector(7 downto 0):= (others => '0');
signal bram_read_flag: std_logic := '0';
signal bram_read_done: std_logic := '0';
signal bram_write_value: std_logic_vector(7 downto 0):= (others => '0');
signal bram_write_flag: std_logic := '0';
signal bram_write_done: std_logic := '0';
signal bram_size: std_logic_vector(15 downto 0);

signal recv_data_in: std_logic := '1';
signal recv_data_out: std_logic_vector(7 downto 0):= (others => '0');

signal sent_flag : std_logic := '0';
signal send_flag : std_logic := '0';
signal send_data_in: std_logic_vector(7 downto 0) := (others => '0');
signal send_data_out: std_logic := '0';

signal debounced_btnL: std_logic := '0';
signal debounced_btnR: std_logic := '0';

begin

get_bram: entity work.fifo(Behavioral)
port map (clk, bram_read_value, bram_read_flag, bram_read_done, bram_write_value, bram_write_flag, bram_write_done, bram_size);

--parallely receiving input
get_data: entity work.rec(Behavioral)
port map (clk, debounced_btnL, RsRx, recv_data_out, rx_full);

-- parellely sending the output
send_data: entity work.trans(Behavioral)
port map (clk, debounced_btnL, send_flag, send_data_in, RsTx, sent_flag);

get_btnL: entity work.btn_debouncer(Behavioral)
port map (clk, btnL, debounced_btnL);

get_btnR: entity work.btn_debouncer(Behavioral)
port map (clk, btnR, debounced_btnR);

get_display: entity work.display(Behavioral)
port map (clk, display_input, display_brightness, c, a);

process(clk)
begin
    if rising_edge(clk) then
        case state is
            when IDLE =>
                if rx_full = '1' then
                    state <= RECV;
                    bram_read_value <= recv_data_out;
                    display_input <= recv_data_out;
                    bram_read_flag <= '1';
                end if;
            when RECV =>
                bram_read_flag <= '0';
                if rx_full = '0' then
                    state <= RECV_IDLE;
                end if;
            when RECV_IDLE =>
                if rx_full = '1' then
                    state <= RECV;
                    bram_read_value <= recv_data_out;
                    display_input <= recv_data_out;
                    bram_read_flag <= '1';
                elsif tx_start = '1' then
                    state <= TRANS;
                    bram_write_flag <= '1';
                end if;
            when TRANS =>
                bram_write_flag <= '0';
                if sent_flag = '0' then
                    send_data_in <= bram_write_value;
                    display_input <= bram_write_value;
                    state <= TRANS_IDLE;
                    send_flag <= '1';
                end if;
            when TRANS_IDLE =>
                send_data_in <= bram_write_value;
                if sent_flag = '1' then
                    send_flag <= '0';
                    if bram_size = "0000000000000000" then
                        state <= IDLE;
                    else
                        state <= TRANS;
                        bram_write_flag <= '1';
                    end if;
                end if;
        end case;
    end if;
end process;

led <= bram_size;
tx_start <= debounced_btnR;

end Behavioral;
