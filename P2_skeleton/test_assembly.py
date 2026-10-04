import sys
import subprocess
import os
import shutil

# Dynamic search for rars.jar
RARS_PATH = None
for path in ["rars.jar", "../P1_skeleton_v1.1/rars.jar", "P1_skeleton_v1.1/rars.jar"]:
    if os.path.exists(path):
        RARS_PATH = os.path.abspath(path)
        break

if not RARS_PATH:
    # Search recursively in the parent directories
    parent = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    candidate = os.path.join(parent, "P1_skeleton_v1.1", "rars.jar")
    if os.path.exists(candidate):
        RARS_PATH = os.path.abspath(candidate)

if not RARS_PATH:
    print("❌ Erro: rars.jar não foi encontrado.")
    sys.exit(1)

TEMPLATE_PATH = os.path.abspath("p2-template.s")
TEMP_TEST_PATH = os.path.abspath("temp_test.s")
TEMP_P2_PATH = os.path.abspath("temp_p2.s")

EQU_HEADER = """###########################################################################
# Hoisted Constants for RARS Compilation (.eqv for macro expansion)
###########################################################################
.eqv CONST_DIMENSION 4
.eqv CONST_BUFFER_SIZE 1024
.eqv CONST_MAX_VOCAB_TOKENS 100
.eqv CONST_MAX_INPUT_TOKENS 10

.eqv CONST_SYSCALL_PRINT_INT 1
.eqv CONST_SYSCALL_PRINT_STRING 4
.eqv CONST_SYSCALL_PRINT_CHAR 11
.eqv CONST_SYSCALL_EXIT 10
.eqv CONST_SYSCALL_EXIT2 93
.eqv CONST_SYSCALL_OPEN 1024
.eqv CONST_SYSCALL_CLOSE 57
.eqv CONST_SYSCALL_READ 63
.eqv CONST_SYSCALL_WRITE 64 

.eqv CONST_CHAR_EOF 0
.eqv CONST_CHAR_SPACE 32
.eqv CONST_CHAR_NEWLINE 10
.eqv CONST_CHAR_HYPHEN 45
.eqv CONST_CHAR_ZERO 48
"""

def preprocess_assembly_content(content):
    # First replace .zero with aligned .space
    content = content.replace(".zero", ".align 2\n.space")
    
    # Resolve the .zero arithmetic expressions so RARS can compile them
    replacements = {
        "(CONST_MAX_INPUT_TOKENS * 4)": "40",
        "(CONST_MAX_VOCAB_TOKENS * CONST_DIMENSION * 4)": "1600",
        "(CONST_MAX_INPUT_TOKENS * CONST_DIMENSION * 4)": "160",
        "(CONST_DIMENSION * CONST_DIMENSION * 4)": "64",
        "-CONST_CHAR_ZERO": "-48"
    }
    for expr, val in replacements.items():
        content = content.replace(expr, val)
        
    # Also comment out original .equ / .eqv lines to avoid duplication warnings/errors
    lines = []
    for line in content.split('\n'):
        stripped = line.strip()
        if stripped.startswith(".equ ") or stripped.startswith(".eqv "):
            lines.append("# " + line)
        else:
            lines.append(line)
    return '\n'.join(lines)

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

def create_temp_assembly(test_assembly_prefix):
    if not os.path.exists(TEMPLATE_PATH):
        raise FileNotFoundError(f"Ficheiro {TEMPLATE_PATH} não encontrado.")
        
    with open(TEMPLATE_PATH, "r") as f:
        template_content = f.read()
        
    # Replace main: with p2_main: to avoid collision
    modified_content = template_content.replace("\nmain:", "\np2_main:")
    modified_content = preprocess_assembly_content(modified_content)
    
    # Preprocess the test prefix to resolve its .zero to .space
    processed_prefix = preprocess_assembly_content(test_assembly_prefix)
    
    full_code = f"""{EQU_HEADER}

{processed_prefix}

# --- INÍCIO DO CÓDIGO DO PROJETO 2 ---
{modified_content}
"""
    with open(TEMP_TEST_PATH, "w") as f:
        f.write(full_code)

