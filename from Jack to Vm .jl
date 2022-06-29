
############ funtions of the Tokening ###############

function keywords4(token, currentfile, newFile)
    global keyword
    global symbol
    println(newFile, "<keyword> "*token*" </keyword>")
end


function symbols4(token, currentfile, newFile)  
    global keyword
    global symbol
    if token=='>'
        println(newFile, "<symbol> &gt; </symbol>")
        token=""                                        # enter to token "" for initialization
    elseif token=='<'
        println(newFile, "<symbol> &lt; </symbol>")
        token=""
    elseif token=='\"'     # refer to the " , in jack is quote
        println(newFile, "<symbol> &quet; </symbol>")
        token=""
    elseif token=='&'
        println(newFile, "<symbol> &amp; </symbol>")
        token=""
    else
        println(newFile, "<symbol> "*token* " </symbol>")
        token=""
    end
end


function identifier4(token, currentfile, newFile)
    global keyword
    global symbol
    while !(token[end] in symbol) && !(token[end]==' ') && !(token[end]=="\n") && !eof(currentfile)  # if not one of them then -
         token=token*string(read(currentfile, Char))    # connects(chain) all values ​​to a single string
     end
    println(newFile, "<identifier> "*token[1:end-1]*" </identifier>")
    if token[end] in symbol
        symbols4(token[end], currentfile,newFile)        
    else
        token=""                                       # enter to token "" for initialization
    end
end


function StringConstant4(token, currentfile, newFile)
    if !eof(currentfile)
        token=""
        token=token*string(read(currentfile, Char))
    end
    while !endswith(token, "\"") && !eof(currentfile)
        token=token*string(read(currentfile, Char))
    end
    println(newFile, "<stringConstant4> "*token[1:end-1]* " </stringConstant4>")
    token=""                                                    # enter to token "" for initialization
end


function IntegerConstant4(token, currentfile, newFile)
    global keyword
    global symbol
    if !eof(currentfile)
        token=token*string(read(currentfile, Char))   # connects(chain) all values ​​to a single string
    end
    while all(isdigit, token) && !eof(currentfile)    # while is integerConstant4 or the file is`nt end 
        token=token*string(read(currentfile, Char))   # connects(chain) all values ​​to a single string
    end
    println(newFile, "<integerConstant4> "*token[1:end-1]* " </integerConstant4>")
    if token[end] in symbol
        symbols4(token[end], currentfile,newFile)
    else
        token=""                                     # enter to token "" for initialization
    end
end

function letters4(token, currentfile,newFile)
    global keyword
    global symbol
    if !eof(currentfile)
        token=token*string(read(currentfile, Char))      # connects(chain) all values ​​to a single string
    end
    while all(isletter, token) && !eof(currentfile)      # while isletter or the file is`nt end 
        token=token*string(read(currentfile, Char))
    end
    if token[1:end-1] in keyword
        keywords4(token[1:end-1], currentfile,newFile)
        if token[end] in symbol
            symbols4(token[end], currentfile,newFile)
        else
            token=""                                    # enter to token "" for initialization
        end
    else
        identifier4(token, currentfile,newFile)
    end
end

function comments4(token, currentfile)  # comments4 in jack can look: // or /*
    global keyword
    global symbol
    if token=='/' && !eof(currentfile)     # that mean is: //
        line=readline(currentfile)
        token=""                           # enter to token "" for initialization
    elseif token=='*' && !eof(currentfile) # that mean is: /*
        token=string(read(currentfile, Char))   # connects(chain) all values ​​to a single string
        while !endswith(token, "*/")  && !eof(currentfile)
            token=token*string(read(currentfile, Char))
        end
        token=""                           # enter to token "" for initialization
    end
end






############ funtions of the Parsing ###############

function GetNextToken4(tokens) # Checks if we have not reached the end and if not return tokens[index4]
    global index4
    if index4+1<=length(tokens) 
        index4=index4+1
        return tokens[index4]
    end
end


function CheckNextToken4(tokens)   # Checks if we have not reached the end and if not advances to the next token
    global index4
    if index4+1<=length(tokens)
        return tokens[index4+1]
    end
end


function ParseClass4(tokens, newFile)
    global index4
    println(newFile, "<class>")
    println(newFile, GetNextToken4(tokens))    #<keyword> class </keyword
    println(newFile, GetNextToken4(tokens))    #<identifier> className </identifier>
    println(newFile, GetNextToken4(tokens))    #<symbol> { </symbol>
    ParseClass4VarDec(tokens, newFile)         # classVarDec
    ParseClass4SubroutineDec(tokens, newFile)  # subroutineDec
    println(newFile, GetNextToken4(tokens))     #<symbol> } </symbol>
    println(newFile, "</class>")
end


function ParseClass4VarDec(tokens, newFile)
    while occursin("static",CheckNextToken4(tokens)) || occursin("field",CheckNextToken4(tokens))    # while the next token contain "static" or "field"
        println(newFile, "<classVarDec>")
        println(newFile, GetNextToken4(tokens))     #<keyword> static/field </keyword>
        println(newFile, GetNextToken4(tokens))     #<keyword> type </keyword>
        println(newFile, GetNextToken4(tokens))     #<identifier> varName </identifier>
        while occursin( ",",CheckNextToken4(tokens))
            println(newFile, GetNextToken4(tokens)) #<symbol> , </symbol>
            println(newFile, GetNextToken4(tokens)) #<identifier> varName </identifier>
        end
        println(newFile, GetNextToken4(tokens))     #<symbol> ; </symbol>
        println(newFile, "</classVarDec>")
    end
end


function ParseClass4SubroutineDec(tokens, newFile)
    while occursin( "method",CheckNextToken4(tokens)) || occursin("function",CheckNextToken4(tokens)) || occursin("constructor",CheckNextToken4(tokens))  # while the next token contain "method" or "function" or "constructor"
        println(newFile, "<subroutineDec>")
        println(newFile, GetNextToken4(tokens)) #<keyword> method/constructor/function </keyword>
        println(newFile, GetNextToken4(tokens)) #<keyword> void </keyword>  /  <identifier> type </identifier>
        println(newFile, GetNextToken4(tokens)) #<identifier> subroutineName </identifier>
        println(newFile, GetNextToken4(tokens)) #<symbol> ( </symbol>
        ParseParameterList4(tokens, newFile)    # parameterList
        println(newFile, GetNextToken4(tokens)) #<symbol> ) </symbol>
        ParseSubroutineBody4(tokens, newFile)   # subroutineBody
        println(newFile, "</subroutineDec>")
    end
