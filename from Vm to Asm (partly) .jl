
#= The purpose of the exercise : open a file with .vm ending ,that written in VM language 
   and create a new file with .asm ending and convert to Hack assembly languag
=#

#M - virtual register, that exist in place A in the RAM 

labelCounter = 0 # useful for duplicates labels in the same "vm" file

#= when the line start with the word "push" , 
   get the line and the word "push" into fName
=#
function push(line, fName)
	words=split(line)
	result = ""
	
	if words[2]=="constant" # constant- Pseudo-segment that holds all the constants in the range 0 ... 32767.
		result = result * "@" * words[3] * "\n"   # A- register that contain number of row in the RAM- address register 
		result = result * "D=A" * "\n" # D- register containing a value on which the calculation will be performed- information register
		
	elseif words[2]=="local" # local- Stores the function’s local variables
		result = result * "@" * "LCL" * "\n"   #LCL - is the constant 1
		result = result * "D=M" * "\n"          # D= RAM[1] (RAM[1] is a pointer to local variables in the stack)
		result = result * "@" * words[3] * "\n" # A= words[3]
		result = result * "A=D+A" * "\n"        # A= D + words[3]
		result = result * "D=M" * "\n"          # D= RAM[A]
	
	elseif words[2]=="argument"        # argument- Stores the function's arguments
		result = result * "@" * "ARG" * "\n"      #ARG - is the constant 2 
		result = result * "D=M" * "\n"            # D= RAM[2] (RAM[2] is a pointer to parameters)
		result = result * "@" * words[3] * "\n"   # A= words[3]
		result = result * "A=D+A" * "\n"          # A= D + words[3]
		result = result * "D=M" * "\n"            # D= RAM[A]

	elseif words[2]=="this"            # this- General-purpose segments. Can be made to correspond 10 different areas in the heap. Serve various programming needs.
		result = result * "@" * "THIS" * "\n"     # THIS - is the constant 3
		result = result * "D=M" * "\n"            # D= RAM[3] (RAM[3] is the object it`s self)
		result = result * "@" * words[3] * "\n"   # A= words[3]
		result = result * "A=D+A" * "\n"          # A= D + words[3]
		result = result * "D=M" * "\n"            # D= RAM[A]
	
	elseif words[2]=="that"            # that- General-purpose segments. Can be made to correspond 10 different areas in the heap. Serve various programming needs.
		result = result * "@" * "THAT" * "\n"     #THAT - is the constant 4	
		result = result * "D=M" * "\n"            # D= RAM[4] (RAM[4] is the dynamic object)
		result = result * "@" * words[3] * "\n"   # A= words[3]
		result = result * "A=D+A" * "\n"          # A= D + words[3]
		result = result * "D=M" * "\n"            # D= RAM[A]
	
	elseif words[2]=="temp"          # temp- Fixed eight- entry segment that holds temorary variables for general use.
		result = result * "@" * words[3] * "\n"   # A- register that contain number of row in the RAM- address register 
		result = result * "D=A" * "\n"            # D- register containing a value on which the calculation will be performed- information register
		result = result * "@" * "5" * "\n"        # A= 5
		result = result * "A=D+A" * "\n"          # A= words[3] + 5
		result = result * "D=M" * "\n"            # D= RAM[A]
	
	elseif words[2]=="static"       # static- Stores static variables shared by all functions in the same .vm file
		result = result * "@" * fName * "." * words[3] * "\n"   # A= file Name . the variable
		result = result * "D=M" * "\n"                          # D= RAM[A]
		
	elseif words[2]=="pointer"     # pointer- A two entry segments. Can be made to correspond to different areas in the heap. Serve various programming needs.
		if words[3]=="0"   
			result = result * "@" * "THIS" * "\n"   # THIS - is the constant 3
			result = result * "D=M" * "\n"          # D= RAM[A]
		elseif words[3]=="1"
			result = result * "@" * "THAT" * "\n"  #THAT is the constant 4 
			result = result * "D=M" * "\n"		   # D= RAM[A]	
		end
	end
		
	result = result * "@SP" * "\n"    # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "A=M" * "\n"    # A= RAM[A]= RAM[0] 	
	result = result * "M=D" * "\n"    # saving in the stack  , RAM[A]= D 
	result = result * "@SP" * "\n"    # next sp function 
	result = result * "M=M+1" * "\n"  # M= RAM[A] +1
	return result * "\n\n"            # for convenience  
