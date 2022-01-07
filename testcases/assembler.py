read_file = open("TwoOperand.asm", "r")
array = ["0000000000000000" for i in range(300)]
array_counter = 0 
lines = read_file.readlines()
for i in range(len(lines)):
    line = lines[i].split()
    if len(line) > 0:
        if(not lines[i].startswith("#")):  
            if(lines[i].startswith(".ORG")):
                next_line = lines[i + 1].split()
                if len(next_line) == 1:
                    array[int(line[1])] = '{0:016b}'.format(int(next_line[0], 16))
                    i = i + 1
                else:
                    array_counter = int(line[1], 16)
            if(lines[i].startswith("SETC")):
                array[array_counter] = "0000000000000010"
                array_counter += 1 
            if(lines[i].startswith("NOP")):
                array[array_counter] = "0000000000000000"
                array_counter += 1 
            if(lines[i].startswith("HLT")):
                array[array_counter] = "0000000000000001"
                array_counter += 1 
            if(lines[i].startswith("NOT")):
                if(line[1] == 'R0'): 
                    array[array_counter] = "00000000000" + "00011"
                elif(line[1] == 'R1'):
                    array[array_counter] = "00001000001" + "00011"
                elif(line[1] == 'R2'): 
                    array[array_counter] = "00010000010" + "00011"
                elif(line[1] == 'R3'): 
                    array[array_counter] = "00011000011" + "00011"
                elif(line[1] == 'R4'): 
                    array[array_counter] = "00100000100" + "00011"
                elif(line[1] == 'R5'): 
                    array[array_counter] = "00101000101" + "00011"
                elif(line[1] == 'R6'): 
                    array[array_counter] = "00110000110" + "00011"
                else: 
                    array[array_counter] = "00111000111" + array[array_counter]
                array_counter += 1
            if(lines[i].startswith("INC")):
                array[array_counter] = "00100"
                if(line[1] == 'R0'): 
                    array[array_counter] = "00000000000" + array[array_counter]
                if(line[1] == 'R1'): 
                    array[array_counter] = "00001000001" + array[array_counter]
                if(line[1] == 'R2'): 
                    array[array_counter] = "00010000010" + array[array_counter]
                if(line[1] == 'R3'): 
                    array[array_counter] = "00011000011" + array[array_counter]
                if(line[1] == 'R4'): 
                    array[array_counter] = "00100000100" + array[array_counter]
                if(line[1] == 'R5'): 
                    array[array_counter] = "00101000101" + array[array_counter]
                if(line[1] == 'R6'): 
                    array[array_counter] = "00110000110" + array[array_counter]
                if(line[1] == 'R7'): 
                    array[array_counter] = "00111000111" + array[array_counter]
                array_counter += 1 
            if(lines[i].startswith("IN")):
                array[array_counter] = "00110"
                if(line[1] == 'R0'): 
                    array[array_counter] = "00000000000" + array[array_counter]
                if(line[1] == 'R1'): 
                    array[array_counter] = "00001000000" + array[array_counter]
                if(line[1] == 'R2'): 
                    array[array_counter] = "00010000000" + array[array_counter]
                if(line[1] == 'R3'): 
                    array[array_counter] = "00011000000" + array[array_counter]
                if(line[1] == 'R4'): 
                    array[array_counter] = "00100000000" + array[array_counter]
                if(line[1] == 'R5'): 
                    array[array_counter] = "00101000000" + array[array_counter]
                if(line[1] == 'R6'): 
                    array[array_counter] = "00110000000" + array[array_counter]
                if(line[1] == 'R7'): 
                    array[array_counter] = "00111000000" + array[array_counter]
                array_counter += 1 
            if(lines[i].startswith("OUT")):
                array[array_counter] = "00101"
                if(line[1] == 'R0'): 
                    array[array_counter] = "00000000000" + array[array_counter]
                if(line[1] == 'R1'): 
                    array[array_counter] = "00000000001" + array[array_counter]
                if(line[1] == 'R2'): 
                    array[array_counter] = "00000000010" + array[array_counter]
                if(line[1] == 'R3'): 
                    array[array_counter] = "00000000011" + array[array_counter]
                if(line[1] == 'R4'): 
                    array[array_counter] = "00000000100" + array[array_counter]
                if(line[1] == 'R5'): 
                    array[array_counter] = "00000000101" + array[array_counter]
                if(line[1] == 'R6'): 
                    array[array_counter] = "00000000110" + array[array_counter]
                if(line[1] == 'R7'): 
                    array[array_counter] = "00000000111" + array[array_counter]
                array_counter += 1
            ################################ two operand 
            if(lines[i].startswith("MOV")):
                array[array_counter] = "00111"
                reg = line[1].split(',')
                if(reg[0] == 'R0'): 
                    array[array_counter] = "000000" + array[array_counter]
                if(reg[0] == 'R1'): 
                    array[array_counter] = "000001" + array[array_counter]
                if(reg[0] == 'R2'): 
                    array[array_counter] = "000010" + array[array_counter]
                if(reg[0] == 'R3'): 
                    array[array_counter] = "000011" + array[array_counter]
                if(reg[0] == 'R4'): 
                    array[array_counter] = "000100" + array[array_counter]
                if(reg[0] == 'R5'): 
                    array[array_counter] = "000101" + array[array_counter]
                if(reg[0] == 'R6'): 
                    array[array_counter] = "000110" + array[array_counter]
                if(reg[0] == 'R7'): 
                    array[array_counter] = "000111" + array[array_counter]
                ############### destination
                if(reg[1] == 'R0'): 
                    array[array_counter] = "00000" + array[array_counter]
                if(reg[1] == 'R1'): 
                    array[array_counter] = "00001" + array[array_counter]
                if(reg[1] == 'R2'): 
                    array[array_counter] = "00010" + array[array_counter]
                if(reg[1] == 'R3'): 
                    array[array_counter] = "00011" + array[array_counter]
                if(reg[1] == 'R4'): 
                    array[array_counter] = "00100" + array[array_counter]
                if(reg[1] == 'R5'): 
                    array[array_counter] = "00101" + array[array_counter]
                if(reg[1] == 'R6'): 
                    array[array_counter] = "00110" + array[array_counter]
                if(reg[1] == 'R7'): 
                    array[array_counter] = "00111" + array[array_counter]
                array_counter += 1 
            if(lines[i].startswith("ADD")):
                array[array_counter] = "01000"
                reg = line[1].split(',')
                if(reg[0] == 'R0'): 
                    array[array_counter] = "000" + array[array_counter]
                if(reg[0] == 'R1'): 
                    array[array_counter] = "001" + array[array_counter]
                if(reg[0] == 'R2'): 
                    array[array_counter] = "010" + array[array_counter]
                if(reg[0] == 'R3'): 
                    array[array_counter] = "011" + array[array_counter]
                if(reg[0] == 'R4'): 
                    array[array_counter] = "100" + array[array_counter]
                if(reg[0] == 'R5'): 
                    array[array_counter] = "101" + array[array_counter]
                if(reg[0] == 'R6'): 
                    array[array_counter] = "110" + array[array_counter]
                if(reg[0] == 'R7'): 
                    array[array_counter] = "111" + array[array_counter]
                ###########source 2
                if(reg[1] == 'R0'): 
                    array[array_counter] = "000" + array[array_counter]
                if(reg[1] == 'R1'): 
                    array[array_counter] = "001" + array[array_counter]
                if(reg[1] == 'R2'): 
                    array[array_counter] = "010" + array[array_counter]
                if(reg[1] == 'R3'): 
                    array[array_counter] = "011" + array[array_counter]
                if(reg[1] == 'R4'): 
                    array[array_counter] = "100" + array[array_counter]
                if(reg[1] == 'R5'): 
                    array[array_counter] = "101" + array[array_counter]
                if(reg[1] == 'R6'): 
                    array[array_counter] = "110" + array[array_counter]
                if(reg[1] == 'R7'): 
                    array[array_counter] = "111" + array[array_counter]
                ############### destination
                if(reg[2] == 'R0'): 
                    array[array_counter] = "00000" + array[array_counter]
                if(reg[2] == 'R1'): 
                    array[array_counter] = "00001" + array[array_counter]
                if(reg[2] == 'R2'): 
                    array[array_counter] = "00010" + array[array_counter]
                if(reg[2] == 'R3'): 
                    array[array_counter] = "00011" + array[array_counter]
                if(reg[2] == 'R4'): 
                    array[array_counter] = "00100" + array[array_counter]
                if(reg[2] == 'R5'): 
                    array[array_counter] = "00101" + array[array_counter]
                if(reg[2] == 'R6'): 
                    array[array_counter] = "00110" + array[array_counter]
                if(reg[2] == 'R7'): 
                    array[array_counter] = "00111" + array[array_counter]
                array_counter += 1
            if(lines[i].startswith("SUB")):
                array[array_counter] = "01001"
                reg = line[1].split(',')
                if(reg[0] == 'R0'): 
                    array[array_counter] = "000" + array[array_counter]
                if(reg[0] == 'R1'): 
                    array[array_counter] = "001" + array[array_counter]
                if(reg[0] == 'R2'): 
                    array[array_counter] = "010" + array[array_counter]
                if(reg[0] == 'R3'): 
                    array[array_counter] = "011" + array[array_counter]
                if(reg[0] == 'R4'): 
                    array[array_counter] = "100" + array[array_counter]
                if(reg[0] == 'R5'): 
                    array[array_counter] = "101" + array[array_counter]
                if(reg[0] == 'R6'): 
                    array[array_counter] = "110" + array[array_counter]
                if(reg[0] == 'R7'): 
                    array[array_counter] = "111" + array[array_counter]
                ###########source 2
                if(reg[1] == 'R0'): 
                    array[array_counter] = "000" + array[array_counter]
                if(reg[1] == 'R1'): 
                    array[array_counter] = "001" + array[array_counter]
                if(reg[1] == 'R2'): 
                    array[array_counter] = "010" + array[array_counter]
                if(reg[1] == 'R3'): 
                    array[array_counter] = "011" + array[array_counter]
                if(reg[1] == 'R4'): 
                    array[array_counter] = "100" + array[array_counter]
                if(reg[1] == 'R5'): 
                    array[array_counter] = "101" + array[array_counter]
                if(reg[1] == 'R6'): 
                    array[array_counter] = "110" + array[array_counter]
                if(reg[1] == 'R7'): 
                    array[array_counter] = "111" + array[array_counter]
                ############### destination
                if(reg[2] == 'R0'): 
                    array[array_counter] = "00000" + array[array_counter]
                if(reg[2] == 'R1'): 
                    array[array_counter] = "00001" + array[array_counter]
                if(reg[2] == 'R2'): 
                    array[array_counter] = "00010" + array[array_counter]
                if(reg[2] == 'R3'): 
                    array[array_counter] = "00011" + array[array_counter]
                if(reg[2] == 'R4'): 
                    array[array_counter] = "00100" + array[array_counter]
                if(reg[2] == 'R5'): 
                    array[array_counter] = "00101" + array[array_counter]
                if(reg[2] == 'R6'): 
                    array[array_counter] = "00110" + array[array_counter]
                if(reg[2] == 'R7'): 
                    array[array_counter] = "00111" + array[array_counter]
                array_counter += 1
            if(lines[i].startswith("AND")):
                array[array_counter] = "01010"
                reg = line[1].split(',')
                if(reg[0] == 'R0'): 
                    array[array_counter] = "000" + array[array_counter]
                if(reg[0] == 'R1'): 
                    array[array_counter] = "001" + array[array_counter]
                if(reg[0] == 'R2'): 
                    array[array_counter] = "010" + array[array_counter]
                if(reg[0] == 'R3'): 
                    array[array_counter] = "011" + array[array_counter]
                if(reg[0] == 'R4'): 
                    array[array_counter] = "100" + array[array_counter]
                if(reg[0] == 'R5'): 
                    array[array_counter] = "101" + array[array_counter]
                if(reg[0] == 'R6'): 
                    array[array_counter] = "110" + array[array_counter]
                if(reg[0] == 'R7'): 
                    array[array_counter] = "111" + array[array_counter]
                ###########source 2
                if(reg[1] == 'R0'): 
                    array[array_counter] = "000" + array[array_counter]
                if(reg[1] == 'R1'): 
                    array[array_counter] = "001" + array[array_counter]
                if(reg[1] == 'R2'): 
                    array[array_counter] = "010" + array[array_counter]
                if(reg[1] == 'R3'): 
                    array[array_counter] = "011" + array[array_counter]
                if(reg[1] == 'R4'): 
                    array[array_counter] = "100" + array[array_counter]
                if(reg[1] == 'R5'): 
                    array[array_counter] = "101" + array[array_counter]
                if(reg[1] == 'R6'): 
                    array[array_counter] = "110" + array[array_counter]
                if(reg[1] == 'R7'): 
                    array[array_counter] = "111" + array[array_counter]
                ############### destination
                if(reg[2] == 'R0'): 
                    array[array_counter] = "00000" + array[array_counter]
                if(reg[2] == 'R1'): 
                    array[array_counter] = "00001" + array[array_counter]
                if(reg[2] == 'R2'): 
                    array[array_counter] = "00010" + array[array_counter]
                if(reg[2] == 'R3'): 
                    array[array_counter] = "00011" + array[array_counter]
                if(reg[2] == 'R4'): 
                    array[array_counter] = "00100" + array[array_counter]
                if(reg[2] == 'R5'): 
                    array[array_counter] = "00101" + array[array_counter]
                if(reg[2] == 'R6'): 
                    array[array_counter] = "00110" + array[array_counter]
                if(reg[2] == 'R7'): 
                    array[array_counter] = "00111" + array[array_counter]
                array_counter += 1
            if(lines[i].startswith("IADD")):
                array[array_counter] = "01011"
                reg = line[1].split(',')
                array[array_counter + 1] = '{0:016b}'.format(int(reg[2], 16))
                if(reg[0] == 'R0'): 
                    array[array_counter] = "000000" + array[array_counter]
                if(reg[0] == 'R1'): 
                    array[array_counter] = "000001" + array[array_counter]
                if(reg[0] == 'R2'): 
                    array[array_counter] = "000010" + array[array_counter]
                if(reg[0] == 'R3'): 
                    array[array_counter] = "000011" + array[array_counter]
                if(reg[0] == 'R4'): 
                    array[array_counter] = "000100" + array[array_counter]
                if(reg[0] == 'R5'): 
                    array[array_counter] = "000101" + array[array_counter]
                if(reg[0] == 'R6'): 
                    array[array_counter] = "000110" + array[array_counter]
                if(reg[0] == 'R7'): 
                    array[array_counter] = "000111" + array[array_counter]
                ############### destination
                if(reg[1] == 'R0'): 
                    array[array_counter] = "00000" + array[array_counter]
                if(reg[1] == 'R1'): 
                    array[array_counter] = "00001" + array[array_counter]
                if(reg[1] == 'R2'): 
                    array[array_counter] = "00010" + array[array_counter]
                if(reg[1] == 'R3'): 
                    array[array_counter] = "00011" + array[array_counter]
                if(reg[1] == 'R4'): 
                    array[array_counter] = "00100" + array[array_counter]
                if(reg[1] == 'R5'): 
                    array[array_counter] = "00101" + array[array_counter]
                if(reg[1] == 'R6'): 
                    array[array_counter] = "00110" + array[array_counter]
                if(reg[1] == 'R7'): 
                    array[array_counter] = "00111" + array[array_counter]
                array_counter += 2
write_file = open("TwoOperand.mem", "a")
for arr in array:
        write_file.write(arr)
        write_file.write('\n')
write_file.close()