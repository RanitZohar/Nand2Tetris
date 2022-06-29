
#= The purpose of the exercise : open each files in folder with .vm ending ,that written in VM language 
   and create a new file "uniteAllFiles.asm" and convert to Hack assembly languag
=#

#M - virtual register, that exist in place A in the RAM 

labelCounter = 0 # useful for duplicates labels in the same "vm" file

#= when the line start with the word "push" , 
   get the line and the word "push" into fileName
=#
function push(line, fileName)
	words=split(line)
	combineAsm = ""
	
	if words[2]=="constant" # constant- Pseudo-segment that holds all the constants in the range 0 ... 32767.
		combineAsm = combineAsm * "@" * words[3] * "\n"   # A- register that contain number of row in the RAM- address register 
		combineAsm = combineAsm * "D=A" * "\n" # D- register containing a value on which the calculation will be performed- information register
		
	elseif words[2]=="local" # local- Stores the function’s local variables
		combineAsm = combineAsm * "@" * "LCL" * "\n"   #LCL - is the constant 1
		combineAsm = combineAsm * "D=M" * "\n"          # D= RAM[1] (RAM[1] is a pointer to local variables in the stack)
		combineAsm = combineAsm * "@" * words[3] * "\n" # A= words[3]
		combineAsm = combineAsm * "A=D+A" * "\n"        # A= D + words[3]
		combineAsm = combineAsm * "D=M" * "\n"          # D= RAM[A]
	
	elseif words[2]=="argument"        # argument- Stores the function's arguments
		combineAsm = combineAsm * "@" * "ARG" * "\n"      #ARG - is the constant 2 
		combineAsm = combineAsm * "D=M" * "\n"            # D= RAM[2] (RAM[2] is a pointer to parameters)
		combineAsm = combineAsm * "@" * words[3] * "\n"   # A= words[3]
		combineAsm = combineAsm * "A=D+A" * "\n"          # A= D + words[3]
		combineAsm = combineAsm * "D=M" * "\n"            # D= RAM[A]

	elseif words[2]=="this"            # this- General-purpose segments. Can be made to correspond 10 different areas in the heap. Serve various programming needs.
		combineAsm = combineAsm * "@" * "THIS" * "\n"     # THIS - is the constant 3
		combineAsm = combineAsm * "D=M" * "\n"            # D= RAM[3] (RAM[3] is the object it`s self)
		combineAsm = combineAsm * "@" * words[3] * "\n"   # A= words[3]
		combineAsm = combineAsm * "A=D+A" * "\n"          # A= D + words[3]
		combineAsm = combineAsm * "D=M" * "\n"            # D= RAM[A]
	
	elseif words[2]=="that"            # that- General-purpose segments. Can be made to correspond 10 different areas in the heap. Serve various programming needs.
		combineAsm = combineAsm * "@" * "THAT" * "\n"     #THAT - is the constant 4	
		combineAsm = combineAsm * "D=M" * "\n"            # D= RAM[4] (RAM[4] is the dynamic object)
		combineAsm = combineAsm * "@" * words[3] * "\n"   # A= words[3]
		combineAsm = combineAsm * "A=D+A" * "\n"          # A= D + words[3]
		combineAsm = combineAsm * "D=M" * "\n"            # D= RAM[A]
	
	elseif words[2]=="temp"          # temp- Fixed eight- entry segment that holds temorary variables for general use.
		combineAsm = combineAsm * "@" * words[3] * "\n"   # A- register that contain number of row in the RAM- address register 
		combineAsm = combineAsm * "D=A" * "\n"            # D- register containing a value on which the calculation will be performed- information register
		combineAsm = combineAsm * "@" * "5" * "\n"        # A= 5
		combineAsm = combineAsm * "A=D+A" * "\n"          # A= words[3] + 5
		combineAsm = combineAsm * "D=M" * "\n"            # D= RAM[A]
	
	elseif words[2]=="static"       # static- Stores static variables shared by all functions in the same .vm file
		combineAsm = combineAsm * "@" * fileName * "." * words[3] * "\n"   # A= file Name . the variable
		combineAsm = combineAsm * "D=M" * "\n"                          # D= RAM[A]
		
	elseif words[2]=="pointer"     # pointer- A two entry segments. Can be made to correspond to different areas in the heap. Serve various programming needs.
		if words[3]=="0"   
			combineAsm = combineAsm * "@" * "THIS" * "\n"   # THIS - is the constant 3
			combineAsm = combineAsm * "D=M" * "\n"          # D= RAM[A]
		elseif words[3]=="1"
			combineAsm = combineAsm * "@" * "THAT" * "\n"  #THAT is the constant 4 
			combineAsm = combineAsm * "D=M" * "\n"		   # D= RAM[A]	
		end
	end
		
	combineAsm = combineAsm * "@SP" * "\n"    # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "A=M" * "\n"    # A= RAM[A]= RAM[0] 	
	combineAsm = combineAsm * "M=D" * "\n"    # saving in the stack  , RAM[A]= D 
	combineAsm = combineAsm * "@SP" * "\n"    # next sp function 
	combineAsm = combineAsm * "M=M+1" * "\n"  # M= RAM[A] +1
	return combineAsm * "\n\n"            # for convenience  
