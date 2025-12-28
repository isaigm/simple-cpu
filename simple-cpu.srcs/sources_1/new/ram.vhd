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
    -- MODIFICACIÓN: Inicializamos la señal usando la función del paquete
    signal s_ram_content : T_RAM := InitRam; 
begin
    -- (El resto de tu código igual: procesos de lectura y escritura)
    write_proc: process (clk_in)
    begin
        if rising_edge(clk_in) then
            if we_in = '1' then
                s_ram_content(to_integer(unsigned(addr_in))) <= data_in;
            end if;
        end if;
    end process;

    data_out <= s_ram_content(to_integer(unsigned(addr_in)));
end Behavioral;