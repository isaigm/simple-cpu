library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_definitions_pkg.all; -- ¡AÑADIR ESTA LÍNEA!

entity ram is
    Port ( clk_in   : in  std_logic;
           we_in    : in  std_logic; -- Write Enable
           addr_in  : in  std_logic_vector(7 downto 0);
           data_in  : in  std_logic_vector(7 downto 0);
           data_out : out std_logic_vector(7 downto 0)
         );
end ram;

architecture Behavioral of ram is

    -- 1. Definir el tipo de dato para nuestra memoria.
    --    Es un array de 256 elementos, donde cada elemento es un vector de 8 bits.
    
    -- 2. Crear la señal de memoria usando nuestro nuevo tipo.
    --    Esta señal SÍ se sintetizará a bloques de memoria (BRAM) en el FPGA.
    signal s_ram_content : T_RAM;

begin

    -- PROCESO 1: Lógica de Escritura (Síncrona)
    -- Solo escribimos en el flanco de subida del reloj si nos dan permiso.
    write_proc: process (clk_in)
    begin
        if rising_edge(clk_in) then
            if we_in = '1' then
                -- La dirección se convierte a entero para usarla como índice del array.
                s_ram_content(to_integer(unsigned(addr_in))) <= data_in;
            end if;
        end if;
    end process;

    -- PROCESO 2: Lógica de Lectura (Asíncrona / Combinacional)
    -- La lectura es simplemente una asignación concurrente.
    -- El dato de la dirección seleccionada está disponible en la salida inmediatamente.
    data_out <= s_ram_content(to_integer(unsigned(addr_in)));

end Behavioral;