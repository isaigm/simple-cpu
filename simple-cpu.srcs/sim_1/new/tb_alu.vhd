----------------------------------------------------------------------------------
-- Testbench para la Unidad Aritmético-Lógica (ALU)
--
-- Misión: Verificar sistemáticamente el comportamiento de la ALU.
-- Este testbench actúa como un "programa" que solo se ejecuta en el simulador.
-- No solo aplica estímulos, sino que comprueba los resultados y reporta fallos.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

ENTITY tb_alu IS
END tb_alu;

ARCHITECTURE behavior OF tb_alu IS 
 
    -- 1. Declaración del Componente Bajo Prueba (Unit Under Test - UUT)
    --    Es una copia exacta de la ENTITY de la ALU.
    COMPONENT alu
    PORT(
         A_in          : IN  std_logic_vector(7 downto 0);
         B_in          : IN  std_logic_vector(7 downto 0);
         Op_code       : IN  std_logic_vector(2 downto 0);
         Result_out    : OUT std_logic_vector(7 downto 0);
         Zero_flag_out : OUT std_logic
        );
    END COMPONENT;
    
   -- 2. Señales Internas ("Cables" del laboratorio virtual)
   --    Las usamos para conectar a los puertos de nuestro UUT.
   --    Las nombramos con un prefijo 's_' para distinguirlas de los puertos.
   signal s_A           : std_logic_vector(7 downto 0) := (others => '0');
   signal s_B           : std_logic_vector(7 downto 0) := (others => '0');
   signal s_Op_code     : std_logic_vector(2 downto 0) := (others => '0');
   signal s_Result_out  : std_logic_vector(7 downto 0);
   signal s_Zero_flag_out : std_logic;
 
BEGIN
 
	-- 3. Instanciación del UUT
    --    Aquí "ponemos el chip en la placa de pruebas" y conectamos los cables.
   uut: alu PORT MAP (
          A_in          => s_A,
          B_in          => s_B,
          Op_code       => s_Op_code,
          Result_out    => s_Result_out,
          Zero_flag_out => s_Zero_flag_out
        );

   -- 4. Proceso de Estímulo y Verificación
   --    Este es el guion de nuestra prueba. Se ejecuta secuencialmente una sola vez.
   stim_proc: process
   begin		
      report "--- Iniciando Testbench para ALU ---";

      -- Test 1: SUMA (10 + 5 = 15)
      report "Test 1: Probando SUMA (10 + 5)...";
      s_A <= x"0A"; -- 10 en hexadecimal
      s_B <= x"05"; -- 5 en hexadecimal
      s_Op_code <= "001"; -- Código de operación para SUMA
      wait for 10 ns; -- Esperar a que la lógica combinacional se estabilice
      assert (s_Result_out = x"0F") report "FALLO: SUMA incorrecta." severity error;
      assert (s_Zero_flag_out = '0') report "FALLO: Zero Flag debería ser 0." severity error;

      -- Test 2: RESTA (20 - 8 = 12)
      report "Test 2: Probando RESTA (20 - 8)...";
      s_A <= x"14"; -- 20 en hexadecimal
      s_B <= x"08"; -- 8 en hexadecimal
      s_Op_code <= "010"; -- Código de operación para RESTA
      wait for 10 ns;
      assert (s_Result_out = x"0C") report "FALLO: RESTA incorrecta." severity error;
      assert (s_Zero_flag_out = '0') report "FALLO: Zero Flag debería ser 0." severity error;

      -- Test 3: AND Lógico
      report "Test 3: Probando AND lógico...";
      s_A <= "11001010";
      s_B <= "10101010";
      s_Op_code <= "011"; -- Código de operación para AND
      wait for 10 ns;
      assert (s_Result_out = "10001010") report "FALLO: AND incorrecto." severity error;
      assert (s_Zero_flag_out = '0') report "FALLO: Zero Flag debería ser 0." severity error;

      -- Test 4: Prueba de la Bandera de Cero (Activación)
      report "Test 4: Probando activación de Zero Flag (15 - 15 = 0)...";
      s_A <= x"0F"; -- 15 en hexadecimal
      s_B <= x"0F"; -- 15 en hexadecimal
      s_Op_code <= "010"; -- RESTA
      wait for 10 ns;
      assert (s_Result_out = x"00") report "FALLO: El resultado no fue cero." severity error;
      assert (s_Zero_flag_out = '1') report "FALLO: Zero Flag no se activó." severity error;

      -- Test 5: Caso por defecto del Op_code
      report "Test 5: Probando Op_code no definido...";
      s_Op_code <= "000"; -- Este código no está asignado
      wait for 10 ns;
      assert (s_Result_out = x"00") report "FALLO: Caso por defecto incorrecto." severity error;
      assert (s_Zero_flag_out = '1') report "FALLO: Zero Flag debería ser 1 para resultado cero." severity error;

      report "--- Todos los tests de la ALU pasaron con éxito. ---";
      
      -- Detener la simulación para siempre
      wait;
   end process;

END;