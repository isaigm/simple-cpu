library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package cpu_definitions_pkg is

    
    type T_RAM is array (0 to 255) of std_logic_vector(7 downto 0);

end package cpu_definitions_pkg;