def create_temp_p2_assembly():
    if not os.path.exists(TEMPLATE_PATH):
        raise FileNotFoundError(f"Ficheiro {TEMPLATE_PATH} não encontrado.")
        
    with open(TEMPLATE_PATH, "r") as f:
        content = f.read()
        
    content = preprocess_assembly_content(content)
    
    full_code = f"""{EQU_HEADER}
{content}
"""
    with open(TEMP_P2_PATH, "w") as f:
        f.write(full_code)

class TestRunner:
    def __init__(self):
        self.passed = 0
        self.failed = 0

    def assert_eq(self, test_name, test_assembly_prefix, expected_a0, expected_a1):
        create_temp_assembly(test_assembly_prefix)
        a0, a1, out = run_rars(TEMP_TEST_PATH)
        
        if a0 is None or a1 is None:
            print(f"❌ FAILED: {test_name}")
            print(f"    Erro ao executar RARS:\n{out}")
            self.failed += 1
            return
            
        if a0 == expected_a0 and (expected_a0 != 0 or a1 == expected_a1):
            print(f"✅ PASSED: {test_name}")
            self.passed += 1
        else:
            print(f"❌ FAILED: {test_name}")
            if expected_a0 == 0:
                print(f"    Esperado (a0, a1): {(expected_a0, expected_a1)}")
            else:
                print(f"    Esperado (a0):     {expected_a0}")
            print(f"    Obtido (a0, a1):   {(a0, a1)}")
            self.failed += 1