end
	
function pop(line, fileName)  
	words=split(line)
	combineAsm = ""
	                    # pop local x -	pop the top of the stack into address RAM[ RAM[LCL] + x ]	,LCL =1
	if words[2]=="local"    # local- Stores the function’s local variables
		combineAsm = combineAsm * "@" * "LCL" * "\n"   # LCL - is the constant 1
		combineAsm = combineAsm * "D=M" * "\n"         # D= RAM[A] = RAM[1]
		combineAsm = combineAsm * "@" * words[3] * "\n" 
		combineAsm = combineAsm * "D=D+A" * "\n"       # D= RAM[1] + words[3]
	
		                # pop argument x - pop the top of the stack into address RAM[ RAM[ARG] + x ]	,ARG =2
	elseif words[2]=="argument"        # argument- Stores the function's arguments 
		combineAsm = combineAsm * "@" * "ARG" * "\n"   #ARG - is the constant 2 
		combineAsm = combineAsm * "D=M" * "\n"         # D= RAM[2]  (RAM[2] is a pointer to parameters)
		combineAsm = combineAsm * "@" * words[3] * "\n"  
		combineAsm = combineAsm * "D=D+A" * "\n"       # D= RAM[2] + words[3]

		             # pop this x	- pop the top of the stack into address RAM[ RAM[THIS] + x ]	,THIS =3
	elseif words[2]=="this"    # this- General-purpose segments. Can be made to correspond 10 different areas in the heap. Serve various programming needs.
		combineAsm = combineAsm * "@" * "THIS" * "\n"  # THIS - is the constant 3
		combineAsm = combineAsm * "D=M" * "\n"         # D= RAM[3] (RAM[3] is the object it`s self)
		combineAsm = combineAsm * "@" * words[3] * "\n" 
		combineAsm = combineAsm * "D=D+A" * "\n"       # D= RAM[3] + words[3]
	
		              # pop that x - pop the top of the stack into address RAM[ RAM[THAT] + x]	,THAT =4	
	elseif words[2]=="that"    # that- General-purpose segments. Can be made to correspond 10 different areas in the heap. Serve various programming needs.
		combineAsm = combineAsm * "@" * "THAT" * "\n"   # THAT - is the constant 4
		combineAsm = combineAsm * "D=M" * "\n"          # D= RAM[4] (RAM[4] is the dynamic object)
		combineAsm = combineAsm * "@" * words[3] * "\n"
		combineAsm = combineAsm * "D=D+A" * "\n"        # D= RAM[4] + words[3]
	              
		             # pop temp x - pop the top of the stack into address RAM[ 5 + x ]	5 is constant value, since temp variables are saved on RAM[5-12]
	elseif words[2]=="temp"     # temp- Fixed eight- entry segment that holds temorary variables for general use. 
		combineAsm = combineAsm * "@" * words[3] * "\n"
		combineAsm = combineAsm * "D=A+1" * "\n"       # D= words[3] + 1
		combineAsm = combineAsm * "D=D+1" * "\n"       
		combineAsm = combineAsm * "D=D+1" * "\n"
		combineAsm = combineAsm * "D=D+1" * "\n"
		combineAsm = combineAsm * "D=D+1" * "\n"
		
		             # pop pointer 0 - pop the top of the stack into address RAM[THIS]	Pointer 0 is THIS. THIS =3
	elseif words[2]=="pointer"    # pointer- A two entry segments. Can be made to correspond to different areas in the heap. Serve various programming needs.
		if words[3]=="0"
			combineAsm = combineAsm * "@" * "THIS" * "\n"    # THIS - is the constant 3
			combineAsm = combineAsm * "D=A" * "\n"           # D= 3
		elseif words[3]=="1"
			combineAsm = combineAsm * "@" * "THAT" * "\n"	 # THAT - is the constant 4
			combineAsm = combineAsm * "D=A" * "\n"           # D= 4
		end
	       
		         
				  # pop static x	pop the top of the stack into address RAM[className.x ]	.
	elseif words[2]=="static"              # static- Stores static variables shared by all functions in the same .vm file
		combineAsm = combineAsm * "@" * fileName * "." * words[3] * "\n"      # A= file Name . the variable
		combineAsm = combineAsm * "D=A" * "\n"                             # D= RAM[A]
	end
	
	combineAsm = combineAsm * "@0" * "\n"
	combineAsm = combineAsm * "M=M-1" * "\n"    # SP = SP -1
	combineAsm = combineAsm * "A=M" * "\n"      # A= RAM[A]
	combineAsm = combineAsm * "A=M" * "\n"      # A= RAM[A]
	combineAsm = combineAsm * "A=A+D" * "\n"    
	combineAsm = combineAsm * "D=A-D" * "\n"
	combineAsm = combineAsm * "A=A-D" * "\n"    # swap (A,D)
	combineAsm = combineAsm * "M=D" * "\n"      # RAM[A]= D
	return combineAsm * "\n\n"
