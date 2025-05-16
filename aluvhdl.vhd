library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Port ( 
        ABUS    : in std_logic_vector(3 downto 0);
        BBUS    : in std_logic_vector(3 downto 0);
        FSEL    : in std_logic_vector(3 downto 0);
        FOUT    : out std_logic_vector(3 downto 0);
        Z       : out std_logic;
        S       : out std_logic;
        C       : out std_logic;
        V       : out std_logic
    );
end alu;

architecture Behavioral of alu is
    -- Half Adder function
    function half_adder(a, b: std_logic) return std_logic_vector is
        variable result : std_logic_vector(1 downto 0);
    begin
        result(1) := a and b; -- carry
        result(0) := a xor b; -- sum
        return result;
    end function;

    -- Full Adder function
    function full_adder(a, b, cin: std_logic) return std_logic_vector is
        variable ha1, ha2 : std_logic_vector(1 downto 0);
        variable result : std_logic_vector(1 downto 0);
    begin
        ha1 := half_adder(a, b);
        ha2 := half_adder(ha1(0), cin);
        result(0) := ha2(0); -- sum
        result(1) := ha1(1) or ha2(1); -- carry
        return result;
    end function;

    -- 4-bit Addition function
    function four_bit_addition(a, b: std_logic_vector(3 downto 0)) 
        return std_logic_vector is
        variable fa1, fa2, fa3, fa4 : std_logic_vector(1 downto 0);
        variable sum : std_logic_vector(3 downto 0);
        variable c1, c2, c3, cout : std_logic;
        variable result : std_logic_vector(4 downto 0);
    begin
        fa1 := full_adder(a(0), b(0), '0');
        sum(0) := fa1(0);
        c1 := fa1(1);

        fa2 := full_adder(a(1), b(1), c1);
        sum(1) := fa2(0);
        c2 := fa2(1);

        fa3 := full_adder(a(2), b(2), c2);
        sum(2) := fa3(0);
        c3 := fa3(1);

        fa4 := full_adder(a(3), b(3), c3);
        sum(3) := fa4(0);
        cout := fa4(1);

        result := cout & sum;
        return result;
    end function;

    -- 4-bit Subtraction function
    function four_bit_subtraction(a, b: std_logic_vector(3 downto 0)) 
        return std_logic_vector is
        variable b_complement : std_logic_vector(3 downto 0);
        variable result : std_logic_vector(4 downto 0);
    begin
        b_complement := not b;
        result := four_bit_addition(b_complement, "0001");
        result := four_bit_addition(a, result(3 downto 0));
        return result;
    end function;

    -- 4-bit Multiplication function
    function four_bit_multiplication(x, y: std_logic_vector(3 downto 0)) 
        return std_logic_vector is
        variable a1,a2,a3,a4,b1,b2,b3,b4: std_logic;
        variable c1,c2,c3,c4,d1,d2,d3,d4: std_logic;
        variable o2,o3,o4,o6,o7,o8,o10,o11,o12: std_logic;
        variable r1,r2,r3,r4,r5,r6,r7,r8,r9,r10: std_logic;
        variable r11,r12,r13,r14,r15: std_logic;
        variable out_temp : std_logic_vector(7 downto 0);
        variable overflow : std_logic;
        variable temp : std_logic_vector(1 downto 0);
        variable result : std_logic_vector(4 downto 0);
    begin
        -- Generate partial products
        a1 := x(0) and y(0);
        a2 := x(1) and y(0);
        a3 := x(2) and y(0);
        a4 := x(3) and y(0);
        b1 := x(0) and y(1);
        b2 := x(1) and y(1);
        b3 := x(2) and y(1);
        b4 := x(3) and y(1);
        c1 := x(0) and y(2);
        c2 := x(1) and y(2);
        c3 := x(2) and y(2);
        c4 := x(3) and y(2);
        d1 := x(0) and y(3);
        d2 := x(1) and y(3);
        d3 := x(2) and y(3);
        d4 := x(3) and y(3);

        -- First row of additions
        temp := full_adder(a1, '0', '0');
        r1 := temp(1); out_temp(0) := temp(0);
        temp := full_adder(a2, '0', r1);
        r2 := temp(1); o2 := temp(0);
        temp := full_adder(a3, '0', r2);
        r3 := temp(1); o3 := temp(0);
        temp := full_adder(a4, '0', r3);
        r4 := temp(1); o4 := temp(0);

        -- Second row of additions
        temp := full_adder(b1, o2, '0');
        r5 := temp(1); out_temp(1) := temp(0);
        temp := full_adder(b2, o3, r5);
        r6 := temp(1); o6 := temp(0);
        temp := full_adder(b3, o4, r6);
        r7 := temp(1); o7 := temp(0);
        temp := full_adder(b4, r4, r7);
        r8 := temp(1); o8 := temp(0);

        -- Third row of additions
        temp := full_adder(c1, o6, '0');
        r9 := temp(1); out_temp(2) := temp(0);
        temp := full_adder(c2, o7, r9);
        r10 := temp(1); o10 := temp(0);
        temp := full_adder(c3, o8, r10);
        r11 := temp(1); o11 := temp(0);
        temp := full_adder(c4, r8, r11);
        r12 := temp(1); o12 := temp(0);

        -- Fourth row of additions
        temp := full_adder(d1, o10, '0');
        r13 := temp(1); out_temp(3) := temp(0);
        temp := full_adder(d2, o11, r13);
        r14 := temp(1); out_temp(4) := temp(0);
        temp := full_adder(d3, o12, r14);
        r15 := temp(1); out_temp(5) := temp(0);
        temp := full_adder(d4, r12, r15);
        out_temp(7) := temp(1); out_temp(6) := temp(0);

        overflow := '0';
        if out_temp(7 downto 4) /= "0000" then
            overflow := '1';
        end if;
        
        result := overflow & out_temp(3 downto 0);
        return result;
    end function;