end


function ParseParameterList4(tokens, newFile)   # list of the parameter that the function get
    println(newFile, "<parameterList>")
    while !occursin( ")",CheckNextToken4(tokens))
        println(newFile, GetNextToken4(tokens))     #<keyword> type </keyword>
        println(newFile, GetNextToken4(tokens))     #<identifier> varName </identifier>
        while occursin(",",CheckNextToken4(tokens))
            println(newFile, GetNextToken4(tokens)) #<symbol> , </symbol>
            println(newFile, GetNextToken4(tokens)) #<keyword> type </keyword>
            println(newFile, GetNextToken4(tokens)) #<identifier> varName </identifier>
        end
    end
    println(newFile, "</parameterList>")
end


function ParseSubroutineBody4(tokens, newFile)
    println(newFile, "<subroutineBody>")
    println(newFile, GetNextToken4(tokens)) #<symbol> { </symbol>
    ParseVarDec4(tokens, newFile)           # varDec
    ParseStatements4(tokens, newFile)       #statements
    println(newFile, GetNextToken4(tokens)) #<symbol> } </symbol>
    println(newFile, "</subroutineBody>")
end


function ParseVarDec4(tokens, newFile)
    while occursin("var",CheckNextToken4(tokens))
        println(newFile, "<varDec>")
        println(newFile, GetNextToken4(tokens))     #<keyword> var </keyword>
        println(newFile, GetNextToken4(tokens))     #<keyword> type </keyword>
        println(newFile, GetNextToken4(tokens))     #<identifier> varName </identifier>
        while occursin( ",",CheckNextToken4(tokens))
            println(newFile, GetNextToken4(tokens)) #<symbol> , </symbol>
            println(newFile, GetNextToken4(tokens)) #<identifier> varName </identifier>
        end
        println(newFile, GetNextToken4(tokens)) #<symbol> ; </symbol>
        println(newFile, "</varDec>")
    end
end


function ParseStatements4(tokens, newFile)
    println(newFile, "<statements>")
                  # while the next token contain "let" or "if" or "while" or "do" or "return"
    while occursin( "let",CheckNextToken4(tokens)) || occursin( "if",CheckNextToken4(tokens)) || occursin( "while",CheckNextToken4(tokens)) || occursin( "do",CheckNextToken4(tokens)) || occursin( "return",CheckNextToken4(tokens))
        if occursin("let",CheckNextToken4(tokens))
            ParseLetStatement4(tokens, newFile)    # letStatement
        elseif occursin("if",CheckNextToken4(tokens))
            ParseIfStatement4(tokens, newFile)     # ifStatement
        elseif occursin("while",CheckNextToken4(tokens))
            ParseWhileStatement4(tokens, newFile)  # whileStatement
        elseif occursin( "do",CheckNextToken4(tokens))
            ParseDoStatement4(tokens, newFile)     # doStatement
        elseif occursin( "return",CheckNextToken4(tokens))
            ParseReturnStatement4(tokens, newFile) # returnStatement
        end
    end
    println(newFile, "</statements>")
end


function ParseLetStatement4(tokens, newFile)
    println(newFile, "<letStatement>")
    println(newFile, GetNextToken4(tokens))     #<keyword> let </keyword>
    println(newFile, GetNextToken4(tokens))     #<identifier> varName </identifier>
    if occursin( "[",CheckNextToken4(tokens))
        println(newFile, GetNextToken4(tokens)) #<symbol> [ </symbol>
            ParseExpression4(tokens, newFile)   # expression
        println(newFile, GetNextToken4(tokens)) #<symbol> ] </symbol>
    end
    println(newFile, GetNextToken4(tokens))     #<symbol> = </symbol>
    ParseExpression4(tokens, newFile)           # expression
    println(newFile, GetNextToken4(tokens))     #<symbol> ; </symbol>
    println(newFile, "</letStatement>")
end


function ParseIfStatement4(tokens, newFile)
    println(newFile, "<ifStatement>")
    println(newFile, GetNextToken4(tokens)) #<keyword> if </keyword>
    println(newFile, GetNextToken4(tokens)) #<symbol> ( </symbol>
    ParseExpression4(tokens, newFile)       #  expression
    println(newFile, GetNextToken4(tokens)) #<symbol> ) </symbol>
    println(newFile, GetNextToken4(tokens)) #<symbol> { </symbol>
    ParseStatements4(tokens, newFile)       # statements
    println(newFile, GetNextToken4(tokens)) #<symbol> } </symbol>
    if occursin( "else",CheckNextToken4(tokens))  
        println(newFile, GetNextToken4(tokens)) #<keyword> else </keyword>
        println(CheckNextToken4(tokens))        #<keyword> let </keyword>
        println(newFile, GetNextToken4(tokens)) #<symbol> { </symbol>
        ParseStatements4(tokens, newFile)       #statements
        println(newFile, GetNextToken4(tokens)) #<symbol> } </symbol>
    end
    println(newFile, "</ifStatement>")
end


function ParseWhileStatement4(tokens, newFile)
    println(newFile, "<whileStatement>")
    println(newFile, GetNextToken4(tokens)) #<keyword> while </keyword>
    println(newFile, GetNextToken4(tokens)) #<symbol> ( </symbol>
    ParseExpression4(tokens, newFile)       # expression
    println(newFile, GetNextToken4(tokens)) #<symbol> ) </symbol>
    println(newFile, GetNextToken4(tokens)) #<symbol> { </symbol>
    ParseStatements4(tokens, newFile)       # statements
    println(newFile, GetNextToken4(tokens)) #<symbol> } </symbol>
    println(newFile, "</whileStatement>")
end


