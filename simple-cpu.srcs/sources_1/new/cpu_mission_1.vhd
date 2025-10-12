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

    -- 1. Declaración de Componentes (sin la RAM)
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

    -- 2. Declaraciones de la Unidad de Control (FSM)
    type T_FSM_STATE is (S_IDLE, S_FETCH_1, S_FETCH_2, S_DECODE, S_EXECUTE_ADD, S_EXECUTE_STORE);
    signal s_state : T_FSM_STATE := S_IDLE;

    -- 3. Señales de Control (Salidas de la FSM)
    signal s_mar_we, s_ir_we, s_acc_we, s_pc_inc, s_pc_jump, s_ram_we : std_logic;
    signal s_alu_opcode : std_logic_vector(2 downto 0);

    -- 4. Buses y Cables Internos (Datapath)
    signal s_pc_out, s_mar_out, s_ir_out, s_acc_out, s_alu_result : std_logic_vector(7 downto 0);
    signal s_zero_flag : std_logic;
    signal s_jump_address : std_logic_vector(7 downto 0);

begin

    -- Lógica combinacional para construir la dirección de salto
    s_jump_address <= "0000" & s_ir_out(3 downto 0);

    -- 5. Instanciación de Componentes (sin la RAM)
    PC_inst: program_counter PORT MAP (
        clk_in => clk_in, reset_in => reset_in, inc_enable_in => s_pc_inc,
        jump_enable_in => s_pc_jump, jump_address_in => s_jump_address,
        pc_out => s_pc_out
    );

    MAR_inst: generic_register PORT MAP (
        clk_in => clk_in, reset_in => reset_in, we_in => s_mar_we,
        D_in   => s_pc_out, Q_out => s_mar_out
    );

    IR_inst: generic_register PORT MAP (
        clk_in => clk_in, reset_in => reset_in, we_in => s_ir_we,
        D_in   => mem_data_in, Q_out => s_ir_out -- Conectado al puerto de entrada
    );

    ACC_inst: generic_register PORT MAP (
        clk_in => clk_in, reset_in => reset_in, we_in => s_acc_we,
        D_in   => s_alu_result, Q_out => s_acc_out
    );

    ALU_inst: alu PORT MAP (
        A_in          => s_acc_out, B_in => mem_data_in, Op_code => s_alu_opcode,
        Result_out    => s_alu_result, Zero_flag_out => s_zero_flag
    );

    -- 6. Conexiones a los Puertos de Memoria Externos
    mem_addr_out <= s_mar_out;
    mem_data_out <= s_acc_out;
    mem_we_out   <= s_ram_we;

    -- 7. Unidad de Control (FSM)
    state_transition_proc: process (clk_in, reset_in)
    begin
        if reset_in = '1' then
            s_state <= S_IDLE;
        elsif rising_edge(clk_in) then
            case s_state is
                when S_IDLE => s_state <= S_FETCH_1;
                when S_FETCH_1 => s_state <= S_FETCH_2;
                when S_FETCH_2 => s_state <= S_DECODE;
                when S_DECODE =>
                    case s_ir_out(7 downto 4) is
                        when "0001" => s_state <= S_EXECUTE_ADD;
                        when "0010" => s_state <= S_EXECUTE_STORE;
                        when others => s_state <= S_IDLE;
                    end case;
                when S_EXECUTE_ADD | S_EXECUTE_STORE => s_state <= S_IDLE;
                when others => s_state <= S_IDLE;
            end case;
        end if;
    end process;

    output_logic_proc: process (s_state)
    begin
        -- Valores por defecto
        s_mar_we <= '0'; s_ir_we <= '0'; s_pc_inc <= '0'; s_pc_jump <= '0';
        s_acc_we <= '0'; s_ram_we <= '0'; s_alu_opcode <= "000";

        case s_state is
            when S_FETCH_1 => s_mar_we <= '1';
            when S_FETCH_2 => s_ir_we <= '1'; s_pc_inc <= '1';
            when S_EXECUTE_ADD => s_alu_opcode <= "001"; s_acc_we <= '1';
            when S_EXECUTE_STORE => s_ram_we <= '1';
            when others => null;
        end case;
    end process;

end structural;