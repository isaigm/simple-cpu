library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity generic_register is
    Port ( clk_in   : in  std_logic;
           reset_in : in  std_logic;
           we_in    : in  std_logic;
           D_in     : in  std_logic_vector(7 downto 0);
           Q_out    : out std_logic_vector(7 downto 0)
         );
end generic_register;

architecture Behavioral of generic_register is
    signal s_internal_value : std_logic_vector(7 downto 0) := (others => '0');
begin

    -- 8 bit flip-flop with asynchronous reset.
    process (clk_in, reset_in)
    begin
        -- Maximum priority: Asynchronous Reset
        if reset_in = '1' then
            s_internal_value <= (others => '0');
        
        elsif rising_edge(clk_in) then
            
            if we_in = '1' then
                s_internal_value <= D_in;
            end if;
            
        end if;
    end process;
    Q_out <= s_internal_value;
end Behavioral;