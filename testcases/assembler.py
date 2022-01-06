read_file = open("OneOperand.asm", "r")
print(read_file.read())

write_file = open("OneOperand.mem", "a")
write_file.write("Now the file has more content!")
write_file.close()