end
	
function pop(line, fName)  
	words=split(line)
	result = ""
	                    # pop local x -	pop the top of the stack into address RAM[ RAM[LCL] + x ]	,LCL =1
	if words[2]=="local"    # local- Stores the function’s local variables
		result = result * "@" * "LCL" * "\n"   # LCL - is the constant 1
		result = result * "D=M" * "\n"         # D= RAM[A] = RAM[1]
		result = result * "@" * words[3] * "\n" 
		result = result * "D=D+A" * "\n"       # D= RAM[1] + words[3]
	
		                # pop argument x - pop the top of the stack into address RAM[ RAM[ARG] + x ]	,ARG =2
	elseif words[2]=="argument"        # argument- Stores the function's arguments 
		result = result * "@" * "ARG" * "\n"   #ARG - is the constant 2 
		result = result * "D=M" * "\n"         # D= RAM[2]  (RAM[2] is a pointer to parameters)
		result = result * "@" * words[3] * "\n"  
		result = result * "D=D+A" * "\n"       # D= RAM[2] + words[3]

		             # pop this x	- pop the top of the stack into address RAM[ RAM[THIS] + x ]	,THIS =3
	elseif words[2]=="this"    # this- General-purpose segments. Can be made to correspond 10 different areas in the heap. Serve various programming needs.
		result = result * "@" * "THIS" * "\n"  # THIS - is the constant 3
		result = result * "D=M" * "\n"         # D= RAM[3] (RAM[3] is the object it`s self)
		result = result * "@" * words[3] * "\n" 
		result = result * "D=D+A" * "\n"       # D= RAM[3] + words[3]
	
		              # pop that x - pop the top of the stack into address RAM[ RAM[THAT] + x]	'THAT =4	
	elseif words[2]=="that"    # that- General-purpose segments. Can be made to correspond 10 different areas in the heap. Serve various programming needs.
		result = result * "@" * "THAT" * "\n"   # THAT - is the constant 4
		result = result * "D=M" * "\n"          # D= RAM[4] (RAM[4] is the dynamic object)
		result = result * "@" * words[3] * "\n"
		result = result * "D=D+A" * "\n"        # D= RAM[4] + words[3]
	              
		             # pop temp x - pop the top of the stack into address RAM[ 5 + x ]	5 is constant value, since temp variables are saved on RAM[5-12]
	elseif words[2]=="temp"     # temp- Fixed eight- entry segment that holds temorary variables for general use. 
		result = result * "@" * words[3] * "\n"
		result = result * "D=A+1" * "\n"       # D= words[3] + 1
		result = result * "D=D+1" * "\n"       
		result = result * "D=D+1" * "\n"
		result = result * "D=D+1" * "\n"
		result = result * "D=D+1" * "\n"
		
		             # pop pointer 0 - pop the top of the stack into address RAM[THIS]	Pointer 0 is THIS. THIS =3
	elseif words[2]=="pointer"    # pointer- A two entry segments. Can be made to correspond to different areas in the heap. Serve various programming needs.
		if words[3]=="0"
			result = result * "@" * "THIS" * "\n"    # THIS - is the constant 3
			result = result * "D=A" * "\n"           # D= 3
		elseif words[3]=="1"
			result = result * "@" * "THAT" * "\n"	 # THAT - is the constant 4
			result = result * "D=A" * "\n"           # D= 4
		end
	       
		         
				  # pop static x	pop the top of the stack into address RAM[className.x ]	.
	elseif words[2]=="static"              # static- Stores static variables shared by all functions in the same .vm file
		result = result * "@" * fName * "." * words[3] * "\n"      # A= file Name . the variable
		result = result * "D=A" * "\n"                             # D= RAM[A]
	end
	
	result = result * "@0" * "\n"
	result = result * "M=M-1" * "\n"    # SP = SP -1
	result = result * "A=M" * "\n"      # A= RAM[A]
	result = result * "A=M" * "\n"      # A= RAM[A]
	result = result * "A=A+D" * "\n"    
	result = result * "D=A-D" * "\n"
	result = result * "A=A-D" * "\n"    # swap (A,D)
	result = result * "M=D" * "\n"      # RAM[A]= D
	return result * "\n\n"