end
	
              # add - x+y , Integer addition (2's complement)
function add()
	combineAsm = ""
	combineAsm = combineAsm * "@SP" * "\n"         # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "A=M-1" * "\n"       # A = RAM[A] - 1
	combineAsm = combineAsm * "D=M" * "\n"         # D= RAM[A] 
	combineAsm = combineAsm * "A=A-1" * "\n"       # A = A - 1
	combineAsm = combineAsm * "M=D+M" * "\n"       # RAM[A]= D + RAM[A]
	combineAsm = combineAsm * "@SP" * "\n"         # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "M=M-1" * "\n"       # RAM[A]= RAM[A] - 1 
	return combineAsm * "\n\n"
end
	        # sub - x+y , Integer addition (2's complement)
function sub()
	combineAsm = ""
	combineAsm = combineAsm * "@SP" * "\n"        # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "A=M-1" * "\n"      # A = RAM[A] - 1
	combineAsm = combineAsm * "D=M" * "\n"        # D= RAM[A]
	combineAsm = combineAsm * "A=A-1" * "\n"      
	combineAsm = combineAsm * "M=M-D" * "\n"      # RAM[A]= RAM[A] - D 
	combineAsm = combineAsm * "@SP" * "\n"        # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "M=M-1" * "\n"      # RAM[A]= RAM[A] - 1
	return combineAsm * "\n\n"
end
	       # neg - (-y) , Arithmetic addition (2's complement)
function neg()
	combineAsm = ""
	combineAsm = combineAsm * "@SP" * "\n"        # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "A=M-1" * "\n"      # A = RAM[A] - 1
	combineAsm = combineAsm * "M=-M" * "\n"       # RAM[A]= - RAM[A]
	return combineAsm * "\n\n" 
end
	      # eq - true if x=y and false otherwise , Equality   
function eq()
	combineAsm = ""
	global labelCounter+=1
	combineAsm = combineAsm * "@SP" * "\n"       # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "A=M-1" * "\n"     # A = RAM[A] - 1
	combineAsm = combineAsm * "D=M" * "\n"       # D = RAM[A]
	combineAsm = combineAsm * "A=A-1" * "\n" 
	combineAsm = combineAsm * "D=D-M" * "\n"     # D = D - RAM[A]   
	combineAsm = combineAsm * "@IF_TRUE" * "$labelCounter" * "\n"   # Load address to jump
	combineAsm = combineAsm * "D;JEQ" * "\n"     # JEQ - If the combineAsm of the calculation is equal to 0
	combineAsm = combineAsm * "D=0" * "\n"
	combineAsm = combineAsm * "@SP" * "\n"       # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "A=M-1" * "\n"     # A = RAM[A] - 1
	combineAsm = combineAsm * "A=A-1" * "\n"
	combineAsm = combineAsm * "M=D" * "\n"       # RAM[A] = 0
	combineAsm = combineAsm * "@IF_FALSE" * "$labelCounter" * "\n"    
	combineAsm = combineAsm * "0;JMP" * "\n"     # Want to jump to the end, so as not to carry out the commands of "otherwise"
	combineAsm = combineAsm * "(IF_TRUE" * "$labelCounter" * ")" * "\n"   
	combineAsm = combineAsm * "D=-1" * "\n"     
	combineAsm = combineAsm * "@SP" * "\n"       # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "A=M-1" * "\n"     # A = RAM[A] - 1
	combineAsm = combineAsm * "A=A-1" * "\n"   
	combineAsm = combineAsm * "M=D" * "\n"       # RAM[A] = 0
	combineAsm = combineAsm * "(IF_FALSE" * "$labelCounter" * ")" * "\n"
	combineAsm = combineAsm * "@SP" * "\n"       # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "M=M-1" * "\n"     # RAM[A]= RAM[A] - 1
	return combineAsm * "\n\n"
end
	
         # gt - true if x>y and false otherwise , Greaeter than