function ParseDoStatement4(tokens, newFile)
    println(newFile, "<doStatement>")
    println(newFile, GetNextToken4(tokens)) #<keyword> do </keyword>
    println(newFile, GetNextToken4(tokens)) #<identifier> className/subRoutineName </identifier>
    subroutineCall4(tokens, newFile)        # subroutineCall4
    println(newFile, GetNextToken4(tokens)) #<symbol> ; </symbol>
    println(newFile, "</doStatement>")
end


function ParseReturnStatement4(tokens, newFile)
    println(newFile, "<returnStatement>")
    println(newFile, GetNextToken4(tokens)) #<keyword> return </keyword>
    if !occursin( ";",CheckNextToken4(tokens))
        ParseExpression4(tokens, newFile)   # expression
    end
    println(newFile, GetNextToken4(tokens)) #<symbol> ; </symbol>
    println(newFile, "</returnStatement>")
end


function ParseExpression4(tokens, newFile)
    println(newFile, "<expression>")
    ParseTerm4(tokens, newFile)   # term
    while occursin( " + ",CheckNextToken4(tokens)) || occursin( " - ",CheckNextToken4(tokens)) || occursin( " * ",CheckNextToken4(tokens)) || occursin( " / ",CheckNextToken4(tokens)) || occursin( "&amp;",CheckNextToken4(tokens)) ||
        occursin( " | ",CheckNextToken4(tokens))|| occursin( "&lt;",CheckNextToken4(tokens)) || occursin( "&gt;",CheckNextToken4(tokens)) || occursin( " = ",CheckNextToken4(tokens))
        println(newFile, GetNextToken4(tokens)) #<symbol> op </symbol>
        ParseTerm4(tokens, newFile)
    end
    println(newFile, "</expression>")
end


function ParseTerm4(tokens, newFile)
    println(newFile, "<term>")
    if  occursin( "stringConstant4",CheckNextToken4(tokens)) || occursin( "integerConstant4",CheckNextToken4(tokens))
        println(newFile, GetNextToken4(tokens)) #/<integerConstant4> integerConstant4 </integerConstant4> /<stringConstant4> stringConstant4 </stringConstant4>
    elseif occursin( "true",CheckNextToken4(tokens)) || occursin( "false",CheckNextToken4(tokens)) || occursin( "null",CheckNextToken4(tokens))|| occursin( "this",CheckNextToken4(tokens))
        println(newFile, GetNextToken4(tokens)) #<keyword> keywordConstant </keyword>
    elseif occursin( "identifier",CheckNextToken4(tokens))
        println(newFile, GetNextToken4(tokens)) #<identifier> varName / className / subRoutineName </identifier>
        if occursin( "[",CheckNextToken4(tokens))
            println(newFile, GetNextToken4(tokens)) #<symbol> [ </symbol>
            ParseExpression4(tokens,newFile)    # expression
            println(newFile, GetNextToken4(tokens)) #<symbol> ] </symbol>
        elseif occursin( "(",CheckNextToken4(tokens)) || occursin( ".",CheckNextToken4(tokens))
            subroutineCall4(tokens, newFile)      #subroutineCall4
        end
    elseif  occursin( "(",CheckNextToken4(tokens))
        println(newFile, GetNextToken4(tokens)) #<symbol> ( </symbol>
        ParseExpression4(tokens,newFile)        # expression
        println(newFile, GetNextToken4(tokens)) #<symbol> ) </symbol>
    elseif  occursin( "-",CheckNextToken4(tokens)) ||  occursin( "~",CheckNextToken4(tokens))   # unaryOp term
        println(newFile, GetNextToken4(tokens)) #<symbol> -/~ </symbol>
        ParseTerm4(tokens, newFile)             # term
    end
    println(newFile, "</term>")
end


function subroutineCall4(tokens, newFile)
    if occursin( "(",CheckNextToken4(tokens))
        println(newFile, GetNextToken4(tokens)) #<symbol> ( </symbol>
        ParseExpression4List(tokens,newFile)    # expressionList
        println(newFile, GetNextToken4(tokens)) #<symbol> ) </symbol>
    else
        println(newFile, GetNextToken4(tokens)) #<symbol> . </symbol>
        println(newFile, GetNextToken4(tokens)) #<identifier> subRoutineName </identifier>
        println(newFile, GetNextToken4(tokens)) #<symbol> ( </symbol>
        ParseExpression4List(tokens,newFile)    # expressionList
        println(newFile, GetNextToken4(tokens)) #<symbol> ) </symbol>
    end
end


function ParseExpression4List(tokens,newFile)
    println(newFile, "<expressionList>")
    while !occursin( ")",CheckNextToken4(tokens))
        ParseExpression4(tokens,newFile)     # expression
        while occursin( ",",CheckNextToken4(tokens))
            println(newFile,  GetNextToken4(tokens)) #<symbol>, </symbol>
            ParseExpression4(tokens,newFile)
        end
    end
    println(newFile, "</expressionList>")
end

# ----------------Parsing functions

function GetNextToken(tokens)  # Checks if we have not reached the end and if not return tokens[index]
    global index
    if index+1<=length(tokens)
        index=index+1
        return tokens[index]
    end
end


function CheckNextToken(tokens) # Checks if we have not reached the end and if not advances to the next token
    global index
    if index+1<=length(tokens)
        return tokens[index+1]
    end
end


function ParseClass(tokens, newFile)
    global classMatrix
    global functionMatrix
    global index
    global className
    global functionName
    global StaticCounter
    global FieldsCounter
    global ArgumentsCounter
    global VarsCounter
    global ParametersCounter
    global ifTrueCounter
    global ifFalseCounter
    global whileExpCounter
    global whileEndCounter
    token=GetNextToken(tokens) #<keyword> class </keyword   ,   'class' className '{' classVarDec* subroutineDec* '}'
    token=GetNextToken(tokens) #<idendifier> className </idendifier>
    global className=split(token, " ")[2]
    token=GetNextToken(tokens) #<symbol> { </symbol>
    ParseClassVarDec(tokens, newFile)
    ParseClassSubroutineDec(tokens, newFile)
    FieldsCounter =0 ###################### needed to be here 
    token=GetNextToken(tokens) #<symbol> } </symbol>
    StaticCounter=0
    whileCounter=0
end


