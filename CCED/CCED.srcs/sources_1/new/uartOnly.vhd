library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uartOnly is
    Port ( CLK100MHZ : in STD_LOGIC;
           BTN0 : in STD_LOGIC;
           SW : in STD_LOGIC_VECTOR (1 downto 0);
           UART_TXD_IN : in STD_LOGIC;
           UART_RXD_OUT : out STD_LOGIC);
end uartOnly;

architecture Behavioral of uartOnly is

-- UART signals
signal sTxData    : std_logic_vector(7 downto 0); --_vector(3 downto 0);
signal sRxData    : std_logic_vector(7 downto 0);
signal sTxBusy    : std_logic;
signal sRxDataRdy : std_logic;
signal sTxStart   : std_logic;
signal sDisplayData : std_logic;

component UART is 
  port
  ( CLK         : in std_logic;
    RST         : in std_logic;
    UART_TXD_IN : in std_logic;
    TxStart     : in std_logic;
    TxData      : in std_logic_vector(7 downto 0);--_vector(3 downto 0);
    RxDataRdy    : out std_logic;
    RxData       : out std_logic_vector(7 downto 0);
    TxBusy       : out std_logic;
    UART_RXD_OUT : out std_logic
  );
end component;

begin
 -- UART
  TransmitReceive : UART
  port map
  ( CLK => CLK100MHZ, 
    RST=> BTN0, 
    UART_TXD_IN  => UART_TXD_IN, 
    TxStart      => sRxDataRdy,
    TxData       => sTxData,
    RxDataRdy    => sRxDataRdy,
    RxData       => sRxData,
    TxBusy       => sTxBusy,
    UART_RXD_OUT => UART_RXD_OUT
  );

  -- Outputs
 sTxData <= sRxData;
 --sTxData(3) <= '0';


end Behavioral;
