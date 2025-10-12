library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity multiplexor is
    Port ( A_in   : in  std_logic_vector(7 downto 0);
           B_in   : in  std_logic_vector(7 downto 0);
           sel_in : in  std_logic;
           Y_out  : out std_logic_vector(7 downto 0)
         );
end multiplexor;

architecture Behavioral of multiplexor is
begin

   Y_out <= A_in when sel_in = '0' else B_in;

end Behavioral;