function ParseClassVarDec(tokens, newFile)
    global classMatrix
    global functionMatrix
    global index
    global className
    global functionName
    global StaticCounter
    global FieldsCounter
    global ArgumentsCounter
    global VarsCounter
    global ParametersCounter
    global ifTrueCounter
    global ifFalseCounter
    global whileExpCounter
    global whileEndCounter
    while occursin("classVarDec", CheckNextToken(tokens))
        token=GetNextToken(tokens) #"<classVarDec>"
        kind=GetNextToken(tokens) #<keyword> static/field </keyword>
        type=GetNextToken(tokens) #<keyword> type </keyword>
        varName=GetNextToken(tokens) #<idendifier> varName </idendifier>
        if occursin("static", kind)
            row=[split(varName, " ")[2] split(type, " ")[2] split(kind, " ")[2] StaticCounter]
            StaticCounter=StaticCounter+1
        else
            row=[split(varName, " ")[2] split(type, " ")[2] split(kind, " ")[2] FieldsCounter]
            FieldsCounter=FieldsCounter+1
        end
        classMatrix=[classMatrix; row] # This row was added to the end of the matrix rows
        while occursin( ",",CheckNextToken(tokens))  # check if there is more variables that define in that line too
            token=GetNextToken(tokens) #<symbol> , </symbol>
            varName=GetNextToken(tokens) #<idendifier> varName </idendifier>
            if occursin("static", kind)
                row=[split(varName, " ")[2] split(type, " ")[2] split(kind, " ")[2] StaticCounter]
                StaticCounter=StaticCounter+1
            else
                row=[split(varName, " ")[2] split(type, " ")[2] split(kind, " ")[2] FieldsCounter]
                FieldsCounter=FieldsCounter+1
            end
            classMatrix=[classMatrix; row] # This row was added to the end of the matrix rows
        end
        token=GetNextToken(tokens) #<symbol> ; </symbol>
        token=GetNextToken(tokens) #"</classVarDec>"
    end
end


function ParseClassSubroutineDec(tokens, newFile)
    global classMatrix
    global functionMatrix
    global index
    global className
    global functionName
    global StaticCounter
    global FieldsCounter
    global ArgumentsCounter
    global VarsCounter
    global ParametersCounter
    global ifTrueCounter
    global ifFalseCounter
    global whileExpCounter
    global whileEndCounter
    while occursin("subroutineDec", CheckNextToken(tokens))
        functionMatrix=zeros(0,4)     # initialize the matrix to zeros (in the 4 coulms) 
        token=GetNextToken(tokens) #"<subroutineDec>"
        functionType=GetNextToken(tokens) #<keyword> method/constructor/function </keyword>
        if occursin("method", functionType)
            row=["this" className "argument" ArgumentsCounter]
            ArgumentsCounter=ArgumentsCounter+1
            functionMatrix=[functionMatrix; row]  # This row was added to the end of the matrix rows
        end
        token=GetNextToken(tokens) #<keyword> void </keyword>  /  <idendifier> type </idendifier>
        functionName=split(GetNextToken(tokens), " ")[2] #<idendifier> subroutineName </idendifier>
        token=GetNextToken(tokens) #<symbol> ( </symbol>
        ParseParameterList(tokens, newFile)
        token=GetNextToken(tokens) #<symbol> ) </symbol>
        ParseSubroutineBody(tokens, newFile, split(functionType, " ")[2])
        token=GetNextToken(tokens) #"</subroutineDec>"
        functionMatrix=zeros(0,4)   # initialize the matrix to zeros (in the 4 coulms) 
        ArgumentsCounter=0
        VarsCounter=0
    end
end


function ParseParameterList(tokens, newFile)
    global classMatrix
    global functionMatrix
    global index
    global className
    global functionName
    global StaticCounter
    global FieldsCounter
    global ArgumentsCounter
    global VarsCounter
    global ParametersCounter
    global ifTrueCounter
    global ifFalseCounter
    global whileExpCounter
    global whileEndCounter
    token=GetNextToken(tokens) #<parameterList>
    while !occursin( "parameterList",CheckNextToken(tokens))
        type=GetNextToken(tokens) #<keyword> type </keyword>
        varName=GetNextToken(tokens) #<idendifier> varName </idendifier>
        row=[split(varName, " ")[2] split(type, " ")[2] "argument" ArgumentsCounter]
        ArgumentsCounter=ArgumentsCounter+1
        functionMatrix=[functionMatrix; row] # This row was added to the end of the matrix rows
        while occursin(",",CheckNextToken(tokens))
            token=GetNextToken(tokens) #<symbol> , </symbol>
            type=GetNextToken(tokens) #<keyword> type </keyword>
            varName=GetNextToken(tokens) #<idendifier> varName </idendifier>
            row=[split(varName, " ")[2] split(type, " ")[2] "argument" ArgumentsCounter]
            ArgumentsCounter=ArgumentsCounter+1
            functionMatrix=[functionMatrix; row]   # This row was added to the end of the matrix rows
        end
    end
    token=GetNextToken(tokens) #</parameterList>
end


function ParseSubroutineBody(tokens, newFile, functionType)
    global classMatrix
    global functionMatrix
    global index
    global className
    global functionName
    global StaticCounter
    global FieldsCounter
    global ArgumentsCounter
    global VarsCounter
    global ParametersCounter
    global ifTrueCounter
    global ifFalseCounter
    global whileExpCounter
    global whileEndCounter
    token=GetNextToken(tokens) #<subroutineBody>
    token=GetNextToken(tokens) #<symbol> { </symbol>
    ParseVarDec(tokens, newFile)
    println(newFile, "function "*className*"."*functionName*" "*string(VarsCounter)) #function decleration print in the vm file
    if functionType=="method"               #check function type
        println(newFile, "push argument 0")   # this is pointer to the object on that the methode activate, so we can get to the fields
        println(newFile, "pop pointer 0")
    elseif functionType=="constructor"  # The object created in memory needs to be constructed in order to do so the Memory.alloc function must be summned
        println(newFile, "push constant "*string(FieldsCounter))  # This function receives one parameter - the number of fields of the object, and allocates space accordingly.
        println(newFile, "call Memory.alloc 1")  # The function returns a reference to the object - and this reference must be saved as this
        println(newFile, "pop pointer 0")  # = 'this'
    end
    ParseStatements(tokens, newFile)
    token=GetNextToken(tokens) #<symbol> } </symbol>
    token=GetNextToken(tokens) #<symbol> </subroutineBody> </symbol>
