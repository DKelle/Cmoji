import re

def create_label_map(insts):
	labels = {}
	label_count = 0
	for i, inst in enumerate(insts):
		#make a map of labels to line number
		if ".LABEL" in inst:
			label_num = inst[6:].rstrip()
			labels[label_num] = i - label_count
			label_count = label_count + 1
	return labels

def create_bit_map(insts):
	bit_map = {}

	bit_map["movi"] = '0'
	bit_map["mov"] = '0'
	bit_map["add"] = '1'
	bit_map["jmp"] = '2'
	bit_map["halt"] = '3'
	bit_map["ld"] = '4'
	bit_map["ldr"] = '5'
	bit_map["jeq"] = '6'
	bit_map["sub"] = '7'
	bit_map["print"] = '8'
	bit_map["mul"] = '9'
	bit_map["div"] = 'a'
	bit_map["jlt"] = 'b'
	return bit_map

def replace_operands(insts, labels):
	#replace all of the operands with hex
	new_insts = []
	for i, inst in enumerate(insts):
		#don't include the initial blank line or the operator
		components = re.split('\s+', inst)[1:]

		if has_three_operands(components[0]):
			#If we have three operands, the first two registers

			op1 = convert_to_hex(int(components[1][3:]))
			op2 = convert_to_hex(int(components[2][3:]))

			#the third operand is either a label or a reg
			if "LABEL" in components[3]:
				#this will be a relative jump, so make sure to subtract off the cur line number
				line_bias = i
				op3 = str(convert_to_hex(labels[components[3][5:]] - line_bias))
			else:
				op3 = convert_to_hex(int(components[3][3:]))
			new_insts.append(components[0]+' '+op1+op2+op3)
		elif has_two_operands(components[0]):
			#Because we have 2 operands, the first takes up a whole bytem instead of half byte
			op1 = convert_to_hex(int(components[1]))
			if len(op1) < 2:
				op1 = '0' + op1
			op2 = convert_to_hex(int(components[2][3:]))
			new_insts.append(components[0]+' '+op1+op2)
		elif has_one_operand(components[0]):
			#if this is a jump, we need to look up our jump in lables
			if "jmp" in components[0]:
				op1 = str(convert_to_hex(labels[components[1][5:]]))
				#make sure to fill all bits with this operand
				op1 = '0' * (3 - len(op1)) + op1
			elif "print" in components[0]:
				op1 = convert_to_hex(int(components[1][3:])) * 3
			new_insts.append(components[0]+' '+op1)
		else:
			#this must be a halt. Use 0 for other bits
			op1 = '000'
			new_insts.append(components[0]+' '+op1)
	return new_insts

def replace_operator(insts, labels, inst_to_bit):
	new_insts = []
	for inst in insts:
		components = re.split(' ', inst)
		new_insts.append(inst_to_bit[components[0]] + ' '.join(components[1:]))
	return new_insts

def convert_comment_labels(comments, labels):
	new_comments = []
	for i, comment in enumerate(comments):
		if 'LABEL' in comment:
			#get the label number
			labelnum = comment.split(' ')[-1][5:].rstrip()
			jumpnum = int(labels[labelnum])
			jump = str(jumpnum) if 'jump' in comment else '+' + str(jumpnum - i)
			new_comments.append(comment.rstrip()[0:-6]+jump)
		else:
			new_comments.append(comment.rstrip())
	return new_comments

def main():
	insts = open("a.cms").readlines()

	#parse out the comments, and save them for later
	comments = [x.split("//")[-1] for x in insts if ".LABEL" not in x.split("//")[0]]
	#parse the comments aways from the instructions
	insts = [x.split("//")[0] for x in insts]

	#Create a map of which label goes to which line number
	labels = create_label_map(insts)

	#replace 'LABEL' with the line number in the comments
	comments = convert_comment_labels(comments, labels)

	#Since we have our map, remove all of the labels
	insts = [x for x in insts if ".LABEL" not in x]

	#create a map of instructions to thier corresponding bit vals
	inst_to_bit = create_bit_map(insts)

	#Replace all of the operands with their hex values
	insts = replace_operands(insts, labels)

	#replace the name of the instructions with their correspoding bits
	insts = replace_operator(insts, labels, inst_to_bit)

	#append the comments back onto the asm to make it more readable
	insts = [x + " //" + comments[i].rstrip() for i,x in enumerate(insts)]

	#write the instructions out to a file
	fout = open('../processor/a.hex', 'w')
	fout.truncate()
	for inst in insts:
 		fout.write("%s\n" % inst)

def convert_to_hex(num):
	return str(hex(num).split('x')[1])

def has_three_operands(inst):
	three_operands = "add sub mul div ldr jeq jlt"
	return inst in three_operands

def has_two_operands(inst):
	two_operands = "mov movi ld"
	return inst in two_operands

def has_one_operand(inst):
	one_operand = "jmp print"
	return inst in one_operand

if __name__ == '__main__':
	main()