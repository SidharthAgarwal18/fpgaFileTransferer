----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.05.2022 15:09:52
-- Design Name: 
-- Module Name: rec - Behavioral
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

entity rec is
  Port ( 
    clk: in std_logic;
    reset: in std_logic;
    data_in: in std_logic;
    data_out: out std_logic_vector(7 downto 0);
    recv_flag : out std_logic
  );
end rec;

architecture Behavioral of rec is
signal counter: std_logic_vector(11 downto 0) := (others => '0');
signal fast_baud_lim: std_logic_vector(11 downto 0) := x"28a";
signal fast_baud: std_logic;

type states is (IDLE, START, GET, FIN);
signal state: states := IDLE;



signal stored_data: std_logic_vector(7 downto 0) := (others => '0');
begin

process(clk)
begin
    -- set so that the counter creates a delay equivalent for 16 * baud rate (9600 Hz) from the internal clock (100 MHz)
    if rising_edge(clk) then
        if counter = fast_baud_lim then
            counter <= (others => '0');
        else
            counter <= counter + 1;
        end if;
    end if;
end process;

--clk which updates at 16 * baud rate
fast_baud <= '1' when counter = fast_baud_lim else '0';

process(clk)
variable bit_ctr: integer := 0;
variable bits: integer := 0;
begin
    if rising_edge(clk) then
        if reset = '1' then
            -- reset button (btnC) sets any ongoing condition back to the IDLE position and forgets any on going input
            state <= IDLE;
            stored_data <= (others => '0');
            data_out <= (others => '0');
            bit_ctr := 0;
            bits := 0;
            recv_flag <= '0';
        else
            if state = IDLE then
                -- wait till it finds 0 as the start bit
                -- it detects at 16*baud rate to as to later be able to more accurately detect bits
                if fast_baud = '1' then
                    recv_flag <= '0';
                    stored_data <= (others => '0');
                    bit_ctr := 0;
                    bits := 0;
                    if data_in = '0' then
                        --start checking for data since start bit in 
                        state <= START;
                    end if;
                end if;
            elsif state = START then
                if fast_baud = '1' then
                    -- wait 8 more fast_bauds to get to mid bit of start bit
                    -- after verifying the start bit 8 times, it switched to the data state 
                    if data_in = '0' then
                        if bit_ctr = 7 then
                            state <= GET;
                            bit_ctr := 0;
                        else
                            bit_ctr := bit_ctr + 1;
                        end if;
                    else
                        -- if not able to verify the start bit for 8 events, it goes back to IDLE
                        state <= IDLE;
                    end if;
                end if;
            elsif state = GET then
                if fast_baud = '1' then
                -- after every 16 fast_bauds (ie 1 baud) it samples the data_in to take the input
                -- since we moved 8 bits after the start bit, thus we sample in the middle portion after every 16 bits
                    if bit_ctr = 15 then
                        stored_data(bits) <= data_in;
                        bit_ctr := 0;
                        -- sample at 16th fast_baud (mid bit)
                        if bits = 7 then
                            state <= FIN;
                        else
                            bits := bits + 1;
                        end if;
                    else
                        bit_ctr := bit_ctr + 1;
                    end if;
                end if;
            elsif state = FIN then
                if fast_baud = '1' then
                    if bit_ctr = 15 then
                        -- after sending out the stop bit (0) after another baud, we copy out the data and move back to IDLE
                        data_out <= stored_data;
                        recv_flag <= '1';  
                        state <= IDLE;
                    -- end by copying stored data outside
                    else 
                        bit_ctr := bit_ctr + 1;
                    end if;
                end if;
            end if;
        end if;
    end if;
end process;


end Behavioral;