end


function ParseVarDec(tokens, newFile)
    global classMatrix
    global functionMatrix
    global index
    global className
    global functionName
    global StaticCounter
    global FieldsCounter
    global ArgumentsCounter
    global VarsCounter
    global ParametersCounter
    global ifTrueCounter
    global ifFalseCounter
    global whileExpCounter
    global whileEndCounter
    while occursin("<varDec>",CheckNextToken(tokens))
        token=GetNextToken(tokens) #<varDec>
        kind=GetNextToken(tokens) #<keyword> var </keyword>
        type=GetNextToken(tokens) #<keyword> type </keyword>
        varName=GetNextToken(tokens) #<idendifier> varName </idendifier>
        row=[split(varName, " ")[2] split(type, " ")[2] "var" VarsCounter]
        VarsCounter=VarsCounter+1
        functionMatrix=[functionMatrix; row]  # This row was added to the end of the matrix rows
        while occursin( ",",CheckNextToken(tokens))
            token=GetNextToken(tokens) #<symbol> , </symbol>
            varName=GetNextToken(tokens) #<idendifier> varName </idendifier>
            row=[split(varName, " ")[2] split(type, " ")[2] "var" VarsCounter]
            functionMatrix=[functionMatrix; row]  # This row was added to the end of the matrix rows
            VarsCounter=VarsCounter+1
        end
        token=GetNextToken(tokens) #<symbol> ; </symbol>
        token=GetNextToken(tokens) #</varDec>
    end
end


function ParseStatements(tokens, newFile)
    global classMatrix
    global functionMatrix
    global index
    global className
    global functionName
    global StaticCounter
    global FieldsCounter
    global ArgumentsCounter
    global VarsCounter
    global ParametersCounter
    global ifCounter
    global ifTrueCounter
    global ifFalseCounter
    global whileExpCounter
    global whileEndCounter
    token=GetNextToken(tokens) #<statements>
    while occursin( "let",CheckNextToken(tokens)) || occursin( "if",CheckNextToken(tokens)) || occursin( "while",CheckNextToken(tokens)) || occursin( "do",CheckNextToken(tokens)) || occursin( "return",CheckNextToken(tokens))
        if occursin("let",CheckNextToken(tokens))
            ParseLetStatement(tokens, newFile)
        elseif occursin("if",CheckNextToken(tokens))
            ParseIfStatement(tokens, newFile)
        elseif occursin("while",CheckNextToken(tokens))
            ParseWhileStatement(tokens, newFile)
        elseif occursin( "do",CheckNextToken(tokens))
            ParseDoStatement(tokens, newFile)
        elseif occursin( "return",CheckNextToken(tokens))
            ParseReturnStatement(tokens, newFile)
        end
    end
    token=GetNextToken(tokens) #</statements>
end


function ParseLetStatement(tokens, newFile)
    global classMatrix
    global functionMatrix
    global index
    global className
    global functionName
    global StaticCounter
    global FieldsCounter
    global ArgumentsCounter
    global VarsCounter
    global ParametersCounter
    global ifTrueCounter
    global ifFalseCounter
    global whileExpCounter
    global whileEndCounter
    mysymbol=[]
    token=GetNextToken(tokens) #<letStatement>
    token=GetNextToken(tokens) #<keyword> let </keyword>
    varName=split(GetNextToken(tokens), " ")[2] #<idendifier> varName </idendifier>
    for j =1:size(functionMatrix,1)
        row=[functionMatrix[j,1] functionMatrix[j,2] functionMatrix[j,3] functionMatrix[j,4]]
        if row[1]==varName
            mysymbol=row
        end
    end
    if mysymbol==[]     
        for j =1:size(classMatrix,1)
            row=[classMatrix[j,1] classMatrix[j,2] classMatrix[j,3] classMatrix[j,4]]
            if row[1]==varName
                mysymbol=row
            end
        end
    end
    if occursin( "[",CheckNextToken(tokens))   # [expression]
        token=GetNextToken(tokens) #<symbol> [ </symbol>
        ParseExpression(tokens, newFile)
        if mysymbol[3]=="field" || mysymbol[3]=="static"#find the location in the array
            println(newFile, "push this "*string(mysymbol[4]))
        elseif mysymbol[3]=="var"
            println(newFile, "push local "*string(mysymbol[4]))
        elseif mysymbol[3]=="argument"
            println(newFile, "push argument "*string(mysymbol[4]))
        end
        println(newFile,"add")
        token=GetNextToken(tokens) #<symbol> ] </symbol>
        token= GetNextToken(tokens) #<symbol> = </symbol>
        ParseExpression(tokens, newFile)
        println(newFile,"pop temp 0") #the value to assign
        println(newFile,"pop pointer 1") #the location in the array
        println(newFile,"push temp 0") #the value to assign
        println(newFile,"pop that 0") #the value inserted to the array
    else
        token= GetNextToken(tokens) #<symbol> = </symbol>
        ParseExpression(tokens, newFile)
        if mysymbol[3]=="field"
            println(newFile, "pop this "*string(mysymbol[4]))
        elseif mysymbol[3]=="static"
            println(newFile, "pop static "*string(mysymbol[4]))
        elseif mysymbol[3]=="var"
            println(newFile, "pop local "*string(mysymbol[4]))
        elseif mysymbol[3]=="argument"
            println(newFile, "pop argument "*string(mysymbol[4]))
        end
    end
    token=GetNextToken(tokens) #<symbol> ; </symbol>
    token=GetNextToken(tokens) #</letStatement>
end