end
	
              # add - x+y , Integer addition (2's complement)
function add()
	result = ""
	result = result * "@SP" * "\n"         # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "A=M-1" * "\n"       # A = RAM[A] - 1
	result = result * "D=M" * "\n"         # D= RAM[A] 
	result = result * "A=A-1" * "\n"       # A = A - 1
	result = result * "M=D+M" * "\n"       # RAM[A]= D + RAM[A]
	result = result * "@SP" * "\n"         # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "M=M-1" * "\n"       # RAM[A]= RAM[A] - 1 
	return result * "\n\n"
end
	        # sub - x+y , Integer addition (2's complement)
function sub()
	result = ""
	result = result * "@SP" * "\n"        # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "A=M-1" * "\n"      # A = RAM[A] - 1
	result = result * "D=M" * "\n"        # D= RAM[A]
	result = result * "A=A-1" * "\n"      
	result = result * "M=M-D" * "\n"      # RAM[A]= RAM[A] - D 
	result = result * "@SP" * "\n"        # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "M=M-1" * "\n"      # RAM[A]= RAM[A] - 1
	return result * "\n\n"
end
	       # neg - (-y) , Arithmetic addition (2's complement)
function neg()
	result = ""
	result = result * "@SP" * "\n"        # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "A=M-1" * "\n"      # A = RAM[A] - 1
	result = result * "M=-M" * "\n"       # RAM[A]= - RAM[A]
	return result * "\n\n" 
end
	      # eq - true if x=y and false otherwise , Equality   
function eq()
	result = ""
	global labelCounter+=1
	result = result * "@SP" * "\n"       # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "A=M-1" * "\n"     # A = RAM[A] - 1
	result = result * "D=M" * "\n"       # D = RAM[A]
	result = result * "A=A-1" * "\n" 
	result = result * "D=D-M" * "\n"     # D = D - RAM[A]   
	result = result * "@IF_TRUE" * "$labelCounter" * "\n"   # Load address to jump
	result = result * "D;JEQ" * "\n"     # JEQ - If the result of the calculation is equal to 0
	result = result * "D=0" * "\n"
	result = result * "@SP" * "\n"       # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "A=M-1" * "\n"     # A = RAM[A] - 1
	result = result * "A=A-1" * "\n"
	result = result * "M=D" * "\n"       # RAM[A] = 0
	result = result * "@IF_FALSE" * "$labelCounter" * "\n"    
	result = result * "0;JMP" * "\n"     # Want to jump to the end, so as not to carry out the commands of "otherwise"
	result = result * "(IF_TRUE" * "$labelCounter" * ")" * "\n"   
	result = result * "D=-1" * "\n"     
	result = result * "@SP" * "\n"       # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "A=M-1" * "\n"     # A = RAM[A] - 1
	result = result * "A=A-1" * "\n"   
	result = result * "M=D" * "\n"       # RAM[A] = 0
	result = result * "(IF_FALSE" * "$labelCounter" * ")" * "\n"
	result = result * "@SP" * "\n"       # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "M=M-1" * "\n"     # RAM[A]= RAM[A] - 1
	return result * "\n\n"
end
	
         # gt - true if x>y and false otherwise , Greaeter than
