library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu_mision_1 is
    Port ( 
        clk_in         : in  std_logic;
        reset_in       : in  std_logic;
        
        -- Bus de Memoria
        mem_addr_out   : out std_logic_vector(7 downto 0);
        mem_data_out   : out std_logic_vector(7 downto 0);
        mem_we_out     : out std_logic;
        mem_data_in    : in  std_logic_vector(7 downto 0)
    );
end cpu_mision_1;

architecture structural of cpu_mision_1 is

    -- Componentes
    component program_counter is
        Port ( clk_in : in std_logic; reset_in : in std_logic; inc_enable_in : in std_logic;
               jump_enable_in : in std_logic; jump_address_in : in std_logic_vector(7 downto 0);
               pc_out : out std_logic_vector(7 downto 0));
    end component;
    
    component generic_register
        Port ( clk_in : in std_logic; reset_in : in std_logic; we_in : in std_logic;
               D_in : in std_logic_vector(7 downto 0); Q_out : out std_logic_vector(7 downto 0));
    end component;

    component alu
        Port ( A_in : in std_logic_vector(7 downto 0); B_in : in std_logic_vector(7 downto 0);
               Op_code : in std_logic_vector(2 downto 0); Result_out : out std_logic_vector(7 downto 0);
               Zero_flag_out : out std_logic);
    end component;

    -- Estados de la FSM (Añadidos estados para buscar operandos)
    type T_FSM_STATE is (
        S_RESET, 
        S_FETCH_INSTR_ADDR, -- Poner PC en MAR
        S_FETCH_INSTR_DATA, -- Leer Opcode -> IR, PC++
        S_DECODE,           -- Decodificar
        S_FETCH_OP_ADDR,    -- Poner PC en MAR (para leer el byte de dirección)
        S_FETCH_OP_DATA,    -- Leer Dirección -> MAR, PC++ (Ahora MAR apunta al dato)
        S_EXECUTE_ADD,      -- Sumar dato en memoria al ACC
        S_EXECUTE_STORE     -- Guardar ACC en memoria
    );
    signal s_state : T_FSM_STATE := S_RESET;

    -- Señales de Control
    signal s_mar_we, s_ir_we, s_acc_we, s_pc_inc, s_pc_jump, s_ram_we : std_logic;
    signal s_mar_src_sel : std_logic; -- 0: PC, 1: Memoria (Nuevo selector)
    signal s_alu_opcode : std_logic_vector(2 downto 0);

    -- Buses Internos
    signal s_pc_out, s_mar_out, s_ir_out, s_acc_out, s_alu_result : std_logic_vector(7 downto 0);
    signal s_mar_in : std_logic_vector(7 downto 0); -- Entrada multiplexada del MAR
    signal s_zero_flag : std_logic;
    signal s_jump_address : std_logic_vector(7 downto 0);