function ParseIfStatement(tokens, newFile)
    global classMatrix
    global functionMatrix
    global index
    global className
    global functionName
    global StaticCounter
    global FieldsCounter
    global ArgumentsCounter
    global VarsCounter
    global ParametersCounter
    global ifTrueCounter
    global ifFalseCounter
    global whileExpCounter
    global whileCounter
    global ifCounter
    token=GetNextToken(tokens) #<ifStatement>
    token=GetNextToken(tokens) #<keyword> if </keyword>
    token=GetNextToken(tokens) #<symbol> ( </symbol>
    ParseExpression(tokens, newFile)   #'(' expression ')'
    token=GetNextToken(tokens) #<symbol> ) </symbol>
    tempCounter=ifCounter                # tempCounter = currentLabelCounter 
    println(newFile, "if-goto "*"IF_TRUE"*string(tempCounter))
    println(newFile, "goto "*"IF_FALSE"*string(tempCounter))
    token=GetNextToken(tokens) #<symbol> { </symbol>
    println(newFile,"label "*"IF_TRUE"*string(tempCounter))
    ifCounter=ifCounter+1
    ParseStatements(tokens, newFile)
    token=GetNextToken(tokens) #<symbol> } </symbol>
    if occursin( "else",CheckNextToken(tokens))
        println(newFile,"goto IF_END"*string(tempCounter))
        println(newFile,"label "*"IF_FALSE"*string(tempCounter))
        token=GetNextToken(tokens) #<keyword> else </keyword>
        token=GetNextToken(tokens) #<symbol> { </symbol>
        ParseStatements(tokens, newFile)  # 'else' '{' statements '}'
        token=GetNextToken(tokens) #<symbol> } </symbol>
        println(newFile,"label IF_END"*string(tempCounter))
    else
        println(newFile,"label "*"IF_FALSE"*string(tempCounter))
    end
    token=GetNextToken(tokens) #</ifStatement>
    ifCounter =0 ############### needed to be here
end


function ParseWhileStatement(tokens, newFile)
    global classMatrix
    global functionMatrix
    global index
    global className
    global functionName
    global StaticCounter
    global FieldsCounter
    global ArgumentsCounter
    global VarsCounter
    global ParametersCounter
    global ifTrueCounter
    global ifCounter
    global whileExpCounter
    global whileCounter
    token=GetNextToken(tokens) #<whileStatement>
    token=GetNextToken(tokens) #<keyword> while </keyword>
    tempCounter=whileCounter     # tempCounter = currentLabelCounter 
    println(newFile, "label WHILE_EXP"*string(tempCounter))
    whileCounter=whileCounter+1
    token=GetNextToken(tokens) #<symbol> ( </symbol>
    ParseExpression(tokens, newFile)  # '(' expression ')'
    println(newFile, "not")
    token=GetNextToken(tokens) #<symbol> ) </symbol>
    println(newFile, "if-goto WHILE_END"*string(tempCounter))
    token=GetNextToken(tokens) #<symbol> { </symbol>
    ParseStatements(tokens, newFile)   # '{' statements '}'
    token=GetNextToken(tokens) #<symbol> } </symbol>
    println(newFile, "goto WHILE_EXP"*string(tempCounter))
    println(newFile, "label WHILE_END"*string(tempCounter))
    token=GetNextToken(tokens) #</whileStatement>
end


function ParseDoStatement(tokens, newFile)
    global classMatrix
    global functionMatrix
    global index
    global className
    global functionName
    global StaticCounter
    global FieldsCounter
    global ArgumentsCounter
    global VarsCounter
    global ParametersCounter
    global ifTrueCounter
    global ifFalseCounter
    global whileExpCounter
    global whileEndCounter
    token= GetNextToken(tokens)#<doStatement>
    token= GetNextToken(tokens)#<keyword> do </keyword>
    subroutineCall(tokens, newFile) # 'do' subroutineCall ';' 
    ParametersCounter=0
    println(newFile, "pop temp 0")  # We would like to ignore the return value , therefore have to perform that
    token=GetNextToken(tokens) #<symbol> ; </symbol>
    token=GetNextToken(tokens)#"</doStatement>"
end


function ParseReturnStatement(tokens, newFile)
    global classMatrix
    global functionMatrix
    global index
    global className
    global functionName
    global StaticCounter
    global FieldsCounter
    global ArgumentsCounter
    global VarsCounter
    global ParametersCounter
    global ifTrueCounter
    global ifFalseCounter
    global whileExpCounter
    global whileEndCounter
    token= GetNextToken(tokens) #<returnStatement>
    token= GetNextToken(tokens) #<keyword> return </keyword>
    if !occursin( ";",CheckNextToken(tokens)) # check if the function return a value 
        ParseExpression(tokens, newFile) # expression ';' ,     yes -> go to ParseExpression ,to calculate the appropriate arithmetic expression
    else
        println(newFile, "push constant 0") #The function does not return a value, so a constant value must be pushed into the stack (push constant 0)
    end
    token=GetNextToken(tokens) #<symbol> ; </symbol>
    token=GetNextToken(tokens)#"</returnStatement>"
    println(newFile, "return")
end


function ParseExpression(tokens, newFile)
    global classMatrix
    global functionMatrix
    global index
    global className
    global functionName
    global StaticCounter
    global FieldsCounter
    global ArgumentsCounter
    global VarsCounter
    global ParametersCounter
    global ifTrueCounter
    global ifFalseCounter
    global whileExpCounter
    global whileEndCounter
    token=GetNextToken(tokens) #<expression>
    ParseTerm(tokens, newFile)
    while occursin( " + ",CheckNextToken(tokens)) || occursin( " - ",CheckNextToken(tokens)) || occursin( " * ",CheckNextToken(tokens)) || occursin( " / ",CheckNextToken(tokens)) || occursin( "&amp;",CheckNextToken(tokens)) ||
        occursin( " | ",CheckNextToken(tokens))|| occursin( "&lt;",CheckNextToken(tokens)) || occursin( "&gt;",CheckNextToken(tokens)) || occursin( " = ",CheckNextToken(tokens))
        token=GetNextToken(tokens) #<symbol> op </symbol>
        ParseTerm(tokens, newFile)
        if occursin( " + ",token)
            println(newFile,"add")
        elseif occursin( " - ",token)
            println(newFile,"sub")
        elseif occursin( " * ",token)
            println(newFile,"call Math.multiply 2")
        elseif occursin( " | ",token)
            println(newFile,"or")
        elseif occursin( " &lt; ",token)
            println(newFile,"lt")
        elseif occursin( " &gt; ",token)
            println(newFile,"gt")
        elseif occursin( " / ",token)
            println(newFile,"call Math.divide 2")
        elseif occursin( " &amp; ",token)
            println(newFile,"and")
        elseif occursin( " = ",token)
            println(newFile,"eq")
        end
    end
    token=GetNextToken(tokens)  #</expression>
