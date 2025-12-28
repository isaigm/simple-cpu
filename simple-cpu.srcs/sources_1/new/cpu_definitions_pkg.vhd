library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package cpu_definitions_pkg is

    -- Definimos el tipo de la memoria (Array de 256 bytes)
    type T_RAM is array (0 to 255) of std_logic_vector(7 downto 0);

    -- Función para inicializar la memoria con un programa
    function InitRam return T_RAM;

end package cpu_definitions_pkg;

package body cpu_definitions_pkg is

    function InitRam return T_RAM is
        variable ram : T_RAM := (others => (others => '0'));
    begin
        -- ============================================================
        -- PROGRAMA DE PRUEBA (Para la CPU corregida de 2 bytes)
        -- ============================================================
        
        -- Instrucción 1: ADD (Suma el valor de la dirección 10 al acumulador)
        -- Opcode ADD = "0001" (4 bits altos)
        ram(0) := "00010000"; -- Byte 1: Opcode ADD
        ram(1) := "00001010"; -- Byte 2: Dirección del dato (10 en decimal)

        -- Instrucción 2: ADD (Suma el valor de la dirección 11 al acumulador)
        ram(2) := "00010000"; -- Byte 1: Opcode ADD
        ram(3) := "00001011"; -- Byte 2: Dirección del dato (11 en decimal)

        -- Instrucción 3: STORE (Guarda el resultado en la dirección 12)
        -- Opcode STORE = "0010" (4 bits altos)
        ram(4) := "00100000"; -- Byte 1: Opcode STORE
        ram(5) := "00001100"; -- Byte 2: Dirección destino (12 en decimal)

        -- ============================================================
        -- DATOS
        -- ============================================================
        ram(10) := "00001010"; -- Dato A: 10
        ram(11) := "00001010"; -- Dato B: 10
        -- Resultado esperado en dirección 12: 20
        
        return ram;
    end function;

end package body cpu_definitions_pkg;