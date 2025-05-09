library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uartWencode is
    Port (
        CLK100MHZ     : in  STD_LOGIC;
        BTN0          : in  STD_LOGIC;
        SW            : in  STD_LOGIC_VECTOR (1 downto 0);
        UART_TXD_IN   : in  STD_LOGIC;
        UART_RXD_OUT  : out STD_LOGIC
    );
end uartWencode;

architecture Behavioral of uartWencode is

    -- UART signals
    signal sTxData      : std_logic_vector(7 downto 0) := (others => '0');
    signal sRxData      : std_logic_vector(7 downto 0);
    signal sTxBusy      : std_logic;
    signal sRxDataRdy   : std_logic;
    signal sTxStart     : std_logic := '0';

    -- Encoder outputs
    signal enOut_0      : std_logic;
    signal enOut_1      : std_logic;
    signal sEncoderIn   : std_logic := '0';

    -- Custom signals
    signal txDataBuffer : std_logic_vector(7 downto 0) := (others => '0');
    signal encodeCount  : integer range 0 to 2 := 0;
    signal bitIndex     : integer range 0 to 7 := 0;
    signal encdDone     : std_logic := '0';
    signal nbblIndx     : std_logic := '0';
    signal recCheck     : std_logic := '0';
    signal enCheck      : std_logic := '0';
    signal encdDone_r   : std_logic := '0'; -- registered version of encdDone
    signal latchReady   : std_logic := '0'; -- flag to delay latching one clock

    -- UART component
    component UART is 
        port (
            CLK          : in  std_logic;
            RST          : in  std_logic;
            UART_TXD_IN  : in  std_logic;
            TxStart      : in  std_logic;
            TxData       : in  std_logic_vector(7 downto 0);
            RxDataRdy    : out std_logic;
            RxData       : out std_logic_vector(7 downto 0);
            TxBusy       : out std_logic;
            UART_RXD_OUT : out std_logic
        );
    end component;

    -- Encoder component
    component encoder is
        port (
            CLK            : in  std_logic;
            RST            : in  std_logic;
            data_in        : in  std_logic;
            in_enable      : in  std_logic;
            out_enable     : out  std_logic;
            constraint_sel : in  std_logic_vector(1 downto 0);
            encoded_out0   : out std_logic;
            encoded_out1   : out std_logic
        );
    end component;

begin

    -- UART instance
    TransmitReceive : UART
    port map (
        CLK          => CLK100MHZ,
        RST          => BTN0,
        UART_TXD_IN  => UART_TXD_IN,
        TxStart      => sTxStart,
        TxData       => sTxData,
        RxDataRdy    => sRxDataRdy,
        RxData       => sRxData,
        TxBusy       => sTxBusy,
        UART_RXD_OUT => UART_RXD_OUT
    );

    -- Encoder instance
    Encoder0 : encoder
    port map (
        clk            => CLK100MHZ,
        rst            => BTN0,
        data_in        => sRxData(0),
        in_enable      => sRxDataRdy,
        out_enable     => encdDone,
        constraint_sel => SW,
        encoded_out0   => enOut_0,
        encoded_out1   => enOut_1
    );

    -- Encode + transmit process
    process(CLK100MHZ, BTN0)
    begin
        if BTN0 = '1' then
            txDataBuffer <= (others => '0');
            sTxData      <= (others => '0');
            sTxStart     <= '0';
            encodeCount  <= 0;
            bitIndex     <= 0;
            recCheck     <= '0';
            enCheck      <= '0';
            encdDone_r   <= '0';
            latchReady   <= '0';

        elsif falling_edge(CLK100MHZ) then
            sTxStart <= '0';  -- default low unless triggered
    
            txDataBuffer(3) <= '0';

            -- Register encdDone
            encdDone_r <= encdDone;

            -- When a new byte is received over UART
            if sRxDataRdy = '1' then
                txDataBuffer(0) <= sRxData(0);
                recCheck <= '1';
            end if;
            
            -- Detect rising edge of encdDone
            if encdDone = '1' and encdDone_r = '0' then
                latchReady <= '1';  -- set flag to latch next cycle
            end if;
            
            -- Latch outputs one cycle after encdDone rises
            if latchReady = '1' then
                latchReady <= '0'; -- clear flag after latching
                txDataBuffer(1) <= enOut_0;
                txDataBuffer(2) <= enOut_1;
                enCheck <= '1';
            end if;
            
            -- Transmit if both reception and encoding done
            if recCheck = '1' and enCheck = '1' then
                recCheck <= '0';
                enCheck <= '0';
                sTxStart <= '1';
            end if; 
        end if;
    end process;

end Behavioral;
