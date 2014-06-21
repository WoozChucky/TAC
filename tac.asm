.8086
.model small
.stack 2048h

dados SEGMENT PARA 'DATA'

	;File variables
	filename db 'da-menu.txt',0
	filename_aritmetica db 'arit.txt',0
	filename_dados db 'dp.txt',0
	file dw 0
	buffer db ?
	
	;Main variables
	num db 8 dup(0)
	num_int dw ?
	base db 0
	year dw 0
	
	;Aritmetic Variables
	num1 db 8 dup(0)
	cont1 dw 0
	num2 db 8 dup(0)
	cont2 dw 0
	result dw 0;

	;Strings	
	string_file_open_error db 'Erro ao abrir o ficheiro!$'
	string_file_open_error_2 db 'Erro ao abrir ficheiro data.txt!$'
	string_file_close_error db 'Erro ao fechar o ficheiro!$'
	string_file_read_error db 'Erro ao ler o ficheiro!$'
	string_overflow_error db 'Foi gerado um overflow!$'
	string_get_action db 'Escolha a operacao a realizar: $'
	string_get_bin db 'Introduza um numero em binario (0 ou 1): $'
	string_invalid_input db 'O digito introduzido nao e valido! $'
	string_diff db 'Nao tem o mesmo numero de digitos! $'
	string_test db 'Fim de programa$'
	
	string_program_exit db 'Programa concluiu com sucesso!$'
	
	string_getnumber db 'Insira o numero a converter: $'
	string_getbase DB 'Insira a base do numero: $'
	
dados ENDS