end


function ParseTerm(tokens, newFile)
    global classMatrix
    global functionMatrix
    global index
    global className
    global functionName
    global StaticCounter
    global FieldsCounter
    global ArgumentsCounter
    global VarsCounter
    global ParametersCounter
    global ifTrueCounter
    global ifFalseCounter
    global whileExpCounter
    global whileEndCounter
    mysymbol=[]
    token=GetNextToken(tokens) #<term>
    if  occursin( "stringConstant",CheckNextToken(tokens))
        stringConstant=split(GetNextToken(tokens), " ") #<stringConstant> stringConstant </stringConstant>
        fullString=stringConstant[2]
        for i in 3:length(stringConstant)-1
            fullString=fullString*" "*stringConstant[i]
        end
        println(newFile, "push constant "*string(length(fullString)))
        println(newFile,"call String.new 1")
        for letter in fullString
            println(newFile, "push constant "*string(Int64(letter)))
            println(newFile, "call String.appendChar 2")
        end
    elseif occursin( "integerConstant",CheckNextToken(tokens))
        integerConstant=split(GetNextToken(tokens), " ")[2] #/<integerConstant> integerConstant </integerConstant>
        println(newFile, "push constant "*integerConstant)
    elseif occursin( "true",CheckNextToken(tokens))
        token=GetNextToken(tokens) #<keyword> keywordConstant </keyword>
        println(newFile, "push constant 0")
        println(newFile, "not")
    elseif occursin( "false",CheckNextToken(tokens)) || occursin("null",CheckNextToken(tokens))
        token=GetNextToken(tokens) #<keyword> keywordConstant </keyword>
        println(newFile, "push constant 0")
    elseif occursin( "this",CheckNextToken(tokens))
        token=GetNextToken(tokens) #<keyword> keywordConstant </keyword>
        println(newFile, "push pointer 0")
    elseif occursin( "identifier",CheckNextToken(tokens))
        varName=split(GetNextToken(tokens), " ")[2] #<idendifier> varName/className/subRoutineName </idendifier>
        for j =1:size(functionMatrix,1)
            row=[functionMatrix[j,1] functionMatrix[j,2] functionMatrix[j,3] functionMatrix[j,4]]
            if row[1]==varName
                mysymbol=row
            end
        end
        if mysymbol==[]
            for j =1:size(classMatrix,1)
                row=[classMatrix[j,1] classMatrix[j,2] classMatrix[j,3] classMatrix[j,4]]
                if row[1]==varName
                    mysymbol=row
                end
            end
        end
        if occursin( "[",CheckNextToken(tokens))
            token=GetNextToken(tokens) #<symbol> [ </symbol>
            ParseExpression(tokens, newFile)
            token=GetNextToken(tokens) #<symbol> ] </symbol>
            if mysymbol!=[]
                if mysymbol[3]=="field" || mysymbol[3]=="static"  #find the location in the array
                    println(newFile, "push this "*string(mysymbol[4]))
                elseif mysymbol[3]=="var"
                    println(newFile, "push local "*string(mysymbol[4]))
                elseif mysymbol[3]=="argument"
                    println(newFile, "push argument "*string(mysymbol[4]))
                end
            end
            println(newFile,"add")
            println(newFile,"pop pointer 1") #the location in the array
            println(newFile,"push that 0") #the value inserted to the array
        elseif occursin( "(",CheckNextToken(tokens)) || occursin( ".",CheckNextToken(tokens))# identifier is subRoutineName
            index=index-1
            subroutineCall(tokens, newFile)
            ParametersCounter=0
        else
            if mysymbol!=[]
                if mysymbol[3]=="field"
                    println(newFile, "push this "*string(mysymbol[4]))
                elseif mysymbol[3]=="static"
                    println(newFile, "push static "*string(mysymbol[4]))
                elseif mysymbol[3]=="var"
                    println(newFile, "push local "*string(mysymbol[4]))
                elseif mysymbol[3]=="argument"
                    println(newFile, "push argument "*string(mysymbol[4]))
                end
            end
        end
    elseif occursin( "(",CheckNextToken(tokens))  # '(' expression ')'
        token=GetNextToken(tokens) #<symbol> ( </symbol>
        ParseExpression(tokens,newFile)
        GetNextToken(tokens) #<symbol> ) </symbol>
    elseif  occursin( "-",CheckNextToken(tokens))  # unaryOp term
        token=GetNextToken(tokens) #<symbol> - </symbol>
        ParseTerm(tokens, newFile)
        println(newFile, "neg")
    elseif  occursin( "~",CheckNextToken(tokens))
        token=GetNextToken(tokens) #<symbol> ~ </symbol>
        ParseTerm(tokens, newFile)
        println(newFile, "not")

    end
    token=GetNextToken(tokens)  #</term>
end