def main():
    runner = TestRunner()

    print("="*60)
    print("   TESTANDO FUNÇÕES INDIVIDUAIS (UNIT TESTS) - PROJETO 2")
    print("="*60)

    # ----------------------------------------------------
    # 1. TESTES UNITÁRIOS: dot
    # ----------------------------------------------------
    print("\n--- Testando dot ---")
    
    # 1.1 Produto Escalar Normal
    runner.assert_eq(
        "dot: Produto Escalar Normal",
        """.data
test_v1: .word 1, 2, 3
test_v2: .word 4, 5, 6
.text
main:
  la a1, test_v1
  la a2, test_v2
  li a3, 3
  jal ra, dot
  li a7, 10
  ecall""",
        0, 32
    )

    # 1.2 Valores negativos normais
    runner.assert_eq(
        "dot: Valores negativos",
        """.data
test_v1: .word -1, -2, -3
test_v2: .word 4, 5, 6
.text
main:
  la a1, test_v1
  la a2, test_v2
  li a3, 3
  jal ra, dot
  li a7, 10
  ecall""",
        0, -32
    )

    # 1.3 Tamanho inválido (< 1)
    runner.assert_eq(
        "dot: Erro tamanho < 1",
        """.text
main:
  li a1, 0
  li a2, 0
  li a3, 0
  jal ra, dot
  li a7, 10
  ecall""",
        50, -1
    )

    # 1.4 Overflow de multiplicação
    runner.assert_eq(
        "dot: Overflow multiplicação",
        """.data
test_v1: .word 50000
test_v2: .word 50000
.text
main:
  la a1, test_v1
  la a2, test_v2
  li a3, 1
  jal ra, dot
  li a7, 10
  ecall""",
        200, -1
    )

    # ----------------------------------------------------
    # 2. TESTES UNITÁRIOS: argmax
    # ----------------------------------------------------
    print("\n--- Testando argmax ---")
    
    # 2.1 Argmax Normal
    runner.assert_eq(
        "argmax: Busca Normal",
        """.data
test_v: .word 1, 5, 3, 2
.text
main:
  la a1, test_v
  li a2, 4
  jal ra, argmax
  li a7, 10
  ecall""",
        0, 1
    )

    # 2.2 Argmax com empates (retorna menor índice)
    runner.assert_eq(
        "argmax: Caso de empate",
        """.data
test_v: .word 1, 5, 3, 5, 2
.text
main:
  la a1, test_v
  li a2, 5
  jal ra, argmax
  li a7, 10
  ecall""",
        0, 1
    )

    # 2.3 Tamanho inválido (< 1)
    runner.assert_eq(
        "argmax: Erro tamanho < 1",
        """.data
test_v: .word 1
.text
main:
  la a1, test_v
  li a2, 0
  jal ra, argmax
  li a7, 10
  ecall""",
        50, -1
    )

    # ----------------------------------------------------
    # 3. TESTES UNITÁRIOS: indices_to_tokens
    # ----------------------------------------------------
    print("\n--- Testando indices_to_tokens ---")
    
    # 3.1 Converter índice 2 em palavra
    runner.assert_eq(
        "indices_to_tokens: Acesso a índice normal",
        """.data
test_vocab: .string "the\\na\\ncat\\ndog\\n"
.text
main:
  la a0, test_vocab
  li a1, 2
  jal ra, indices_to_tokens
  lb t1, 0(a0)
  li t2, 99   # ASCII 'c'
  bne t1, t2, fail
  li a0, 0
  li a1, 0
  j exit
fail:
  li a0, 1
  mv a1, t1
exit:
  li a7, 10
  ecall""",
        0, 0
    )

    # ----------------------------------------------------
    # 4. TESTES UNITÁRIOS: read_file
    # ----------------------------------------------------
    print("\n--- Testando read_file ---")
    
    # Escrever um ficheiro temporário para leitura
    test_file_path = "test_read.txt"
    with open(test_file_path, "w") as f:
        f.write("Hello RISC-V!")

    runner.assert_eq(
        "read_file: Leitura normal",
        f""".data
test_filename: .string "{test_file_path}"
test_buffer:   .zero 32
.text
main:
  la a0, test_filename
  la a1, test_buffer
  li a2, 32
  jal ra, read_file
  la t0, test_buffer
  lw t1, 0(t0)        # "Hell"
  li t2, 0x6c6c6548    # "Hell" em Little Endian
  bne t1, t2, fail
  mv a1, a0            # Passar o número de bytes lidos em a1
  li a0, 0
  j exit
fail:
  li a0, 1
  mv a1, t1
exit:
  li a7, 10
  ecall""",
        0, 13
    )

    if os.path.exists(test_file_path):
        os.remove(test_file_path)

    # ----------------------------------------------------
    # 5. TESTES UNITÁRIOS: parse_matrix_buffer
    # ----------------------------------------------------
    print("\n--- Testando parse_matrix_buffer ---")
    
    runner.assert_eq(
        "parse_matrix_buffer: Matriz com inteiros e negativos",
        """.data
test_buffer: .string "-5 -3\\n6 -1\\n"
test_matrix: .zero 16
.text
main:
  la a0, test_matrix
  la a1, test_buffer
  jal ra, parse_matrix_buffer
  la t0, test_matrix
  lw t1, 0(t0)
  lw t2, 4(t0)
  lw t3, 8(t0)
  lw t4, 12(t0)
  
  li t5, -5
  bne t1, t5, fail
  li t5, -3
  bne t2, t5, fail
  li t5, 6
  bne t3, t5, fail
  li t5, -1
  bne t4, t5, fail
  
  li a0, 0
  # a1 já contém as linhas da matriz (deve ser 2)
  j exit
fail:
  li a0, 1
  li a1, -1
exit:
  li a7, 10
  ecall""",
        0, 2
    )

    # ----------------------------------------------------
    # 6. TESTES UNITÁRIOS: tokens_to_indices
    # ----------------------------------------------------
    print("\n--- Testando tokens_to_indices ---")
    
    runner.assert_eq(
        "tokens_to_indices: Tradução de palavras para índices",
        """.data
test_vocab:  .string "the\\na\\ncat\\ndog\\n"
test_input:  .string "a\\ndog\\n"
test_indices:.zero 16
.text
main:
  la a0, test_indices
  la a2, test_input
  la a3, test_vocab
  jal ra, tokens_to_indices
  la t0, test_indices
  lw t1, 0(t0) # índice de "a" -> 1
  lw t2, 4(t0) # índice de "dog" -> 3
  
  li t3, 1
  bne t1, t3, fail
  li t3, 3
  bne t2, t3, fail
  
  li a0, 0
  # a1 já contém o tamanho (deve ser 2)
  j exit
fail:
  li a0, 1
  li a1, -1
exit:
  li a7, 10
  ecall""",
        0, 2
    )

    # ----------------------------------------------------
    # 7. TESTES UNITÁRIOS: build_input_embeddings_matrix
    # ----------------------------------------------------
    print("\n--- Testando build_input_embeddings_matrix ---")
    
    runner.assert_eq(
        "build_input_embeddings_matrix: Construção da matriz",
        """.data
test_vocab_emb: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
test_indices:   .word 2, 0
test_out_emb:   .zero 32
.text
main:
  la a0, test_out_emb
  la a1, test_vocab_emb
  la a2, test_indices
  li a3, 2
  jal ra, build_input_embeddings_matrix
  
  la t0, test_out_emb
  
  lw t1, 0(t0)
  li t2, 9
  bne t1, t2, fail
  
  lw t1, 4(t0)
  li t2, 10
  bne t1, t2, fail
  
  lw t1, 8(t0)
  li t2, 11
  bne t1, t2, fail
  
  lw t1, 12(t0)
  li t2, 12
  bne t1, t2, fail
  
  lw t1, 16(t0)
  li t2, 1
  bne t1, t2, fail
  
  lw t1, 20(t0)
  li t2, 2
  bne t1, t2, fail
  
  lw t1, 24(t0)
  li t2, 3
  bne t1, t2, fail
  
  lw t1, 28(t0)
  li t2, 4
  bne t1, t2, fail
  
  li a0, 0
  li a1, 2
  j exit
fail:
  li a0, 1
  li a1, -1
exit:
  li a7, 10
  ecall""",
        0, 2
    )

    # ----------------------------------------------------
    # 8. TESTES UNITÁRIOS: matrix_multiply
    # ----------------------------------------------------
    print("\n--- Testando matrix_multiply ---")
    
    runner.assert_eq(
        "matrix_multiply: Multiplicação 2x3 por 3x2",
        """.data
test_A: .word 1, 2, 3, 4, 5, 6
test_B: .word 7, 8, 9, 10, 11, 12
test_C: .zero 16
.text
main:
  la a0, test_C
  la a1, test_A
  li a2, 2
  li a3, 3
  la a4, test_B
  li a5, 3
  li a6, 2
  jal ra, matrix_multiply
  
  la t0, test_C
  lw t1, 0(t0)  # 58
  lw t2, 4(t0)  # 64
  lw t3, 8(t0)  # 139
  lw t4, 12(t0) # 154
  
  li t5, 58
  bne t1, t5, fail
  li t5, 64
  bne t2, t5, fail
  li t5, 139
  bne t3, t5, fail
  li t5, 154
  bne t4, t5, fail
  
  li a0, 0
  li a1, 0
  j exit
fail:
  li a0, 1
  li a1, -1
exit:
  li a7, 10
  ecall""",
        0, 0
    )

    # ----------------------------------------------------
    # 9. TESTES UNITÁRIOS: compute_scores
    # ----------------------------------------------------
    print("\n--- Testando compute_scores ---")
    
    runner.assert_eq(
        "compute_scores: Cálculo de scores de atenção",
        """.data
test_Q: .word 1, 2, 3, 4, 5, 6
test_K: .word 7, 8, 9, 10, 11, 12
test_S: .zero 8
.text
main:
  la a0, test_S
  la a1, test_Q
  la a2, test_K
  li a3, 2 # rows
  li a4, 3 # cols
  li a5, 1 # target index
  jal ra, compute_scores
  
  la t0, test_S
  lw t1, 0(t0) # 122
  lw t2, 4(t0) # 167
  
  li t3, 122
  bne t1, t3, fail
  li t3, 167
  bne t2, t3, fail
  
  li a0, 0
  li a1, 0
  j exit
fail:
  li a0, 1
  li a1, -1
exit:
  li a7, 10
  ecall""",
        0, 0
    )

    # ----------------------------------------------------
    # 10. TESTES UNITÁRIOS: select_vector_in_matrix
    # ----------------------------------------------------
    print("\n--- Testando select_vector_in_matrix ---")
    
    runner.assert_eq(
        "select_vector_in_matrix: Seleção de linha",
        """.data
test_matrix: .word 1, 2, 3, 4, 5, 6, 7, 8
.text
main:
  la a1, test_matrix
  li a2, 2
  li a3, 4
  li a4, 1
  jal ra, select_vector_in_matrix
  la t0, test_matrix
  addi t0, t0, 16
  bne a0, t0, fail
  
  li a0, 0
  li a1, 0
  j exit
fail:
  li a0, 1
  li a1, -1
exit:
  li a7, 10
  ecall""",
        0, 0
    )

    # ----------------------------------------------------
    # 11. TESTES UNITÁRIOS: decide_next_token
    # ----------------------------------------------------
    print("\n--- Testando decide_next_token ---")
    
    runner.assert_eq(
        "decide_next_token: Escolha do token mais similar",
        """.data
test_target:    .word 2, -1, 3, 0
test_vocab_emb: .word 1, 1, 1, 1, 3, -2, 1, 0, -1, 0, 1, 5
.text
main:
  la a0, test_target
  la a1, test_vocab_emb
  li a2, 3
  jal ra, decide_next_token
  mv a1, a0
  li a0, 0
  li a7, 10
  ecall""",
        0, 1
    )

    # Clean up any temporary assembly file
    if os.path.exists(TEMP_TEST_PATH):
        os.remove(TEMP_TEST_PATH)

    # ----------------------------------------------------
    # 12. TESTES DE INTEGRAÇÃO (END-TO-END FLOW)
    # ----------------------------------------------------
    print("\n" + "="*60)
    print("   TESTANDO FLUXO COMPLETO (INTEGRATION TESTS)")
    print("="*60)

    # Create temporary p2-template.s with preprocessed expressions so RARS can compile it
    create_temp_p2_assembly()

    # List of integration test cases: (input words list, expected predicted word)
    integration_cases = [
        (["a", "boy", "eats"], "food"),
        (["a", "girl", "eats"], "food"),
        (["a", "bird", "drinks"], "water"),
        (["a", "fish", "needs"], "water"),
        (["a", "boy", "needs"], "food")
    ]

    input_filename = "input.txt"
    backup_filename = "input.txt.bak"

    # Backup the original input.txt
    backup_made = False
    if os.path.exists(input_filename):
        shutil.copyfile(input_filename, backup_filename)
        backup_made = True

    integration_passed = 0
    integration_failed = 0

    try:
        for idx, (words, expected) in enumerate(integration_cases, 1):
            # Write current test words to input.txt
            with open(input_filename, "w") as f:
                for w in words:
                    f.write(w + "\n")
            
            # Run the entire temp_p2.s program in RARS
            cmd = ["java", "-jar", RARS_PATH, "nc", "dec", TEMP_P2_PATH]
            result = subprocess.run(cmd, capture_output=True, text=True)
            
            if result.returncode != 0 and "Program terminated by calling exit" not in result.stdout:
                print(f"❌ INTEGRATION FAILED {idx}: {' '.join(words)} -> Erro ao executar RARS:\n{result.stderr}")
                integration_failed += 1
                continue
                
            # Parse the predicted token from the output
            lines = result.stdout.split('\n')
            predicted_word = None
            for i, line in enumerate(lines):
                if "=== Decision ===" in line:
                    # The next non-empty line should be the predicted token
                    for next_line in lines[i+1:]:
                        cleaned = next_line.strip()
                        if cleaned:
                            predicted_word = cleaned
                            break
                    break
            
            if predicted_word == expected:
                print(f"✅ INTEGRATION PASSED {idx}: {' '.join(words)} -> {predicted_word}")
                integration_passed += 1
            else:
                print(f"❌ INTEGRATION FAILED {idx}: {' '.join(words)}")
                print(f"    Esperado: {expected}")
                print(f"    Obtido:   {predicted_word}")
                integration_failed += 1

    finally:
        # Restore backup
        if backup_made:
            shutil.copyfile(backup_filename, input_filename)
            os.remove(backup_filename)
        elif os.path.exists(input_filename):
            os.remove(input_filename)
            
        # Clean up temp_p2.s
        if os.path.exists(TEMP_P2_PATH):
            os.remove(TEMP_P2_PATH)

    # ----------------------------------------------------
    # RESUMO GERAL
    # ----------------------------------------------------
    print("\n" + "="*60)
    print("   RESUMO DOS TESTES DO PROJETO 2")
    print("="*60)
    total_passed = runner.passed + integration_passed
    total_failed = runner.failed + integration_failed
    print(f"Unit Tests:  {runner.passed} passaram, {runner.failed} falharam.")
    print(f"Integration: {integration_passed} passaram, {integration_failed} falharam.")
    print(f"Total Geral: {total_passed} passaram, {total_failed} falharam.")
    print("="*60)

    if total_failed > 0:
        sys.exit(1)

if __name__ == '__main__':
    main()