codigo SEGMENT PARA 'CODE'

	ASSUME CS:codigo, DS:dados
	
	main PROC
	
		; Program startup
		MOV AX, dados
		MOV DS, AX
		MOV SI, 0
		MOV DI, 0
		
		choose_action:
			call newline
			call file_proc ;Procedure of file reading and menu display
			call newline
			MOV AH, 09h ;Write string to output
			LEA DX, string_get_action
			INT 21h
			MOV AH, 01h ;Reads characters from input
			INT 21h
			CMP AL, '1'
			JE menu_aritmetica
			CMP AL, '2'
			JE menu_conversoes
			CMP AL, '3'
			JE fim_scnd
			JNE choose_action_error
		
		fim_scnd:
			call save_data
			JMP fim
		
		choose_action_error:
			call newline
			MOV AH, 09h
			LEA DX, string_invalid_input
			INT 21h
			JMP choose_action
		
		menu_aritmetica:
			call newline
			call load_aritmetica ;Procedure for aritmetica menu display
			call newline
			MOV AH, 09h ;Write string to output
			LEA DX, string_get_action
			INT 21h
			MOV AH, 01h ;Reads characters from input
			INT 21h
			CMP AL, '1'
			MOV SI, 0
			JE get_nums_bin  ;Soma binario puro
			CMP AL, '2'
			MOV SI, 0
			JE get_nums_bin  ;Subtração em binário puro
			CMP AL, '3'
			JE fim;Soma em hexadecimal
			CMP AL, '4'
			JE fim;Subtracao em hexadecimal
			CMP AL, '5'
			JE fim;Complementos de 2
			CMP AL, '6'
			JE choose_action
			JNE menu_aritmetica_error
			
		menu_aritmetica_error:
			call newline
			MOV AH, 09H
			LEA DX, string_invalid_input
			INT 21h
			JMP menu_aritmetica
			
		menu_conversoes:
			JMP menu_options
		
		get_nums_bin:
			call newline
			call newline
			MOV AH, 09h ;Write string to output
			LEA DX, string_get_bin
			INT 21h
			MOV SI, 0
			
		get_num1:
			MOV AH, 01h ;Reads characters from input
			INT 21h
			CMP AL, '0'
			JE apply_input1
			CMP AL, '1'
			JE apply_input1
			CMP AL, 13 ;pressed <enter>
			JE get_nums2_bin
			JMP get_num1
			
		apply_input1:
			MOV num1[SI], AL
			INC SI
			CMP SI, 7 ;if JE, means vector is full
			JE get_nums2_bin
			JMP get_num1
			
		get_nums2_bin:
			call newline
			MOV AH, 09h ;Write string to output
			LEA DX, string_get_bin
			INT 21h
			MOV cont1, SI
			MOV SI, 0
			
		get_num2:
			MOV AH, 01h ;Reads characters from input
			INT 21h
			CMP AL, '0'
			JE apply_input2
			CMP AL, '1'
			JE apply_input2
			CMP AL, 13 ;pressed <enter>
			JE compare_bin_vectors
			JMP get_num2
		
		apply_input2:
			MOV num2[SI], AL
			INC SI
			CMP SI, 7 ;if JE, means vector is full
			JE compare_bin_vectors
			JMP get_num2
			
		compare_bin_vectors:
			MOV cont2, SI
			CMP cont1, SI
			
			MOV cont1, SI
			MOV cont2, DI
			
			JA cont1_higher
			
			;cont2 é maior aqui
			JMP do_soma_bin
			
			cont1_higher:
				MOV AL, 0
				
				CMP SI, -1 ;cont1
				JNE set_digit1 
				
				next_digit1:
					ADD AL, num1[SI]
					DEC SI; cont1
					JMP fim
					
				set_digit1:
					CMP DI, -1; cont2
					JNE fim
					
				next_digit2:
					ADD AL, num2[DI]
					DEC DI
				
			JMP do_soma_bin
				
			call newline
			MOV AH, 09h
			LEA DX, string_diff
			INT 21h
			call newline
			
		do_soma_bin:
		JMP fim
			
		
		menu_options:
			call newline
			MOV AH, 09h ;Write string to output
			LEA DX, string_getnumber
			INT 21h
			MOV CX, 0
			MOV SI, 0
			JMP read_number_cycle
			
		read_number_cycle:
			;Asks user the number to be converted
			MOV AH, 01h ;Read character from input
			INT 21h
			MOV num[SI], AL
			INC SI
			INC CX
			CMP SI, 7
			JE conversions_menu
			CMP AL, 13
			JE conversions_menu
			JMP read_number_cycle
			
		convert_string_to_int:
			MOV BL, 10
			MOV BH, 0
			SUB num[SI], 48
			MOV AL, num[SI]
			MUL BX
			MOV AH, 0
			ADD num_int, AX
			CMP SI, CX
			INC SI
			JE convert_string_to_int_last_digit
			JMP convert_string_to_int
			
		convert_string_to_int_last_digit:
			SUB num[SI], 48
			MOV AL, num[SI]
			MOV AH, 0
			ADD num_int, AX
			JMP get_base
		
		conversions_menu:
			SUB CX, 2
			MOV SI, 0
			JMP get_base
			
		get_base:
			call newline
			MOV AH, 09h ;Write string to output
			LEA DX, string_getbase
			INT 21h
			MOV CX, 0
			MOV SI, 0
			JMP read_base_cycle
		
		read_base_cycle:
			;Asks user the base
			MOV AH, 01h ;Read character from input
			INT 21h
			CMP AL, '2'
			JE accept_base
			CMP AL, '3'
			JE accept_base
			CMP AL, '4'
			JE accept_base
			CMP AL, '5'
			JE accept_base
			CMP AL, '6'
			JE accept_base
			CMP AL, '7'
			JE accept_base
			CMP AL, '8'
			JE accept_base
			CMP AL, '9'
			JE accept_base
			;CMP AL, '10'
			;JE accept_base
			;CMP AL, '11'
			;JE accept_base
			;CMP AL, '12'
			;JE accept_base
			;CMP AL, '13'
			;JE accept_base
			;CMP AL, '14'
			;JE accept_base
			;CMP AL, '15'
			;JE accept_base
			;CMP AL, '16'
			;JE accept_base
			;CMP AL, '17'
			;JE accept_base
			;CMP AL, '18'
			;JE accept_base
			;CMP AL, '19'
			;JE accept_base
			;CMP AL, '20'
			;JE accept_base
			JMP get_base
			
		accept_base:
			MOV base, AL
			JMP fim
		
		; End of programm
		fim:
			call newline
			MOV AH, 09h ;Write string to output
			LEA DX, string_program_exit
			INT 21h
			MOV AX, 4c00h
			INT 21h	
			
	main ENDP
	
	newline PROC
			mov dx,10
		    mov ah,2
		    int 21h  
		    mov dx,13
		    mov ah,2
		    int 21h
			ret
	newline ENDP
	
	load_aritmetica PROC
		; Open menu file
		MOV AH, 3dh ;Open file - 3Dh
		MOV AL, 0
		LEA DX, filename_aritmetica
		INT 21h
		JC error_fileopen
		MOV file, AX
		JMP file_read_cycle
		
		; Error opening menu file
		error_fileopen:
			MOV AH, 09h ;Write string to output
			LEA DX, string_file_open_error
			INT 21h
			JMP fim
		
		; File reading cycle (1 char at a time)
		file_read_cycle:
			MOV AH, 3fh ;Reads single character
			MOV BX, file
			MOV CX, 1
			LEA DX, buffer
			INT 21h
			JC reading_error
			CMP AX, 0
			JE close_file
			MOV AH, 02h ;Write character to output
			MOV DL, buffer
			INT 21h
			JMP file_read_cycle
			
		; Reading error
		reading_error:
			MOV AH, 09h ;Write string to output
			LEA DX, string_file_read_error
			INT 21h
		
		; File close
		close_file:
			MOV AH, 3eh ;Close file - 3Eh
			MOV BX, file
			INT 21h
			JNC sair ;If not carry, goto menu_options
			
			MOV AH, 09h ;Write string to output
			LEA DX, string_file_close_error
			INT 21h
			
		sair:
			ret
		; End of programm
		fim:
			MOV AH, 09h ;Write string to output
			LEA DX, string_program_exit
			INT 21h
			MOV AX, 4c00h
			INT 21h		
	load_aritmetica ENDP

	file_proc PROC
		; Open menu file
		MOV AH, 3dh ;Open file - 3Dh
		MOV AL, 0
		LEA DX, filename
		INT 21h
		JC error_fileopen
		MOV file, AX
		JMP file_read_cycle
		
		; Error opening menu file
		error_fileopen:
			MOV AH, 09h ;Write string to output
			LEA DX, string_file_open_error
			INT 21h
			JMP fim
		
		; File reading cycle (1 char at a time)
		file_read_cycle:
			MOV AH, 3fh ;Reads single character
			MOV BX, file
			MOV CX, 1
			LEA DX, buffer
			INT 21h
			JC reading_error
			CMP AX, 0
			JE close_file
			MOV AH, 02h ;Write character to output
			MOV DL, buffer
			INT 21h
			JMP file_read_cycle
			
		; Reading error
		reading_error:
			MOV AH, 09h ;Write string to output
			LEA DX, string_file_read_error
			INT 21h
		
		; File close
		close_file:
			MOV AH, 3eh ;Close file - 3Eh
			MOV BX, file
			INT 21h
			JNC sair ;If not carry, goto menu_options
			
			MOV AH, 09h ;Write string to output
			LEA DX, string_file_close_error
			INT 21h
			
		sair:
			ret
		; End of programm
		fim:
			MOV AH, 09h ;Write string to output
			LEA DX, string_program_exit
			INT 21h
			MOV AX, 4c00h
			INT 21h		
			
	file_proc ENDP
	
	save_data PROC
		INT 3
		; Open menu file
		MOV AH, 3Ch ;Create file - 3Ch
		MOV AL, 0
		MOV CX, 0
		LEA DX, filename_dados
		INT 21h
		JNC get_data
		JMP fim
		
		get_data:
			MOV file, AX
			call newline
			;MOV AH, 2Ch
			;INT 21h
			;CH Horas
			;CL Minutos
			;DH Segundos
			MOV AH, 2Ah
			INT 21h
			;CX Ano
			;DH Mês
			;DL Dia
			
			PUSH CX ;Move year to the stack
			MOV CX, 0 ;Clear CX
			
			MOV CL, DL
			PUSH CX ;Move day to stack

			MOV CL, DH
			PUSH CX
			
			MOV DH, 0 ;Clear DH
			
			MOV DX, 0
			POP AX
			MOV CX, 0
			MOV BX, 10
		
		dividem:
			DIV BX
			PUSH DX
			
			ADD CX, 1
			MOV DX, 0
			CMP AX, 0
			JNE dividem
		divdispm:
			POP BX
			ADD BL, 30h			
			LOOP divdispm

		JMP write_to_file
		
		write_to_file:
			MOV BX, file
			MOV AH, 40h
			LEA DX, string_test
			MOV CX, 16
			INT 21h
			JNC close_file
			
		; Error opening menu file
		error_fileopen:
			MOV AH, 09h ;Write string to output
			LEA DX, string_file_open_error_2
			INT 21h
			JMP fim
		
		; File close
		close_file:
			MOV AH, 3eh ;Close file - 3Eh
			MOV BX, file
			INT 21h
			JNC fim ;If not carry, goto menu_options
			
			MOV AH, 09h ;Write string to output
			LEA DX, string_file_close_error
			INT 21h
			
		sair:
			ret
		; End of programm
		fim:
			call newline
			MOV AH, 09h ;Write string to output
			LEA DX, string_program_exit
			INT 21h
			MOV AX, 4c00h
			INT 21h	
		
		
	save_data ENDP
	
codigo ENDS

END main