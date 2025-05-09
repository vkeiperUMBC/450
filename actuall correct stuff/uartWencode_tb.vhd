library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uartWencode_tb is
-- Testbench doesn't have ports
end uartWencode_tb;

architecture Behavioral of uartWencode_tb is
    -- Component declaration for the Unit Under Test (UUT)
    component uartWencode is
        Port (
            CLK100MHZ     : in  STD_LOGIC;
            BTN0          : in  STD_LOGIC;
            SW            : in  STD_LOGIC_VECTOR (1 downto 0);
            UART_TXD_IN   : in  STD_LOGIC;
            UART_RXD_OUT  : out STD_LOGIC
        );
    end component;

    -- Clock period definitions
    constant CLK_PERIOD : time := 10 ns; -- 100 MHz clock

    -- UART baud rate timing
    constant BIT_PERIOD : time := 104167 ns; -- For 115200 baud rate

    -- Inputs
    signal clk          : std_logic := '0';
    signal reset        : std_logic := '0';
    signal switches     : std_logic_vector(1 downto 0) := "00";
    signal uart_tx_in   : std_logic := '1'; -- Idle high for UART

    -- Outputs
    signal uart_rx_out  : std_logic;

    -- Test signals
    signal sim_done     : boolean := false;

    -- Procedure to send one byte via UART
    procedure uart_send_byte (
        data : in std_logic_vector(7 downto 0);
        signal tx_line : out std_logic) is
    begin
        -- Start bit (low)
        tx_line <= '0';
        wait for BIT_PERIOD;

        -- Data bits (LSB first)
        for i in 0 to 7 loop
            tx_line <= data(i);
            wait for BIT_PERIOD;
        end loop;

        -- Stop bit (high)
        tx_line <= '1';
        wait for BIT_PERIOD;
    end procedure;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: uartWencode
    port map (
        CLK100MHZ    => clk,
        BTN0         => reset,
        SW           => switches,
        UART_TXD_IN  => uart_tx_in,
        UART_RXD_OUT => uart_rx_out
    );

    -- Clock process
    clk_process: process
    begin
        while not sim_done loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stim_proc: process
        variable rx_data : std_logic_vector(7 downto 0);
    begin
        -- Initialize inputs
        reset <= '1';
        uart_tx_in <= '1';  -- UART idle state is high
        switches <= "00";   -- Start with constraint_sel = 00 (K=3 polynomial)

        -- Reset for a few clock cycles
        wait for 10000 ns;
        reset <= '0';
        wait for 10000 ns;

        -- Test case 1: Send '1' with K=3 constraint (00)
        report "Test case 1: K=3 constraint (00), sending '1'";
        uart_send_byte(x"01", uart_tx_in); -- Send byte with LSB = '1'
        wait for 10 * BIT_PERIOD;
        uart_send_byte(x"00", uart_tx_in); -- Send byte with LSB = '1'

        -- Wait for the encoding process and response

        -- End simulation
        report "Simulation complete";
        wait for 20 * BIT_PERIOD;
        sim_done <= true;
        wait;
    end process;

    baud_clock: process
        constant bit_period : time := 104.167 us;  -- for 9600 baud
        variable temp : std_logic := '0';
    begin
        while sim_done = false loop
            temp := not temp;
            wait for bit_period;
        end loop;
    end process;
--    -- Monitor process to observe UART output
--    monitor_proc: process
--        variable received_byte : std_logic_vector(7 downto 0);
--    begin
--        wait for 200 ns; -- Initial wait after reset

--        while not sim_done loop
--            -- Try to receive a byte (will wait for start bit)
--            if uart_rx_out = '1' then
--                wait until uart_rx_out = '0' for 10 * BIT_PERIOD;
--                if uart_rx_out = '0' then -- Start bit detected
--                    -- Back up to the start of the start bit
--                    wait for BIT_PERIOD/2;

--                    -- Receive the data bits
--                    for i in 0 to 7 loop
--                        wait for BIT_PERIOD;
--                        received_byte(i) := uart_rx_out;
--                    end loop;

--                    -- Wait for stop bit
--                    wait for BIT_PERIOD;

--                    -- Display the received byte
--                    report "Received byte: 0x" & to_hstring(unsigned(received_byte)) & 
--                           " (binary: " & to_string(received_byte) & ")";

--                    -- Analyze the encoding results
--                    report "Original bit: " & std_logic'image(received_byte(0)) & 
--                           ", Encoded bit 0: " & std_logic'image(received_byte(1)) & 
--                           ", Encoded bit 1: " & std_logic'image(received_byte(2));

--                    if received_byte(3) /= '0' then
--                        report "Warning: The padding bit is not 0 as expected" severity warning;
--                    end if;

--                    if received_byte(7 downto 4) /= "0000" then
--                        report "Second nibble values - Original: " & std_logic'image(received_byte(4)) & 
--                               ", Encoded 0: " & std_logic'image(received_byte(5)) & 
--                               ", Encoded 1: " & std_logic'image(received_byte(6));
--                    end if;
--                end if;
--            else
--                wait for BIT_PERIOD;
--            end if;
--        end loop;
--        wait;
--    end process;

end Behavioral;
