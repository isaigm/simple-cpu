library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Port ( A_in           : in  std_logic_vector(7 downto 0);
           B_in           : in  std_logic_vector(7 downto 0);
           Op_code        : in  std_logic_vector(2 downto 0); -- 3 bits = 8 operaciones
           Result_out     : out std_logic_vector(7 downto 0);
           Zero_flag_out  : out std_logic
         );
end alu;

architecture Behavioral of alu is
begin

    process (A_in, B_in, Op_code)
        variable A_uns      : unsigned(7 downto 0);
        variable B_uns      : unsigned(7 downto 0);
        variable Result_var : unsigned(7 downto 0);
    begin
        -- 1. Convertir entradas a tipo numérico
        A_uns := unsigned(A_in);
        B_uns := unsigned(B_in);

        -- 2. Lógica principal usando una sentencia 'case'
        case Op_code is
            -- Operaciones Aritméticas
            when "001" => -- SUMA
                Result_var := A_uns + B_uns;
            when "010" => -- RESTA
                Result_var := A_uns - B_uns;
            
            -- Operaciones Lógicas
            when "011" => -- AND
                -- Nota: Para operaciones lógicas, es mejor volver a los std_logic_vector
                Result_var := unsigned(A_in and B_in);
            when "100" => -- OR
                Result_var := unsigned(A_in or B_in);
            when "101" => -- XOR
                Result_var := unsigned(A_in xor B_in);

            -- Operaciones de Transferencia (útiles para cargar registros)
            when "110" => -- Pasar A directamente
                Result_var := A_uns;
            when "111" => -- Pasar B directamente
                Result_var := B_uns;

            -- Caso por defecto
            when others =>
                Result_var := (others => '0');
        end case;

        -- 3. Asignar el resultado a la salida
        Result_out <= std_logic_vector(Result_var);

        -- 4. Calcular la bandera de cero
        if Result_var = 0 then -- NUMERIC_STD permite comparar directamente con un entero
            Zero_flag_out <= '1';
        else
            Zero_flag_out <= '0';
        end if;

    end process;

end Behavioral;