function gt()
	combineAsm = ""
	global labelCounter+=1
	combineAsm = combineAsm * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "A=M-1" * "\n"    # A = RAM[A] - 1
	combineAsm = combineAsm * "D=M" * "\n"      # D = RAM[A]
	combineAsm = combineAsm * "A=A-1" * "\n" 
	combineAsm = combineAsm * "D=M-D" * "\n"    # D = D - RAM[A]
	combineAsm = combineAsm * "@IF_TRUE" * "$labelCounter" * "\n"
	combineAsm = combineAsm * "D;JGT" * "\n"    # If the combineAsm of the calculation is greater than 0
	combineAsm = combineAsm * "D=0" * "\n"      
	combineAsm = combineAsm * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "A=M-1" * "\n"    # A = RAM[A] - 1
	combineAsm = combineAsm * "A=A-1" * "\n"
	combineAsm = combineAsm * "M=D" * "\n"      # RAM[A] = 0
	combineAsm = combineAsm * "@IF_FALSE" * "$labelCounter" * "\n"
	combineAsm = combineAsm * "0;JMP" * "\n"    # Want to jump to the end, so as not to carry out the commands of "otherwise"
	combineAsm = combineAsm * "(IF_TRUE" * "$labelCounter" * ")" * "\n"
	combineAsm = combineAsm * "D=-1" * "\n"
	combineAsm = combineAsm * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "A=M-1" * "\n"    # A = RAM[A] - 1
	combineAsm = combineAsm * "A=A-1" * "\n"
	combineAsm = combineAsm * "M=D" * "\n"      # RAM[A] = 0
	combineAsm = combineAsm * "(IF_FALSE" * "$labelCounter" * ")" * "\n"
	combineAsm = combineAsm * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "M=M-1" * "\n"    # RAM[A]= RAM[A] - 1
	return combineAsm * "\n\n"
end
	
          # lt - true if x<y and false otherwise 
function lt()
	combineAsm = ""
	global labelCounter+=1
	combineAsm = combineAsm * "@SP" * "\n"     # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "A=M-1" * "\n"   # A = RAM[A] - 1
	combineAsm = combineAsm * "D=M" * "\n"     # D = RAM[A]
	combineAsm = combineAsm * "A=A-1" * "\n" 
	combineAsm = combineAsm * "D=M-D" * "\n"   # D = D - RAM[A]
	combineAsm = combineAsm * "@IF_TRUE" * "$labelCounter" * "\n"
	combineAsm = combineAsm * "D;JLT" * "\n"   # If the calculation combineAsm is less than 0
	combineAsm = combineAsm * "D=0" * "\n"
	combineAsm = combineAsm * "@SP" * "\n"     # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack  
	combineAsm = combineAsm * "A=M-1" * "\n"   # A = RAM[A] - 1
	combineAsm = combineAsm * "A=A-1" * "\n"
	combineAsm = combineAsm * "M=D" * "\n"     # RAM[A] = 0
	combineAsm = combineAsm * "@IF_FALSE" * "$labelCounter" * "\n"
	combineAsm = combineAsm * "0;JMP" * "\n"   # Want to jump to the end, so as not to carry out the commands of "otherwise"
	combineAsm = combineAsm * "(IF_TRUE" * "$labelCounter" * ")" * "\n"
	combineAsm = combineAsm * "D=-1" * "\n"
	combineAsm = combineAsm * "@SP" * "\n"     # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack 
	combineAsm = combineAsm * "A=M-1" * "\n"   # A = RAM[A] - 1
	combineAsm = combineAsm * "A=A-1" * "\n"
	combineAsm = combineAsm * "M=D" * "\n"     # RAM[A] = 0
	combineAsm = combineAsm * "(IF_FALSE" * "$labelCounter" * ")" * "\n"
	combineAsm = combineAsm * "@SP" * "\n"     # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "M=M-1" * "\n"   # RAM[A]= RAM[A] - 1
	return combineAsm * "\n\n"
end
	
	        # and - x And y 