function gt()
	result = ""
	global labelCounter+=1
	result = result * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "A=M-1" * "\n"    # A = RAM[A] - 1
	result = result * "D=M" * "\n"      # D = RAM[A]
	result = result * "A=A-1" * "\n" 
	result = result * "D=M-D" * "\n"    # D = D - RAM[A]
	result = result * "@IF_TRUE" * "$labelCounter" * "\n"
	result = result * "D;JGT" * "\n"    # If the result of the calculation is greater than 0
	result = result * "D=0" * "\n"      
	result = result * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "A=M-1" * "\n"    # A = RAM[A] - 1
	result = result * "A=A-1" * "\n"
	result = result * "M=D" * "\n"      # RAM[A] = 0
	result = result * "@IF_FALSE" * "$labelCounter" * "\n"
	result = result * "0;JMP" * "\n"    # Want to jump to the end, so as not to carry out the commands of "otherwise"
	result = result * "(IF_TRUE" * "$labelCounter" * ")" * "\n"
	result = result * "D=-1" * "\n"
	result = result * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "A=M-1" * "\n"    # A = RAM[A] - 1
	result = result * "A=A-1" * "\n"
	result = result * "M=D" * "\n"      # RAM[A] = 0
	result = result * "(IF_FALSE" * "$labelCounter" * ")" * "\n"
	result = result * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "M=M-1" * "\n"    # RAM[A]= RAM[A] - 1
	return result * "\n\n"
end
	
          # lt - true if x<y and false otherwise 
function lt()
	result = ""
	global labelCounter+=1
	result = result * "@SP" * "\n"     # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "A=M-1" * "\n"   # A = RAM[A] - 1
	result = result * "D=M" * "\n"     # D = RAM[A]
	result = result * "A=A-1" * "\n" 
	result = result * "D=M-D" * "\n"   # D = D - RAM[A]
	result = result * "@IF_TRUE" * "$labelCounter" * "\n"
	result = result * "D;JLT" * "\n"   # If the calculation result is less than 0
	result = result * "D=0" * "\n"
	result = result * "@SP" * "\n"     # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack  
	result = result * "A=M-1" * "\n"   # A = RAM[A] - 1
	result = result * "A=A-1" * "\n"
	result = result * "M=D" * "\n"     # RAM[A] = 0
	result = result * "@IF_FALSE" * "$labelCounter" * "\n"
	result = result * "0;JMP" * "\n"   # Want to jump to the end, so as not to carry out the commands of "otherwise"
	result = result * "(IF_TRUE" * "$labelCounter" * ")" * "\n"
	result = result * "D=-1" * "\n"
	result = result * "@SP" * "\n"     # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack 
	result = result * "A=M-1" * "\n"   # A = RAM[A] - 1
	result = result * "A=A-1" * "\n"
	result = result * "M=D" * "\n"     # RAM[A] = 0
	result = result * "(IF_FALSE" * "$labelCounter" * ")" * "\n"
	result = result * "@SP" * "\n"     # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "M=M-1" * "\n"   # RAM[A]= RAM[A] - 1
	return result * "\n\n"
end
	
	        # and - x And y 
function and()
	result = ""
	global labelCounter+=1
	result = result * "@SP" * "\n"     # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "A=M-1" * "\n"   # A = RAM[A] - 1
	result = result * "D=M" * "\n"     # D = RAM[A]
	result = result * "A=A-1" * "\n" 
	result = result * "D=D&M" * "\n"   # D = -1 or 0
	result = result * "@IF_FALSE" * "$labelCounter" * "\n"
	result = result * "D;JEQ" * "\n"   # If the result of the calculation is equal to 0
	result = result * "@SP" * "\n"     # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "A=M-1" * "\n"   # A = RAM[A] - 1
	result = result * "A=A-1" * "\n"
	result = result * "M=D" * "\n"     # RAM[A] = 0
	result = result * "@IF_TRUE" * "$labelCounter" * "\n"
	result = result * "0;JMP" * "\n"   # Want to jump to the end, so as not to carry out the commands of "otherwise"
	result = result * "(IF_FALSE" * "$labelCounter" * ")" * "\n"
	result = result * "@SP" * "\n"     # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "A=M-1" * "\n"   # A = RAM[A] - 1
	result = result * "A=A-1" * "\n"
	result = result * "M=D" * "\n"     # RAM[A] = 0
	result = result * "(IF_TRUE" * "$labelCounter" * ")" * "\n"
	result = result * "@SP" * "\n"     # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	result = result * "M=M-1" * "\n"   # RAM[A]= RAM[A] - 1
	return result * "\n\n"
