library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_unit is
    Port (
        CLK     : in  std_logic;
        RST     : in  std_logic;
        IR      : in  std_logic_vector(12 downto 0);
        ASEL    : out std_logic_vector(2 downto 0);
        BSEL    : out std_logic_vector(2 downto 0);
        DSEL    : out std_logic_vector(2 downto 0);
        FSEL    : out std_logic_vector(3 downto 0);
        RFMUX   : out std_logic;
        DMUX    : out std_logic;
        LDMAR   : out std_logic;
        E_RIN   : out std_logic;
        WR_EN   : out std_logic
    );
end control_unit;

architecture Behavioral of control_unit is
    type state_type is (FETCH, DECODE, EXECUTE);
    signal current_state : state_type;
    
    alias ir_asel : std_logic_vector(2 downto 0) is IR(12 downto 10);
    alias ir_bsel : std_logic_vector(2 downto 0) is IR(9 downto 7);
    alias ir_dsel : std_logic_vector(2 downto 0) is IR(6 downto 4);
    alias ir_fsel : std_logic_vector(3 downto 0) is IR(3 downto 0);
    
    constant OP_LOAD    : std_logic_vector(3 downto 0) := "1011";
    constant OP_STORE   : std_logic_vector(3 downto 0) := "1100";
    constant OP_LOADI   : std_logic_vector(3 downto 0) := "1101";
    constant OP_NOP     : std_logic_vector(3 downto 0) := "1111";
    
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            current_state <= FETCH;
            ASEL <= "000";
            BSEL <= "000";
            DSEL <= "000";
            FSEL <= "0000";
            RFMUX <= '0';
            DMUX <= '0';
            LDMAR <= '0';
            E_RIN <= '0';
            WR_EN <= '0';
            
        elsif rising_edge(CLK) then
            case current_state is
                when FETCH =>
                    E_RIN <= '0';
                    WR_EN <= '0';
                    current_state <= DECODE;
                    
                when DECODE =>
                    ASEL <= ir_asel;
                    BSEL <= ir_bsel;
                    DSEL <= ir_dsel;
                    FSEL <= ir_fsel;
                    
                    RFMUX <= '0';
                    DMUX <= '0';
                    LDMAR <= '0';
                    E_RIN <= '0';
                    WR_EN <= '0';
                    
                    case ir_fsel is
                        when OP_LOAD =>
                            DMUX <= '1';
                            E_RIN <= '0';
                            LDMAR <= '1';
                            WR_EN <= '1';
                            
                        when OP_STORE =>
                            LDMAR <= '1';
                            E_RIN <= '0';
                            WR_EN <= '0';
                            
                        when OP_LOADI =>
                            DMUX <= '1';
                            RFMUX <= '1';
                            E_RIN <= '0';
                            WR_EN <= '1';
                            
                        when OP_NOP =>
                            E_RIN <= '0';
                            WR_EN <= '0';
                            
                        when others =>
                            E_RIN <= '1';
                            WR_EN <= '1';
                    end case;
                    
                    current_state <= EXECUTE;
                    
                when EXECUTE =>
                    WR_EN <= '0';
                    LDMAR <= '0';
                    current_state <= FETCH;
            end case;
        end if;
    end process;
    
end Behavioral;