function and()
	combineAsm = ""
	global labelCounter+=1
	combineAsm = combineAsm * "@SP" * "\n"     # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "A=M-1" * "\n"   # A = RAM[A] - 1
	combineAsm = combineAsm * "D=M" * "\n"     # D = RAM[A]
	combineAsm = combineAsm * "A=A-1" * "\n" 
	combineAsm = combineAsm * "D=D&M" * "\n"   # D = -1 or 0
	combineAsm = combineAsm * "@IF_FALSE" * "$labelCounter" * "\n"
	combineAsm = combineAsm * "D;JEQ" * "\n"   # If the combineAsm of the calculation is equal to 0
	combineAsm = combineAsm * "@SP" * "\n"     # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "A=M-1" * "\n"   # A = RAM[A] - 1
	combineAsm = combineAsm * "A=A-1" * "\n"
	combineAsm = combineAsm * "M=D" * "\n"     # RAM[A] = 0
	combineAsm = combineAsm * "@IF_TRUE" * "$labelCounter" * "\n"
	combineAsm = combineAsm * "0;JMP" * "\n"   # Want to jump to the end, so as not to carry out the commands of "otherwise"
	combineAsm = combineAsm * "(IF_FALSE" * "$labelCounter" * ")" * "\n"
	combineAsm = combineAsm * "@SP" * "\n"     # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "A=M-1" * "\n"   # A = RAM[A] - 1
	combineAsm = combineAsm * "A=A-1" * "\n"
	combineAsm = combineAsm * "M=D" * "\n"     # RAM[A] = 0
	combineAsm = combineAsm * "(IF_TRUE" * "$labelCounter" * ")" * "\n"
	combineAsm = combineAsm * "@SP" * "\n"     # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
	combineAsm = combineAsm * "M=M-1" * "\n"   # RAM[A]= RAM[A] - 1
	return combineAsm * "\n\n"
end

          # or - x Or y
function or()
  combineAsm = ""
  global labelCounter+=1
  combineAsm = combineAsm * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
  combineAsm = combineAsm * "A=M-1" * "\n"    # A = RAM[A] - 1
  combineAsm = combineAsm * "D=M" * "\n"      # D = RAM[A]
  combineAsm = combineAsm * "A=A-1" * "\n" 
  combineAsm = combineAsm * "D=D|M" * "\n"    # D = -1 or 0
  combineAsm = combineAsm * "@IF_FALSE" * "$labelCounter" * "\n"
  combineAsm = combineAsm * "D;JEQ" * "\n"    # If the combineAsm of the calculation is equal to 0
  combineAsm = combineAsm * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
  combineAsm = combineAsm * "A=M-1" * "\n"    # A = RAM[A] - 1
  combineAsm = combineAsm * "A=A-1" * "\n"    
  combineAsm = combineAsm * "M=D" * "\n"      # RAM[A] = 0
  combineAsm = combineAsm * "@IF_TRUE" * "$labelCounter" * "\n"
  combineAsm = combineAsm * "0;JMP" * "\n"    # Want to jump to the end, so as not to carry out the commands of "otherwise"
  combineAsm = combineAsm * "(IF_FALSE" * "$labelCounter" * ")" * "\n"
  combineAsm = combineAsm * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
  combineAsm = combineAsm * "A=M-1" * "\n"    # A = RAM[A] - 1
  combineAsm = combineAsm * "A=A-1" * "\n"  
  combineAsm = combineAsm * "M=D" * "\n"      # RAM[A] = 0
  combineAsm = combineAsm * "(IF_TRUE" * "$labelCounter" * ")" * "\n"
  combineAsm = combineAsm * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
  combineAsm = combineAsm * "M=M-1" * "\n"    # RAM[A]= RAM[A] - 1
  return combineAsm * "\n\n"
end

           # Not y
function not()
  combineAsm = ""
  global labelCounter+=1
  combineAsm = combineAsm * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
  combineAsm = combineAsm * "A=M-1" * "\n"    # A = RAM[A] - 1
  combineAsm = combineAsm * "D=!M" * "\n"   
  combineAsm = combineAsm * "@IF_FALSE" * "$labelCounter" * "\n"
  combineAsm = combineAsm * "D;JEQ" * "\n"    # If the combineAsm of the calculation is equal to 0
  combineAsm = combineAsm * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
  combineAsm = combineAsm * "A=M-1" * "\n"    # A = RAM[A] - 1
  combineAsm = combineAsm * "M=D" * "\n"      # RAM[A] = D
  combineAsm = combineAsm * "@IF_TRUE" * "$labelCounter" * "\n"
  combineAsm = combineAsm * "0;JMP" * "\n"    # Want to jump to the end, so as not to carry out the commands of "otherwise"
  combineAsm = combineAsm * "(IF_FALSE" * "$labelCounter" * ")" * "\n"
  combineAsm = combineAsm * "@SP" * "\n"      # (SP- is the constant 0 ) , mean that load the address of the pointer to the stack
  combineAsm = combineAsm * "A=M-1" * "\n"    # A = RAM[A] - 1
  combineAsm = combineAsm * "M=D" * "\n"      # RAM[A] = D
  combineAsm = combineAsm * "(IF_TRUE" * "$labelCounter" * ")" * "\n"
  return combineAsm * "\n\n"
end

         # label - A declaration of a label c, inside current file FileName
function label(line, fileName)
  combineAsm = ""
  words=split(line)
  # reminder : label c   -> translate to asm:   (FileName.c) 
  combineAsm = combineAsm * "(" * fileName * "."
  combineAsm = combineAsm * words[2] * ")" * "\n"
  return combineAsm * "\n\n"
