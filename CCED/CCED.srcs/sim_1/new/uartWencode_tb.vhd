library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uartWencode_tb is
end uartWencode_tb;

architecture sim of uartWencode_tb is

    -- Component under test
    component uartWencode is
        port (
            CLK100MHZ     : in  STD_LOGIC;
            BTN0          : in  STD_LOGIC;
            SW            : in  STD_LOGIC_VECTOR (1 downto 0);
            UART_TXD_IN   : in  STD_LOGIC;
            UART_RXD_OUT  : out STD_LOGIC
        );
    end component;

    -- Signals for driving inputs and capturing outputs
    signal CLK100MHZ     : STD_LOGIC := '0';
    signal BTN0          : STD_LOGIC := '0';
    signal SW            : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal UART_TXD_IN   : STD_LOGIC := '1'; -- Idle line
    signal UART_RXD_OUT  : STD_LOGIC;

    -- Clock period constant
    constant clk_period : time := 10 ns;

begin

    -- Instantiate DUT
    DUT: uartWencode
        port map (
            CLK100MHZ     => CLK100MHZ,
            BTN0          => BTN0,
            SW            => SW,
            UART_TXD_IN   => UART_TXD_IN,
            UART_RXD_OUT  => UART_RXD_OUT
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            CLK100MHZ <= '0';
            wait for clk_period / 2;
            CLK100MHZ <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initial reset
        BTN0 <= '1';
        wait for 100 ns;
        BTN0 <= '0';
        wait for 100 ns;

        -- Set switch configuration
        SW <= "00";
        wait for 100 ns;

        -- Send 1st UART bytes
        UART_TXD_IN <= '1';
        wait for 208240 ns;
        
        UART_TXD_IN <= '0';
        wait for 104170 ns;
        UART_TXD_IN <= '1';
        wait for 104170 ns;
        UART_TXD_IN <= '0';
        wait for 104170 ns;
        UART_TXD_IN <= '1';
        wait for 104170 ns;

        UART_TXD_IN <= '0';
        wait for 104170 ns;
        UART_TXD_IN <= '1';
        wait for 104170 ns;
        UART_TXD_IN <= '0';
        wait for 104170 ns;
        UART_TXD_IN <= '1';
        wait for 104170 ns;


        -- Wait some time and finish
        wait for 5 ms;
        assert false report "Simulation complete." severity failure;
    end process;

end sim;