begin

    -- ========================================================================
    -- 1. DATAPATH
    -- ========================================================================

    -- Lógica de Salto (Simple: 4 bits bajos del IR)
    s_jump_address <= "0000" & s_ir_out(3 downto 0);

    -- MUX para la entrada del MAR (CORRECCIÓN CRÍTICA)
    -- Si sel=0, carga el PC (para buscar instrucción).
    -- Si sel=1, carga el dato de memoria (para usarlo como puntero/dirección).
    s_mar_in <= s_pc_out when s_mar_src_sel = '0' else mem_data_in;

    PC_inst: program_counter PORT MAP (
        clk_in => clk_in, reset_in => reset_in, inc_enable_in => s_pc_inc,
        jump_enable_in => s_pc_jump, jump_address_in => s_jump_address,
        pc_out => s_pc_out
    );

    MAR_inst: generic_register PORT MAP (
        clk_in => clk_in, reset_in => reset_in, we_in => s_mar_we,
        D_in   => s_mar_in, -- Conectado al MUX
        Q_out  => s_mar_out
    );

    IR_inst: generic_register PORT MAP (
        clk_in => clk_in, reset_in => reset_in, we_in => s_ir_we,
        D_in   => mem_data_in, Q_out => s_ir_out
    );

    ACC_inst: generic_register PORT MAP (
        clk_in => clk_in, reset_in => reset_in, we_in => s_acc_we,
        D_in   => s_alu_result, Q_out => s_acc_out
    );

    ALU_inst: alu PORT MAP (
        A_in          => s_acc_out, B_in => mem_data_in, Op_code => s_alu_opcode,
        Result_out    => s_alu_result, Zero_flag_out => s_zero_flag
    );

    -- Salidas al exterior
    mem_addr_out <= s_mar_out;
    mem_data_out <= s_acc_out; -- Para STORE
    mem_we_out   <= s_ram_we;

    -- ========================================================================
    -- 2. UNIDAD DE CONTROL (FSM)
    -- ========================================================================
    
    state_transition_proc: process (clk_in, reset_in)
    begin
        if reset_in = '1' then
            s_state <= S_RESET;
        elsif rising_edge(clk_in) then
            case s_state is
                when S_RESET => s_state <= S_FETCH_INSTR_ADDR;
                
                -- Ciclo de Búsqueda de Instrucción (Fetch)
                when S_FETCH_INSTR_ADDR => s_state <= S_FETCH_INSTR_DATA;
                when S_FETCH_INSTR_DATA => s_state <= S_DECODE;
                
                -- Decodificación
                when S_DECODE =>
                    case s_ir_out(7 downto 4) is -- Miramos los 4 bits altos (Opcode)
                        when "0001" => s_state <= S_FETCH_OP_ADDR; -- ADD (requiere operando)
                        when "0010" => s_state <= S_FETCH_OP_ADDR; -- STORE (requiere operando)
                        -- Aquí podrías añadir un JUMP directo sin operando extra
                        when others => s_state <= S_FETCH_INSTR_ADDR; -- NOP o error
                    end case;

                -- Ciclo de Búsqueda de Operando (Dirección de memoria)
                when S_FETCH_OP_ADDR => s_state <= S_FETCH_OP_DATA;
                
                when S_FETCH_OP_DATA => 
                    -- Ahora el MAR tiene la dirección del dato. Vamos a ejecutar.
                    if s_ir_out(7 downto 4) = "0001" then
                        s_state <= S_EXECUTE_ADD;
                    elsif s_ir_out(7 downto 4) = "0010" then
                        s_state <= S_EXECUTE_STORE;
                    else
                        s_state <= S_FETCH_INSTR_ADDR;
                    end if;

                -- Ejecución
                when S_EXECUTE_ADD   => s_state <= S_FETCH_INSTR_ADDR;
                when S_EXECUTE_STORE => s_state <= S_FETCH_INSTR_ADDR;
                
                when others => s_state <= S_RESET;
            end case;
        end if;
    end process;

    output_logic_proc: process (s_state)
    begin
        -- Valores por defecto (evita latches inferidos)
        s_mar_we <= '0'; s_ir_we <= '0'; s_acc_we <= '0'; s_ram_we <= '0';
        s_pc_inc <= '0'; s_pc_jump <= '0'; 
        s_mar_src_sel <= '0'; -- Por defecto MAR toma PC
        s_alu_opcode <= "000";

        case s_state is
            -- 1. Poner PC en MAR
            when S_FETCH_INSTR_ADDR => 
                s_mar_src_sel <= '0'; -- Fuente: PC
                s_mar_we <= '1';

            -- 2. Leer Memoria -> IR, Incrementar PC
            when S_FETCH_INSTR_DATA => 
                s_ir_we <= '1'; 
                s_pc_inc <= '1';

            -- 3. Decodificar (sin salidas activas)
            when S_DECODE => null;

            -- 4. Preparar para leer el 2do byte (Dirección del dato)
            when S_FETCH_OP_ADDR =>
                s_mar_src_sel <= '0'; -- Fuente: PC (que ahora apunta al 2do byte)
                s_mar_we <= '1';

            -- 5. Leer la dirección desde memoria y cargarla DIRECTAMENTE al MAR
            when S_FETCH_OP_DATA =>
                s_mar_src_sel <= '1'; -- Fuente: Memoria (CORRECCIÓN CLAVE)
                s_mar_we <= '1';      -- Cargamos la dirección leída en el MAR
                s_pc_inc <= '1';      -- Saltamos este byte de dirección para la próxima instrucción

            -- 6. Ejecutar ADD: Sumar lo que hay en memoria (apuntado por MAR) al ACC
            when S_EXECUTE_ADD =>
                s_alu_opcode <= "001"; -- Asumiendo "001" es ADD en tu ALU
                s_acc_we <= '1';

            -- 7. Ejecutar STORE: Escribir ACC en memoria (apuntada por MAR)
            when S_EXECUTE_STORE =>
                s_ram_we <= '1';

            when others => null;
        end case;
    end process;

end structural;