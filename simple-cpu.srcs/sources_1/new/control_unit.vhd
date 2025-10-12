library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    Port ( clk_in   : in  std_logic;
           reset_in : in  std_logic;
           
           -- Salidas de Control (nuestros "botones" para los otros componentes)
           mar_we_out : out std_logic; -- 'we' para el MAR
           ir_we_out  : out std_logic; -- 'we' para el IR
           pc_inc_out : out std_logic  -- Señal para decirle al PC que incremente
           -- ... aquí irán muchas más señales después
         );
end control_unit;

architecture Behavioral of control_unit is

    -- 1. Definir los estados con nombres descriptivos.
    type T_FSM_STATE is (
        S_IDLE,                 -- Estado de reposo / reset
        S_PC_TO_MAR,            -- Mover la dirección del PC al MAR
        S_MEM_TO_IR_AND_INC_PC, -- Cargar IR desde memoria, Incrementar PC
        S_DECODE                -- Decodificar la instrucción en el IR
    );
    
    -- 2. La señal de estado empieza en IDLE.
    signal s_state : T_FSM_STATE := S_IDLE;

begin

    -- PROCESO 1: Lógica de Transición de Estados (Síncrono)
    state_transition_proc: process (clk_in, reset_in)
    begin
        if reset_in = '1' then
            s_state <= S_IDLE;
        elsif rising_edge(clk_in) then
            case s_state is
                when S_IDLE =>
                    s_state <= S_PC_TO_MAR; -- Empezar el ciclo de búsqueda
                
                when S_PC_TO_MAR =>
                    s_state <= S_MEM_TO_IR_AND_INC_PC;
                
                when S_MEM_TO_IR_AND_INC_PC =>
                    s_state <= S_DECODE;
                
                when S_DECODE =>
                    -- Aquí iría la lógica para saltar al estado de ejecución correcto
                    s_state <= S_IDLE; -- Por ahora, volvemos al inicio
                
                when others =>
                    s_state <= S_IDLE;
            end case;
        end if;
    end process;

    -- PROCESO 2: Lógica de Salida (Combinacional)
    output_logic_proc: process (s_state)
    begin
        -- Por defecto, todas las señales de control están APAGADAS.
        mar_we_out <= '0';
        ir_we_out  <= '0';
        pc_inc_out <= '0';

        case s_state is
            when S_PC_TO_MAR =>
                -- Misión: Cargar el MAR con la dirección del PC.
                mar_we_out <= '1';
                
            when S_MEM_TO_IR_AND_INC_PC =>
                -- Misión: Cargar el IR e incrementar el PC.
                ir_we_out  <= '1';
                pc_inc_out <= '1';
                
            when others =>
                -- No activamos ninguna señal de control en estos estados.
                null;
        end case;
    end process;

end Behavioral;

