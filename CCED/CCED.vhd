-- Top level CCED

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity CCED is
  port 
  ( CLK100MHZ    : in std_logic;
    BTN0         : in std_logic;
    SW           : in std_logic_vector(1 downto 0);
    UART_TXD_IN  : in std_logic; -- UART Input
    UART_RXD_OUT : out std_logic -- UART Output
  );
end CCED;

architecture Behavioral of CCED is

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

component encoder_k3 is
  port
  ( clk            : in std_logic;
    rst            : in std_logic;
    data_in        : in std_logic;
    in_enable      : in std_logic;
    out_enable     : in std_logic;
    constraint_sel : in std_logic_vector(1 downto 0);
    encoded_out0   : out std_logic;
    encoded_out1   : out std_logic
  );
end component;

component FSM is
  Port
  ( CLK       : in std_logic;
    RST       : in std_logic;       
    RxDataRdy : in std_logic;
    UART_TXD_IN : in std_logic;
    DisplayData : out std_logic
    --TxStart : out std_logic
  );
end component;

begin

 -- UART
  TransmitReceive : UART
  port map
  ( CLK => CLK100MHZ, 
    RST=> BTN0, 
    UART_TXD_IN  => sDisplayData, 
    TxStart      => sRxDataRdy,
    TxData       => sTxData,
    RxDataRdy    => sRxDataRdy,
    RxData       => sRxData,
    TxBusy       => sTxBusy,
    UART_RXD_OUT => UART_RXD_OUT
  );
  
  -- FSM
  FiniteStateMachine : FSM
  port map
  ( CLK       => CLK100MHZ,
    RST       => BTN0,
    RxDataRdy => sRxDataRdy,
    UART_TXD_IN  => UART_TXD_IN,
    DisplayData => sDisplayData
    --TxStart   => sTxStart
  );

Encode : encoder_k3 
  port map
  ( clk            => CLK100MHZ,
    rst            => BTN0,
    data_in        => UART_TXD_IN,
    in_enable      => sRxDataRdy,
    out_enable     => sRxDataRdy,
    constraint_sel => SW,
    encoded_out0   => sTxData(1), --sTxData,
    encoded_out1   => sTxData(2)
  );
  
  
  -- Outputs
 sTxData <= sRxData;
 --sTxData(3) <= '0';
  

end Behavioral;