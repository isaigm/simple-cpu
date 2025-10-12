----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.08.2025 20:32:34
-- Design Name: 
-- Module Name: tb_register - Behavioral
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

entity tb_register is
--  Port ( );
end tb_register;

architecture Behavioral of tb_register is
    component generic_register
    Port ( clk_in   : in  std_logic;
            reset_in : in  std_logic;
            we_in    : in  std_logic; -- Write Enable
            D_in     : in  std_logic_vector(7 downto 0);
            Q_out    : out std_logic_vector(7 downto 0)
        );
    end component;
signal s_clk_in : std_logic := '0';
signal s_reset_in: std_logic := '0';
signal s_we_in : std_logic;
signal s_D_in: std_logic_vector(7 downto 0 ) := (others => '0');
signal s_Q_out: std_logic_vector(7 downto 0 ) := (others => '0');

constant T: time := 20 ns;

begin
    uut: generic_register PORT MAP(
            clk_in   => s_clk_in,
            reset_in => s_reset_in,
            we_in    => s_we_in,
            D_in     => s_D_in,
            Q_out    => s_Q_out
    );
clk_process:
    process
        begin
            s_clk_in <= '0';
            wait for T / 2;
            s_clk_in <= '1';
            wait for T / 2;
    end process;
stim_proc: process
    begin
        report "--- Iniciando Testbench para Registro ---";

        report "Test 1: Probando Reset...";
        s_reset_in <= '1';
        s_we_in    <= '0'; 
        s_D_in     <= x"FF"; 
    
        wait for 35 ns;
        assert (s_Q_out = x"00") report "FALLO: Reset no funcionó." severity error;

        report "Test 2: Probando Escritura...";
        s_reset_in <= '0';
        s_we_in    <= '1';
        s_D_in     <= x"AA";
        
        wait until rising_edge(s_clk_in);
        
        wait for 1 ns; 
        assert (s_Q_out = x"AA") report "FALLO: Escritura de xAA falló." severity error;

        report "Test 3: Probando Mantener...";
        s_we_in <= '0'; 
        s_D_in  <= x"55"; 
        wait for 3 * T; 
        assert (s_Q_out = x"AA") report "FALLO: El registro no mantuvo su valor." severity error;

        report "--- Todos los tests pasaron con éxito. ---";
        wait; 
    end process;


end Behavioral;