end

          # or - x Or y
function or()
  result = ""
  global labelCounter+=1
  result = result * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
  result = result * "A=M-1" * "\n"    # A = RAM[A] - 1
  result = result * "D=M" * "\n"      # D = RAM[A]
  result = result * "A=A-1" * "\n" 
  result = result * "D=D|M" * "\n"    # D = -1 or 0
  result = result * "@IF_FALSE" * "$labelCounter" * "\n"
  result = result * "D;JEQ" * "\n"    # If the result of the calculation is equal to 0
  result = result * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
  result = result * "A=M-1" * "\n"    # A = RAM[A] - 1
  result = result * "A=A-1" * "\n"    
  result = result * "M=D" * "\n"      # RAM[A] = 0
  result = result * "@IF_TRUE" * "$labelCounter" * "\n"
  result = result * "0;JMP" * "\n"    # Want to jump to the end, so as not to carry out the commands of "otherwise"
  result = result * "(IF_FALSE" * "$labelCounter" * ")" * "\n"
  result = result * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
  result = result * "A=M-1" * "\n"    # A = RAM[A] - 1
  result = result * "A=A-1" * "\n"  
  result = result * "M=D" * "\n"      # RAM[A] = 0
  result = result * "(IF_TRUE" * "$labelCounter" * ")" * "\n"
  result = result * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
  result = result * "M=M-1" * "\n"    # RAM[A]= RAM[A] - 1
  return result * "\n\n"
end

           # Not y
function not()
  result = ""
  global labelCounter+=1
  result = result * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
  result = result * "A=M-1" * "\n"    # A = RAM[A] - 1
  result = result * "D=!M" * "\n"   
  result = result * "@IF_FALSE" * "$labelCounter" * "\n"
  result = result * "D;JEQ" * "\n"    # If the result of the calculation is equal to 0
  result = result * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
  result = result * "A=M-1" * "\n"    # A = RAM[A] - 1
  result = result * "M=D" * "\n"      # RAM[A] = D
  result = result * "@IF_TRUE" * "$labelCounter" * "\n"
  result = result * "0;JMP" * "\n"    # Want to jump to the end, so as not to carry out the commands of "otherwise"
  result = result * "(IF_FALSE" * "$labelCounter" * ")" * "\n"
  result = result * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
  result = result * "A=M-1" * "\n"    # A = RAM[A] - 1
  result = result * "M=D" * "\n"      # RAM[A] = D
  result = result * "(IF_TRUE" * "$labelCounter" * ")" * "\n"
  return result * "\n\n"
end


# ------- main -------
	
println("Enter directory name")
dirName = readline()
if sizeof(dirName)==0
	content=readdir() # default directory
else
	content=readdir(dirName)
end

for file in filter(x -> endswith(x, "vm"), content)

		inputFile=open(dirName*"\\"*file,"r") 
		fileName = file[1:length(file)-3]
		outputFile=open(fileName * ".asm", "w")
		
		for line in eachline(inputFile)
			
			if startswith(line, "push")
				write(outputFile, push(line, fileName))
			
			elseif startswith(line, "pop")
				write(outputFile,pop(line, fileName))
			
			elseif startswith(line, "add")
				write(outputFile,add())
			
			elseif startswith(line, "sub")
				write(outputFile,sub())
			
			elseif startswith(line, "neg")
				write(outputFile,neg())
			
			elseif startswith(line, "eq")
				write(outputFile,eq())
			
			elseif startswith(line, "gt")
				write(outputFile,gt())
			
			elseif startswith(line, "lt")
				write(outputFile,lt())
			
			elseif startswith(line, "and")
				write(outputFile,and())
			
			elseif startswith(line, "or")
				write(outputFile,or())
			
			elseif startswith(line, "not")
				write(outputFile,not())
			
			# if line startWith '//' do nothing
			end
		end
		
		close(outputFile)
		close(inputFile)
end