end	

          # goto - Jump to label, Meaning: The next command to execute, will be from the label c
function goto(line, fileName)
  combineAsm = ""
  words=split(line)
  # reminder :  goto c  
  combineAsm = combineAsm * "@" * fileName * "." * words[2] * "\n"    # load the jump address
  combineAsm = combineAsm * "0;JMP" * "\n"                            # jump to the label
  return combineAsm * "\n\n"
end	

        # if_goto - Conditional jump to label, Meaning: Pull out the organ at the top of the stack . If it is not 0, jump to the label c
function if_goto(line, fileName)
  combineAsm = ""
  words=split(line)
  
  combineAsm = combineAsm * "@SP" * "\n" 
  combineAsm = combineAsm * "A=M-1" * "\n"
  combineAsm = combineAsm * "D=M" * "\n" # now D contain the last pushed value , A peek to the top of the stack
  
  combineAsm = combineAsm * "@SP" * "\n" 
  combineAsm = combineAsm * "M=M-1" * "\n" # decrease the stack in one
  
  combineAsm = combineAsm * "@" * fileName * "." * words[2] * "\n"     # words[2] = where to jump (=label)
  combineAsm = combineAsm * "D;JNE" * "\n" # jump if not false (not equal to zero) 
  
  return combineAsm * "\n\n" 
end	

          #func - Function start, Meaning: Here begins the function named g, and k has local variables
function func(line)
  combineAsm = ""
  words=split(line)
  # reminder : function g k
  times = parse(Int64, words[3]) # words[3] = k local variables
  
  combineAsm = combineAsm * "(" * words[2] * ")" * "\n"  # words[3] = (fileName.functionName) , Create a label for entering a function
  for time = 1:times                          # repeat k times:   (For all local variables)
	combineAsm = combineAsm * "@0" * "\n"     # Initialize to 0
	combineAsm = combineAsm * "D=A" * "\n"    # D = 0
	
	combineAsm = combineAsm * "@SP" * "\n" 
	combineAsm = combineAsm * "A=M" * "\n"
	combineAsm = combineAsm * "M=D" * "\n"    # saving D in the stack
	
	combineAsm = combineAsm * "@SP" * "\n" 
	combineAsm = combineAsm * "M=M+1" * "\n"  # SP+=1
		
  end
  
  return combineAsm * "\n\n" 
end	

          # call - Function summoning, Meaning:(After pushing n parameters (args) to the stack), time the function g
function call(line,fileName)
  combineAsm = ""
  words=split(line)
  # reminder : call g n
  times = parse(Int64, words[3]) # words[3] = n arguments
  global labelCounter+=1
  
  combineAsm = combineAsm * "@" * fileName* "." * words[2] * "$labelCounter" * "\n" 
  combineAsm = combineAsm * "D=A" * "\n" 
  combineAsm = combineAsm * "@SP" * "\n" 
  combineAsm = combineAsm * "A=M" * "\n" 
  combineAsm = combineAsm * "M=D" * "\n" 
  combineAsm = combineAsm * "@SP" * "\n"
  combineAsm = combineAsm * "M=M+1" * "\n"    # push return address
  
  combineAsm = combineAsm * "@LCL" * "\n" 
  combineAsm = combineAsm * "D=M" * "\n" 
  combineAsm = combineAsm * "@SP" * "\n" 
  combineAsm = combineAsm * "A=M" * "\n" 
  combineAsm = combineAsm * "M=D" * "\n" 
  combineAsm = combineAsm * "@SP" * "\n"
  combineAsm = combineAsm * "M=M+1" * "\n"     # push LCL - for saving and updating pointer values

  combineAsm = combineAsm * "@ARG" * "\n" 
  combineAsm = combineAsm * "D=M" * "\n" 
  combineAsm = combineAsm * "@SP" * "\n" 
  combineAsm = combineAsm * "A=M" * "\n" 
  combineAsm = combineAsm * "M=D" * "\n" 
  combineAsm = combineAsm * "@SP" * "\n"
  combineAsm = combineAsm * "M=M+1" * "\n"      # push ARG

  combineAsm = combineAsm * "@THIS" * "\n" 
  combineAsm = combineAsm * "D=M" * "\n" 
  combineAsm = combineAsm * "@SP" * "\n" 
  combineAsm = combineAsm * "A=M" * "\n" 
  combineAsm = combineAsm * "M=D" * "\n" 
  combineAsm = combineAsm * "@SP" * "\n"
  combineAsm = combineAsm * "M=M+1" * "\n"      # push THIS

  combineAsm = combineAsm * "@THAT" * "\n" 
  combineAsm = combineAsm * "D=M" * "\n" 
  combineAsm = combineAsm * "@SP" * "\n" 
  combineAsm = combineAsm * "A=M" * "\n" 
  combineAsm = combineAsm * "M=D" * "\n" 
  combineAsm = combineAsm * "@SP" * "\n"
  combineAsm = combineAsm * "M=M+1" * "\n"       # push THAT
  
  newArg = times
  combineAsm = combineAsm * "@" * "$newArg" * "\n"   # number ' n-5
  combineAsm = combineAsm * "D=A\n@5\nD=D+A\n@SP\nD=M-D\n@ARG\nM=D\n" # ARG = SP-n-5   , n is the numbers ot the  parameters
  
  combineAsm = combineAsm * "@SP" * "\n" 
  combineAsm = combineAsm * "D=M" * "\n" 
  combineAsm = combineAsm * "@LCL" * "\n"
  combineAsm = combineAsm * "M=D" * "\n"           # LCL=SP
  
  combineAsm = combineAsm * "@" * words[2] * "\n"
  combineAsm = combineAsm * "0;JMP" * "\n"         # goto g  , Transferring the control to a the function g 
  
  combineAsm = combineAsm * "(" * fileName* "." * words[2] * "$labelCounter" *  ")" * "\n"    # (fileName.functioName_i) the return address , Create a return label from the function
  
  return combineAsm * "\n\n" 
