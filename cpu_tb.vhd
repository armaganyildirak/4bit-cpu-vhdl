library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity cpu_tb is
end cpu_tb;

architecture behavior of cpu_tb is
    -- Component declarations
    component cpu
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
            R0_OUT : out std_logic_vector(3 downto 0);
            R1_OUT : out std_logic_vector(3 downto 0);
            R2_OUT : out std_logic_vector(3 downto 0);
            R3_OUT : out std_logic_vector(3 downto 0);
            R4_OUT : out std_logic_vector(3 downto 0);
            R5_OUT : out std_logic_vector(3 downto 0);
            R6_OUT : out std_logic_vector(3 downto 0);
            R7_OUT : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Signals for CPU interface
    signal CLK, RST : std_logic := '0';
    signal DATA_I : std_logic_vector(3 downto 0) := (others => '0');
    signal DATA_O : std_logic_vector(3 downto 0);
    signal DATA_INSTR : std_logic_vector(12 downto 0) := (others => '0');
    signal LDIR : std_logic := '0';
    signal UPZ, UPS, UPC, UPV : std_logic;
    signal MAR_OUT : std_logic_vector(3 downto 0);

    -- Clock period
    constant CLK_period : time := 100 ps;
    
    -- Signal to track instruction name
    signal current_instr : string(1 to 20) := (others => ' ');
    
    -- For cycle count tracking
    signal cycle_count : integer := 0;

    signal R0_OUT, R1_OUT, R2_OUT, R3_OUT : std_logic_vector(3 downto 0);
    signal R4_OUT, R5_OUT, R6_OUT, R7_OUT : std_logic_vector(3 downto 0);

    -- Constants for instruction formats
    constant LOADI_OP : std_logic_vector(3 downto 0) := "1101";
    constant ADD_OP   : std_logic_vector(3 downto 0) := "0000";
    constant SUB_OP   : std_logic_vector(3 downto 0) := "0001";
    constant MUL_OP   : std_logic_vector(3 downto 0) := "0010";

begin
    uut: cpu port map (
        CLK => CLK,
        RST => RST,
        DATA_I => DATA_I,
        DATA_O => DATA_O,
        DATA_INSTR => DATA_INSTR,
        LDIR => LDIR,
        UPZ => UPZ,
        UPS => UPS,
        UPC => UPC,
        UPV => UPV,
        MAR_OUT => MAR_OUT,
        R0_OUT => R0_OUT,
        R1_OUT => R1_OUT,
        R2_OUT => R2_OUT,
        R3_OUT => R3_OUT,
        R4_OUT => R4_OUT,
        R5_OUT => R5_OUT,
        R6_OUT => R6_OUT,
        R7_OUT => R7_OUT
    );

    -- Clock process
    CLK_process: process
    begin
        CLK <= '1';
        wait for CLK_period/2;
        CLK <= '0';
        wait for CLK_period/2;
        cycle_count <= cycle_count + 1;
    end process;

    stim_proc: process
    begin
        -- Initialize signals
        current_instr <= "RESET               ";
        
        -- Reset sequence (longer to ensure proper initialization)
        RST <= '1';
        wait for CLK_period * 3;
        RST <= '0';
        wait for CLK_period * 3;
        
        -- Test sequence ------------------------------------------------------
        
        -- 1. LOADI R1, 12 (Load immediate value 12 into R1)
        current_instr <= "LOADI R1,12         ";
        DATA_INSTR <= "000" & "000" & "001" & LOADI_OP; -- LOADI to R1 (12)
        DATA_I <= "1100"; -- Value 12
        LDIR <= '1';
        wait for CLK_period * 3;
        LDIR <= '0';
        
        -- 2. LOADI R2, 3 (Load immediate value 3 into R2)
        current_instr <= "LOADI R2,3          ";
        DATA_INSTR <= "000" & "000" & "010" & LOADI_OP; -- LOADI to R2 (3)
        DATA_I <= "0011"; -- Value 3
        LDIR <= '1';
        wait for CLK_period * 3;
        LDIR <= '0';
        
        -- 3. ADD R1, R2, R3 (R1 + R2 -> R3, should be 15)
        current_instr <= "ADD R1,R2,R3        ";
        DATA_INSTR <= "001" & "010" & "011" & ADD_OP; -- ADD R1 + R2 -> R3
        LDIR <= '1';
        wait for CLK_period * 3;
        LDIR <= '0';
        
        -- 4. SUB R3, R1, R4 (R3 - R1 -> R4, should be 3)
        current_instr <= "SUB R3,R1,R4        ";
        DATA_INSTR <= "011" & "001" & "100" & SUB_OP; -- SUB R3 - R1 -> R4
        LDIR <= '1';
        wait for CLK_period * 3;
        LDIR <= '0';
        
        -- 5. MUL R2, R4, R5 (R2 * R4 -> R5, should be 9)
        current_instr <= "MUL R2,R4,R5        ";
        DATA_INSTR <= "010" & "100" & "101" & MUL_OP; -- MUL R2 * R4 -> R5
        LDIR <= '1';
        wait for CLK_period * 3;
        LDIR <= '0';
        
        -- End test
        current_instr <= "END                 ";
        wait;
    end process;

end behavior;