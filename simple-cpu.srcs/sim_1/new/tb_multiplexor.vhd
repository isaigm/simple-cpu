----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.08.2025 21:09:24
-- Design Name: 
-- Module Name: tb_multiplexor - Behavioral
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
entity tb_multiplexor is
--  Port ( );
end tb_multiplexor;
architecture Behavioral of tb_multiplexor is
component multiplexor is
    Port ( A_in   : in  std_logic_vector(7 downto 0);
           B_in   : in  std_logic_vector(7 downto 0);
           sel_in : in  std_logic;
           Y_out  : out std_logic_vector(7 downto 0)
         );
end component;
signal s_A_in   : std_logic_vector(7 downto 0) := (others => '0');
signal s_B_in   : std_logic_vector(7 downto 0) := (others => '0');
signal s_sel_in : std_logic := '0';
signal s_Y_out  : std_logic_vector(7 downto 0) := (others => '0');
begin
    uut: multiplexor
        port map (
            A_in   => s_A_in,
            B_in   => s_B_in,
            sel_in => s_sel_in,
            Y_out  => s_Y_out
        );
    process
    begin
        s_A_in <= "00000001";  
        s_B_in <= "00000010";  
        s_sel_in <= '0';       
        wait for 10 ns;        
        assert (s_Y_out = "00000001") report "Error: Y_out should match A_in when sel_in = '0'" severity error;
        s_sel_in <= '1';       
        wait for 10 ns;        
        assert (s_Y_out = "00000010") report "Error: Y_out should match B_in when sel_in = '1'" severity error;
        wait;
        end process;
end Behavioral;