end	


          # returnFromFunc - Return from function, Meaning: stopping the execution of the function, and returning control to the function that called it
function returnFromFunc()
  combineAsm = ""
  combineAsm = combineAsm * "@LCL" * "\n" 
  combineAsm = combineAsm * "D=M" * "\n"      # D=FRAME=LCL
  combineAsm = combineAsm * "@FRAME" * "\n"   # FRAME - Temporary variable
  combineAsm = combineAsm * "M=D" * "\n"      # RAM[13]=*(FRAME-5)
  combineAsm = combineAsm * "@FRAME" * "\n"   # FRAME -Temporary variable
  combineAsm = combineAsm * "D=M" * "\n" 
  combineAsm = combineAsm * "@5" * "\n" 
  combineAsm = combineAsm * "A=D-A" * "\n"    # A=FRAME-5 
  combineAsm = combineAsm * "D=M" * "\n" 
  combineAsm = combineAsm * "@RET" * "\n"     # RET - in that temporary variable we save the return address
  combineAsm = combineAsm * "M=D" * "\n"      # RAM[13]=*(FRAME-5)
  combineAsm = combineAsm * "@SP" * "\n" 
  combineAsm = combineAsm * "AM=M-1" * "\n"   # in that rgiester we save the return address
  combineAsm = combineAsm * "D=M" * "\n" 
  combineAsm = combineAsm * "@ARG" * "\n"     
  combineAsm = combineAsm * "A=M" * "\n"
  combineAsm = combineAsm * "M=D" * "\n"      # *ARG=pop() , Location of the return value to the ordering function
  combineAsm = combineAsm * "@ARG" * "\n"  
  combineAsm = combineAsm * "D=M+1" * "\n"    # SP = ARG+1  , Reposition the stack head
  combineAsm = combineAsm * "@SP" * "\n" 
  combineAsm = combineAsm * "M=D" * "\n"      # RAM[13]=*(FRAME-5)
  combineAsm = combineAsm * "@FRAME" * "\n"   # Restoration of the segments values in to the RAM
  combineAsm = combineAsm * "A=M-1" * "\n" 
  combineAsm = combineAsm * "D=M" * "\n"      # RAM[13]=*(FRAME-5)
  combineAsm = combineAsm * "@THAT" * "\n"    # RAM[13]=*(FRAME-5)   THAT = *(FRAM-1)
  combineAsm = combineAsm * "M=D" * "\n"      # RAM[13]=*(FRAME-5)

  combineAsm = combineAsm * "@FRAME" * "\n" 
  combineAsm = combineAsm * "A=M-1" * "\n" 
  combineAsm = combineAsm * "D=M" * "\n"     # RAM[13]=*(FRAME-5)
  combineAsm = combineAsm * "@THIS" * "\n"   # RAM[13]=*(FRAME-5)    THIS = *(FRAM-2) 
  combineAsm = combineAsm * "M=D" * "\n"     # RAM[13]=*(FRAME-5)
  
  combineAsm = combineAsm * "@FRAME" * "\n" 
  combineAsm = combineAsm * "D=M" * "\n"     # RAM[13]=*(FRAME-5)
  combineAsm = combineAsm * "@3" * "\n"      # RAM[13]=*(FRAME-5)
  combineAsm = combineAsm * "A=D-A" * "\n"   # RAM[13]=*(FRAME-5)
  combineAsm = combineAsm * "D=M" * "\n"     # RAM[13]=*(FRAME-5)
  combineAsm = combineAsm * "@ARG" * "\n"    # RAM[13]=*(FRAME-5)    ARG = *(FRAM-3)
  combineAsm = combineAsm * "M=D" * "\n"     # RAM[13]=*(FRAME-5)

  combineAsm = combineAsm * "@FRAME" * "\n" 
  combineAsm = combineAsm * "D=M" * "\n"     # RAM[13]=*(FRAME-5)
  combineAsm = combineAsm * "@4" * "\n"      # RAM[13]=*(FRAME-5)
  combineAsm = combineAsm * "A=D-A" * "\n"   # RAM[13]=*(FRAME-5)
  combineAsm = combineAsm * "D=M" * "\n"     # RAM[13]=*(FRAME-5)
  combineAsm = combineAsm * "@LCL" * "\n"    # RAM[13]=*(FRAME-5)   LCL = *(FRAM-4)
  combineAsm = combineAsm * "M=D" * "\n"     # RAM[13]=*(FRAME-5)

  combineAsm = combineAsm * "@RET" * "\n"    # RAM[13]=*(FRAME-5)   goto RET , Returning control to the orderinig function
  combineAsm = combineAsm * "A=M" * "\n"     # RAM[13]=*(FRAME-5)
  combineAsm = combineAsm * "0;JMP" * "\n"   # RAM[13]=*(FRAME-5)
  
  return combineAsm * "\n\n" 
