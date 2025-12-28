library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cpu_definitions_pkg.all; -- Usamos el paquete

entity tb_cpu_system is
end tb_cpu_system;

architecture behavior of tb_cpu_system is

    -- Declaración de la CPU
    component cpu_mision_1 is
        Port ( 
            clk_in         : in  std_logic;
            reset_in       : in  std_logic;
            mem_addr_out   : out std_logic_vector(7 downto 0);
            mem_data_out   : out std_logic_vector(7 downto 0);
            mem_we_out     : out std_logic;
            mem_data_in    : in  std_logic_vector(7 downto 0)
        );
    end component;

    -- Declaración de TU RAM
    component ram is
        Port ( 
            clk_in   : in  std_logic;
            we_in    : in  std_logic;
            addr_in  : in  std_logic_vector(7 downto 0);
            data_in  : in  std_logic_vector(7 downto 0);
            data_out : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Señales internas
    signal s_clk   : std_logic := '0';
    signal s_reset : std_logic := '1';

    -- Cables entre CPU y RAM
    signal s_bus_addr : std_logic_vector(7 downto 0);
    signal s_bus_data_cpu_to_ram : std_logic_vector(7 downto 0);
    signal s_bus_data_ram_to_cpu : std_logic_vector(7 downto 0);
    signal s_bus_we : std_logic;

    constant T_CLK : time := 20 ns;

begin

    -- 1. Instanciar CPU
    inst_cpu: cpu_mision_1 PORT MAP (
        clk_in       => s_clk,
        reset_in     => s_reset,
        mem_addr_out => s_bus_addr,          -- Dirección sale de CPU
        mem_data_out => s_bus_data_cpu_to_ram, -- Datos salen de CPU (para Store)
        mem_we_out   => s_bus_we,            -- Control de escritura sale de CPU
        mem_data_in  => s_bus_data_ram_to_cpu  -- Datos entran a CPU (Lectura)
    );

    -- 2. Instanciar RAM
    inst_ram: ram PORT MAP (
        clk_in   => s_clk,
        we_in    => s_bus_we,            -- Conectado al WE de la CPU
        addr_in  => s_bus_addr,          -- Conectado al bus de direcciones
        data_in  => s_bus_data_cpu_to_ram, -- Entrada de datos (desde CPU)
        data_out => s_bus_data_ram_to_cpu  -- Salida de datos (hacia CPU)
    );

    -- 3. Generador de Reloj
    process
    begin
        s_clk <= '0';
        wait for T_CLK/2;
        s_clk <= '1';
        wait for T_CLK/2;
    end process;

    -- 4. Proceso de simulación
    process
    begin
        report "Iniciando simulación...";
        
        -- Reset inicial
        s_reset <= '1';
        wait for T_CLK * 2;
        
        -- Soltar reset
        s_reset <= '0';
        report "Reset liberado. CPU ejecutando...";

        -- Dejar correr la simulación suficiente tiempo
        -- El programa de ejemplo toma unos 20-30 ciclos de reloj
        wait for T_CLK * 100;

        report "Fin de la simulación.";
        wait;
    end process;

end behavior;