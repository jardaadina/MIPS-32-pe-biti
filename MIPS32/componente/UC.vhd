library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity UC is
  Port ( 
    Instr : in std_logic_vector(5 downto 0);
    RegDst : out std_logic;
    ExtOp : out std_logic;
    ALUSrc : out std_logic;
    Branch : out std_logic;
    Branch_gtz : out std_logic;
    Jump : out std_logic;
    ALUOp : out std_logic_vector(1 downto 0);
    MemWrite : out std_logic;
    MemtoReg : out std_logic;
    RegWrite : out std_logic
  );
end UC;

architecture Behavioral of UC is
begin
process(Instr)
begin
RegDst <= '0';
ExtOp <= '0';
ALUSrc <= '0';
Branch <= '0';              
Jump <= '0';
MemWrite <= '0';
MemtoReg <= '0';
RegWrite <= '0';
ALUOp <= "00";
Branch_gtz <= '0';
case Instr is
    when "000000" =>
        RegDst <= '1';
        RegWrite <= '1';
        ALUOp <= "10";
    when "001000" =>
        ExtOp <= '1';
        ALUSrc <= '1';
        RegWrite <= '1';
        ALUOp <= "00";
    when "001100" =>
        ALUSrc <= '1';
        RegWrite <= '1';
        ALUOp <= "11";
    when "100011" =>
        ExtOp <= '1';
        ALUSrc <= '1';
        MemtoReg <= '1';
        RegWrite <= '1';
        ALUOp <= "00";
    when "101011" =>
        ExtOp <= '1';
        ALUSrc <= '1';
        MemWrite <= '1';
        ALUOp <= "00";
    when "000100" =>
        ExtOp <= '1';
        Branch <= '1';
        ALUOp <= "01";
    when "000111" =>
        ExtOp <= '1';
        Branch_gtz <= '1';
        ALUOp <= "01";
    when "000010" => 
        Jump <= '1';
    when others =>
end case;
end process;
end Behavioral;
