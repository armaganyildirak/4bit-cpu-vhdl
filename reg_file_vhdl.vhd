library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
    Port (
        DIN     : in  std_logic_vector(3 downto 0);
        RIN     : in  std_logic_vector(3 downto 0);
        ASEL    : in  std_logic_vector(2 downto 0);
        BSEL    : in  std_logic_vector(2 downto 0);
        DSEL    : in  std_logic_vector(2 downto 0);
        E_RIN   : in  std_logic;
        WR_EN   : in  std_logic;
        RST     : in  std_logic;
        CLK     : in  std_logic;
        ABUS    : out std_logic_vector(3 downto 0);
        BBUS    : out std_logic_vector(3 downto 0);
        R0_OUT  : out std_logic_vector(3 downto 0);
        R1_OUT  : out std_logic_vector(3 downto 0);
        R2_OUT  : out std_logic_vector(3 downto 0);
        R3_OUT  : out std_logic_vector(3 downto 0);
        R4_OUT  : out std_logic_vector(3 downto 0);
        R5_OUT  : out std_logic_vector(3 downto 0);
        R6_OUT  : out std_logic_vector(3 downto 0);
        R7_OUT  : out std_logic_vector(3 downto 0)
    );
end register_file;

architecture Behavioral of register_file is
    type reg_file_type is array (0 to 7) of std_logic_vector(3 downto 0);
    signal reg_file : reg_file_type := (others => (others => '0'));
begin    
    process(CLK, RST)
    begin
        if RST = '1' then
            reg_file <= (others => (others => '0'));
        elsif rising_edge(CLK) then
            if WR_EN = '1' and DSEL /= "UUU" then
                if E_RIN = '1' then
                    reg_file(to_integer(unsigned(DSEL))) <= RIN;
                else
                    reg_file(to_integer(unsigned(DSEL))) <= DIN;
                end if;
            end if;
        end if;
    end process;
    
    ABUS <= reg_file(to_integer(unsigned(ASEL)));
    BBUS <= reg_file(to_integer(unsigned(BSEL)));
    
    R0_OUT <= reg_file(0);
    R1_OUT <= reg_file(1);
    R2_OUT <= reg_file(2);
    R3_OUT <= reg_file(3);
    R4_OUT <= reg_file(4);
    R5_OUT <= reg_file(5);
    R6_OUT <= reg_file(6);
    R7_OUT <= reg_file(7);
end Behavioral;