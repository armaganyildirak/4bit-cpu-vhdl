library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu is
    Port (
        CLK         : in  std_logic;
        RST         : in  std_logic;
        DATA_I      : in  std_logic_vector(3 downto 0);
        DATA_O      : out std_logic_vector(3 downto 0);
        DATA_INSTR  : in  std_logic_vector(12 downto 0);
        LDIR        : in  std_logic;
        UPZ         : out std_logic;
        UPS         : out std_logic;
        UPC         : out std_logic;
        UPV         : out std_logic;
        MAR_OUT     : out std_logic_vector(3 downto 0);
        R0_OUT      : out std_logic_vector(3 downto 0);
        R1_OUT      : out std_logic_vector(3 downto 0);
        R2_OUT      : out std_logic_vector(3 downto 0);
        R3_OUT      : out std_logic_vector(3 downto 0);
        R4_OUT      : out std_logic_vector(3 downto 0);
        R5_OUT      : out std_logic_vector(3 downto 0);
        R6_OUT      : out std_logic_vector(3 downto 0);
        R7_OUT      : out std_logic_vector(3 downto 0)
    );
end cpu;

architecture Behavioral of cpu is
    component control_unit is
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
    end component;
    
    component register_file is
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
    end component;
    
    component alu is
        Port (
            ABUS    : in  std_logic_vector(3 downto 0);
            BBUS    : in  std_logic_vector(3 downto 0);
            FSEL    : in  std_logic_vector(3 downto 0);
            FOUT    : out std_logic_vector(3 downto 0);
            Z       : out std_logic;
            S       : out std_logic;
            C       : out std_logic;
            V       : out std_logic
        );
    end component;
    
    signal IR       : std_logic_vector(12 downto 0);
    signal ASEL     : std_logic_vector(2 downto 0);
    signal BSEL     : std_logic_vector(2 downto 0);
    signal DSEL     : std_logic_vector(2 downto 0);
    signal FSEL     : std_logic_vector(3 downto 0);
    signal RFMUX    : std_logic;
    signal DMUX     : std_logic;
    signal LDMAR    : std_logic;
    signal E_RIN    : std_logic;
    signal WR_EN    : std_logic;
    
    signal ABUS     : std_logic_vector(3 downto 0);
    signal BBUS     : std_logic_vector(3 downto 0);
    signal FOUT     : std_logic_vector(3 downto 0);
    
    signal MAR      : std_logic_vector(3 downto 0);
    signal RIN      : std_logic_vector(3 downto 0);
    signal DIN      : std_logic_vector(3 downto 0);
    
    signal Z_FLAG   : std_logic;
    signal S_FLAG   : std_logic;
    signal C_FLAG   : std_logic;
    signal V_FLAG   : std_logic;
    
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            IR <= (others => '0');
        elsif rising_edge(CLK) and LDIR = '1' then
            IR <= DATA_INSTR;
        end if;
    end process;
    
    process(CLK, RST)
    begin
        if RST = '1' then
            MAR <= (others => '0');
        elsif rising_edge(CLK) and LDMAR = '1' then
            MAR <= ABUS;
        end if;
    end process;
    
    DIN <= DATA_I when DMUX = '1' else FOUT;
    RIN <= BBUS when RFMUX = '1' else FOUT;
    
    U_CONTROL: control_unit
    port map (
        CLK     => CLK,
        RST     => RST,
        IR      => IR,
        ASEL    => ASEL,
        BSEL    => BSEL,
        DSEL    => DSEL,
        FSEL    => FSEL,
        RFMUX   => RFMUX,
        DMUX    => DMUX,
        LDMAR   => LDMAR,
        E_RIN   => E_RIN,
        WR_EN   => WR_EN
    );
    
    U_REGFILE: register_file
    port map (
        CLK     => CLK,
        RST     => RST,
        DIN     => DIN,
        RIN     => RIN,
        ASEL    => ASEL,
        BSEL    => BSEL,
        DSEL    => DSEL,
        E_RIN   => E_RIN,
        WR_EN   => WR_EN,
        ABUS    => ABUS,
        BBUS    => BBUS,
        R0_OUT  => R0_OUT,
        R1_OUT  => R1_OUT,
        R2_OUT  => R2_OUT,
        R3_OUT  => R3_OUT,
        R4_OUT  => R4_OUT,
        R5_OUT  => R5_OUT,
        R6_OUT  => R6_OUT,
        R7_OUT  => R7_OUT
    );
    
    U_ALU: alu
    port map (
        ABUS    => ABUS,
        BBUS    => BBUS,
        FSEL    => FSEL,
        FOUT    => FOUT,
        Z       => Z_FLAG,
        S       => S_FLAG,
        C       => C_FLAG,
        V       => V_FLAG
    );
    
    DATA_O   <= FOUT;
    MAR_OUT  <= MAR;
    UPZ <= Z_FLAG;
    UPS <= S_FLAG;
    UPC <= C_FLAG;
    UPV <= V_FLAG;
    
end Behavioral;