function subroutineCall(tokens, newFile)
    global classMatrix
    global functionMatrix
    global index
    global className
    global functionName
    global StaticCounter
    global FieldsCounter
    global ArgumentsCounter
    global VarsCounter
    global ParametersCounter
    global ifTrueCounter
    global ifFalseCounter
    global whileExpCounter
    global whileEndCounter
    mysymbol=[]
    identifier=split(GetNextToken(tokens), " ")[2] #<idendifier> className/subRoutineName </idendifier>
    if occursin( "(",CheckNextToken(tokens))  # '(' expressionList ')'
        token=GetNextToken(tokens) #<symbol> ( </symbol>
        ParametersCounter=ParametersCounter+1
        println(newFile, "push pointer 0")
        ParseExpressionList(tokens,newFile)
        println(newFile, "call "*className*"."*identifier*" "*string(ParametersCounter))
        token=GetNextToken(tokens) #<symbol> ) </symbol>
    else
        token=GetNextToken(tokens) #<symbol> . </symbol>
        subRoutineName=split(GetNextToken(tokens), " ")[2] #<idendifier> subRoutineName </idendifier>
        for j =1:size(functionMatrix,1)
            row=[functionMatrix[j,1] functionMatrix[j,2] functionMatrix[j,3] functionMatrix[j,4]]
            if row[1]==identifier
                mysymbol=row
            end
        end
        if mysymbol==[]
            for j =1:size(classMatrix,1)
                row=[classMatrix[j,1] classMatrix[j,2] classMatrix[j,3] classMatrix[j,4]]
                if row[1]==identifier
                    mysymbol=row
                end
            end
        end
        if mysymbol!=[]  #the identifier is varName
            if mysymbol[3]=="field" || mysymbol[3]=="static"
                println(newFile, "push this "*string(mysymbol[4]))
            elseif mysymbol[3]=="argument"
                println(newFile, "push argument "*string(mysymbol[4]))
            elseif mysymbol[3]=="var"
                println(newFile, "push local "*string(mysymbol[4]))
            end
            token=GetNextToken(tokens) #<symbol> ( </symbol>
            ParseExpressionList(tokens,newFile)    # '(' expressionList ')'
            ParametersCounter=ParametersCounter+1
            println(newFile, "call "*mysymbol[2]*"."*subRoutineName*" "*string(ParametersCounter))
        else  #identifier is other class
            token=GetNextToken(tokens) #<symbol ( </symbol>
            ParseExpressionList(tokens,newFile)  # (expression(','expression)*)
            println(newFile, "call "*identifier*"."*subRoutineName*" "*string(ParametersCounter))
        end
        token=GetNextToken(tokens) #<symbol> ) </symbol>
    end
end


function ParseExpressionList(tokens,newFile)
    global classMatrix
    global functionMatrix
    global index
    global className
    global functionName
    global StaticCounter
    global FieldsCounter
    global ArgumentsCounter
    global VarsCounter
    global ParametersCounter
    global ifTrueCounter
    global ifFalseCounter
    global whileExpCounter
    global whileEndCounter
    token=GetNextToken(tokens) #<expressionList>
    while !occursin( "expressionList",CheckNextToken(tokens))
        ParametersCounter=ParametersCounter+1
        ParseExpression(tokens,newFile)
        while occursin( ",",CheckNextToken(tokens))
            token=GetNextToken(tokens) #<symbol>, </symbol>
            ParametersCounter=ParametersCounter+1
            ParseExpression(tokens,newFile)
        end
    end
    token=GetNextToken(tokens) #</expressionList>
end



#########                       main                     ########
global keyword=["class","constructor","function","method","field","static","let","do","if","else","while","return","var","int","char","boolean","void","true","false","null","this"]
global symbol=['{','}','(',')','[',']','.',',',';','+','-','*','/','&','|','<','>','=','~']  # all the symbols4 in jack
global index4=1
global classMatrix=zeros(0,4)
global functionMatrix=zeros(0,4)  # initialize the matrix to zeros (in the 4 coulms) 
global index=1
global className=""
global functionName=""
global StaticCounter=0
global FieldsCounter=0
global ArgumentsCounter=0
global VarsCounter=0
global ParametersCounter=0
global ifTrueCounter=0
global ifFalseCounter=0
global ifCounter=0
global whileCounter=0
global whileEndCounter=0
println("Enter directory name: ")
path=readline()
arr=split(path, "\\")
files=readdir(path)
for file in files
    if endswith(file, "jack")
       
        currentfile=open(path*'\\'*file, "r")    # currentfile is ->  main.jack
        file=SubString(file, 1, length(file)-5)   # file = name of the current jack file
        newFile=open(path*"\\"*file*"T.xml", "w")  # newfile is the tokenizer  
        println(newFile, "<tokens>")
        token=""
        while !eof(currentfile)
            token=token*string(read(currentfile, Char)) # connects(chain) all values ​​to a single string
            if token=="/"  && !eof(currentfile)
                token2=read(currentfile, Char)          # token2 is for a single char in currentfile
                if token2=='/' || token2=='*'   # comments4 in jack can look: // or /*
                    comments4(token2, currentfile)
                else
                    symbols4(token[end], currentfile, newFile)  # that mean it was one / therefor it`s a symbol
                    if isdigit(token2)
                        IntegerConstant4(token2, currentfile, newFile)
                    elseif token2==' '
                        token=""                  # enter to token "" for initialization
                    else
                        identifier4(token2, currentfile, newFile)
                    end
                end
            elseif all(isletter, token)         # check if the token is a letter
                letters4(token, currentfile,newFile)

            elseif all(isdigit, token)         # check if the token is a letter
                IntegerConstant4(token, currentfile,newFile)

            elseif token[end] in symbol 
                symbols4(token[end], currentfile,newFile)

            elseif token[end]=='\"' && !eof(currentfile)    # refer to the " , in jack is quote -> stringConstant4
                StringConstant4(token, currentfile,newFile)

            elseif token[end]=='_' && !eof(currentfile)
                token=token*string(read(currentfile, Char))
                identifier4(token, currentfile,newFile)

            elseif (token[end]=="\n"||token[end]=='\t'|| token[end]==' ') && !eof(currentfile)
                token=""                         # enter to token "" for initialization
            end
            token=""
        end
        println(newFile, "</tokens>")
        close(currentfile)  # currentfile is  -> main.jack
        close(newFile)      # newFile is      -> mainT.xml
        currentfile=open(path*"\\"*file*"T.xml", "r") # currentfile is  -> mainT.xml
        newFile=open(path*"\\"*file*".xml", "w")      # newFile is      -> main.xml
        tokens=readlines(currentfile)
        ParseClass4(tokens, newFile)
        close(currentfile)
        close(newFile)
        global index4=1
         
    end
end
files=readdir(path)
for file in files   # to pass on the xml files that created in the prev for
    if endswith(file, ".xml") && !endswith(file, "T.xml")
        currentfile=open(path*'\\'*file, "r")
        file=SubString(file, 1, length(file)-3)
        newFile=open(path*"\\"*file*"vm", "w")
        tokens=readlines(currentfile)
        ParseClass(tokens, newFile)
        close(currentfile)
        close(newFile)
        global index=1
        global classMatrix=zeros(0,4)
        StaticCounter=0
        FieldsCounter=0
    end 
end