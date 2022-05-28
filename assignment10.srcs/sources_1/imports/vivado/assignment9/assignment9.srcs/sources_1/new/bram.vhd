----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/24/2022 11:55:10 AM
-- Design Name: 
-- Module Name: bram - Behavioral
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

entity fifo is
  Port (
    clk:in  std_logic;
    read_value:in  std_logic_vector(7 downto 0);
    read_flag:in  std_logic;
    read_done: out std_logic;
    write_value:out  std_logic_vector(7 downto 0);
    write_flag:in  std_logic;
    write_done: out std_logic;
    size: out std_logic_vector(15 downto 0)
   );
end fifo;

architecture Behavioral of fifo is

constant RAM_DEPTH: integer := 1024;

--type bram_type is array (0 to RAM_DEPTH-1) of std_logic_vector(15 downto 0);
--signal bram: bram_type;
signal head: integer := 0;
signal tail: integer := 0;
signal size_out : std_logic_vector(15 downto 0) := (others => '0');

type states is (IDLE, FULL, EMPTY, ST_PUSH, PUSHING, END_PUSH, ST_POP, POPPING, END_POP);
signal state : states := EMPTY;

signal bram_addr: std_logic_vector(9 downto 0) := (others => '0');
signal bram_din: std_logic_vector(7 downto 0) := (others => '0');
signal bram_dout: std_logic_vector(7 downto 0) := (others => '0');
signal bram_en: std_logic := '1';
signal bram_rst: std_logic := '0';
signal bram_we: std_logic_vector(0 downto 0) := (others => '0');

COMPONENT blk_mem_gen_0
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END COMPONENT;

begin
your_instance_name : blk_mem_gen_0
  PORT MAP (
    clka => clk,
    ena => bram_en,
    wea => bram_we,
    addra => bram_addr,
    dina => bram_din,
    douta => bram_dout
  );
--get_bram_module: entity work.bram_wrapper(STRUCTURE)
--port map (bram_addr, clk, bram_din, bram_dout, bram_en, bram_rst, bram_we);

process(clk)
begin
    if rising_edge(clk) then
        case state is
        --default state where both push and pop are available
            when IDLE =>
                read_done <= '0';
                write_done <= '0';
                if read_flag = '1' then
                    state <= ST_PUSH;
                elsif write_flag = '1' then
                    state <= ST_POP;
                    bram_addr <= std_logic_vector(to_unsigned(tail, 10));           
                end if;
         -- only pop is available in FULL
            when FULL =>
                write_done <= '0';
                if write_flag = '1' then
                    read_done <= '0';
                    state <= ST_POP;
                    bram_addr <= std_logic_vector(to_unsigned(tail, 10));
                elsif read_flag = '1' then
                    read_done <= '1';
                else
                    read_done <= '0';
                end if;
         -- only push is available in EMPTY
            when EMPTY =>
                read_done <= '0';
                if read_flag = '1' then
                    state <= ST_PUSH;
                    write_done <= '0';
                elsif write_flag = '1' then
                    write_done <= '1';
                else
                    write_done <= '0';
                end if;
         -- pushes read_value in FIFO queue at head
         -- goes to FULL no space
            when ST_PUSH =>
                bram_addr <= std_logic_vector(to_unsigned(head, 10));
                bram_din <= read_value;
--                bram(head) <= read_value;
                read_done <= '0';
                bram_we <= (others => '1');
                state <= PUSHING;
            when PUSHING =>
                bram_we <= (others => '0');
                state <= END_PUSH;
            when END_PUSH =>
                size_out <= size_out + 1;
                if (head + 1) mod RAM_DEPTH = tail then
                    state <= FULL;
                    head <= (head + 1) mod RAM_DEPTH;
                else
                    state <= IDLE;
                    head <= (head + 1) mod RAM_DEPTH;
                end if;
                read_done <= '1';
         -- pops value at the tail pointer in the queue
         -- goes to EMPTY state if only single element was left
            when ST_POP =>
--                write_value <= bram(tail);
                write_done <= '0';
                state <= POPPING;
            when POPPING =>
                state <= END_POP;
            when END_POP =>
                write_value <= bram_dout;
                size_out <= size_out - 1;
                if (tail + 1) mod RAM_DEPTH = head then
                    state <= EMPTY;
                    tail <= (tail + 1) mod RAM_DEPTH;
                else
                    state <= IDLE;
                    tail <= (tail + 1) mod RAM_DEPTH;
                end if;
                write_done <= '1';
        end case;
    end if;
end process; 

size <= size_out;

end Behavioral;