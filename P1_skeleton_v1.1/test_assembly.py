import sys
import subprocess
import os

RARS_PATH = "rars.jar"
INT32_MIN = -2147483648
INT32_MAX = 2147483647

def run_rars(file_path):
    cmd = ["java", "-jar", RARS_PATH, "nc", "dec", "a0", "a1", file_path]
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0 and "Program terminated by calling exit" not in result.stdout:
        return None, None, f"Erro RARS:\n{result.stderr}\n{result.stdout}"
        
    a0_val = None
    a1_val = None
    for line in result.stdout.split('\n'):
        if line.startswith('a0\t'):
            a0_val = int(line.split('\t')[1])
        elif line.startswith('a1\t'):
            val = int(line.split('\t')[1])
            if val >= 2**31:
                val -= 2**32
            a1_val = val
            
    return a0_val, a1_val, result.stdout

def to_word_list(arr):
    if not arr:
        return "0"
    return ", ".join(map(str, arr))

def create_temp_assembly(func_name, func_code, arr1, arr2=None, index=None):
    if func_name == "argmax":
        data_section = f"""
.data
A:    .word {to_word_list(arr1)}
SIZE: .word {len(arr1)}

.text
main:
  la a1, A
  lw a2, SIZE
  jal ra, argmax
exit:
  li a7, 10
  ecall

{func_code}
"""
    elif func_name == "select":
        data_section = f"""
.data
A:    .word {to_word_list(arr1)}
SIZE: .word {len(arr1)}
INDEX:.word {index}

.text
main:
  la a1, A
  lw a2, SIZE
  lw a3, INDEX
  jal ra, select
exit:
  li a7, 10
  ecall

{func_code}
"""
    elif func_name == "dot":
        data_section = f"""
.data
A:    .word {to_word_list(arr1)}
B:    .word {to_word_list(arr2)}
SIZE: .word {len(arr1)}

.text
main:
  la a1, A
  la a2, B
  lw a3, SIZE
  jal ra, dot
exit:
  li a7, 10
  ecall

{func_code}
"""
    with open("temp_test.s", "w") as f:
        f.write(data_section)

class TestRunner:
    def __init__(self):
        self.passed = 0
        self.failed = 0

    def assert_eq(self, test_name, func_name, expected, func_code, arr1, arr2=None, index=None):
        create_temp_assembly(func_name, func_code, arr1, arr2, index)
        a0, a1, out = run_rars("temp_test.s")
        
        expected_status, expected_res = expected
        got_status = a0
        got_res = a1
        
        if expected_status != 0:
            if got_status == expected_status:
                print(f"✅ PASSED: {test_name}")
                self.passed += 1
            else:
                print(f"❌ FAILED: {test_name}")
                print(f"    Esperado Status: {expected_status}")
                print(f"    Obtido Status:   {got_status}")
                self.failed += 1
        else:
            if got_status == expected_status and got_res == expected_res:
                print(f"✅ PASSED: {test_name}")
                self.passed += 1
            else:
                print(f"❌ FAILED: {test_name}")
                print(f"    Esperado (Status, Res): {expected}")
                print(f"    Obtido (Status, Res):   {(got_status, got_res)}")
                self.failed += 1

def extract_func(filename, func_name):
    if not os.path.exists(filename):
        return None
    with open(filename, "r") as f:
        content = f.read()
    func_start = content.find(f"{func_name}:")
    if func_start == -1:
        return None
    return content[func_start:]

def main():
    runner = TestRunner()
    
    code_argmax = extract_func("argmax.s", "argmax")
    code_select = extract_func("select.s", "select")
    code_dot = extract_func("dot.s", "dot")
    
    if code_argmax:
        print("="*60)
        print("   TESTANDO ASSEMBLY: argmax.s")
        print("="*60)
        runner.assert_eq("Lista normal", "argmax", (0, 2), code_argmax, [1, 2, 5, 4])
        runner.assert_eq("Lista com empates", "argmax", (0, 1), code_argmax, [1, 5, 5, 4])
        runner.assert_eq("Tudo negativo", "argmax", (0, 0), code_argmax, [-1, -2, -5, -4])
        runner.assert_eq("Erro: Tamanho < 1", "argmax", (50, -1), code_argmax, [])
        
    if code_select:
        print("\n" + "="*60)
        print("   TESTANDO ASSEMBLY: select.s")
        print("="*60)
        runner.assert_eq("Acesso normal", "select", (0, 6), code_select, [-6, -1, 6, 1], index=2)
        runner.assert_eq("Erro: Tamanho < 1", "select", (50, -1), code_select, [], index=0)
        runner.assert_eq("Erro: Index = Tamanho", "select", (100, -1), code_select, [1, 2, 3], index=3)
        runner.assert_eq("Erro: Index > Tamanho", "select", (100, -1), code_select, [1, 2], index=5)
        
        # RISC-V costuma comparar índices de forma unsigned (bltu) ou signed (blt).
        # Como no teu ficheiro usas 'bge', ele trata -1 como um número negativo menor que o tamanho,
        # e portanto um índex negativo acaba por provocar um acesso invãlido de memória.
        runner.assert_eq("Erro: Index < 0", "select", (100, -1), code_select, [1, 2, 3], index=-1)

    if code_dot:
        print("\n" + "="*60)
        print("   TESTANDO ASSEMBLY: dot.s")
        print("="*60)
        runner.assert_eq("Produto Escalar Normal", "dot", (0, 32), code_dot, [1, 2, 3], [4, 5, 6])
        runner.assert_eq("Valores negativos normais", "dot", (0, -32), code_dot, [-1, -2, -3], [4, 5, 6])
        runner.assert_eq("Erro: Tamanho < 1", "dot", (50, -1), code_dot, [], [])
        
        runner.assert_eq("Erro 200: Overflow Mult Positiva", "dot", (200, -1), code_dot, [50000], [50000])
        runner.assert_eq("Erro 200: Overflow Mult Negativa", "dot", (200, -1), code_dot, [50000], [-50000])
        runner.assert_eq("Erro 200: Overflow INT32_MIN * -1", "dot", (200, -1), code_dot, [INT32_MIN], [-1])
        runner.assert_eq("Erro 200: Overflow Soma Positiva", "dot", (200, -1), code_dot, [INT32_MAX, 1], [1, 1])
        runner.assert_eq("Erro 200: Overflow Soma Negativa", "dot", (200, -1), code_dot, [INT32_MIN, -1], [1, 1])
        
        print("\n   --- Casos onde o Bug Atual Vai Fazer Falhar ---")
        runner.assert_eq("Bug Assembly #2: Soma c/ mesmo sinal", "dot", (0, 2), code_dot, [1, 1], [1, 1])
        runner.assert_eq("Bug Assembly #3: 2+ produtos negativos", "dot", (0, -2), code_dot, [-1, -1], [1, 1])

    print("\n" + "="*60)
    print(f"Resumo Geral Assembly: {runner.passed} passaram, {runner.failed} falharam.")
    print("="*60)
    
    if os.path.exists("temp_test.s"):
        os.remove("temp_test.s")
        
    if runner.failed > 0:
        sys.exit(1)

if __name__ == '__main__':
    main()
