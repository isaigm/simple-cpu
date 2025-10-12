----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.08.2025 18:27:45
-- Design Name: 
-- Module Name: tb_program_counter - Behavioral
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

entity tb_program_counter is
--  Port ( );
end tb_program_counter;

architecture Behavioral of tb_program_counter is
component program_counter 
        Port ( clk_in       : in  std_logic;
           reset_in         : in  std_logic;
           jump_enable_in   : in  std_logic;
           jump_address_in  : in  std_logic_vector(7 downto 0);
           pc_out           : out std_logic_vector(7 downto 0)
         );
end component;
signal s_clk_in : std_logic := '0';
signal s_reset_in: std_logic := '0';
signal s_jump_enable_in : std_logic := '0';
signal s_jump_address_in: std_logic_vector(7 downto 0 ) := (others => '0');
signal s_pc_out: std_logic_vector(7 downto 0) := (others => '0');   
constant T: time := 20 ns;
begin
uut: program_counter PORT MAP(
            clk_in           => s_clk_in,
            reset_in         => s_reset_in,
            jump_enable_in   => s_jump_enable_in,
            jump_address_in  => s_jump_address_in,
            pc_out           => s_pc_out
        );

        --clock process
    clk_process: process
    begin
        s_clk_in <= '0';
        wait for T/2;
        s_clk_in <= '1';
        wait for T/2;
    end process;

    --stim process
    stim_proc: process
    begin
    report "Empezando prueba";
    s_reset_in <= '1';
    s_jump_enable_in <= '1';
    s_jump_address_in <= x"FF";
    wait for 40 ns;
    assert (s_pc_out = x"00") report "FALLO: Reset no funcionó." severity error;
    wait for 1 ns;

    s_jump_enable_in <= '1';
    s_jump_address_in <= x"10";
    s_reset_in <= '0';
    wait until rising_edge(s_clk_in);
    assert (s_pc_out = x"10") report "FALLO: El salto no funcionó." severity error;

    wait  for 1 ns;
    s_jump_enable_in <= '0';
    wait until rising_edge(s_clk_in);
    assert (s_pc_out = x"11") report "FALLO: El incremento no funcionó." severity error;
    wait;
    end process;
end Behavioral;
