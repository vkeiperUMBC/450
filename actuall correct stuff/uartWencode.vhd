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
    signal recCheck     : std_logic := '0';
    signal enCheck      : std_logic := '0';
    signal decdIn       : std_logic_vector(13 downto 0);
    signal decdOut      : std_logic_vector(6 downto 0);
    signal dcSz         : std_logic_vector(2 downto 0);
    signal dcDone       : std_logic;

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
    
    component decoder is
    port(
        rstring     : in std_logic_vector(13 downto 0);
        CLK         : in std_logic;
        RST         : in std_logic;
        size        : in std_logic_vector(2 downto 0);
        dstring     : out std_logic_vector(6 downto 0);
        done        : out std_logic
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

    decoder0: decoder
    port map(
        rstring => decdIn, -- expects double the size
        CLK     => CLK100MHZ,
        RST     => BTN0,
        size    => dcSz, -- 00=3, 01=4, 10=5, 11=7
        dstring => decdOut,
        done    => dcDone
    );

    -- process to handle loading into the tx buffer
    process(CLK100MHZ, BTN0)
    begin
        if BTN0 = '1' then
            txDataBuffer <= (others => '0');
            sTxData      <= (others => '0');
            sTxStart     <= '0';
            encodeCount  <= 0;
        else
            -- When a new byte is received over UART load b0 into tx buffer
            if sRxDataRdy = '1' then
                sTxData(0) <= sRxData(0);
            end if;
            
            if encdDone = '1' then
                sTxData(1) <= enOut_0;
                sTxData(2) <= enOut_1;
            end if;
            
            if enCheck = '1' then
                sTxStart <= '1';
            else
                sTxStart <= '0';
            end if;
            
        end if;
    end process;
    
    process(CLK100MHZ, BTN0)
        variable encdDone_prev : std_logic := '0';
    begin
        if BTN0 = '1' then
            encdDone_prev := '0';
        elsif rising_edge(CLK100MHZ) then
            -- Detect rising edge of encdDone using synchronous logic
            if encdDone = '1' and encdDone_prev = '0' then
                enCheck <= '1';
            else
                enCheck <= '0';
            end if;
            -- Store previous value for edge detection
            encdDone_prev := encdDone;
        end if;
    end process;
    
    process(CLK100MHZ, BTN0)
        variable cnstrnt : natural range 0 to 7;
    begin
    
        if 
        
    
    end process;
    
     
    -- Process to handle transmission timing
end Behavioral;