end	
	



# main :
	
println("Enter directory name")
# files in dir (=direction)
directionName = readline() 
if sizeof(directionName)==0
    #=readdir - if it false then return the name of the files 
                if it true then return the path                    
    =#
	content=readdir() # default directory
else
	content=readdir(directionName)
end

for file in filter(x -> endswith(x, "vm"), content)

		vmInput=open(directionName*"\\"*file,"r")
		fileName = file[1:length(file)-3]
		asmOutPut=open(fileName * ".asm", "w")
		
		for line in eachline(vmInput)
		
		    if (!startswith(line, "//"))
				write(asmOutPut, "// " * line * "\n")
			end

			if startswith(line, "push")
				write(asmOutPut, push(line, fileName))
			
			elseif startswith(line, "pop")
				write(asmOutPut,pop(line, fileName))
			
			elseif startswith(line, "add")
				write(asmOutPut,add())
			
			elseif startswith(line, "sub")
				write(asmOutPut,sub())
			
			elseif startswith(line, "neg")
				write(asmOutPut,neg())
			
			elseif startswith(line, "eq")
				write(asmOutPut,eq())
			
			elseif startswith(line, "gt")
				write(asmOutPut,gt())
			
			elseif startswith(line, "lt")
				write(asmOutPut,lt())
			
			elseif startswith(line, "and")
				write(asmOutPut,and())
			
			elseif startswith(line, "or")
				write(asmOutPut,or())
			
			elseif startswith(line, "not")
				write(asmOutPut,not())
				
			elseif startswith(line, "label")
				write(asmOutPut,label(line, fileName))
				
			elseif startswith(line, "goto")
				write(asmOutPut,goto(line, fileName))
				
			elseif startswith(line, "if-goto")
				write(asmOutPut,if_goto(line, fileName))
				
			elseif startswith(line, "function")
				write(asmOutPut,func(line))
				
			elseif startswith(line, "return")
				write(asmOutPut,returnFromFunc())
				
			elseif startswith(line, "call")
				write(asmOutPut,call(line,fileName))
			
			# if line startWith '//' do nothing
			end
		end
		
		close(asmOutPut)
		close(vmInput)
end





asmOutPut=open("uniteAllFiles.asm", "a")

# first command that we need to add for each running to reset the stack: SP = 256
startLines = ""
startLines = startLines * "@256" * "\n"
startLines = startLines * "D=A" * "\n"
startLines = startLines * "@SP" * "\n"
startLines = startLines * "M=D" * "\n"
write(asmOutPut, startLines)

# second command that we need to add for each running to reset the stack: call Sys.init 0
write(asmOutPut ,call("call Sys.init 0","uniteAllFiles"))



# now we'll assemble all the files together

if sizeof(directionName)==0
     #=readdir - if it false then readdir returns just the names in the directory as is, 
                if it true then it returns joinpath(dir, name) for each name so that the returned strings are full paths                   
    =#
	content=readdir() # default directory
else
	content=readdir(directionName)
end


for file in filter(x -> endswith(x, "asm"), content)
        # read - open the file to reading a single value of type String from file
		s = read(file, String)
        # write - write into asmOutPut the string s
		write(asmOutPut, s)
end

close(asmOutPut)
