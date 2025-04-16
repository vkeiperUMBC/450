-- UART

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART is 
  Port
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
end UART;

architecture Behavior of UART is    

-- Baud Counters Signals
signal TxBaudCount : unsigned(16 downto 0);
signal RxBaudCount : unsigned(16 downto 0);

-- Shift Registers Signals
signal TxShiftReg : std_logic_vector(8 downto 0);
signal RxShiftReg : std_logic_vector(7 downto 0);

-- BaudCnt values
constant Baud1   : natural := 10417;
constant Baud2   : natural := 20833;
constant Baud3   : natural := 31250;
constant Baud4   : natural := 41667;
constant Baud5   : natural := 52083;
constant Baud6   : natural := 62500;
constant Baud7   : natural := 72917;
constant Baud8   : natural := 83333;
constant Baud9   : natural := 93750;
constant Baud9p5 : natural := 98958;
constant Baud10  : natural := 104167;

begin

  -- Baud Counters
  process(CLK, RST)
  begin
    if RST = '1' then -- Reset
      RxbaudCount <= (others => '0');
      TxBaudCount <= (others => '0');
    elsif rising_edge(CLK) then
      if UART_TXD_IN = '0' AND RxBaudCount = 0 then -- For UART Receiver
        RxBaudCount <= to_unsigned(Baud9p5, 17); 
      elsif RxBaudCount /= 0 then
        RxBaudCount <= RxBaudCount - 1; -- Countdown 
      end if;
      if TxStart = '1' then -- For UART Transmitter
        TxBaudCount <= to_unsigned(Baud10, 17);
      elsif TxBaudCount /= 0 then
        TxBaudCount <= TxBaudCount - 1; -- Countdown
      end if;
    end if;
  end process;

  -- Shift Registers
  process(CLK, RST)
  begin
    if RST = '1' then
      RxShiftReg <= (others => '0');
      TxShiftReg <= (others => '1');
      RxData     <= (others => '0');
    elsif rising_edge(CLK) then
      if RxBaudCount = Baud8 OR RxBaudCount = Baud7 OR RxBaudCount = Baud6 OR RxBaudCount = Baud5 OR RxBaudCount = Baud4 OR RxBaudCount = Baud3 OR RxBaudCount = Baud2 OR RxBaudCount = Baud1 then
        RxShiftReg <= UART_TXD_IN & RxShiftReg(7 downto 1); -- For UART Receiver
      end if;
      if RxBaudCount = 2 then
        RxData <= RxShiftReg;
      end if;
      if TxStart = '1' then 
        TxShiftReg <= TxData & '0';
      elsif TxBaudCount = Baud9 OR TxBaudCount = Baud8 OR TxBaudCount = Baud7 OR TxBaudCount = Baud6 OR TxBaudCount = Baud5 OR TxBaudCount = Baud4 OR TxBaudCount = Baud3 OR TxBaudCount = Baud2 OR TxBaudCount = Baud1 then
        TxShiftReg <= '1' & TxShiftReg(8 downto 1);
      end if;
    end if;
  end process;

  -- Status Flag Outputs
  TxBusy <= '1' when TxBaudCount /= 0 else '0';
  RxDataRdy <= '1' when RxBaudCount = 1 else '0';
  UART_RXD_OUT <= TxShiftReg(0);
  
end Behavior;