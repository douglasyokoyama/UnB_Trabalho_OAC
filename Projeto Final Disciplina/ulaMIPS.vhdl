library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ulaMIPS is
	port (opULA : in std_logic_vector(3 downto 0);
			A, B : in std_logic_vector(31 downto 0);
			S : out std_logic_vector(31 downto 0);
			zero, ovfl : out std_logic);
end ulaMIPS;

--12 operacoes em complemento de 2

architecture ulaMIPS_op of ulaMIPS is
   signal a32 : signed(31 downto 0);
	signal As, Bs : signed (31 downto 0);
	signal shiftA : signed(4 downto 0);
	signal B31 : std_logic;
	signal int_shiftA : integer;

begin	
  S <= std_logic_vector(a32);
  As <= signed(A);
  Bs <= signed(B);
  shiftA <= A(4)& A(3) & A(2) & A(1) & A(0);
  int_shiftA <= to_integer(shiftA);
  B31 <= B(31);
  proc_ula: process(As, Bs)
  	variable result : signed(31 downto 0);
	variable CBIT: STD_LOGIC:= '0';
  begin

      if (a32 = X"00000000") then zero <= '1';  else zero <= '0'; end if; 
      case opULA is  
          when  "0000" => a32 <= (As and Bs);								--and A, B - Sa�da S recebe a opera��o l�gica A and B, bit a bit - 0000
          when  "0001" => a32 <= (As or Bs);								--or A, B - S recebe a opera��o l�gica A or B, bit a bit - 0001
          when  "0010" => for i in 0 to 31 loop							--add A, B - S recebe a soma das entradas A, B - 0010
										result(i) := CBIT xor A(i) xor B(i);
										CBIT := (CBIT and A(i)) or (CBIT and B(i)) or (A(i) and B(i));
								  end loop;
								  a32 <= result;
								  ovfl <= CBIT;
          when  "0011" => a32 <= Bs srl int_shiftA;						--srl A, B - S <= B >> A, utiliza 5 bits de A, shift l�gico - 0011
          when  "0100" => a32 <= Bs srl int_shiftA;						--sra A, B - S <= B - S <= B << >> A, idem, shift aritm�tico - 01
								  a32(31) <= B31;
          when  "0101" => a32 <= Bs sll int_shiftA;						--sll A, B A, utiliza 5 bits de A, shift l�gico - 0101
			 when	 "0110" => for i in 0 to 31 loop							--sub A, B - S recebe A - B - 0110 
										result(i) := CBIT xor As(i) xor not(Bs(i));
										CBIT := (CBIT and As(i)) or (CBIT and not(Bs(i))) or (As(i) and not(Bs(i)));
								  end loop;
								  a32 <= result;
								  ovfl <= CBIT;									
			 when	 "0111" => if (As < Bs) then									--slt A, B - S <= 1 se A < B, 0 caso contr�rio - 0111
										a32 <= X"00000000"; else a32 <= X"FFFFFFFF";
								  end if;
			 when	 "1000" => a32 <=	not(As);									--not A - S recebe a entrada A invertida bit a bit - 1000
			 when	 "1001" => a32 <=	As xor Bs;									--xor A, B - S recebe a opera��o l�gica A xor B, bit a bit - 1001
			 when	 "1100" => a32 <=	As nand Bs;								--nand A, B - S recebe a opera��o l�gica A nand B, bit a bit - 1100
			 when  "1101" => a32 <= As nor Bs;									--nor A, B - S recebe a opera��o l�gica A nor B, bit a bit - 1101
			 when others  => a32 <= (others => '0');
		end case;
	end process proc_ula;
end architecture ulaMIPS_op;