begin
    process(ABUS, BBUS, FSEL)
        variable temp_result : std_logic_vector(4 downto 0);
    begin
        -- Initialize flags
        Z <= '0';
        V <= '0';
        C <= '0';
        S <= '0';

        -- Initialize result
        temp_result := "00000";

        case FSEL is
            when "0000" =>  -- Addition
                temp_result := four_bit_addition(ABUS, BBUS);
                C <= temp_result(4);
                V <= (ABUS(3) xnor BBUS(3)) and 
                               (temp_result(3) xor ABUS(3));

            when "0001" =>  -- Subtraction
                temp_result := four_bit_subtraction(ABUS, BBUS);
                C <= not temp_result(4);
                V <= (ABUS(3) xor BBUS(3)) and 
                               (temp_result(3) xor ABUS(3));

            when "0010" =>  -- Multiplication
                temp_result := four_bit_multiplication(ABUS, BBUS);
                V <= temp_result(4);
                C <= temp_result(4);

            when "0011" =>  -- AND
                temp_result(3 downto 0) := ABUS and BBUS;

            when "0100" =>  -- OR
                temp_result(3 downto 0) := ABUS or BBUS;

            when "0101" =>  -- XOR
                temp_result(3 downto 0) := ABUS xor BBUS;

            when "0110" =>  -- NAND
                temp_result(3 downto 0) := not (ABUS and BBUS);

            when "0111" =>  -- Shift Left
                temp_result(3 downto 0) := ABUS(2 downto 0) & '0';
                C <= ABUS(3);

            when "1000" =>  -- Shift Right
                temp_result(3 downto 0) := '0' & ABUS(3 downto 1);
                C <= ABUS(0);

            when "1001" =>  -- Increment
                temp_result := four_bit_addition(ABUS, "0001");
                C <= temp_result(4);
                V <= (ABUS(3) xnor '0') and 
                               (temp_result(3) xor ABUS(3));

            when "1010" =>  -- Decrement
                temp_result := four_bit_subtraction(ABUS, "0001");
                C <= not temp_result(4);
                V <= (ABUS(3) xor '0') and 
                               (temp_result(3) xor ABUS(3));
            
            -- LOAD (from memory - pass through ABUS)
            when "1011" =>
                temp_result(3 downto 0) := ABUS;
                C <= '0';
                V <= '0';

            -- STORE (to memory - pass through ABUS)
            when "1100" =>
                temp_result(3 downto 0) := ABUS;
                C <= '0';
                V <= '0';

            -- LOADI (load immediate - pass through BBUS)
            when "1101" =>
                temp_result(3 downto 0) := BBUS;
                C <= '0';
                V <= '0';

            -- NOP (No Operation)
            when "1111" =>
                temp_result(3 downto 0) := (others => '0');
                C <= '0';
                V <= '0';
                Z <= '0';
                S <= '0';
            
            when others =>
                temp_result := "00000";
        end case;

        -- Set zero flag
        if temp_result(3 downto 0) = "0000" then
            Z <= '1';
        end if;
        
        -- Set sign flag
        S <= temp_result(3);

        -- Set result
        FOUT <= temp_result(3 downto 0);
    end process;
end Behavioral;