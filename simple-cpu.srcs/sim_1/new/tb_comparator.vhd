LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_comparator IS
END tb_comparator;

ARCHITECTURE behavior OF tb_comparator IS

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT comparator
    PORT(
         A       : IN  std_logic_vector(7 downto 0);
         B       : IN  std_logic_vector(7 downto 0);
         EQ      : OUT std_logic;
         GREATER : OUT std_logic;
         LESS    : OUT std_logic
        );
    END COMPONENT;

   -- Inputs
   signal A : std_logic_vector(7 downto 0) := (others => '0');
   signal B : std_logic_vector(7 downto 0) := (others => '0');

   -- Outputs (local signals in the testbench)
   signal eq      : std_logic := '0';
   signal greater : std_logic := '0';
   signal less    : std_logic := '0';

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: comparator PORT MAP (
          A       => A,
          B       => B,
          EQ      => eq,
          GREATER => greater,
          LESS    => less
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Case: A < B
        A <= "00000000";
        B <= "11111111";
        wait for 100 ns;

        -- Case: A > B
        A <= "00111111";
        B <= "00011111";
        wait for 100 ns;

        -- Case: A = B
        A <= "00111111";
        B <= "00111111";
        wait for 100 ns;

        -- Case: A > B (max vs min)
        A <= "11111111";
        B <= "00000000";
        wait for 100 ns;

        wait; -- end of test vectors
    end process;

END behavior;
