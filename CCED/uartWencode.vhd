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

    -- Custom signals
    signal txDataBuffer : std_logic_vector(7 downto 0) := (others => '0');
    signal encodeCount  : integer range 0 to 2 := 0;
    signal bitIndex     : integer range 0 to 7 := 0;

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
    component encoder_k3 is
        port (
            CLK            : in  std_logic;
            RST            : in  std_logic;
            data_in        : in  std_logic;
            in_enable      : in  std_logic;
            out_enable     : in  std_logic;
            constraint_sel : in  std_logic_vector(1 downto 0);
            encoded_out0   : out std_logic;
            encoded_out1   : out std_logic
        );
    end component;
    
    signal encoderEnableIt : std_logic_vector(3 downto 0);
--    signal encoderEnableIt : std_logic_vector(3 downto 0);
    
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
    Encoder : encoder_k3
    port map (
        CLK            => CLK100MHZ,
        RST            => BTN0,
        data_in        => sRxData(0),
        in_enable      => sRxDataRdy,
        out_enable     => sRxDataRdy,
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

        elsif rising_edge(CLK100MHZ) then
            sTxStart <= '0';  -- default low unless triggered

            -- When a new byte is received over UART
            if sRxDataRdy = '1' then
                -- Write 4 bits: original, encoded0, encoded1, zero
                txDataBuffer(bitIndex + 0) <= sRxData(0);
                txDataBuffer(bitIndex + 1) <= enOut_0;
                txDataBuffer(bitIndex + 2) <= enOut_1;
                txDataBuffer(bitIndex + 3) <= '0';

                bitIndex    <= bitIndex + 4;
                encodeCount <= encodeCount + 1;
            end if;

            -- When 2 sets of 4 bits have been written, transmit
            if encodeCount = 2 then
                sTxData     <= txDataBuffer;
                sTxStart    <= '1';            -- trigger UART transmit
                encodeCount <= 0;              -- reset for next frame
                bitIndex    <= 0;
            end if;
        end if;
    end process;
    
    process(sRxDataRdy)
    begin
        if rising_edge(sRxDataRdy) then
            while encoderEnableIt < "4" loop
            
            end loop;
        end if;
    
    end process;

end Behavioral;
