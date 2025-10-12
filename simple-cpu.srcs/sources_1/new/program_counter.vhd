library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity program_counter is
    Port ( clk_in           : in  std_logic;
           reset_in         : in  std_logic;
           inc_enable_in    : in  std_logic; -- NUEVO: Habilitar incremento
           jump_enable_in   : in  std_logic;
           jump_address_in  : in  std_logic_vector(7 downto 0);
           pc_out           : out std_logic_vector(7 downto 0)
         );
end program_counter;

architecture Behavioral of program_counter is
    signal s_pc_value : unsigned(7 downto 0) := (others => '0');
begin
    process (clk_in, reset_in)
    begin
        if reset_in = '1' then
            s_pc_value <= (others => '0');
        elsif rising_edge(clk_in) then
            if jump_enable_in = '1' then
                s_pc_value <= unsigned(jump_address_in);
            elsif inc_enable_in = '1' then -- CORRECCIÓN: Solo incrementa si se lo piden
                s_pc_value <= s_pc_value + 1;
            end if;
            -- Si ni jump ni inc están activos, mantiene su valor.
        end if;
    end process;
    pc_out <= std_logic_vector(s_pc_value);
end Behavioral;