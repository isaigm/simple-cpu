library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_cpu_mission_1 is
end tb_cpu_mission_1;

architecture behavior of tb_cpu_mission_1 is

    ------------------------------------------------------------------------
    -- 1. Component Declarations (CPU and RAM)
    ------------------------------------------------------------------------
    component cpu_mision_1 is
        Port (
            clk_in       : in  std_logic,
            reset_in     : in  std_logic,
            mem_data_in  : in  std_logic_vector(7 downto 0),
            mem_addr_out : out std_logic_vector(7 downto 0),
            mem_data_out : out std_logic_vector(7 downto 0),
            mem_we_out   : out std_logic
        );
    end component;

    component ram is
        Port (
            clk_in   : in  std_logic,
            we_in    : in  std_logic,
            addr_in  : in  std_logic_vector(7 downto 0),
            data_in  : in  std_logic_vector(7 downto 0),
            data_out : out std_logic_vector(7 downto 0)
        );
    end component;

    ------------------------------------------------------------------------
    -- 2. Testbench signals
    ------------------------------------------------------------------------
    signal s_clk   : std_logic := '0';
    signal s_reset : std_logic := '1';

    -- Signals driven by the CPU (to memory)
    signal s_cpu_addr_out : std_logic_vector(7 downto 0);
    signal s_cpu_data_out : std_logic_vector(7 downto 0);
    signal s_cpu_we       : std_logic;

    -- Testbench pre-load signals (TB drives RAM while overriding CPU)
    signal s_tb_addr_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal s_tb_data_in  : std_logic_vector(7 downto 0) := (others => '0');
    signal s_tb_we_in    : std_logic := '0';
    signal s_tb_override : std_logic := '1'; -- '1' = testbench controls the bus

    -- Signals that go to the RAM (output of the arbiter / mux)
    signal s_ram_addr_in  : std_logic_vector(7 downto 0);
    signal s_ram_data_in  : std_logic_vector(7 downto 0);
    signal s_ram_we_in    : std_logic;
    signal s_ram_data_out : std_logic_vector(7 downto 0);

    constant T_CLK: time := 20 ns;

begin

    ------------------------------------------------------------------------
    -- 3. Instantiate DUTs (CPU and RAM)
    ------------------------------------------------------------------------
    CPU_UUT: cpu_mision_1
        PORT MAP (
            clk_in       => s_clk,
            reset_in     => s_reset,
            mem_addr_out => s_cpu_addr_out,
            mem_data_out => s_cpu_data_out,
            mem_we_out   => s_cpu_we,
            mem_data_in  => s_ram_data_out
        );

    RAM_UUT: ram
        PORT MAP (
            clk_in   => s_clk,
            we_in    => s_ram_we_in,
            addr_in  => s_ram_addr_in,
            data_in  => s_ram_data_in,
            data_out => s_ram_data_out
        );

    ------------------------------------------------------------------------
    -- 4. Arbiter (multiplexer resolving bus conflict)
    -- If the testbench has control, RAM listens to the testbench; otherwise, to CPU.
    ------------------------------------------------------------------------
    s_ram_addr_in <= s_tb_addr_in  when s_tb_override = '1' else s_cpu_addr_out;
    s_ram_data_in <= s_tb_data_in  when s_tb_override = '1' else s_cpu_data_out;
    s_ram_we_in   <= s_tb_we_in    when s_tb_override = '1' else s_cpu_we;

    ------------------------------------------------------------------------
    -- 5. Clock generator
    ------------------------------------------------------------------------
    clk_gen_proc: process
    begin
        wait for T_CLK / 2;
        s_clk <= not s_clk;
    end process;

    ------------------------------------------------------------------------
    -- 6. Stimulus process
    ------------------------------------------------------------------------
    stim_proc: process
        -- Constrain the procedure arguments to 8-bit vectors
        procedure write_ram(
            addr : in std_logic_vector(7 downto 0);
            data : in std_logic_vector(7 downto 0)
        ) is
        begin
            s_tb_addr_in <= addr;
            s_tb_data_in <= data;
            s_tb_we_in   <= '1';
            -- apply at a rising edge so RAM samples on the clock
            wait until rising_edge(s_clk);
            s_tb_we_in   <= '0';
            -- keep values driven for one cycle (optional)
            wait until rising_edge(s_clk);
            s_tb_addr_in <= (others => '0');
            s_tb_data_in <= (others => '0');
        end procedure;
    begin
        report "--- Starting CPU system testbench ---";

        -- 1) PRELOAD RAM (testbench controls the bus: s_tb_override = '1')
        report "Loading program/data into RAM...";
        -- Example program/data (you can replace with your opcodes/data):
        -- Program idea in comments: ACC = 10, STORE [15], ACC = 5, ADD [15], STORE [16]
        -- For now we preload a simple instruction and data for read verification.
        write_ram(x"00", "00011010"); -- example instruction (binary literal)
        write_ram(x"0A", x"19");      -- data 0x19 (25) at address 0x0A

        -- Allow bus settles
        wait for T_CLK;

        -- 2) Give control to the CPU and start execution
        report "Releasing bus to CPU and deasserting reset...";
        s_tb_override <= '0'; -- CPU now controls the bus
        s_reset       <= '0'; -- release reset (assuming active-high reset)

        -- Let the CPU run for some cycles
        wait for 100 * T_CLK;

        report "--- Simulation finished. Inspect waveforms. ---";
        wait; -- stop simulation here
    end process;

end behavior;
